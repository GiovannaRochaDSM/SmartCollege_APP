import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/widgets/texts/custom_dropdown.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/common/widgets/texts/custom_text_field.dart'; // Importando o widget CustomTextField // Importando o widget CustomDropdown

class EditTaskModal extends StatefulWidget {
  final TaskModel task;

  const EditTaskModal({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskModalState createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedSubjectId;
  String? _selectedCategory;
  DateTime? _selectedDate;
  List<SubjectModel> _subjects = []; // Inicializar como lista vazia
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedSubjectId = widget.task.subjectId;
    _selectedCategory = widget.task.category;
    _selectedDate = widget.task.deadline;
    _httpClient = HttpClient();

    // Chamada para buscar matérias
    _fetchSubjects();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Nome',
              // keyboardType: TextInputType.text,
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Descrição',
              // keyboardType: TextInputType.text,
            ),
            SizedBox(height: 12),
            CustomDropdown(
              value: _selectedPriority,
              items: ['Baixa', 'Média', 'Alta'],
              labelText: 'Prioridade',
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            SizedBox(height: 12),
            CustomDropdown(
              value: _selectedCategory,
              items: ['Atividade', 'Avaliação', 'Estudo'],
              labelText: 'Categoria',
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 12),
            CustomDropdown(
              value: _selectedStatus,
              items: ['Pendente', 'Em progresso', 'Concluída'],
              labelText: 'Status',
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              items: _subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id.toString(),
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                });
              },
              decoration: InputDecoration(labelText: 'Matéria'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Selecione uma data limite'
                        : 'Data Limite: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _updateTask(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSubjects() async {
    try {
      List<SubjectModel> subjects = await SubjectHelper.fetchSubjects();
      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      print('Failed to fetch subjects: $e');
      // Tratar erro ao buscar matérias
    }
  }

  Future<void> _updateTask(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newDescription = _descriptionController.text;
      String newPriority = _selectedPriority ?? 'Média';
      String newStatus = _selectedStatus ?? 'Pendente';
      String newSubjectId = _selectedSubjectId ?? '';
      String newCategory = _selectedCategory ?? '';
      DateTime? newDeadline = _selectedDate;

      TaskModel updatedTask = TaskModel(
        id: widget.task.id,
        name: newName,
        description: newDescription,
        priority: newPriority,
        status: newStatus,
        subjectId: newSubjectId,
        category: newCategory,
        deadline: newDeadline,
      );

      await _performUpdate(updatedTask);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.taskUpdatedSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.taskUpdatedError);
    }
  }

  Future<void> _performUpdate(TaskModel updatedTask) async {
    final TaskRepository taskRepository =
        TaskRepository(client: _httpClient);
    String? token =
        await AppStrings.secureStorage.read(key: 'token');
    await taskRepository.updateTask(updatedTask, token);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

void showEditTaskPage(BuildContext context, TaskModel task) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return EditTaskModal(task: task);
      },
    ),
  );
}
