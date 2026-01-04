import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs_task_managment/core/viewmodels/complaint_viewmodel.dart';
import 'package:cs_task_managment/core/models/complaint.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ComplaintDetailsView extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailsView({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsView> createState() => _ComplaintDetailsViewState();
}

class _ComplaintDetailsViewState extends State<ComplaintDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaintDetails();
    });
  }

  void _loadComplaintDetails() {
    final viewModel = Provider.of<ComplaintViewModel>(context, listen: false);
    viewModel.getComplaintById(widget.complaintId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        actions: [
          Consumer<ComplaintViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadComplaintDetails,
              );
            },
          ),
        ],
      ),
      body: Consumer<ComplaintViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.currentComplaint == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.currentComplaint == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Complaint not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final complaint = viewModel.currentComplaint!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complaint Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                complaint.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(complaint.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.category, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              complaint.category.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Complaint Description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(complaint.description),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Customer Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Name', complaint.customerName),
                        _buildInfoRow('Email', complaint.customerEmail),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Assignment Information
                if (complaint.assignedEmployeeName != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assigned Employee',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Name', complaint.assignedEmployeeName!),
                          if (complaint.assignedEmployeeEmail != null)
                            _buildInfoRow('Email', complaint.assignedEmployeeEmail!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Timeline
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTimelineItem(
                          'Created',
                          complaint.createdAt,
                          Icons.add_circle,
                          Colors.green,
                        ),
                        if (complaint.updatedAt != null)
                          _buildTimelineItem(
                            'Last Updated',
                            complaint.updatedAt!,
                            Icons.update,
                            Colors.blue,
                          ),
                        if (complaint.resolvedAt != null)
                          _buildTimelineItem(
                            'Resolved',
                            complaint.resolvedAt!,
                            Icons.check_circle,
                            Colors.orange,
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),

                // Resolution Notes
                if (complaint.resolutionNotes != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resolution Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(complaint.resolutionNotes!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Image (if available)
                if (complaint.imageUrl != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attached Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                complaint.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 48),
                                        SizedBox(height: 8),
                                        Text('Failed to load image'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                _buildActionButtons(complaint, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'assigned':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.purple;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            _formatDate(date),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButtons(Complaint complaint, ComplaintViewModel viewModel) {
    final List<Widget> buttons = [];

    // Edit complaint (if pending and owned by user)
    if (complaint.status == 'pending') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _editComplaint(complaint.id),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
      );
    }

    // Close complaint (if resolved)
    if (complaint.status == 'resolved') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _closeComplaint(complaint.id, viewModel),
          icon: const Icon(Icons.close),
          label: const Text('Close'),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...buttons.map((button) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: button,
            )),
          ],
        ),
      ),
    );
  }

  void _editComplaint(int complaintId) {
    Fluttertoast.showToast(
      msg: 'Edit functionality coming soon',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _closeComplaint(int complaintId, ComplaintViewModel viewModel) async {
    try {
      await viewModel.markAsClosed(complaintId);
      Fluttertoast.showToast(
        msg: 'Complaint closed successfully',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.green,
      );
      _loadComplaintDetails(); // Refresh
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error closing complaint: $e',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
      );
    }
  }
}
