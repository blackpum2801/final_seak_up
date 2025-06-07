import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speak_up/core/constants/asset_color.dart';

class EditProfileWidgets {
  static void showStyledDialog({
    required BuildContext context,
    required String title,
    required List<Widget> contentFields,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.secondBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...contentFields,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void editFullName({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required Function(String, String) onSave,
  }) {
    final firstController = TextEditingController(text: firstName);
    final lastController = TextEditingController(text: lastName);

    showStyledDialog(
      context: context,
      title: 'Edit Name',
      contentFields: [
        TextField(
          controller: firstController,
          style: const TextStyle(color: Colors.white),
          decoration: inputDecoration('First Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lastController,
          style: const TextStyle(color: Colors.white),
          decoration: inputDecoration('Last Name'),
        ),
      ],
      onSave: () {
        onSave(firstController.text.trim(), lastController.text.trim());
        Navigator.pop(context);
      },
    );
  }

  static void editField({
    required BuildContext context,
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showStyledDialog(
      context: context,
      title: 'Edit $title',
      contentFields: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: inputDecoration(title),
        ),
      ],
      onSave: () {
        onSave(controller.text.trim());
        Navigator.pop(context);
      },
    );
  }

  static Future<void> changeAvatar({
    required BuildContext context,
    required Function(String, File?) onAvatarChanged,
  }) async {
    if (await Permission.photos.request().isGranted) {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        onAvatarChanged(file.path, File(file.path));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access photos')),
      );
    }
  }

  static void changePasswordDialog({
    required BuildContext context,
    required Function(String?, String?) onSave,
  }) {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    showStyledDialog(
      context: context,
      title: 'Change Password',
      contentFields: [
        TextField(
          controller: currentController,
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          decoration: inputDecoration('Current Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: newController,
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          decoration: inputDecoration('New Password'),
        ),
      ],
      onSave: () {
        onSave(currentController.text, newController.text);
        Navigator.pop(context);
      },
    );
  }

  static void editGender({
    required BuildContext context,
    required String currentGender,
    required ValueChanged<String> onSave,
  }) {
    String selectedGender = currentGender;

    showStyledDialog(
      context: context,
      title: 'Edit Gender',
      contentFields: [
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ['male', 'female', 'other'].map((g) {
                return ListTile(
                  title: Text(
                    g == 'male'
                        ? 'Male'
                        : g == 'female'
                            ? 'Female'
                            : 'Other',
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: Radio<String>(
                    value: g,
                    groupValue: selectedGender,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedGender = value);
                      }
                    },
                    activeColor: Colors.blueAccent,
                  ),
                  onTap: () {
                    setState(() => selectedGender = g);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
      onSave: () {
        onSave(selectedGender);
        Navigator.pop(context);
      },
    );
  }

  static InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2C2C3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  static Widget buildItem(String title, String value, VoidCallback? onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child:
                  const Text('Edit', style: TextStyle(color: Colors.lightBlue)),
            ),
        ],
      ),
    );
  }
}
