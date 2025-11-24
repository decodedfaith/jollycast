import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'podcast_list_screen.dart';

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PodcastListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003334), // Dark Green Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00A86B), // Lighter Green top
              Color(0xFF003334), // Dark Green bottom
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
          Center(child: Image.asset('assets/icons/Jolly2.png', height: 60)),
          const SizedBox(height: 32),
          const Text(
            'Complete account setup',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField('First name', _firstNameController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Last name', _lastNameController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Phone number',
            _phoneController,
            prefixIcon: Icons.flag,
          ),
          const SizedBox(height: 16),
          _buildTextField('Email address', _emailController),
          const SizedBox(height: 16),
          _buildTextField(
            'Create password',
            _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.white70)
                  : null,
              suffixIcon: isPassword
                  ? const Icon(Icons.visibility_outlined, color: Colors.white70)
                  : null,
            ),
          ),
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
        const Icon(Icons.headphones, size: 80, color: Colors.white),
        const SizedBox(height: 16),
        const Text(
          'Welcome, Devon',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Personalize your Jolly experience by selecting your top interest and favorite topics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.headphones, size: 80, color: Colors.white),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'Select an avatar to represent your funk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
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
          Center(child: Image.asset('assets/icons/Jolly2.png', height: 40)),
          const SizedBox(height: 24),
          const Text(
            'Enjoy unlimited podcasts',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 24),
          _buildPlanCard('Daily Jolly Plan', '100', const Color(0xFF00A86B)),
          const SizedBox(height: 16),
          _buildPlanCard('Weekly Jolly Plan', '200', const Color(0xFF00A86B)),
          const SizedBox(height: 16),
          _buildPlanCard('Monthly Jolly Plan', '500', const Color(0xFF00A86B)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _nextPage, // Navigate to All Set page
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70,
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
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headphones, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            'Enjoy unlimited podcast for 24 hours.\nYou can cancel at anytime.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
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
                  child: const Text('One-time'),
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
                  child: const Text('Auto-renewal'),
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
          Image.asset('assets/icons/Jolly2.png', height: 40),
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
                'assets/icons/Jolly2.png',
              ), // Placeholder for user avatar
              // In real app, use the selected avatar
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "You're all set Devon!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Subscribe to a plan to enjoy Jolly Premium.\nGet access to all audio contents, personalize your library to your style and do more cool jolly stuff.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishOnboarding, // Go to Home
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003334),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'See plans', // Or 'Continue' based on flow. Design says 'See plans' but user said 'You are all set' is next.
                // If they skipped, maybe this button takes them back to plans?
                // But for now, let's make it go to Home as "Continue" to finish the flow.
                // The user prompt said: "skip button also to move to the next page which is the you are all set page".
                // So this is the final page.
                // I'll label it "Continue" to be safe for entering the app, or "See plans" if it's an upsell.
                // Let's use "Continue" to actually enter the app.
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'By continuing, you verify that you are at least 18 years old, and you agree with our Terms and Refund policy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
