import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/location_provider.dart';

import '../../../core/services/content_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackToHome;
  const ProfileScreen({super.key, this.onBackToHome});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = 'Rahul Sharma';
  String _email = 'rahul.sharma@gmail.com';
  String _phone = '';
  String _address = 'Flat 302, Green Residency, Hasmathpet, Bowenpally, Secunderabad';

  final ImagePicker _picker = ImagePicker();

  final List<String> _presetAvatars = const [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
  ];

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _saveProfileAvatar(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select image: $e')),
        );
      }
    }
  }

  void _saveProfileAvatar(String pathOrUrl) {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    final name = (user?['name']?.toString().trim().isNotEmpty == true)
        ? user!['name'].toString()
        : _name;
    final email = (user?['email']?.toString().trim().isNotEmpty == true)
        ? user!['email'].toString()
        : _email;
    final phone = authState.phoneNumber.isNotEmpty
        ? authState.phoneNumber
        : (user?['phoneNumber']?.toString() ?? _phone);
    final address = ref.read(locationStateProvider).currentAddress;

    ref.read(authStateProvider.notifier).updateUserProfile(
      name: name,
      email: email,
      phoneNumber: phone,
      address: address,
      profilePic: pathOrUrl,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully!'),
          backgroundColor: AppColors.darkNavy,
        ),
      );
    }
  }

  void _removeProfileImage() {
    _saveProfileAvatar('');
  }

  void _showPresetAvatarDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          title: const Text(
            'Select Avatar Icon',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy),
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetAvatars.map((url) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _saveProfileAvatar(url);
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(url),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarOptionsSheet(String? currentPic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.face_rounded, color: AppColors.primary),
                title: const Text('Choose Preset Avatar', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPresetAvatarDialog();
                },
              ),
              if (currentPic != null && currentPic.trim().isNotEmpty) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeProfileImage();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget(String? picUrl, String displayName) {
    if (picUrl != null && picUrl.trim().isNotEmpty) {
      final cleanUrl = picUrl.trim();
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://') || cleanUrl.startsWith('blob:')) {
        return CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(cleanUrl),
        );
      }
      if (!kIsWeb) {
        try {
          final file = File(cleanUrl);
          if (file.existsSync()) {
            return CircleAvatar(
              radius: 36,
              backgroundImage: FileImage(file),
            );
          }
        } catch (_) {}
      }
    }
    return CircleAvatar(
      radius: 36,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'R',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.darkNavy,
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName, String currentEmail, String currentPhone, String currentAddress) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final addressCtrl = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          title: const Text(
            'Edit Profile & Real Data',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Pickup Address', prefixIcon: Icon(Icons.location_on)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newEmail = emailCtrl.text.trim();
                final newPhone = phoneCtrl.text.trim();
                final newAddress = addressCtrl.text.trim();

                ref.read(authStateProvider.notifier).updateUserProfile(
                  name: newName,
                  email: newEmail,
                  phoneNumber: newPhone,
                  address: newAddress,
                );

                if (newAddress.isNotEmpty) {
                  ref.read(locationStateProvider.notifier).updateAddress(newAddress);
                }

                setState(() {
                  _name = newName;
                  _email = newEmail;
                  _phone = newPhone;
                  _address = newAddress;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile information updated successfully!'),
                    backgroundColor: AppColors.darkNavy,
                  ),
                );
              },
              child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final locationState = ref.watch(locationStateProvider);
    final String currentPic = user?['profilePic']?.toString() ?? '';

    final String displayName = (user?['name']?.toString().trim().isNotEmpty == true)
        ? user!['name'].toString()
        : _name;
    final String displayPhone = authState.phoneNumber.isNotEmpty
        ? authState.phoneNumber
        : (user?['phoneNumber']?.toString() ?? _phone);
    final String displayEmail = (user?['email']?.toString().trim().isNotEmpty == true)
        ? user!['email'].toString()
        : _email;
    final String displayAddress = locationState.currentAddress.isNotEmpty
        ? locationState.currentAddress
        : (user?['fullAddress']?.toString() ?? _address);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          ContentService.t('customer.profile.title', 'My Profile & Account'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.darkNavy),
            tooltip: 'Edit Profile Data',
            onPressed: () => _showEditProfileDialog(displayName, displayEmail, displayPhone, displayAddress),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.lg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarOptionsSheet(currentPic),
                        child: _buildAvatarWidget(currentPic, displayName),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarOptionsSheet(currentPic),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditProfileDialog(displayName, displayEmail, displayPhone, displayAddress),
                              child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayEmail,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGray.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Saved Address Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Saved Pickup Address',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayAddress,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account Options Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.lg,
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: AppColors.darkNavy),
                    title: const Text('Edit Account Details', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Update Name, Phone & Email'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showEditProfileDialog(displayName, displayEmail, displayPhone, displayAddress),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.payment_rounded, color: AppColors.darkNavy),
                    title: const Text('SemPay UPI Preferences', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('SemPay Client ID: fe362a4cA64890E9'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('SemPay Test Account Credentials Active!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_rounded, color: AppColors.darkNavy),
                    title: const Text('Help & Customer Support', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Direct WhatsApp Chat: +91 83417 26226'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent)),
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
