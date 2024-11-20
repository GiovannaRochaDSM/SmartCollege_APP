import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';

class EditTaskModal extends StatefulWidget {
  final TaskModel task;

  const EditTaskModal({super.key, required this.task});

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
  List<SubjectModel> _subjects = [];
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedSubjectId = widget.task.subjectId;
    _selectedCategory = widget.task.category;
    _selectedDate = widget.task.deadline;
    _httpClient = HttpClient();

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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar tarefa',
              style: AppNewTextStyles.balooTitle
                  .copyWith(color: AppNewColors.lightBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Nome',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descrição',
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Prioridade',
              value: _selectedPriority,
              items: ['Baixa', 'Média', 'Alta'],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Categoria',
              value: _selectedCategory,
              items: ['Atividade', 'Avaliação', 'Estudo'],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Status',
              value: _selectedStatus,
              items: ['Pendente', 'Em progresso', 'Concluída'],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 20),
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
              decoration: InputDecoration(
                labelText: 'Matéria',
                labelStyle:
                    AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.darkGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.darkGray, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Selecione uma data limite'
                        : 'Data Limite: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: AppNewTextStyles.smallPoppinsRegular.copyWith(
                      color: AppNewColors.textGray,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: AppNewColors.lightBlue),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomElevatedButton(
              text: 'Salvar',
              onPressed: () async {
                await _updateTask(context);
              },
              buttonColor: AppNewColors.lightBlue,
              borderColor: AppNewColors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppNewTextStyles.mediumExtraLight
            .copyWith(color: AppNewColors.textGray),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppNewTextStyles.mediumExtraLight
            .copyWith(color: AppNewColors.textGray),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
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
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskUpdatedError);
    }
  }

  Future<void> _performUpdate(TaskModel updatedTask) async {
    final TaskRepository taskRepository = TaskRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await taskRepository.updateTask(updatedTask, token);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime firstDate = DateTime.now();

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
