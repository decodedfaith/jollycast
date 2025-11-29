import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_assets.dart';
import '../widgets/common/jolly_button.dart';
import '../widgets/common/jolly_text_field.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  // State for steps
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '08023400000');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _selectedInterests = [];
  int? _selectedAvatarIndex;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.accent, // Lighter Green top
              AppColors.background, // Dark Green bottom
            ],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAccountSetupStep(),
              _buildInterestsStep(),
              _buildAvatarStep(),
              _buildSubscriptionStep(),
              _buildAllSetStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSetupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset(AppAssets.logo, height: 60)),
          const SizedBox(height: 32),
          const Text(
            AppStrings.completeAccountSetup,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  AppStrings.firstName,
                  _firstNameController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  AppStrings.lastName,
                  _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.phoneNumber,
            _phoneController,
            prefixIcon: Icons.flag,
          ),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.emailAddress, _emailController),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.createPassword,
            _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 48),
          JollyButton(text: AppStrings.continueText, onPressed: _nextPage),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        JollyTextField(
          controller: controller,
          hintText: '',
          isPassword: isPassword,
          prefixIcon: prefixIcon,
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    final interests = [
      'Business & Career',
      'Movies & Cinema',
      'Tech events',
      'Mountain climbing',
      'Educational',
      'Religious & Spiritual',
      'Sip & Paint',
      'Fitness',
      'Sports',
      'Kayaking',
      'Clubs & Party',
      'Games',
      'Concerts',
      'Art & Culture',
      'Karaoke',
      'Adventure',
      'Health & Lifestyle',
      'Food & Drinks',
    ];

    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.headphones, size: 80, color: AppColors.textPrimary),
        const SizedBox(height: 16),
        const Text(
          '${AppStrings.welcome}Devon',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            AppStrings.selectInterests,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: interests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF333333),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                  avatar: isSelected
                      ? const Icon(Icons.close, size: 18, color: Colors.white)
                      : const Icon(Icons.add, size: 18, color: Colors.black54),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: JollyButton(
            text: AppStrings.continueText,
            onPressed: _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.headphones, size: 80, color: AppColors.textPrimary),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            AppStrings.selectAvatar,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isSelected = _selectedAvatarIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    color: Colors.white.withAlpha(51),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: JollyButton(
            text: AppStrings.continueText,
            onPressed: _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Center(child: Image.asset(AppAssets.logo, height: 40)),
          const SizedBox(height: 24),
          const Text(
            AppStrings.enjoyUnlimited,
            style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          _buildPlanCard(AppStrings.dailyPlan, '100', AppColors.accent),
          const SizedBox(height: 16),
          _buildPlanCard(AppStrings.weeklyPlan, '200', AppColors.accent),
          const SizedBox(height: 16),
          _buildPlanCard(AppStrings.monthlyPlan, '500', AppColors.accent),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _nextPage, // Navigate to All Set page
            child: const Text(
              AppStrings.skipForNow,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(204), color.withAlpha(153)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headphones, color: AppColors.textPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₦ $price',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.planDescription,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage, // Navigate to All Set page
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(AppStrings.oneTime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage, // Navigate to All Set page
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(AppStrings.autoRenewal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllSetStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(AppAssets.logo, height: 40),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                AppAssets.logo,
              ), // Placeholder for user avatar
              // In real app, use the selected avatar
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '${AppStrings.allSet}Devon!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.subscribeMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          JollyButton(text: AppStrings.seePlans, onPressed: _finishOnboarding),
          const SizedBox(height: 16),
          const Text(
            AppStrings.termsVerify,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
