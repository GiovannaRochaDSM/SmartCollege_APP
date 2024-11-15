import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/task_page.dart';
import 'package:smart_college/app/pages/subject_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_college/app/pages/schedule_page.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_college/app/data/helpers/fetch_schedules.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';

class SubjectDetailPage extends StatefulWidget {
  final SubjectModel subject;

  const SubjectDetailPage({super.key, required this.subject});

  @override
  _SubjectDetailPageState createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _gradesController;
  late TextEditingController _absenceController;
  late TextEditingController _notesController;
  late Future<List<ScheduleModel>> _scheduleFuture;
  late IHttpClient _httpClient;
  Future<int>? _pendingOrOngoingTaskCount;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _acronymController = TextEditingController(text: widget.subject.acronym);
    _gradesController =
        TextEditingController(text: widget.subject.grades?.join(",") ?? '');
    _absenceController =
        TextEditingController(text: widget.subject.abscence?.toString() ?? '');
    _notesController = TextEditingController(text: widget.subject.notes ?? '');
    _scheduleFuture = ScheduleHelper.fetchSchedules();
    _pendingOrOngoingTaskCount =
        TaskHelper.countPendingOrOngoingTasks(subjectId: widget.subject.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acronymController.dispose();
    _gradesController.dispose();
    _absenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _exportSubjectNotes(SubjectModel subject) async {
    try {
      final String content = '''
        Matéria: ${subject.name}
        Acrônimo: ${subject.acronym}
        Anotações: ${subject.notes ?? 'N/A'}
      ''';
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      final file = File('$path/${subject.name}_Anotacoes.txt');
      await file.writeAsString(content);
      await _requestPermissions();
      await _showFileDialog(file);
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.generatedFileSuccess);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.generatedFileError);
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print('Permissão concedida!');
    } else {
      print('Permissão negada!');
    }
  }

  Future<void> _showFileDialog(File file) async {
    final params = SaveFileDialogParams(
      sourceFilePath: file.path,
      mimeTypesFilter: ['text/plain'],
      fileName: file.uri.pathSegments.last,
    );
    await FlutterFileDialog.saveFile(params: params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppNewColors.lightBlue,
        toolbarHeight: 65,
        title: TextField(
          controller: _nameController,
          style: AppNewTextStyles.balooTitle.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            setState(() {
              widget.subject.name = value;
            });
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAcronymAndScheduleCard(),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                _navigateToTasksPage(widget.subject.id);
              },
              child: FutureBuilder<int>(
                future: _pendingOrOngoingTaskCount,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildCard(
                      title: 'Tarefas',
                      content: Text('Carregando tarefas...'),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildCard(
                      title: 'Tarefas',
                      content: Text('Erro ao carregar as tarefas.'),
                    );
                  }

                  int taskCount = snapshot.data ?? 0;

                  return _buildCard(
                    title: 'Tarefas',
                    content: Text(
                        'Você possui $taskCount tarefas pendentes e/ou em andamento.',
                        style: AppNewTextStyles.smallExtraLight
                            .copyWith(color: AppNewColors.textGray)),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            _buildCard(
              title: 'Anotações',
              content: TextField(
                controller: _notesController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Digite suas anotações aqui...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                style: AppNewTextStyles.smallExtraLight,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryButton(
                  text: 'Salvar',
                  onPressed: () {
                    _updateSubject(context);
                  },
                  textColor: AppNewColors.lightBlue,
                  buttonColor: AppNewColors.white,
                  borderColor: AppNewColors.lightBlue,
                ),
                FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    _exportSubjectNotes(widget.subject);
                  },
                  child: Image.asset(
                    'assets/images/download.png',
                    width: 32,
                    height: 32,
                  ),
                  backgroundColor: AppNewColors.lightBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcronymAndScheduleCard() {
    return FutureBuilder<List<ScheduleModel>>(
      future: _scheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Erro ao carregar horários');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhum horário encontrado');
        }

        List<ScheduleModel> schedules = snapshot.data!;

        return Card(
          color: AppNewColors.lightGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .center,
              children: [
                Container(
                  width: 150,
                  child: _buildEditableField(
                    title: 'Sigla',
                    controller: _acronymController,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 150,
                  child: _buildField(
                    title: 'Horário',
                    value: _getScheduleDisplay(schedules),
                    isClickable: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getScheduleDisplay(List<ScheduleModel> schedules) {
    List<ScheduleModel> subjectSchedules = schedules.where((schedule) {
      return schedule.subjectId == widget.subject.id;
    }).toList();

    if (subjectSchedules.isNotEmpty) {
      String display = '';
      for (var schedule in subjectSchedules) {
        display +=
            '${schedule.room ?? 'N/A'} às ${schedule.time ?? 'N/A'}\n${schedule.dayWeek}';
      }
      return display.trim();
    } else {
      return 'Nenhum horário encontrado para esta matéria.';
    }
  }

  Widget _buildEditableField(
      {required String title, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppNewTextStyles.poppinsMedium
                .copyWith(color: AppNewColors.textGray)),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          decoration: const InputDecoration(border: InputBorder.none),
          style: AppNewTextStyles.smallExtraLight
              .copyWith(color: AppNewColors.textGray),
        ),
      ],
    );
  }

  Widget _buildField(
      {required String title,
      required String value,
      bool isClickable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppNewTextStyles.poppinsMedium
                .copyWith(color: AppNewColors.textGray)),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: isClickable ? () => _navigateToSchedulePage() : null,
          child: Container(
            height: 55,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Sala: ',
                    style: AppNewTextStyles.smallExtraLight.copyWith(
                      color: isClickable
                          ? AppNewColors.textGray
                          : AppNewColors.textGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppNewTextStyles.smallExtraLight.copyWith(
                      color: isClickable
                          ? AppNewColors.black
                          : AppNewColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSchedulePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      color: AppNewColors.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppNewTextStyles.poppinsMedium.copyWith(
                color: AppNewColors.textGray,
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }

  void _navigateToTasksPage(String subjectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(subjectId: subjectId),
      ),
    );
  }

  void _updateSubject(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newAcronym = _acronymController.text;
      List<int>? newGrades;
      int? newAbsence;
      String? newNotes = _notesController.text;

      if (_gradesController.text.isNotEmpty) {
        newGrades = _gradesController.text.split(',').map((grade) {
          return int.parse(grade.trim());
        }).toList();
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
        notes: newNotes,
      );

      await _performUpdate(updatedSubject);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectUpdatedSuccess);

      _updateAndReloadPage();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectUpdatedError);
    }
  }

  Future<void> _performUpdate(SubjectModel updatedSubject) async {
    final SubjectRepository subjectRepository = SubjectRepository(client: _httpClient);
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    await subjectRepository.updateSubject(updatedSubject, token);
    setState(() {});
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SubjectPage(),
      ),
    );
  }
}
