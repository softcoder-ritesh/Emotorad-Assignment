import '../../../domain/entities/attendance_record.dart';

abstract class AttendanceEvent {}

class FetchAttendance extends AttendanceEvent {
  final String date;
  FetchAttendance(this.date);
}

class UpdateAttendance extends AttendanceEvent {
  final AttendanceRecord record;
  UpdateAttendance(this.record);
}

class AddEmployee extends AttendanceEvent {
  final String employeeName;
  AddEmployee(this.employeeName);
}

class RemoveEmployee extends AttendanceEvent {
  final String employeeName;
  RemoveEmployee(this.employeeName);
}
