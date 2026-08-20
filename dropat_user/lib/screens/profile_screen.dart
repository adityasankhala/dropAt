import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/user_profile_model.dart';
import '../services/user_repository.dart';
import '../services/google_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserRepository.getProfile();
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: DropAtColors.lightGrey,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: DropAtColors.primary),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 20,
                      20,
                      30,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DropAtColors.primary,
                          DropAtColors.primaryDark
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (_profile?.name ?? user?.displayName ?? 'U')
                                .isNotEmpty
                                ? (_profile?.name ??
                                        user?.displayName ??
                                        'U')[0]
                                    .toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _profile?.name ??
                              user?.displayName ??
                              'User',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.phone ??
                              user?.phoneNumber ??
                              '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                                DropAtRadius.round),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 18,
                                  color: DropAtColors.starYellow),
                              const SizedBox(width: 6),
                              Text(
                                (_profile?.rating ?? 5.0)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wallet card
                  _walletCard(),

                  const SizedBox(height: 20),

                  // Menu items
                  _menuCard([
                    _menuItem(Icons.person_outline_rounded, 'Edit Profile'),
                    _menuItem(
                        Icons.bookmark_outline_rounded, 'Saved Places'),
                    _menuItem(Icons.local_offer_outlined, 'My Vouchers'),
                  ]),
                  const SizedBox(height: 14),
                  _menuCard([
                    _menuItem(Icons.help_outline_rounded, 'Help & Support'),
                    _menuItem(Icons.info_outline_rounded, 'About'),
                    _menuItem(Icons.privacy_tip_outlined, 'Privacy Policy'),
                  ]),
                  const SizedBox(height: 14),
                  _menuCard([
                    _menuItem(
                      Icons.logout_rounded,
                      'Sign Out',
                      color: DropAtColors.error,
                      onTap: () async {
                        await GoogleAuthService.signOut();
                      },
                    ),
                  ]),
                  const SizedBox(height: 120), // ADDED PADDING TO CLEAR BOTTOM NAV
                ],
              ),
            ),
    );
  }

  Widget _walletCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DropAtColors.primarySurface,
              borderRadius: BorderRadius.circular(DropAtRadius.md),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: DropAtColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance',
                    style: DropAtTextStyles.bodySmall),
                Text(
                  '₹${(_profile?.walletBalance ?? 0).toInt()}',
                  style: DropAtTextStyles.h2.copyWith(
                    color: DropAtColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              minimumSize: Size.zero,
            ),
            child: const Text('Add',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: DropAtColors.white,
        borderRadius: BorderRadius.circular(DropAtRadius.lg),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _menuItem(IconData icon, String title,
      {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? DropAtColors.primary, size: 22),
      title: Text(
        title,
        style: DropAtTextStyles.bodyMedium.copyWith(
          color: color ?? DropAtColors.black,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: DropAtColors.grey, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
