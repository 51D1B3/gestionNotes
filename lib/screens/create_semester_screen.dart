
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class CreateSemesterScreen extends StatefulWidget {
  const CreateSemesterScreen({super.key});

  @override
  _CreateSemesterScreenState createState() => _CreateSemesterScreenState();
}

class _CreateSemesterScreenState extends State<CreateSemesterScreen> {
  final PageController _pageController = PageController();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedLicence;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedSemesterName;

  // Titres pour chaque étape
  final List<String> _titles = [
    "Licence ",
    "Faculté ",
    "Département ",
    "Semestre",
  ];
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < _titles.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _onLicenceSelected(String licence) {
    setState(() => _selectedLicence = licence);
    _nextPage();
  }

  void _onFacultySelected(String faculty) {
    setState(() => _selectedFaculty = faculty);
    _nextPage();
  }

  void _onDepartmentSelected(String department) {
    setState(() => _selectedDepartment = department);
    _nextPage();
  }

  void _onSemesterSelected(String semester) {
    setState(() => _selectedSemesterName = semester);
    _createSemester();
  }

  void _createSemester() async {
    if (_selectedLicence != null &&
        _selectedFaculty != null &&
        _selectedDepartment != null &&
        _selectedSemesterName != null) {

      String semesterDisplayName = "$_selectedSemesterName - $_selectedDepartment";

      await _firestoreService.addSemester(
        semesterDisplayName,
        _selectedFaculty!,
        _selectedDepartment!,
        _selectedLicence!,
      );
      Navigator.pop(context);
    }
  }

  Widget _buildSelectionList({required List<String> items, required ValueChanged<String> onItemSelected}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            title: Center(child: Text(items[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            onTap: () => onItemSelected(items[index]),
          ),
        );
      },
    );
  }

  Widget _buildLicencePage() {
    return _buildSelectionList(
      items: ["Licence 1", "Licence 2", "Licence 3"],
      onItemSelected: _onLicenceSelected,
    );
  }

  Widget _buildFacultyPage() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('faculties').orderBy('name').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final faculties = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
        return _buildSelectionList(items: faculties, onItemSelected: _onFacultySelected);
      },
    );
  }

  Widget _buildDepartmentPage() {
    if (_selectedFaculty == null) return const Center(child: Text("Veuillez retourner en arrière et sélectionner une faculté."));

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('faculties').where('name', isEqualTo: _selectedFaculty).limit(1).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Aucun département trouvé."));

        final departmentsData = snapshot.data!.docs.first.get('departments') as List<dynamic>?;
        final departments = departmentsData?.map((d) => d.toString()).toList() ?? [];

        return _buildSelectionList(items: departments, onItemSelected: _onDepartmentSelected);
      },
    );
  }

  Widget _buildSemesterPage() {
    List<String> semesters = [];
    if (_selectedLicence == "Licence 1") semesters = ["Semestre 1", "Semestre 2"];
    else if (_selectedLicence == "Licence 2") semesters = ["Semestre 3", "Semestre 4"];
    else if (_selectedLicence == "Licence 3") semesters = ["Semestre 5", "Semestre 6"];

    return _buildSelectionList(items: semesters, onItemSelected: _onSemesterSelected);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildLicencePage(),
      _buildFacultyPage(),
      _buildDepartmentPage(),
      _buildSemesterPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentPage]),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                },
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
            setState(() {
                _currentPage = index;
            });
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    pages[index],
                ]),
          );
        },
      ),
    );
  }
}
