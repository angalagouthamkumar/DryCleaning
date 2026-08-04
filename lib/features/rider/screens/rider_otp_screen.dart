import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../providers/rider_provider.dart';
import '../widgets/rider_responsive_wrapper.dart';

class RiderOtpScreen extends ConsumerStatefulWidget {
  const RiderOtpScreen({super.key});

  @override
  ConsumerState<RiderOtpScreen> createState() => _RiderOtpScreenState();
}

class _RiderOtpScreenState extends ConsumerState<RiderOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSecondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    setState(() {
      _resendSecondsRemaining = 30;
      _canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsRemaining > 0) {
        setState(() {
          _resendSecondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _resendTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onResendPressed() async {
    final phoneNumber = ref.read(riderStateProvider).phoneNumber;
    final success = await ref.read(riderStateProvider.notifier).sendOtp(phoneNumber);
    if (mounted && success) {
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _startTimers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New verification code requested successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit verification code'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    final success = await ref.read(riderStateProvider.notifier).verifyOtp(otp);

    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/rider-main', (route) => false);
    } else {
      final errorMsg = ref.read(riderStateProvider).errorMessage ?? 'Invalid verification code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final riderState = ref.watch(riderStateProvider);

    return RiderResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VERIFY RIDER CODE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter 6-digit code sent to ${riderState.phoneNumber.isEmpty ? "your mobile number" : riderState.phoneNumber}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textGray),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 44,
                      height: 52,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardFill,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (value.isNotEmpty && index == 5) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _onResendPressed,
                          child: const Text(
                            "CAN'T GET CODE? REQUEST NEW ONE",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : Text(
                          "CAN'T GET CODE? RESEND IN ${_resendSecondsRemaining}s",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGray,
                          ),
                        ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                    ),
                    onPressed: riderState.isLoading ? null : _verifyOtp,
                    child: riderState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'VERIFY & PROCEED',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

