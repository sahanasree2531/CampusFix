import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<List<dynamic>> issuesFuture;

  @override
  void initState() {
    super.initState();
    issuesFuture = ApiService.getAdminIssues();
  }

  // ============================================================
  // REFRESH ISSUES
  // ============================================================

  Future<void> refreshIssues() async {
    final future = ApiService.getAdminIssues();

    if (!mounted) return;

    setState(() {
      issuesFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder will show the error.
    }
  }

  // ============================================================
  // ASSIGN / REASSIGN ISSUE
  // ============================================================

  Future<void> assignIssue(int issueId) async {
    // First open the staff ID dialog.
    final int? staffId = await _askForStaffId();

    // User pressed CANCEL.
    if (!mounted || staffId == null) {
      return;
    }

    try {
      // Show loading message after dialog is completely finished.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assigning issue...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Call backend.
      await ApiService.assignIssue(issueId: issueId, staffId: staffId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Issue #$issueId assigned to staff ID $staffId successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reload issues.
      await refreshIssues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // STAFF ID DIALOG
  // ============================================================

  Future<int?> _askForStaffId() async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _StaffIdDialog();
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: refreshIssues,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      // ==========================================================
      // ISSUE LIST
      // ==========================================================
      body: RefreshIndicator(
        onRefresh: refreshIssues,
        child: FutureBuilder<List<dynamic>>(
          future: issuesFuture,
          builder: (context, snapshot) {
            // ----------------------------------------------------
            // LOADING
            // ----------------------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ----------------------------------------------------
            // ERROR
            // ----------------------------------------------------

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),

                  const Icon(Icons.error_outline, size: 60, color: Colors.red),

                  const SizedBox(height: 16),

                  const Text(
                    'Unable to load issues',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Text(snapshot.error.toString(), textAlign: TextAlign.center),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: refreshIssues,
                    child: const Text('RETRY'),
                  ),
                ],
              );
            }

            // ----------------------------------------------------
            // DATA
            // ----------------------------------------------------

            final issues = snapshot.data ?? [];

            int reported = 0;
            int assigned = 0;
            int inProgress = 0;
            int resolved = 0;

            for (final item in issues) {
              final issue = Map<String, dynamic>.from(item as Map);

              final status = issue['status']?.toString() ?? '';

              switch (status) {
                case 'Reported':
                  reported++;
                  break;

                case 'Assigned':
                  assigned++;
                  break;

                case 'In Progress':
                  inProgress++;
                  break;

                case 'Resolved':
                case 'Closed':
                  resolved++;
                  break;
              }
            }

            // ----------------------------------------------------
            // MAIN LIST
            // ----------------------------------------------------

            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // =================================================
                // DASHBOARD STATISTICS
                // =================================================

                Row(
                  children: [
                    _statCard('Total', issues.length, Icons.list_alt),
                    _statCard('Reported', reported, Icons.report_problem),
                  ],
                ),

                Row(
                  children: [
                    _statCard('Assigned', assigned, Icons.person_add),
                    _statCard('In Progress', inProgress, Icons.engineering),
                  ],
                ),

                Row(
                  children: [
                    _statCard('Resolved', resolved, Icons.check_circle),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'All Issues',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // =================================================
                // NO ISSUES
                // =================================================
                if (issues.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No issues found.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // =================================================
                // ISSUE CARDS
                // =================================================
                ...issues.map((item) {
                  final issue = Map<String, dynamic>.from(item as Map);

                  final issueId = int.tryParse(issue['id'].toString()) ?? 0;

                  final title = issue['title']?.toString() ?? 'Issue';

                  final category = issue['category']?.toString() ?? 'Unknown';

                  final location = issue['location']?.toString() ?? 'Unknown';

                  final priority = issue['priority']?.toString() ?? 'Medium';

                  final status = issue['status']?.toString() ?? 'Reported';

                  final assignedTo = issue['assigned_to']?.toString();

                  final isCompleted =
                      status == 'Resolved' || status == 'Closed';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------------------------------------
                          // TITLE
                          // ---------------------------------------

                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ---------------------------------------
                          // ISSUE DETAILS
                          // ---------------------------------------
                          Text(
                            'Issue ID: $issueId',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 5),

                          Text('Category: $category'),

                          Text('Location: $location'),

                          Text('Priority: $priority'),

                          Text('Status: $status'),

                          const SizedBox(height: 5),

                          // ---------------------------------------
                          // ASSIGNED STAFF
                          // ---------------------------------------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.engineering, size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  assignedTo == null || assignedTo.isEmpty
                                      ? 'Assigned to: Not assigned'
                                      : 'Assigned to Staff ID: $assignedTo',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ---------------------------------------
                          // ASSIGN / REASSIGN BUTTON
                          // ---------------------------------------
                          if (!isCompleted)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: issueId == 0
                                    ? null
                                    : () {
                                        assignIssue(issueId);
                                      },
                                icon: Icon(
                                  assignedTo == null
                                      ? Icons.person_add
                                      : Icons.manage_accounts,
                                ),
                                label: Text(
                                  assignedTo == null
                                      ? 'ASSIGN STAFF'
                                      : 'REASSIGN STAFF',
                                ),
                              ),
                            ),

                          // ---------------------------------------
                          // RESOLVED
                          // ---------------------------------------
                          if (isCompleted)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Issue resolved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 28),

              const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STAFF ID DIALOG
// ================================================================
//
// IMPORTANT:
// There is NO GlobalKey<FormState> here.
// There is NO controller coming from the parent.
// The controller belongs only to this dialog.
// ================================================================

class _StaffIdDialog extends StatefulWidget {
  const _StaffIdDialog();

  @override
  State<_StaffIdDialog> createState() => _StaffIdDialogState();
}

class _StaffIdDialogState extends State<_StaffIdDialog> {
  late final TextEditingController _controller;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    if (_isSubmitting) return;

    final text = _controller.text.trim();

    // Empty
    if (text.isEmpty) {
      _showError('Please enter the maintenance staff ID.');
      return;
    }

    // Not a number
    final int? staffId = int.tryParse(text);

    if (staffId == null) {
      _showError('Staff ID must be a number.');
      return;
    }

    // Invalid number
    if (staffId <= 0) {
      _showError('Please enter a valid staff ID.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Return the ID to assignIssue().
    Navigator.of(context).pop(staffId);
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Maintenance Staff'),

      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,

        decoration: const InputDecoration(
          labelText: 'Maintenance Staff ID',
          hintText: 'Example: 3',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.badge),
        ),

        onSubmitted: (_) {
          _submit();
        },
      ),

      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('CANCEL'),
        ),

        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: const Icon(Icons.person_add),
          label: const Text('ASSIGN'),
        ),
      ],
    );
  }
}
