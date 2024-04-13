import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/subject_model.dart';

class ViewSubjectModal extends StatelessWidget {
  final SubjectModel subject;

  const ViewSubjectModal({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Visualizar Matéria',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4B61C2),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoField('Nome', subject.name),
            _buildInfoField('Sigla', subject.acronym),
            _buildInfoField('Notas',
                subject.grades?.join(", ") ?? 'Nenhuma nota registrada'),
            _buildInfoField('Faltas',
                subject.abscence?.toString() ?? 'Nenhuma falta registrada'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fechar o modal
          },
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
