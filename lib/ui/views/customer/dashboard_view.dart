import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs_task_managment/core/viewmodels/auth_viewmodel.dart';
import 'package:cs_task_managment/core/viewmodels/complaint_viewmodel.dart';
import 'package:cs_task_managment/core/services/navigation_service.dart';

class CustomerDashboardView extends StatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  State<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends State<CustomerDashboardView> {
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final complaintViewModel = Provider.of<ComplaintViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (authViewModel.currentUser != null) {
      await complaintViewModel.getMyComplaints(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final complaintViewModel = Provider.of<ComplaintViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              await _navigationService.navigateAndRemoveUntil('/login');
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
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authViewModel.currentUser?.name ?? 'Customer',
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
                  icon: Icons.add,
                  title: 'New Complaint',
                  onTap: () {
                    _navigationService.navigateTo('/create-complaint');
                  },
                ),
                _buildActionCard(
                  icon: Icons.list,
                  title: 'My Complaints',
                  onTap: () {
                    _navigationService.navigateTo('/my-complaints');
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
                : complaintViewModel.myComplaints.isEmpty
                    ? const Center(
                        child: Text('No complaints found'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: complaintViewModel.myComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = complaintViewModel.myComplaints[index];
                          return _buildComplaintCard(complaint);
                        },
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigationService.navigateTo('/create-complaint');
        },
        child: const Icon(Icons.add),
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
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
    return Card(
      child: ListTile(
        title: Text(complaint.title),
        subtitle: Text(complaint.status),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _navigationService.navigateToWithData(
            '/complaint-details',
            complaint.id,
          );
        },
      ),
    );
  }
}
