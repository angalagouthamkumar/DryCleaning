import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/location_provider.dart';

class CustomerOnboardingScreen extends ConsumerStatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  ConsumerState<CustomerOnboardingScreen> createState() => _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends ConsumerState<CustomerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _houseNoController.dispose();
    _landmarkController.dispose();
    _altPhoneController.dispose();
    super.dispose();
  }

  void _saveProfileAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authState = ref.read(authStateProvider);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final houseNo = _houseNoController.text.trim();
    final landmark = _landmarkController.text.trim();
    final fullAddress = '$houseNo, $landmark'.trim();
    final phone = authState.phoneNumber.isNotEmpty
        ? authState.phoneNumber
        : (authState.user?['phoneNumber']?.toString() ?? '');

    ref.read(authStateProvider.notifier).updateUserProfile(
      name: name,
      email: email.isNotEmpty ? email : 'customer@drycleaning.com',
      phoneNumber: phone,
      address: fullAddress,
    );

    // Update location state address
    if (fullAddress.isNotEmpty) {
      ref.read(locationStateProvider.notifier).updateAddress(fullAddress);
    }

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Customer Registration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 45,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Welcome to DryCleaning!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Please fill in your details to set up your account',
                    style: TextStyle(fontSize: 13, color: AppColors.textGray.withValues(alpha: 0.9)),
                  ),
                ),
                const SizedBox(height: 28),

                // Phone number read-only
                const Text(
                  'Mobile Number',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardFill,
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    authState.phoneNumber.isNotEmpty
                        ? authState.phoneNumber
                        : (authState.user?['phoneNumber']?.toString() ?? ''),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name
                const Text(
                  'Full Name *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                  decoration: InputDecoration(
                    hintText: 'e.g. Rahul Sharma',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Address
                const Text(
                  'Email Address (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                  decoration: InputDecoration(
                    hintText: 'rahul@example.com',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // House / Flat No.
                const Text(
                  'Flat / House / Building Name *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _houseNoController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter flat/house number' : null,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                  decoration: InputDecoration(
                    hintText: 'Flat 302, Green Residency',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Landmark / Area
                const Text(
                  'Landmark / Area *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _landmarkController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter landmark or area' : null,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkNavy),
                  decoration: InputDecoration(
                    hintText: 'Near Metro Station, Madhapur',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _saveProfileAndContinue,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Save & Explore Services',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
