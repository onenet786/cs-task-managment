import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs_task_managment/core/viewmodels/auth_viewmodel.dart';
import 'package:cs_task_managment/core/viewmodels/complaint_viewmodel.dart';
import 'package:cs_task_managment/core/services/navigation_service.dart';

class EmployeeDashboardView extends StatefulWidget {
  const EmployeeDashboardView({super.key});

  @override
  State<EmployeeDashboardView> createState() => _EmployeeDashboardViewState();
}

class _EmployeeDashboardViewState extends State<EmployeeDashboardView> {
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
      await complaintViewModel.getAssignedComplaints(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final complaintViewModel = Provider.of<ComplaintViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
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
                      authViewModel.currentUser?.name ?? 'Employee',
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

            // Stats Cards
            const Text(
              'Your Stats',
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
                _buildStatCard(
                  title: 'Assigned',
                  value: complaintViewModel.assignedComplaints.where((c) => c.status == 'assigned').length.toString(),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'In Progress',
                  value: complaintViewModel.assignedComplaints.where((c) => c.status == 'in_progress').length.toString(),
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Resolved',
                  value: complaintViewModel.assignedComplaints.where((c) => c.status == 'resolved').length.toString(),
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Total',
                  value: complaintViewModel.assignedComplaints.length.toString(),
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Assigned Complaints
            const Text(
              'Assigned Complaints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            complaintViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : complaintViewModel.assignedComplaints.isEmpty
                    ? const Center(
                        child: Text('No assigned complaints found'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: complaintViewModel.assignedComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = complaintViewModel.assignedComplaints[index];
                          return _buildComplaintCard(complaint);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
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
        subtitle: Text(complaint.status),
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
          _navigationService.navigateToWithData(
            '/employee-complaint-details',
            complaint.id,
          );
        },
      ),
    );
  }
}
