import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class MaintenanceHomeScreen extends StatefulWidget {
  const MaintenanceHomeScreen({super.key});

  @override
  State<MaintenanceHomeScreen> createState() =>
      _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState
    extends State<MaintenanceHomeScreen> {
  late Future<List<dynamic>> issuesFuture;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    issuesFuture =
        ApiService.getMaintenanceIssues();
  }

  Future<void> refreshIssues() async {
    setState(() {
      _loadIssues();
    });

    await issuesFuture;
  }

  Future<void> updateStatus(
    int issueId,
    String status,
  ) async {
    try {
      await ApiService.maintenanceUpdateStatus(
        issueId: issueId,
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Issue updated to $status',
          ),
        ),
      );

      await refreshIssues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  void logout() {
    ApiService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.blue;

      case 'In Progress':
        return Colors.orange;

      case 'Resolved':
      case 'Closed':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maintenance Dashboard',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: issuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: refreshIssues,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 150),
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to load assigned issues.\n\n'
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final issues = snapshot.data ?? [];

          if (issues.isEmpty) {
            return RefreshIndicator(
              onRefresh: refreshIssues,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 150),
                  Icon(
                    Icons.assignment_turned_in,
                    size: 70,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No issues assigned to you.',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Pull down to refresh.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshIssues,
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue =
                    Map<String, dynamic>.from(
                  issues[index] as Map,
                );

                final issueId =
                    int.tryParse(
                          issue['id'].toString(),
                        ) ??
                        0;

                final title =
                    issue['title']?.toString() ??
                        'Issue';

                final category =
                    issue['category']?.toString() ??
                        '';

                final location =
                    issue['location']?.toString() ??
                        '';

                final priority =
                    issue['priority']?.toString() ??
                        'Medium';

                final status =
                    issue['status']?.toString() ??
                        'Assigned';

                final color =
                    statusColor(status);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.build,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style:
                                    const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Category: $category',
                        ),

                        Text(
                          'Location: $location',
                        ),

                        Text(
                          'Priority: $priority',
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                color.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        if (status == 'Assigned')
                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  issueId == 0
                                      ? null
                                      : () =>
                                          updateStatus(
                                            issueId,
                                            'In Progress',
                                          ),
                              icon: const Icon(
                                Icons.play_arrow,
                              ),
                              label: const Text(
                                'START WORK',
                              ),
                            ),
                          ),

                        if (status ==
                            'In Progress')
                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  issueId == 0
                                      ? null
                                      : () =>
                                          updateStatus(
                                            issueId,
                                            'Resolved',
                                          ),
                              icon: const Icon(
                                Icons.check,
                              ),
                              label: const Text(
                                'MARK RESOLVED',
                              ),
                            ),
                          ),

                        if (status == 'Resolved' ||
                            status == 'Closed')
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Issue resolved',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}