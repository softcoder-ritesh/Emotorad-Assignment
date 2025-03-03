import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/attendance/attendance_bloc.dart';
import 'presentation/bloc/attendance/attendance_event.dart';
import 'presentation/screens/home_page.dart';
import 'data/repositories/attendance_repository.dart';
import 'core/services/google_sheets_service.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final googleSheetsService = GoogleSheetsService();
  await googleSheetsService.initialize(); // Ensure Google Sheets is initialized

  final attendanceRepository = AttendanceRepository(googleSheetsService);

  runApp(MyApp(attendanceRepository));
}

class MyApp extends StatelessWidget {
  final AttendanceRepository attendanceRepository;

  const MyApp(this.attendanceRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => attendanceRepository, // Pass the repository directly
      child: BlocProvider(
        create: (context) => AttendanceBloc(
          context.read<AttendanceRepository>(), // ✅ Pass the correct dependency
        )..add(
          FetchAttendance(DateFormat('yyyy-MM-dd').format(DateTime.now())), // ✅ Fix DateTime issue
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Attendance Manager',
          theme: ThemeData(primarySwatch: Colors.blue),
          home:  HomeScreen(),
        ),
      ),
    );
  }
}
