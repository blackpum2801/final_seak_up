// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/features/profile/widgets/edit_profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String address = '';
  String gender = 'male';
  String phoneNumber = '';
  String avatar = '';
  String email = '';
  File? newAvatarFile;

  String? currentPassword;
  String? newPassword;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    firstName = await storage.read(key: 'firstName') ?? '';
    lastName = await storage.read(key: 'lastName') ?? '';
    address = await storage.read(key: 'address') ?? '';
    gender = await storage.read(key: 'gender') ?? 'male';
    phoneNumber = await storage.read(key: 'phoneNumber') ?? '';
    avatar = await storage.read(key: 'avatar') ?? '';
    email = await storage.read(key: 'email') ?? '';
    setState(() {});
  }

  Future<void> _submit() async {
    final formData = FormData.fromMap({
      'firstname': firstName,
      'lastname': lastName,
      'username': '$firstName $lastName',
      'address': address,
      'gender': gender,
      'phoneNumber': phoneNumber,
      if (currentPassword != null && newPassword != null) ...{
        'currentPassword': currentPassword,
        'password': newPassword,
      },
      if (newAvatarFile != null)
        'avatar': await MultipartFile.fromFile(newAvatarFile!.path,
            filename: 'avatar.jpg'),
    });

    try {
      final dio = DioClient().dio;
      final response = await dio.put(
        '/users/profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final updated = response.data['rs'];
        await storage.write(key: 'firstName', value: updated['firstname']);
        await storage.write(key: 'lastName', value: updated['lastname']);
        await storage.write(key: 'username', value: updated['username']);
        await storage.write(key: 'address', value: updated['address']);
        await storage.write(key: 'gender', value: updated['gender']);
        await storage.write(key: 'phoneNumber', value: updated['phoneNumber']);
        if (updated['avatar'] != null) {
          await storage.write(key: 'avatar', value: updated['avatar']);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Profile updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ ${response.data['rs'] ?? 'Update failed'}')),
        );
      }
    } catch (e) {
      print('❌ Update error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Network or server error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: newAvatarFile != null
                      ? FileImage(newAvatarFile!)
                      : (avatar.isNotEmpty ? NetworkImage(avatar) : null)
                          as ImageProvider?,
                  backgroundColor: Colors.white,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => EditProfileWidgets.changeAvatar(
                      context: context,
                      onAvatarChanged: (path, file) {
                        setState(() {
                          avatar = path;
                          newAvatarFile = file;
                        });
                      },
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.purple,
                      child:
                          Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          EditProfileWidgets.buildItem(
            'Name',
            '$firstName $lastName',
            () => EditProfileWidgets.editFullName(
              context: context,
              firstName: firstName,
              lastName: lastName,
              onSave: (newFirst, newLast) {
                setState(() {
                  firstName = newFirst;
                  lastName = newLast;
                });
              },
            ),
          ),
          EditProfileWidgets.buildItem('Email', email, null),
          EditProfileWidgets.buildItem(
            'Address',
            address,
            () => EditProfileWidgets.editField(
              context: context,
              title: 'Address',
              initialValue: address,
              onSave: (value) => setState(() => address = value),
            ),
          ),
          EditProfileWidgets.buildItem(
            'Phone Number',
            phoneNumber,
            () => EditProfileWidgets.editField(
              context: context,
              title: 'Phone Number',
              initialValue: phoneNumber,
              onSave: (value) => setState(() => phoneNumber = value),
            ),
          ),
          EditProfileWidgets.buildItem(
            'Gender',
            gender == 'male'
                ? 'Male'
                : gender == 'female'
                    ? 'Female'
                    : 'Other',
            () => EditProfileWidgets.editGender(
              context: context,
              currentGender: gender,
              onSave: (newGender) {
                setState(() => gender = newGender);
              },
            ),
          ),
          EditProfileWidgets.buildItem(
            'New Password',
            'Change password',
            () => EditProfileWidgets.changePasswordDialog(
              context: context,
              onSave: (current, newPass) {
                setState(() {
                  currentPassword = current;
                  newPassword = newPass;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
