import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';

class NewSubjectModal extends StatefulWidget {
  @override
  _NewSubjectModalState createState() => _NewSubjectModalState();
}

class _NewSubjectModalState extends State<NewSubjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _gradesController;
  late TextEditingController _absenceController;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _acronymController = TextEditingController();
    _gradesController = TextEditingController();
    _absenceController = TextEditingController();

    _httpClient = HttpClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acronymController.dispose();
    _gradesController.dispose();
    _absenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova Matéria',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B61C2),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _acronymController,
              decoration: const InputDecoration(labelText: 'Sigla'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gradesController,
              decoration: const InputDecoration(labelText: 'Notas'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _absenceController,
              decoration: const InputDecoration(labelText: 'Faltas'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _addSubject(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubject(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newAcronym = _acronymController.text;
      List<int>? newGrades;
      int? newAbsence;

      if (_gradesController.text.isNotEmpty) {
        newGrades = _gradesController.text
            .split(',')
            .map((grade) => int.parse(grade.trim()))
            .toList();
      }

      if (_absenceController.text.isNotEmpty) {
        newAbsence = int.parse(_absenceController.text);
      }

      SubjectModel newSubject = SubjectModel(
        id: '',
        name: newName,
        acronym: newAcronym,
        grades: newGrades,
        abscence: newAbsence,
      );

      await _performAdd(newSubject);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectAddError);
    }
  }

  Future<void> _performAdd(SubjectModel newSubject) async {
    final SubjectRepository subjectRepository =
        SubjectRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await subjectRepository.addSubject(newSubject, token);
  }
}

void showNewSubjectModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: NewSubjectModal(),
      );
    },
  );
}
