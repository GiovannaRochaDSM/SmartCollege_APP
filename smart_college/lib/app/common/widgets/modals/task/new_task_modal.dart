import 'package:flutter/material.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/data/models/subject_model.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedSubjectId;
  String? _selectedCategory;
  DateTime? _selectedDate;
  List<SubjectModel> _subjects = [];
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _httpClient = HttpClient();

    // Carregar matérias disponíveis ao iniciar a página
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
        title: const Text('Nova Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: ['Baixa', 'Média', 'Alta'].map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Prioridade'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Atividade', 'Avaliação', 'Estudo'].map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: ['Pendente', 'Em progresso', 'Concluída'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              items: _subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Matéria'),
            ),
            const SizedBox(height: 12),
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
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _addTask(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSubjects() async {
    List<SubjectModel> subjects = await SubjectHelper.fetchSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _addTask(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newDescription = _descriptionController.text;
      String newPriority = _selectedPriority ?? 'Média';
      String newStatus = _selectedStatus ?? 'Pendente';
      String newSubjectId = _selectedSubjectId ?? '';
      String newCategory = _selectedCategory ?? '';
      DateTime? newDeadline = _selectedDate;

      TaskModel newTask = TaskModel(
        id: '',
        name: newName,
        description: newDescription,
        priority: newPriority,
        status: newStatus,
        subjectId: newSubjectId,
        category: newCategory,
        deadline: newDeadline,
      );

      await _performAdd(newTask);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskAddSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskAddError);
    }
  }

  Future<void> _performAdd(TaskModel newTask) async {
    final TaskRepository taskRepository = TaskRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await taskRepository.addTask(newTask, token);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

void showNewTaskPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return const NewTaskPage();
      },
    ),
  );
}