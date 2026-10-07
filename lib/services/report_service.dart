import '../data/network/api_client.dart';

class ReportService {
  static Future<Map<String, dynamic>> fetchReport(String type, DateTime start, DateTime end) async {
    try {
      final response = await ApiClient.get('/api/reports/$type', params: {
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
      });
      
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      print('❌ Error fetching $type report: $e');
      throw Exception('Failed to load $type report: $e');
    }
  }
}