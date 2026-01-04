import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Manage Users View'),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
