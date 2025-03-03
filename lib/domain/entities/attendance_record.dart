import 'package:intl/intl.dart';

class AttendanceRecord {
  final String employeeName;
  String checkIn;
  String checkOut;
  final String date;

  AttendanceRecord({
    required this.employeeName,
    required this.checkIn,
    required this.checkOut,
    required this.date,
  });

  // Factory constructor to create an instance from a list of strings
  factory AttendanceRecord.fromList(List<String> row) {
    return AttendanceRecord(
      employeeName: row[0],
      checkIn: _validateTime(row[1]) ? _convertTo24HourFormat(row[1]) : "",
      checkOut: _validateTime(row[2]) ? _convertTo24HourFormat(row[2]) : "",
      date: row[3],
    );
  }

  // Convert the record to a list of strings
  List<String> toList() {
    return [employeeName, checkIn, checkOut, date];
  }

  // Validate time format
  static bool _validateTime(String time) {
    return time.isNotEmpty && RegExp(r"^\d{1,2}:\d{2}(\s?[APap][Mm])?$").hasMatch(time);
  }

  // Convert time to 24-hour format
  static String _convertTo24HourFormat(String time) {
    try {
      // If the time is already in 24-hour format, return it directly
      if (RegExp(r"^\d{1,2}:\d{2}$").hasMatch(time)) {
        return time;
      }
      // If the time is in 12-hour format (with AM/PM), convert it to 24-hour format
      if (time.contains("AM") || time.contains("PM")) {
        return DateFormat("HH:mm").format(DateFormat("hh:mm a").parse(time));
      }
      // Default to 24-hour format
      return DateFormat("HH:mm").format(DateFormat("HH:mm").parse(time));
    } catch (e) {
      throw FormatException("Invalid time format: $time");
    }
  }

  // Getter for formatted check-in time
  String get formattedCheckIn => checkIn.isEmpty ? "Abs" : _convertTo24HourFormat(checkIn);

  // Getter for formatted check-out time
  String get formattedCheckOut => checkOut.isEmpty ? "Abs" : _convertTo24HourFormat(checkOut);

  // Check if the employee is absent
  bool get isAbsent => checkIn.isEmpty || checkOut.isEmpty;

  // Calculate overtime
  String calculateOvertime() {
    if (isAbsent) return "Absent";

    try {
      final checkInTime = _parseTime(checkIn);
      final checkOutTime = _parseTime(checkOut);
      final workDuration = checkOutTime.difference(checkInTime);
      final overtime = workDuration.inHours - 9;
      return overtime > 0 ? "${overtime}h" : "0h";
    } catch (e) {
      return "Invalid Time";
    }
  }

  // Parse time string into DateTime
  DateTime _parseTime(String time) {
    try {
      String formattedTime = _convertTo24HourFormat(time);
      return DateFormat("yyyy-MM-dd HH:mm").parse("$date $formattedTime");
    } catch (e) {
      throw FormatException("Invalid time format: $time");
    }
  }

  // Add the copyWith method
  AttendanceRecord copyWith({
    String? employeeName,
    String? checkIn,
    String? checkOut,
    String? date,
  }) {
    return AttendanceRecord(
      employeeName: employeeName ?? this.employeeName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      date: date ?? this.date,
    );
  }
}