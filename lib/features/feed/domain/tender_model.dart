class Tender {
  final String id;
  final String title;
  final String category;
  final String organization;
  final DateTime deadline;
  final DateTime postedDate;
  final double? cpoAmount; // Null if not specified or varies
  final String status; // Open, Closed
  final String minGrade; // e.g. GC-5
  final String location;
  
  Tender({
    required this.id,
    required this.title,
    required this.category,
    required this.organization,
    required this.deadline,
    required this.postedDate,
    this.cpoAmount,
    required this.status,
    required this.minGrade,
    required this.location,
  });
}
