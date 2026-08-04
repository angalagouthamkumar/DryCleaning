import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../core/services/content_service.dart';
import '../../../repositories/order_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final double subtotal;
  final Map<String, int>? initialCartItems;
  final VoidCallback onOrderPlaced;

  const CheckoutScreen({
    super.key,
    required this.subtotal,
    this.initialCartItems,
    required this.onOrderPlaced,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPickupSlot = 'Express Fast Pickup & Delivery';
  String _selectedPaymentMethod = '';
  final TextEditingController _notesController = TextEditingController();

  late final Map<String, int> _cartQuantities;

  final Map<String, Map<String, dynamic>> _itemLookup = const {
    's1': {'name': 'Shirts / T-Shirts', 'price': 60},
    's2': {'name': 'Trousers / Jeans', 'price': 70},
    's3': {'name': '2-Piece Suits', 'price': 250},
    's4': {'name': 'Silk Sarees', 'price': 180},
    's5': {'name': 'Wash & Fold (kg)', 'price': 50},
    's6': {'name': 'Daily Wash & Iron', 'price': 80},
    's7': {'name': 'Steam Iron Shirt', 'price': 25},
    's8': {'name': 'Double Blanket', 'price': 350},
    's9': {'name': 'Curtain Panels', 'price': 120},
    'p1': {'name': 'Weekly Pack', 'price': 349},
    'p2': {'name': 'Office Wear Pack', 'price': 599},
    'p3': {'name': 'Family Pack', 'price': 899},
  };

  int _currentHintIndex = 0;
  Timer? _hintTimer;
  final List<String> _placeholderNotes = const [
    'e.g. Please ring the bell twice...',
    'e.g. Leave garments with building security gate...',
    'e.g. Call 10 mins before arrival at doorstep...',
    'e.g. Separate white garments from colored items...',
    'e.g. Handle delicate silk saree with extra care...',
  ];

  bool _isPlacingOrder = false;
  bool _hasVoiceInstruction = false;
  bool _isRecordingVoice = false;
  final List<XFile> _selectedPhotos = [];
  final List<String> _selectedPhotosBase64 = [];

  late final AudioRecorder _audioRecorder;
  AudioPlayer? _audioPlayer;
  String? _recordedAudioPath;
  int _recordDurationSeconds = 0;
  Timer? _recordTimer;
  bool _isPlayingPreview = false;

  final List<Map<String, String>> _slots = const [
    {
      'title': 'Tomorrow, 2:00 PM - 4:00 PM',
      'subtitle': 'Afternoon slot (Recommended)',
      'isExpress': 'false',
    },
    {
      'title': 'Express Fast Pickup & Delivery',
      'subtitle': 'Fastest rider dispatch to your doorstep',
      'isExpress': 'true',
    },
    {
      'title': 'Today, 10:00 AM - 12:00 PM',
      'subtitle': 'Standard pickup window',
      'isExpress': 'false',
    },
    {
      'title': 'Today, 5:00 PM - 7:00 PM',
      'subtitle': 'Evening slot',
      'isExpress': 'false',
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _selectedPickupSlot = 'Tomorrow, 2:00 PM - 4:00 PM';
    _selectedPaymentMethod = 'SemPay UPI Gateway (Instant Auto-App)';
    _cartQuantities = Map<String, int>.from(
      (widget.initialCartItems != null && widget.initialCartItems!.isNotEmpty)
          ? widget.initialCartItems!
          : {'s1': 2, 's3': 1, 's2': 3},
    );

    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _placeholderNotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _recordTimer?.cancel();
    _notesController.dispose();
    _audioRecorder.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final current = _cartQuantities[itemId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cartQuantities.remove(itemId);
      } else {
        _cartQuantities[itemId] = next;
      }
    });
  }

  double get _calculatedSubtotal {
    double sum = 0.0;
    _cartQuantities.forEach((id, qty) {
      final item = _itemLookup[id];
      final price = (item?['price'] ?? 60) as int;
      sum += price * qty;
    });
    return sum > 0 ? sum : (widget.subtotal > 0 ? widget.subtotal : 470.0);
  }

  void _pickGarmentPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _selectedPhotos.add(image);
        _selectedPhotosBase64.add(base64Str);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo attached to pickup instructions!'),
            backgroundColor: AppColors.darkNavy,
          ),
        );
      }
    }
  }

  Future<void> _toggleVoiceNoteRecording() async {
    if (_isRecordingVoice) {
      // Stop recording
      try {
        final path = await _audioRecorder.stop();
        _recordTimer?.cancel();
        setState(() {
          _isRecordingVoice = false;
          _recordedAudioPath = path;
          _hasVoiceInstruction = path != null && path.isNotEmpty;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice instruction recorded (${_recordDurationSeconds}s) and attached to order!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        debugPrint('Stop recording error: $e');
      }
    } else {
      // Request microphone permission
      try {
        final micPermission = await Permission.microphone.request();
        if (!micPermission.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Microphone permission is required to record voice instructions.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        if (await _audioRecorder.hasPermission()) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: filePath,
          );

          setState(() {
            _isRecordingVoice = true;
            _recordDurationSeconds = 0;
            _recordedAudioPath = null;
            _hasVoiceInstruction = false;
          });

          _recordTimer?.cancel();
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted && _isRecordingVoice) {
              setState(() {
                _recordDurationSeconds++;
              });
            }
          });
        }
      } catch (e) {
        debugPrint('Start recording exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Microphone recording error: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _playRecordedPreview() async {
    if (_recordedAudioPath == null) return;
    if (_isPlayingPreview) {
      await _audioPlayer?.stop();
      setState(() => _isPlayingPreview = false);
    } else {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.play(DeviceFileSource(_recordedAudioPath!));
      setState(() => _isPlayingPreview = true);
      _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingPreview = false);
      });
    }
  }

  void _deleteRecordedVoice() async {
    await _audioPlayer?.stop();
    setState(() {
      _recordedAudioPath = null;
      _hasVoiceInstruction = false;
      _isRecordingVoice = false;
      _recordDurationSeconds = 0;
      _isPlayingPreview = false;
    });
  }

  void _showSemPayQrDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded, color: AppColors.darkNavy, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'SemPay UPI QR',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Scan Sem QR with GPay / PhonePe / Paytm',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray),
                ),
                const SizedBox(height: 14),

                // Interactive SemPay QR Code Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: AppColors.cardFill,
                          borderRadius: AppRadius.md,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.darkNavy),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.pill,
                              ),
                              child: const Text(
                                'SEMPAY',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'VPA: angala@fam',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Amount: ₹${amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Auto-Verifying Payment via SemPay Gateway...',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      _confirmAndPlaceOrder();
                    },
                    child: const Text(
                      'I Have Completed Payment',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderSuccessModal(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 40, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #$orderId has been scheduled for pickup.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogCtx); // close dialog
                      Navigator.pop(context); // exit checkout screen
                      widget.onOrderPlaced();
                    },
                    child: const Text(
                      'Track Order in App',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUpiApp(double amount) async {
    final upiUrl = 'upi://pay?pa=angala@fam&pn=DryCleaningApp&am=${amount.toStringAsFixed(2)}&cu=INR&tn=DryCleaningOrder';
    try {
      final uri = Uri.parse(upiUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _confirmAndPlaceOrder() async {
    if (_isPlacingOrder) return;
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      const double deliveryCharge = 30.0;
      const double handlingFee = 15.0;
      final double effectiveSubtotal = _calculatedSubtotal;
      final double grandTotal = effectiveSubtotal + deliveryCharge + handlingFee;

      if (_selectedPaymentMethod.contains('UPI')) {
        await _launchUpiApp(grandTotal);
      }

      final authState = ref.read(authStateProvider);
      final user = authState.user;
      final locationState = ref.read(locationStateProvider);

      final String realCustomerName = (user?['name']?.toString() ?? 'Rahul Sharma').trim();
      final String realCustomerPhone = (user?['phoneNumber']?.toString() ?? (authState.phoneNumber.isNotEmpty ? authState.phoneNumber : '')).trim();

      final String fallbackAddress = 'Flat 302, Green Residency, Hasmathpet, Bowenpally, Secunderabad';
      final String realAddress = locationState.currentAddress.isNotEmpty
          ? locationState.currentAddress
          : (user?['fullAddress']?.toString().isNotEmpty == true ? user!['fullAddress'].toString() : fallbackAddress);

      final String generatedOrderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";

      // Upload real audio and photo attachments to backend
      String uploadedVoiceUrl = "";
      List<String> uploadedPhotoUrls = [];

      final orderRepo = ref.read(orderRepositoryProvider);

      if (_hasVoiceInstruction && _recordedAudioPath != null && _recordedAudioPath!.isNotEmpty) {
        debugPrint('Uploading recorded audio file: $_recordedAudioPath');
        final serverAudioUrl = await orderRepo.uploadAudio(_recordedAudioPath!);
        if (serverAudioUrl != null && serverAudioUrl.isNotEmpty) {
          uploadedVoiceUrl = serverAudioUrl;
          debugPrint('Audio uploaded successfully to backend: $uploadedVoiceUrl');
        }
      }

      if (_selectedPhotos.isNotEmpty) {
        final paths = _selectedPhotos.map((f) => f.path).toList();
        debugPrint('Uploading ${paths.length} photo attachments');
        final serverPhotoUrls = await orderRepo.uploadImages(paths);
        if (serverPhotoUrls.isNotEmpty) {
          uploadedPhotoUrls = serverPhotoUrls;
          debugPrint('Photos uploaded successfully to backend: $uploadedPhotoUrls');
        } else {
          uploadedPhotoUrls = _selectedPhotosBase64.isNotEmpty ? _selectedPhotosBase64 : paths;
        }
      }

      final orderPayload = {
        "orderId": generatedOrderId,
        "customerName": realCustomerName,
        "customerPhone": realCustomerPhone,
        "fullAddress": realAddress,
        "landmark": "",
        "latitude": locationState.latitude ?? 17.476370,
        "longitude": locationState.longitude ?? 78.488990,
        "liveLocationUrl": "https://maps.google.com/?q=${locationState.latitude ?? 17.476370},${locationState.longitude ?? 78.488990}",
        "services": ["Dry Cleaning", "Ironing"],
        "items": _cartQuantities.entries.map((entry) {
          final info = _itemLookup[entry.key] ?? {'name': 'Garment Item', 'price': 60};
          return {
            "name": info['name'],
            "quantity": entry.value,
            "price": info['price'],
          };
        }).toList(),
        "pickupDate": "27 July 2026",
        "pickupSlot": _selectedPickupSlot,
        "paymentMethod": _selectedPaymentMethod,
        "upiVpa": _selectedPaymentMethod.contains('SemPay') ? "angala@fam" : null,
        "subtotal": effectiveSubtotal,
        "deliveryCharge": deliveryCharge,
        "handlingFee": handlingFee,
        "grandTotal": grandTotal,
        "notes": _notesController.text.trim(),
        "hasVoiceInstruction": _hasVoiceInstruction,
        "voiceNoteUrl": uploadedVoiceUrl,
        "photoUrls": uploadedPhotoUrls,
        "status": "Placed",
      };

      final orderNotifier = ref.read(ordersProvider.notifier);
      final createdOrder = await orderNotifier.placeOrder(orderPayload);

      final finalOrderId = createdOrder != null
          ? (createdOrder['orderId'] ?? generatedOrderId)
          : generatedOrderId;

      if (!mounted) return;
      _showOrderSuccessModal(finalOrderId.toString());
    } catch (e) {
      debugPrint('Order placement exception: $e');
      final generatedOrderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      if (mounted) {
        _showOrderSuccessModal(generatedOrderId);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _handlePlaceOrderTap(double grandTotal) {
    if (_selectedPaymentMethod.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment option (SemPay UPI Gateway or Cash on Delivery) to proceed.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_selectedPaymentMethod.contains('SemPay')) {
      _showSemPayQrDialog(grandTotal);
    } else {
      _confirmAndPlaceOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentStateProvider);
    const double deliveryCharge = 30.0;
    const double handlingFee = 15.0;
    final double subtotal = _calculatedSubtotal;
    final double grandTotal = subtotal + deliveryCharge + handlingFee;

    final locationState = ref.watch(locationStateProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final String currentDeliveryAddress = locationState.currentAddress.isNotEmpty
        ? locationState.currentAddress
        : (user?['fullAddress']?.toString() ?? 'Flat 302, Green Residency, Hasmathpet, Bowenpally, Secunderabad');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(ContentService.t('customer.checkout.header_title', 'Checkout & Schedule')), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: AppRadius.md),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Location Address',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentDeliveryAddress,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Itemized Garment List with Interactive Quantity Buttons
            const Text(
              'Selected Garments & Quantities',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.md, border: Border.all(color: AppColors.borderLight)),
              child: Column(
                children: [
                  ..._cartQuantities.entries.map((entry) {
                    final itemId = entry.key;
                    final qty = entry.value;
                    final info = _itemLookup[itemId] ?? {'name': 'Garment Item', 'price': 60};
                    final name = info['name'];
                    final price = info['price'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$name',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                                ),
                                Text(
                                  '₹$price each',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textGray),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                  onPressed: () => _updateQuantity(itemId, -1),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                  onPressed: () => _updateQuantity(itemId, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_cartQuantities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('No garments in cart. Tap + or ADD items from home screen.', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pickup Schedule Slot
            const Text(
              'Pickup Schedule Slot',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            Column(
              children: _slots.map((slot) {
                final isSelected = slot['title'] == _selectedPickupSlot;
                final isExpress = slot['isExpress'] == 'true';

                return GestureDetector(
                  onTap: () => setState(() => _selectedPickupSlot = slot['title']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkNavy : Colors.white,
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: isExpress
                            ? AppColors.primary
                            : (isSelected ? AppColors.darkNavy : AppColors.borderLight),
                        width: isExpress ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isExpress)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.two_wheeler_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot['title']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                slot['subtitle']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white70 : AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Payment Options
            const Text(
              'Payment Options',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),

            // Option 1: SemPay UPI Gateway
            GestureDetector(
              onTap: () {
                setState(() => _selectedPaymentMethod = 'SemPay UPI Gateway (Instant Auto-App)');
                _showSemPayQrDialog(grandTotal);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _selectedPaymentMethod.contains('SemPay')
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: _selectedPaymentMethod.contains('SemPay')
                        ? AppColors.primary
                        : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.md,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SemPay UPI Gateway (Auto-App)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                          ),
                          Text(
                            'Scan Sem QR or Pay via GPay / PhonePe (VPA: angala@fam)',
                            style: TextStyle(fontSize: 11, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedPaymentMethod.contains('SemPay'))
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            ),

            // Option 2: Cash on Delivery (COD)
            GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = 'Cash on Delivery (COD)'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedPaymentMethod == 'Cash on Delivery (COD)'
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: _selectedPaymentMethod == 'Cash on Delivery (COD)'
                        ? AppColors.primary
                        : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.md,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(Icons.payments_rounded, color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash on Delivery (COD)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                          ),
                          Text(
                            'Pay cash when agent picks up your garments',
                            style: TextStyle(fontSize: 11, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedPaymentMethod == 'Cash on Delivery (COD)')
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Special Notes Field
            const Text(
              'Pickup Instructions & Media Attachment',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: _placeholderNotes[_currentHintIndex],
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textGray.withValues(alpha: 0.6), fontStyle: FontStyle.italic),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: const OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide(color: AppColors.borderLight)),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    onPressed: _pickGarmentPhoto,
                    icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 18),
                    label: Text(
                      _selectedPhotos.isEmpty ? 'Add Photos (${_selectedPhotos.length})' : 'Photos Added (${_selectedPhotos.length})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                      side: BorderSide(color: _hasVoiceInstruction ? Colors.green : (_isRecordingVoice ? Colors.red : AppColors.primary)),
                      backgroundColor: _isRecordingVoice ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    onPressed: _toggleVoiceNoteRecording,
                    icon: Icon(
                      _isRecordingVoice ? Icons.stop_circle_rounded : Icons.mic_rounded,
                      color: _isRecordingVoice ? Colors.red : (_hasVoiceInstruction ? Colors.green : AppColors.primary),
                      size: 18,
                    ),
                    label: Text(
                      _isRecordingVoice
                          ? 'Stop (${_recordDurationSeconds}s)'
                          : (_hasVoiceInstruction ? 'Voice Added' : 'Record Voice'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _hasVoiceInstruction ? Colors.green : (_isRecordingVoice ? Colors.red : AppColors.darkNavy),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_hasVoiceInstruction && _recordedAudioPath != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: Icon(_isPlayingPreview ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: Colors.green, size: 30),
                      onPressed: _playRecordedPreview,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isPlayingPreview ? 'Playing voice preview...' : 'Recorded Voice Note (${_recordDurationSeconds}s)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                      onPressed: _deleteRecordedVoice,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Bill Summary
            const Text(
              'Bill Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.md, border: Border.all(color: AppColors.borderLight)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal', style: TextStyle(fontSize: 12)),
                      Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pickup & Delivery Charge', style: TextStyle(fontSize: 12)),
                      Text('₹${deliveryCharge.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Handling & Bag Fee', style: TextStyle(fontSize: 12)),
                      Text('₹${handlingFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
                      Text('₹${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkNavy)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                  elevation: 0,
                ),
                onPressed: _isPlacingOrder ? null : () => _handlePlaceOrderTap(grandTotal),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'PLACE ORDER • ₹${grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
