import '../../../domain/entities/attendance_record.dart';

abstract class AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final List<AttendanceRecord> defaultRecords; // Add this field
  AttendanceLoaded(this.records, {this.defaultRecords = const []}); // Initialize with an empty list
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}