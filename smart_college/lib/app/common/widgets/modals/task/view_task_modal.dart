import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/task_model.dart';

class ViewTaskModal extends StatelessWidget {
  final TaskModel task;

  const ViewTaskModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Visualizar Tarefa',
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
            _buildInfoField('Nome', task.name),
            _buildInfoField('Descrição', task.description ?? 'Sem descrição'),
            _buildInfoField('Prioridade', task.priority),
            _buildInfoField('Prazo', task.deadline?.toString() ?? 'Sem prazo'),
            _buildInfoField('Status', task.status),
            _buildInfoField('Matéria', task.subjectName ?? 'Sem matéria'), 
            _buildInfoField('Categoria', task.category ?? 'Sem categoria'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
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