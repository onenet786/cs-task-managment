import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs_task_managment/core/viewmodels/auth_viewmodel.dart';
import 'package:cs_task_managment/core/viewmodels/complaint_viewmodel.dart';
import 'package:cs_task_managment/core/viewmodels/user_viewmodel.dart';
import 'package:cs_task_managment/core/services/navigation_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final complaintViewModel = Provider.of<ComplaintViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    await complaintViewModel.getAllComplaints();
    await userViewModel.getAllUsers();
    await userViewModel.getEmployees();
    await userViewModel.getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final complaintViewModel = Provider.of<ComplaintViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    final navigationService = Provider.of<NavigationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              await navigationService.navigateAndRemoveUntil('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authViewModel.currentUser?.name ?? 'Admin',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authViewModel.currentUser?.email ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // System Stats
            const Text(
              'System Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: userViewModel.users.length.toString(),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Employees',
                  value: userViewModel.employees.length.toString(),
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Customers',
                  value: userViewModel.customers.length.toString(),
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Total Complaints',
                  value: complaintViewModel.allComplaints.length.toString(),
                  color: Colors.purple,
                ),
                _buildStatCard(
                  title: 'Pending',
                  value: complaintViewModel.allComplaints.where((c) => c.status == 'pending').length.toString(),
                  color: Colors.grey,
                ),
                _buildStatCard(
                  title: 'Resolved',
                  value: complaintViewModel.allComplaints.where((c) => c.status == 'resolved').length.toString(),
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  icon: Icons.people,
                  title: 'Manage Users',
                  onTap: () {
                    navigationService.navigateTo('/manage-users');
                  },
                ),
                _buildActionCard(
                  icon: Icons.list_alt,
                  title: 'Manage Complaints',
                  onTap: () {
                    navigationService.navigateTo('/manage-complaints');
                  },
                ),
                _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Reports',
                  onTap: () {
                    navigationService.navigateTo('/reports');
                  },
                ),
                _buildActionCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    navigationService.navigateTo('/settings');
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Complaints
            const Text(
              'Recent Complaints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            complaintViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : complaintViewModel.allComplaints.isEmpty
                    ? const Center(
                        child: Text('No complaints found'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: complaintViewModel.allComplaints.length > 5 ? 5 : complaintViewModel.allComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = complaintViewModel.allComplaints[index];
                          return _buildComplaintCard(complaint, navigationService);
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint, NavigationService navigationService) {
    Color statusColor;
    switch (complaint.status) {
      case 'pending':
        statusColor = Colors.grey;
        break;
      case 'assigned':
        statusColor = Colors.blue;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'closed':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        title: Text(complaint.title),
        subtitle: Text('${complaint.customerName} - ${complaint.status}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            complaint.status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          navigationService.navigateToWithData(
            '/complaint-details',
            complaint.id,
          );
        },
      ),
    );
  }
}
