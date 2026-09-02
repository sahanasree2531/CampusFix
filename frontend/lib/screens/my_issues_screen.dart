import 'package:flutter/material.dart';

import '../services/api_service.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() =>
      _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  late Future<List<dynamic>> issuesFuture;

  @override
  void initState() {
    super.initState();
    issuesFuture = ApiService.getMyIssues();
  }

  Future<void> refreshIssues() async {
    setState(() {
      issuesFuture = ApiService.getMyIssues();
    });

    await issuesFuture;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Resolved':
      case 'Closed':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      case 'Assigned':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issues'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshIssues,
        child: FutureBuilder<List<dynamic>>(
          future: issuesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load issues.\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final issues = snapshot.data ?? [];

            if (issues.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'No issues reported yet.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue =
                    Map<String, dynamic>.from(
                  issues[index] as Map,
                );

                final title =
                    issue['title']?.toString() ??
                        'Issue';

                final category =
                    issue['category']?.toString() ?? '';

                final location =
                    issue['location']?.toString() ?? '';

                final description =
                    issue['description']?.toString() ?? '';

                final priority =
                    issue['priority']?.toString() ??
                        'Medium';

                final status =
                    issue['status']?.toString() ??
                        'Reported';

                final color = statusColor(status);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Category: $category',
                        ),

                        Text(
                          'Location: $location',
                        ),

                        Text(
                          'Priority: $priority',
                        ),

                        const SizedBox(height: 10),

                        Text(
                          description,
                          maxLines: 3,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
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
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}