import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/core/services/app_services.dart';
import 'package:speak_up/features/profile/profile_edit/screens/edit_screen.dart';
import 'package:speak_up/features/profile/widgets/list_tile_custom.dart';
import 'package:speak_up/widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String avatarUrl = '';
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final fName = await storage.read(key: 'firstName') ?? '';
    final lName = await storage.read(key: 'lastName') ?? '';
    final avatar = await storage.read(key: 'avatar') ?? '';

    setState(() {
      firstName = fName;
      lastName = lName;
      avatarUrl = avatar;
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        final apiService = AppService();
        await apiService.logoutUser(); // Gọi API logout
      }
    } catch (e) {
      print('Lỗi khi gọi logout API: $e');
    }

    // Xoá thông tin người dùng khỏi storage
    await storage.deleteAll();

    // Điều hướng về trang login
    if (context.mounted) {
      GoRouter.of(context).go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 32, bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage(AppAssets.imageUserDefault)
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '$lastName $firstName',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );

                            if (result == true) {
                              await _loadUserInfo();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit,
                                    color: Colors.white70, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Chỉnh sửa hồ sơ',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            CustomListTile(
              leadingIcon: Icons.person,
              title: 'Cài đặt chung',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
            ),
            CustomListTile(
              leadingIcon: Icons.notifications_active_outlined,
              title: 'Thông báo',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
            ),
            CustomListTile(
              leadingIcon: Icons.lock,
              title: 'Điều khoản',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
            ),
            CustomListTile(
              leadingIcon: Icons.article,
              title: 'Chính sách',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
            ),
            CustomListTile(
              leadingIcon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content:
                        const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  _logout(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
