class AttendanceRecord {
  final String studentId;
  final String classId;
  final DateTime checkInTime;
  final double latitude;
  final double longitude;
  final String? mood;
  final String? reflection;

  const AttendanceRecord({
    required this.studentId,
    required this.classId,
    required this.checkInTime,
    required this.latitude,
    required this.longitude,
    this.mood,
    this.reflection,
  });
}
