// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';

class EditSubjectModal extends StatefulWidget {
  final SubjectModel subject;

  const EditSubjectModal({super.key, required this.subject});

  @override
  _EditSubjectModalState createState() => _EditSubjectModalState();
}

class _EditSubjectModalState extends State<EditSubjectModal> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _gradesController;
  late TextEditingController _absenceController;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _acronymController = TextEditingController(text: widget.subject.acronym);
    _gradesController =
        TextEditingController(text: widget.subject.grades?.join(",") ?? '');
    _absenceController =
        TextEditingController(text: widget.subject.abscence?.toString() ?? '');

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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Matéria',
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
              onPressed: () {
                _updateSubject(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSubject(BuildContext context) async {
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

      SubjectModel updatedSubject = SubjectModel(
        id: widget.subject.id,
        name: newName,
        acronym: newAcronym,
        grades: newGrades,
        abscence: newAbsence,
      );

      await _performUpdate(updatedSubject);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('matéria atualizada com sucesso.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar matéria.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _performUpdate(SubjectModel updatedSubject) async {
    final SubjectRepository subjectRepository =
        SubjectRepository(client: _httpClient);
    await subjectRepository.updateSubject(updatedSubject);
    setState(() {});
  }
}

void showEditSubjectModal(BuildContext context, SubjectModel subject) {
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
        child: EditSubjectModal(subject: subject),
      );
    },
  );
}
