import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceLoading()) {
    on<FetchAttendance>(_onFetchAttendance);
    on<UpdateAttendance>(_onUpdateAttendance);
    on<AddEmployee>(_onAddEmployee);
    on<RemoveEmployee>(_onRemoveEmployee);
  }

  void _onFetchAttendance(FetchAttendance event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final records = await repository.fetchAttendance(event.date);

      if (records.isEmpty) {
        // Fetch default data (March 1, 2025) if no records are found
        final defaultDate = "2025-03-01";
        final defaultRecords = await repository.fetchAttendance(defaultDate);

        // Set default check-in and check-out times for default records
        final updatedDefaultRecords = defaultRecords.map((record) {
          return record.copyWith(
            checkIn: "09:00",
            checkOut: "18:00",
          );
        }).toList();

        emit(AttendanceLoaded([], defaultRecords: updatedDefaultRecords));
      } else {
        emit(AttendanceLoaded(records));
      }
    } catch (e) {
      print("Error fetching attendance: $e"); // Debug print
      emit(AttendanceError("Failed to load attendance."));
    }
  }

  void _onUpdateAttendance(UpdateAttendance event, Emitter<AttendanceState> emit) async {
    try {
      await repository.updateAttendance(event.record);
      final records = await repository.fetchAttendance(event.record.date);
      emit(AttendanceLoaded(records));
    } catch (e) {
      emit(AttendanceError("Failed to update attendance."));
    }
  }
  void _onAddEmployee(AddEmployee event, Emitter<AttendanceState> emit) async {
    try {
      await repository.addEmployee(event.employeeName);
      final records = await repository.fetchAttendance(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      emit(AttendanceLoaded(records));
    } catch (e) {
      emit(AttendanceError("Failed to add employee."));
    }
  }

  void _onRemoveEmployee(RemoveEmployee event, Emitter<AttendanceState> emit) async {
    try {
      await repository.removeEmployee(event.employeeName);
      final records = await repository.fetchAttendance(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      emit(AttendanceLoaded(records));
    } catch (e) {
      emit(AttendanceError("Failed to remove employee."));
    }
  }
}