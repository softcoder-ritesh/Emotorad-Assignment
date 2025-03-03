class Employee {
  final String name;
  final String date;

  Employee({required this.name, required this.date});

  // Convert the employee to a list of strings for the sheet
  List<String> toList() {
    return [name, date];
  }

  // Factory constructor to create an instance from a list of strings
  factory Employee.fromList(List<String> row) {
    return Employee(
      name: row[0],
      date: row[1],
    );
  }
}