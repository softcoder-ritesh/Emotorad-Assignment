import 'package:intl/intl.dart';

import '../../core/services/google_sheets_service.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceRepository {
  final GoogleSheetsService googleSheetsService;

  AttendanceRepository(this.googleSheetsService);

  Future<List<AttendanceRecord>> fetchAttendance(String date) async {
    await _ensureInitialized();
    final data = await googleSheetsService.fetchAttendanceData();

    if (data.isEmpty) return [];

    print("Selected Date: $date"); // Debug print
    final records = data.skip(1) // Skip header row
        .where((row) {
      print("Row Date: ${row[3]}"); // Debug print
      return row.length >= 4 && row[3] == date;
    })
        .map((row) => AttendanceRecord.fromList(row.map((e) => e.toString()).toList()))
        .toList();

    print("Fetched Records: $records"); // Debug print
    return records;
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    await _ensureInitialized();
    await googleSheetsService.updateAttendance(record.employeeName, record.checkIn, record.checkOut, record.date);
  }
  Future<void> removeEmployee(String employeeName) async {
    await _ensureInitialized();
    await googleSheetsService.removeEmployee(employeeName);
  }Future<void> addEmployee(String employeeName) async {
    await _ensureInitialized();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await googleSheetsService.addEmployee(employeeName, date);
  }

  Future<void> _ensureInitialized() async {
    if (!googleSheetsService.isInitialized) {
      await googleSheetsService.initialize();
    }
  }
}
