import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_college/app/pages/task_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/pages/subject/subject_page.dart';
import 'package:smart_college/app/data/stores/schedule_store.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_college/app/data/helpers/fetch_schedules.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/subject_repository.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_primary_button.dart';
import 'package:smart_college/app/common/widgets/modals/schedule/new_schedule_modal.dart';
import 'package:smart_college/app/common/widgets/modals/schedule/edit_schedule_modal.dart';

class DetailSubjectPage extends StatefulWidget {
  final SubjectModel subject;

  const DetailSubjectPage({super.key, required this.subject});

  @override
  _DetailSubjectPageState createState() => _DetailSubjectPageState();
}

class _DetailSubjectPageState extends State<DetailSubjectPage> {
  late TextEditingController _nameController;
  late TextEditingController _acronymController;
  late TextEditingController _notesController;
  late Future<List<ScheduleModel>> _scheduleFuture;
  late IHttpClient _httpClient;
  Future<int>? _pendingOrOngoingTaskCount;
  final ScheduleStore store = ScheduleStore(
    repository: ScheduleRepository(
      client: HttpClient(),
    ),
  );

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _httpClient = HttpClient();
    _nameController = TextEditingController(text: widget.subject.name);
    _acronymController = TextEditingController(text: widget.subject.acronym);
    _notesController = TextEditingController(text: widget.subject.notes ?? '');
    _scheduleFuture = ScheduleHelper.fetchSchedules();
    _pendingOrOngoingTaskCount = TaskHelper.countPendingOrOngoingTasks(subjectId: widget.subject.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _acronymController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.permissioGranted);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.permissioDenied);
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

  void _updateSubject(BuildContext context) async {
    try {
      String newName = _nameController.text;
      String newAcronym = _acronymController.text;
      String newNotes = _notesController.text;

      SubjectModel updatedSubject = SubjectModel(
          id: widget.subject.id, 
          name: newName, 
          acronym: newAcronym,
          notes: newNotes
      );

      await _performUpdate(updatedSubject);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectUpdatedSuccess);

      _updateAndReloadPage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.subjectUpdatedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppNewColors.lightBlue,
        toolbarHeight: 78,
        title: TextField(
          controller: _nameController,
          style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.white),
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
        iconTheme: const IconThemeData(color: AppColors.white, size: 30),
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
                      content: const Text('Carregando tarefas...'),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildCard(
                      title: 'Tarefas',
                      content: const Text('Erro ao carregar as tarefas.'),
                    );
                  }

                  int taskCount = snapshot.data ?? 0;

                  return _buildCard(
                    title: 'Tarefas',
                    content: Text(
                        'Você possui $taskCount tarefas pendentes e/ou Em progresso.',
                        style: AppNewTextStyles.smallExtraLight.copyWith(color: AppNewColors.textGray)),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildCard(
              title: 'Anotações',
              content: TextField(
                controller: _notesController,
                maxLines: 15,
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
                CustomPrimaryButton(
                  text: 'Salvar',
                  onPressed: () {
                    _updateSubject(context);
                  },
                  textColor: AppNewColors.lightBlue,
                  buttonColor: AppNewColors.white,
                  borderColor: AppNewColors.lightBlue,
                ),
                FloatingActionButton(
                  elevation: 0,
                  shape: const CircleBorder(),
                  onPressed: () {
                    _exportSubjectNotes(widget.subject);
                  },
                  backgroundColor: AppNewColors.lightBlue,
                  child: Image.asset(
                    'assets/images/download.png',
                    width: 32,
                    height: 32,
                  ),
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

        String scheduleDisplay = 'Nenhum horário encontrado';
        bool showAddScheduleIcon = false;
        bool showDeleteScheduleIcon = false;
        ScheduleModel? scheduleToDelete;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<ScheduleModel> subjectSchedules =
              snapshot.data!.where((schedule) {
            return schedule.subjectId == widget.subject.id;
          }).toList();

          if (subjectSchedules.isNotEmpty) {
            scheduleDisplay = _getScheduleDisplay(subjectSchedules);
            showDeleteScheduleIcon = true;
            scheduleToDelete = subjectSchedules.first;
          } else {
            scheduleDisplay = 'Nenhum horário encontrado para esta matéria.';
            showAddScheduleIcon = true;
          }
        } else {
          showAddScheduleIcon = true;
        }

        return Card(
          color: AppNewColors.lightGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: _buildEditableField(
                    title: 'Sigla',
                    controller: _acronymController,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  child: GestureDetector(
                    onTap: () {
                      if (scheduleToDelete != null) {
                        showEditScheduleModal(context, scheduleToDelete);
                      }
                    },
                    child: _buildField(
                      title: 'Horário',
                      value: scheduleDisplay,
                      isClickable: true,
                    ),
                  ),
                ),
                if (showAddScheduleIcon)
                  IconButton(
                    icon: const Icon(Icons.add, color: AppNewColors.lightBlue),
                    onPressed: () {
                      showNewScheduleModal(context, widget.subject.id);
                    },
                  ),
                if (showDeleteScheduleIcon && scheduleToDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppNewColors.red),
                    onPressed: () {
                      _deleteSchedule(scheduleToDelete!.id);
                    },
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
      return display;
    } else {
      return 'Nenhum horário encontrado para esta matéria.';
    }
  }

  Widget _buildEditableField({required String title, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppNewTextStyles.poppinsMedium.copyWith(color: AppNewColors.textGray)),
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

  Widget _buildField({required String title, required String value, bool isClickable = false, String? scheduleId}) {
    bool isScheduleNotEmpty = value != 'Nenhum horário encontrado' && value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppNewTextStyles.poppinsMedium.copyWith(color: AppNewColors.textGray)),
        const SizedBox(height: 2),
        GestureDetector(
          child: Container(
            height: 55,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  if (isScheduleNotEmpty)
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
              style: AppNewTextStyles.poppinsMedium.copyWith(color: AppNewColors.textGray),
            ),
            content,
          ],
        ),
      ),
    );
  }

  void showNewScheduleModal(BuildContext context, String subjectId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            color: AppNewColors.white,
            constraints: const BoxConstraints(maxHeight: 600),
            child: NewScheduleModal(
              parentContext: context,
              subjectId: subjectId,
            ),
          ),
        );
      },
    ).whenComplete(() {
      _updateAndReloadPage();
    });
  }

  void _navigateToTasksPage(String subjectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(subjectId: subjectId),
      ),
    );
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

  void _deleteSchedule(String subjectId) {
    store.deleteSchedule(subjectId).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectDeletedSuccess);

      setState(() {
        _scheduleFuture = ScheduleHelper.fetchSchedules();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.subjectDeletedError);
    });
  }

  void showEditScheduleModal(
      BuildContext context, ScheduleModel scheduleToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            color: AppNewColors.white,
            constraints: const BoxConstraints(maxHeight: 600),
            child: EditScheduleModal(
              schedule: scheduleToEdit,
            ),
          ),
        );
      },
    ).whenComplete(() {
      _updateAndReloadPage();
    });
  }
}