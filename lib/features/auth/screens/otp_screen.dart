import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/content_service.dart';
import '../../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 30; // 30 seconds resend countdown timer
  bool _canResend = false;
  bool _isResending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleResendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    final success = await ref.read(authStateProvider.notifier).resendOtp(widget.phoneNumber);

    if (!mounted) return;
    setState(() {
      _isResending = false;
    });

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ContentService.t('customer.auth.otp_dispatched_toast', 'A new 6-digit verification code has been dispatched.'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.darkNavy,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ContentService.t('customer.auth.otp_incomplete_toast', 'Please enter the complete 6-digit verification code.')),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    bool success = await ref.read(authStateProvider.notifier).verifyOtp(
          otp,
          phoneNumber: widget.phoneNumber,
        );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (success) {
      final user = ref.read(authStateProvider).user;
      final userName = user?['name']?.toString().trim() ?? '';
      final isOnboarded = user?['isOnboarded'] == true;
      final isRegistered = userName.isNotEmpty || isOnboarded;

      if (isRegistered) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding-details');
      }
    } else {
      // Automatically clear input fields and focus back to first box when invalid/error
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      final errorMsg = ref.read(authStateProvider).errorMessage ?? ContentService.t('customer.auth.otp_invalid_toast', 'Invalid verification code. Please check and try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contentStateProvider);

    final String minutesStr = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final String secondsStr = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final String timerText = '$minutesStr:$secondsStr';

    return Scaffold(
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
              Text(
                ContentService.t('customer.auth.otp_title', 'Verify Phone'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${ContentService.t('customer.auth.otp_subtitle', 'Enter the 6-digit code sent to')} ${widget.phoneNumber.isEmpty ? "+91 XXXXX XXXXX" : widget.phoneNumber}',
                style: const TextStyle(fontSize: 14, color: AppColors.textGray),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 54,
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
                      decoration: const InputDecoration(
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
                          final fullOtp = _controllers.map((c) => c.text).join();
                          if (fullOtp.length == 6) {
                            _verifyOtp();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      ContentService.t('customer.auth.otp_didnt_receive', "Didn't receive the code?"),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _canResend
                        ? GestureDetector(
                            onTap: _isResending ? null : _handleResendCode,
                            child: _isResending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : Text(
                                    ContentService.t('customer.auth.otp_resend_button', 'Resend Verification Code'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                          )
                        : Text(
                            '${ContentService.t('customer.auth.otp_resend_timer_prefix', 'Resend code in')} $timerText',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkNavy,
                            ),
                          ),
                  ],
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
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                  ),
                  onPressed: _isVerifying ? null : _verifyOtp,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ContentService.t('customer.auth.otp_verify_button', 'Verify & Proceed'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
