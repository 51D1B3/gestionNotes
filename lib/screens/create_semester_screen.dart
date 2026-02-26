
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class CreateSemesterScreen extends StatefulWidget {
  final bool hasExistingSemesters;

  const CreateSemesterScreen({super.key, required this.hasExistingSemesters});

  @override
  _CreateSemesterScreenState createState() => _CreateSemesterScreenState();
}

class _CreateSemesterScreenState extends State<CreateSemesterScreen> {
  late final PageController _pageController;
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedLicence;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedSemesterName;

  List<String> _titles = [];
  List<Widget> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupPages();
  }

  void _setupPages() {
      if (widget.hasExistingSemesters) {
        _pages = [_buildLicencePage(), _buildSemesterPage()];
        _titles = ["Quelle est votre licence ?", "Choisissez le semestre"];
      } else {
        _pages = [_buildLicencePage(), _buildFacultyPage(), _buildDepartmentPage(), _buildSemesterPage()];
        _titles = ["Quelle est votre licence ?", "Votre faculté ?", "Quel est votre département ?", "Choisissez le semestre"];
      }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _onLicenceSelected(String licence) {
    setState(() {
      _selectedLicence = licence;
      // Reconstruire la page du semestre pour mettre à jour la liste
      if (widget.hasExistingSemesters) {
         _pages[1] = _buildSemesterPage();
      } else {
         _pages[3] = _buildSemesterPage();
      }
    });
    _nextPage();
  }

  void _onFacultySelected(String faculty) {
    setState(() {
       _selectedFaculty = faculty;
       // Reconstruire la page des départements
       _pages[2] = _buildDepartmentPage();
    });
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
    if (widget.hasExistingSemesters && _selectedLicence != null && _selectedSemesterName != null) {
      final existingSemester = await _firestoreService.getSemesters().first;
      if (existingSemester.docs.isNotEmpty) {
        final data = existingSemester.docs.first.data() as Map<String, dynamic>;
        _selectedFaculty = data['faculty'];
        _selectedDepartment = data['department'];
      }
    }

    if (_selectedLicence != null && _selectedFaculty != null && _selectedDepartment != null && _selectedSemesterName != null) {
      await _firestoreService.addSemester(
        _selectedSemesterName!,
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
    if (_selectedFaculty == null) return const Center(child: Text("Sélectionnez une faculté."));
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('faculties').where('name', isEqualTo: _selectedFaculty).limit(1).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Aucun département."));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles.isNotEmpty ? _titles[_currentPage] : ""),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.1), _pages[index]]),
          );
        },
      ),
    );
  }
}
