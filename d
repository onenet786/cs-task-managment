import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';
import 'core/services/user_service.dart';
import 'core/services/complaint_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/report_service.dart';
import 'core/services/api_service.dart';
import 'core/services/navigation_service.dart';
import 'core/services/dialog_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/image_picker_service.dart';

import 'core/viewmodels/auth_viewmodel.dart';
import 'core/viewmodels/user_viewmodel.dart';
import 'core/viewmodels/complaint_viewmodel.dart';
import 'core/viewmodels/notification_viewmodel.dart';
import 'core/viewmodels/report_viewmodel.dart';

import 'ui/views/splash_view.dart';
import 'ui/views/auth/login_view.dart';
import 'ui/views/auth/register_view.dart';
import 'ui/views/auth/verify_email_view.dart';
import 'ui/views/auth/forgot_password_view.dart';

import 'ui/views/customer/dashboard_view.dart';
import 'ui/views/customer/create_complaint_view.dart';
import 'ui/views/customer/complaint_details_view.dart';
import 'ui/views/customer/my_complaints_view.dart';

import 'ui/views/employee/dashboard_view.dart';
import 'ui/views/employee/assigned_complaints_view.dart';
import 'ui/views/employee/complaint_details_view.dart';
import 'ui/views/employee/update_status_view.dart';

import 'ui/views/admin/dashboard_view.dart';
import 'ui/views/admin/manage_users_view.dart';
import 'ui/views/admin/manage_complaints_view.dart';
import 'ui/views/admin/reports_view.dart';
import 'ui/views/admin/settings_view.dart';

import 'ui/themes/app_theme.dart';
import 'ui/widgets/custom_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<ComplaintService>(create: (_) => ComplaintService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<ReportService>(create: (_) => ReportService()),
        Provider<NavigationService>(create: (_) => NavigationService()),
        Provider<DialogService>(create: (_) => DialogService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ConnectivityService>(create: (_) => ConnectivityService()),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
        
        // ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<UserViewModel>(
          create: (_) => UserViewModel(),
        ),
        ChangeNotifierProvider<ComplaintViewModel>(
          create: (_) => ComplaintViewModel(),
        ),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(),
        ),
        ChangeNotifierProvider<ReportViewModel>(
          create: (_) => ReportViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Customer Task Management',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        navigatorKey: Provider.of<NavigationService>(context, listen: false).navigatorKey,
        home: const SplashView(),
        routes: {
          // Auth Routes
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/verify-email': (context) => const VerifyEmailView(),
          '/forgot-password': (context) => const ForgotPasswordView(),
          
          // Customer Routes
          '/customer-dashboard': (context) => const CustomerDashboardView(),
          '/create-complaint': (context) => const CreateComplaintView(),
          '/complaint-details': (context) {
            final complaintId = ModalRoute.of(context)?.settings.arguments as int?;
            return ComplaintDetailsView(complaintId: complaintId ?? 0);
          },
          '/my-complaints': (context) => const MyComplaintsView(),
          
          // Employee Routes
          '/employee-dashboard': (context) => const EmployeeDashboardView(),
          '/assigned-complaints': (context) => const AssignedComplaintsView(),
          '/employee-complaint-details': (context) => const EmployeeComplaintDetailsView(),
          '/update-status': (context) => const UpdateStatusView(),
          
          // Admin Routes
          '/admin-dashboard': (context) => const AdminDashboardView(),
          '/manage-users': (context) => const ManageUsersView(),
          '/manage-complaints': (context) => const ManageComplaintsView(),
          '/reports': (context) => const ReportsView(),
          '/settings': (context) => const SettingsView(),
        },
        builder: (context, child) {
          return CustomDialog(
            child: child!,
          );
        },
      ),
    );
  }
}
