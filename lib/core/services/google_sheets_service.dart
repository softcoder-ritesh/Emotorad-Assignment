import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class GoogleSheetsService {
  bool isInitialized = false; // Track initialization
  final String spreadsheetId = "1GSqmo5XRKvicN66iuzjFjTntT-SVHJPzAT-_GYwhWSg";
  sheets.SheetsApi? sheetsApi; // Nullable to avoid late initialization error

  /// Initialize Google Sheets API**
  Future<void> initialize() async {
    if (isInitialized) return; // Prevent multiple initializations

    try {
      final credentials = jsonDecode(await rootBundle.loadString('assets/credentials.json'));

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentials),
        [sheets.SheetsApi.spreadsheetsScope], // Scope for Google Sheets
      );

      sheetsApi = sheets.SheetsApi(client); // Initialize API
      isInitialized = true;
      print("Google Sheets initialized successfully!");
    } catch (e) {
      print("Error initializing Google Sheets: $e");
      throw Exception("Failed to initialize Google Sheets");
    }
  }

  /// Fetch Attendance Data**
  Future<List<List<dynamic>>> fetchAttendanceData() async {
    if (sheetsApi == null) {
      throw Exception("GoogleSheetsService is not initialized.");
    }

    try {
      final response = await sheetsApi!.spreadsheets.values.get(
        spreadsheetId,
        "Attendance!A:D",
      );

      print("Fetched Data: ${response.values}");
      return response.values ?? [];
    } catch (e) {
      print("Error fetching attendance data: $e");
      throw Exception("Failed to fetch attendance data.");
    }
  }

  /// **Update Attendance**
  Future<void> updateAttendance(String employeeName, String checkIn, String checkOut, String date) async {
    if (sheetsApi == null) {
      throw Exception("GoogleSheetsService has not been initialized. Call initialize() first.");
    }

    // Fetch the current data to find the row index
    final data = await fetchAttendanceData();
    int rowIndex = -1;

    for (int i = 0; i < data.length; i++) {
      if (data[i].length >= 4 && data[i][0] == employeeName && data[i][3] == date) {
        rowIndex = i + 1; // Rows are 1-indexed in Google Sheets
        break;
      }
    }

    if (rowIndex == -1) {
      throw Exception("Row not found for the given employee and date.");
    }

    // Update the specific row
    await sheetsApi!.spreadsheets.values.update(
      sheets.ValueRange(values: [
        [employeeName, checkIn, checkOut, date]
      ]),
      spreadsheetId,
      "Attendance!A$rowIndex:D$rowIndex",
      valueInputOption: "USER_ENTERED",
    );

    print("Attendance updated successfully!");
  }
  Future<void> addEmployee(String employeeName, String date) async {
    if (sheetsApi == null) {
      throw Exception("GoogleSheetsService is not initialized.");
    }
    await sheetsApi!.spreadsheets.values.append(
      sheets.ValueRange(values: [
        [employeeName, "09:00", "18:00", date]
      ]),
      spreadsheetId,
      "Attendance!A:D",
      valueInputOption: "USER_ENTERED",
    );
  }
  Future<void> removeEmployee(String employeeName) async {
    if (sheetsApi == null) {
      throw Exception("GoogleSheetsService is not initialized.");
    }
    final data = await fetchAttendanceData();
    for (int i = 0; i < data.length; i++) {
      if (data[i].length >= 4 && data[i][0] == employeeName) {
        await deleteRow(data[i]);
        break;
      }
    }
  }
  /// **Delete a Row**
  Future<void> deleteRow(List<dynamic> rowToDelete) async {
    if (sheetsApi == null) {
      throw Exception("GoogleSheetsService has not been initialized. Call initialize() first.");
    }

    // Fetch all rows from the sheet
    final data = await fetchAttendanceData();

    // Find the index of the row to delete
    int rowIndex = -1;
    for (int i = 0; i < data.length; i++) {
      if (data[i].toString() == rowToDelete.toString()) {
        rowIndex = i + 1; // Rows are 1-indexed in Google Sheets
        break;
      }
    }

    if (rowIndex == -1) {
      throw Exception("Row not found in the sheet.");
    }

    // Create a DimensionRange to specify the row to delete
    final dimensionRange = sheets.DimensionRange()
      ..sheetId = 0 // Assuming the sheet ID is 0
      ..dimension = "ROWS"
      ..startIndex = rowIndex - 1 // Convert to 0-based index
      ..endIndex = rowIndex; // End index is exclusive

    // Create a DeleteDimensionRequest
    final deleteRequest = sheets.DeleteDimensionRequest()
      ..range = dimensionRange;

    // Create a Request object
    final request = sheets.Request()
      ..deleteDimension = deleteRequest;

    // Create a BatchUpdateSpreadsheetRequest
    final batchUpdateRequest = sheets.BatchUpdateSpreadsheetRequest()
      ..requests = [request];

    // Execute the batch update
    await sheetsApi!.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);

    print("Row deleted successfully!");
  }
}