import 'package:intl/intl.dart'; // Import intl package for date formatting
import '../../data/repositories/attendance_repository.dart';
import '../entities/attendance_record.dart';

class FetchAttendanceUseCase {
  final AttendanceRepository repository;

  FetchAttendanceUseCase(this.repository);

  Future<List<AttendanceRecord>> execute(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date); // Convert DateTime to String
    return await repository.fetchAttendance(formattedDate);
  }
}
