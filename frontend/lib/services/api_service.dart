import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================
  //
  // Android Emulator -> Windows localhost
  //
  // FastAPI:
  // http://127.0.0.1:8000
  //
  // Android Emulator:
  // http://10.0.2.2:8000
  // ============================================================

  static const String baseUrl =
      'http://10.0.2.2:8000';

  static String? token;

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/auth/register',
          ),
          headers: {
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': role,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/auth/login',
          ),
          headers: {
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    final result =
        Map<String, dynamic>.from(
      _handleResponse(response),
    );

    token =
        result['access_token']?.toString();

    return result;
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/auth/me',
          ),
          headers: _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // CREATE ISSUE
  // ============================================================

  static Future<Map<String, dynamic>> createIssue({
    required String title,
    required String category,
    required String location,
    required String description,
    required String priority,
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '$baseUrl/issues/',
          ),
          headers: {
            ..._authHeaders(),
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'title': title,
            'category': category,
            'location': location,
            'description': description,
            'priority': priority,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // STUDENT - MY ISSUES
  // ============================================================

  static Future<List<dynamic>> getMyIssues() async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/issues/',
          ),
          headers: _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    final result =
        _handleResponse(response);

    return List<dynamic>.from(result);
  }

  // ============================================================
  // ADMIN - ALL ISSUES
  // ============================================================

  static Future<List<dynamic>> getAdminIssues() async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/admin/issues/',
          ),
          headers: _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    final result =
        _handleResponse(response);

    return List<dynamic>.from(result);
  }

  // ============================================================
  // ADMIN - ASSIGN / REASSIGN ISSUE
  // ============================================================

  static Future<Map<String, dynamic>> assignIssue({
    required int issueId,
    required int staffId,
  }) async {
    final response = await http
        .put(
          Uri.parse(
            '$baseUrl/admin/issues/$issueId/assign/$staffId',
          ),
          headers: _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // ADMIN - UPDATE STATUS
  // ============================================================

  static Future<Map<String, dynamic>>
      adminUpdateStatus({
    required int issueId,
    required String status,
  }) async {
    final response = await http
        .put(
          Uri.parse(
            '$baseUrl/admin/issues/$issueId/status',
          ),
          headers: {
            ..._authHeaders(),
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'status': status,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // MAINTENANCE - ASSIGNED ISSUES
  // ============================================================

  static Future<List<dynamic>>
      getMaintenanceIssues() async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/maintenance/issues/',
          ),
          headers: _authHeaders(),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    final result =
        _handleResponse(response);

    return List<dynamic>.from(result);
  }

  // ============================================================
  // MAINTENANCE - UPDATE STATUS
  // ============================================================

  static Future<Map<String, dynamic>>
      maintenanceUpdateStatus({
    required int issueId,
    required String status,
  }) async {
    final response = await http
        .put(
          Uri.parse(
            '$baseUrl/maintenance/issues/$issueId/status',
          ),
          headers: {
            ..._authHeaders(),
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'status': status,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // ============================================================
  // AUTH HEADERS
  // ============================================================

  static Map<String, String> _authHeaders() {
    if (token == null || token!.isEmpty) {
      throw Exception(
        'Please login first.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static void logout() {
    token = null;
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  static dynamic _handleResponse(
    http.Response response,
  ) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid server response '
        '(${response.statusCode})',
      );
    }

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    // ----------------------------------------------------------
    // FASTAPI ERROR
    // ----------------------------------------------------------

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail != null) {
        if (detail is String) {
          throw Exception(detail);
        }

        // FastAPI validation errors can be lists.
        if (detail is List) {
          final messages = detail
              .map(
                (item) {
                  if (item is Map) {
                    return item['msg']
                            ?.toString() ??
                        item.toString();
                  }

                  return item.toString();
                },
              )
              .join(', ');

          throw Exception(messages);
        }
      }
    }

    throw Exception(
      'Request failed '
      '(${response.statusCode})',
    );
  }
}