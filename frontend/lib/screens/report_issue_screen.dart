import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() =>
      _ReportIssueScreenState();
}

class _ReportIssueScreenState
    extends State<ReportIssueScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  String category = 'Electrical';
  String priority = 'Medium';

  bool loading = false;

  final List<String> categories = [
    'Electrical',
    'Plumbing',
    'AC',
    'Furniture',
    'Wi-Fi',
    'Cleaning',
    'Other',
  ];

  final List<String> priorities = [
    'Low',
    'Medium',
    'High',
  ];

  Future<void> submitIssue() async {
    final title = titleController.text.trim();
    final location = locationController.text.trim();
    final description =
        descriptionController.text.trim();

    if (title.isEmpty) {
      showMessage('Please enter an issue title');
      return;
    }

    if (location.isEmpty) {
      showMessage('Please enter the location');
      return;
    }

    if (description.isEmpty) {
      showMessage('Please describe the issue');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.createIssue(
        title: title,
        category: category,
        location: location,
        description: description,
        priority: priority,
      );

      if (!mounted) return;

      showMessage(
        'Issue reported successfully!',
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  InputDecoration decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_problem,
                        size: 35,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tell us about the problem '
                          'so it can be fixed quickly.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: titleController,
                enabled: !loading,
                decoration: decoration(
                  'Issue Title',
                  Icons.title,
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: decoration(
                  'Category',
                  Icons.category,
                ),
                items: categories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: locationController,
                enabled: !loading,
                decoration: decoration(
                  'Location',
                  Icons.location_on,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,
                enabled: !loading,
                maxLines: 5,
                decoration: decoration(
                  'Description',
                  Icons.description,
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: decoration(
                  'Priority',
                  Icons.priority_high,
                ),
                items: priorities.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            priority = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed:
                      loading ? null : submitIssue,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(),
                        )
                      : const Icon(
                          Icons.send,
                        ),
                  label: Text(
                    loading
                        ? 'SUBMITTING...'
                        : 'SUBMIT ISSUE',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}