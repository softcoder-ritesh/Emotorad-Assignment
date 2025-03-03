import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import 'employee_management_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  final Map<int, TextEditingController> checkInControllers = {};
  final Map<int, TextEditingController> checkOutControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  @override
  void dispose() {
    checkInControllers.values.forEach((controller) => controller.dispose());
    checkOutControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  /// Fetches attendance records for the selected date.
  void _fetchAttendance() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    context.read<AttendanceBloc>().add(FetchAttendance(formattedDate));
  }

  /// Opens a date picker and updates the selected date.
  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAttendance();
    }
  }

  /// Updates the check-in or check-out time for an employee.
  void _updateAttendance(
      AttendanceRecord record,
      int index,
      bool isCheckIn,
      ) async {
    TimeOfDay? pickedTime = await pickTime(
      context,
      isCheckIn
          ? checkInControllers[index]!.text
          : checkOutControllers[index]!.text,
    );
    if (pickedTime != null) {
      String formattedTime =
          "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";

      // Update the UI immediately
      setState(() {
        if (isCheckIn) {
          checkInControllers[index]?.text = formattedTime;
        } else {
          checkOutControllers[index]?.text = formattedTime;
        }
      });

      // Update the record in the backend
      AttendanceRecord updatedRecord;
      if (isCheckIn) {
        updatedRecord = record.copyWith(
          checkIn: formattedTime,
          checkOut: record.checkOut,
        );
      } else {
        updatedRecord = record.copyWith(
          checkIn: record.checkIn,
          checkOut: formattedTime,
        );
      }

      context.read<AttendanceBloc>().add(UpdateAttendance(updatedRecord));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(), // Corrected: Returns an AppBar (PreferredSizeWidget)
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            SizedBox(height: 20),
            _buildTableHeader(),
            SizedBox(height: 10),
            _buildAttendanceList(),
            SizedBox(height: 10),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar with a title and a button to manage employees.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Employee Attendance",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
      elevation: 4,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.group, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageEmployeesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds the date selector section.
  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(selectedDate),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the table header for the attendance list.
  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 40), // Space for present indicator
          Expanded(
            flex: 2,
            child: Text(
              "Employee",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Check-in",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              "Check-out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              "Overtime",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the attendance list.
  Widget _buildAttendanceList() {
    return Expanded(
      child: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is AttendanceError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (state is AttendanceLoaded) {
            // Check if the selected date is in the future
            if (selectedDate.isAfter(DateTime.now())) {
              return _buildFutureDateWarning();
            }
            // If no records are found, use defaultRecords
            final records =
            state.records.isEmpty ? state.defaultRecords : state.records;

            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                var record = records[index];

                checkInControllers.putIfAbsent(
                  index,
                      () => TextEditingController(text: record.checkIn),
                );

                checkOutControllers.putIfAbsent(
                  index,
                      () => TextEditingController(text: record.checkOut),
                );

                return _buildAttendanceRow(record, index);
              },
            );
          }
          return Center(
            child: Text(
              "No records found for this date.",
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  /// Builds a warning message for future dates.
  Widget _buildFutureDateWarning() {
    return Center(
      child: FadeInUp(
        duration: Duration(milliseconds: 500),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  "Cannot Check Attendance for Future Dates",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Please select a past or current date to view attendance records.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a row for the attendance list.
  Widget _buildAttendanceRow(AttendanceRecord record, int index) {
    return FadeInUp(
      duration: Duration(milliseconds: 500 + (index * 100)),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 6),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              // Present/Absent Indicator
              _buildPresentAbsentIndicator(record),
              SizedBox(width: 5),

              // Employee Name
              Expanded(
                flex: 2,
                child: Text(
                  record.employeeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Check-in with edit icon
              _buildTimeField(
                record,
                index,
                true,
                checkInControllers[index]!.text,
              ),
              SizedBox(width: 10),

              // Check-out with edit icon
              _buildTimeField(
                record,
                index,
                false,
                checkOutControllers[index]!.text,
              ),
              SizedBox(width: 10),

              // Overtime
              Expanded(
                child: Text(
                  record.isAbsent ? "Absent" : record.calculateOvertime(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: record.isAbsent ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the present/absent indicator.
  Widget _buildPresentAbsentIndicator(AttendanceRecord record) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: record.isAbsent
            ? Colors.red.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        record.isAbsent ? Icons.cancel : Icons.check_circle,
        color: record.isAbsent ? Colors.red : Colors.green,
      ),
    );
  }

  /// Builds a time field with an edit icon.
  Widget _buildTimeField(
      AttendanceRecord record,
      int index,
      bool isCheckIn,
      String currentTime,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          TimeOfDay? pickedTime = await pickTime(context, currentTime);
          if (pickedTime != null) {
            setState(() {
              if (isCheckIn) {
                checkInControllers[index]?.text =
                "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
              } else {
                checkOutControllers[index]?.text =
                "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
              }
            });
            _updateAttendance(record, index, isCheckIn);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 2,
          ),
          decoration: BoxDecoration(
            color: record.isAbsent
                ? Colors.grey.withOpacity(0.1)
                : Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isCheckIn ? record.formattedCheckIn : record.formattedCheckOut,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: record.isAbsent ? Colors.grey : Colors.blueAccent,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.edit,
                color: record.isAbsent ? Colors.grey : Colors.blueAccent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the bottom buttons for changing the date and managing employees.
  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              "Change Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageEmployeesScreen(),
                ),
              );
            },
            icon: Icon(Icons.group, color: Colors.white),
            label: Text(
              "Manage Employees",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Opens a time picker and returns the selected time.
  Future<TimeOfDay?> pickTime(BuildContext context, String currentTime) async {
    TimeOfDay initialTime;
    try {
      initialTime = TimeOfDay(
        hour: int.parse(currentTime.split(":")[0]),
        minute: int.parse(currentTime.split(":")[1]),
      );
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}