import '../domain/tender_model.dart';
import 'package:uuid/uuid.dart';

class MockTenders {
  static final List<Tender> list = [
    Tender(
      id: const Uuid().v4(),
      title: 'Procurement of 500 Laptops for Higher Education Institutions',
      category: 'IT Equipment',
      organization: 'Ministry of Education',
      deadline: DateTime.now().add(const Duration(days: 15)),
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      cpoAmount: 50000,
      status: 'OPEN',
      minGrade: 'N/A',
      location: 'Addis Ababa',
    ),
    Tender(
      id: const Uuid().v4(),
      title: 'Construction of G+4 Mixed Use Building',
      category: 'Construction',
      organization: 'Oromia Roads Authority',
      deadline: DateTime.now().add(const Duration(days: 5)),
      postedDate: DateTime.now().subtract(const Duration(days: 10)),
      cpoAmount: 200000,
      status: 'OPEN',
      minGrade: 'GC-3',
      location: 'Adama',
    ),
    Tender(
      id: const Uuid().v4(),
      title: 'Supply of Office Furniture and Fixtures',
      category: 'Furniture',
      organization: 'Commercial Bank of Ethiopia',
      deadline: DateTime.now().add(const Duration(days: 20)),
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      cpoAmount: 15000,
      status: 'OPEN',
      minGrade: 'N/A',
      location: 'Addis Ababa',
    ),
    Tender(
      id: const Uuid().v4(),
      title: 'Consultancy Service for Software Development',
      category: 'Software',
      organization: 'Ethio Telecom',
      deadline: DateTime.now().add(const Duration(days: 2)),
      postedDate: DateTime.now().subtract(const Duration(days: 12)),
      cpoAmount: null, // "1% of bid"
      status: 'OPEN',
      minGrade: 'N/A',
      location: 'Addis Ababa',
    ),
     Tender(
      id: const Uuid().v4(),
      title: 'Supply of Rebar (Reinforcement Bars) Grade 60',
      category: 'Construction Material',
      organization: 'Defense Construction Enterprise',
      deadline: DateTime.now().add(const Duration(hours: 18)),
      postedDate: DateTime.now().subtract(const Duration(days: 14)),
      cpoAmount: 500000,
      status: 'OPEN',
      minGrade: 'N/A',
      location: 'Dese',
    ),
  ];
}
