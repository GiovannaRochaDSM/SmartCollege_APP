import 'package:flutter/material.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/modals/schedule/edit_schedule_modal.dart';
import 'package:smart_college/app/common/widgets/modals/schedule/new_schedule_modal.dart';
import 'package:smart_college/app/data/helpers/fetch_schedules.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';
import 'package:smart_college/app/data/stores/schedule_store.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/services/auth_service.dart';

class SchedulePage extends StatefulWidget {
  final String? subjectId;

  const SchedulePage({Key? key, this.subjectId}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late Future<List<ScheduleModel>> futureSchedules;
  final ScheduleStore store = ScheduleStore(
    repository: ScheduleRepository(
      client: HttpClient(),
    ),
  );
  String? selectedSubjectId;
  List<SubjectModel> subjects = [];

  @override
  void initState() {
    super.initState();
    futureSchedules = ScheduleHelper.fetchSchedules();
    _fetchSubjects();
    selectedSubjectId= widget.subjectId;
  }

  Future<void> _fetchSubjects() async {
    List<SubjectModel> fetchedSubjects = await SubjectHelper.fetchSubjects();
    setState(() {
      subjects = fetchedSubjects;
    });
  }

  Future<List<ScheduleModel>> getSchedulesBySubject(String? subjectId) async {
    final schedules = await ScheduleHelper.fetchSchedules();
    if (subjectId != null) {
      return schedules.where((schedules) => schedules.subjectId == subjectId).toList();
    } else {
      return schedules;
    }
  }

  void _updateSchedulesForSubject(String subjectId) {
    setState(() {
      selectedSubjectId = subjectId;
      futureSchedules = getSchedulesBySubject(subjectId); 
    });
  }

  void _showAllSchedules() {
    setState(() {
      selectedSubjectId = null;
      futureSchedules = ScheduleHelper.fetchSchedules(); 
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Horários',
        style: AppTextStyles.smallText.copyWith(color: AppColors.white),
        textAlign: TextAlign.start,
      ),
      backgroundColor: AppColors.purple,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_alt, color: AppColors.white),
          onSelected: (String? subjectId) {
            if (subjectId == 'Todos') {
              _showAllSchedules();
            } else {
              _updateSchedulesForSubject(subjectId!);
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> menuItems = [];
            menuItems.add(
              const PopupMenuItem<String>(
                value: 'Todos',
                child: Text('Todos'),
              ),
            );
            menuItems.addAll(subjects.map((SubjectModel subject) {
              return PopupMenuItem<String>(
                value: subject.id,
                child: Text(subject.name),
              );
            }));
            return menuItems;
          },
        ),
      ],
    ),
    drawer: const CustomDrawer(),
    body: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<ScheduleModel>>(
                future: getSchedulesBySubject(selectedSubjectId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar horários: ${snapshot.error}',
                        style: AppTextStyles.mediumText.copyWith(
                            color: Colors.red, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final schedules = snapshot.data!;
                    if (schedules.isEmpty) {
                      return Center(
                        child: Text(
                          'Oops... Nenhum horário cadastrado.',
                          style: AppTextStyles.mediumText.copyWith(
                              color: AppColors.gray,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return ListView.separated(
                        padding: const EdgeInsets.all(19),
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemCount: schedules.length,
                        itemBuilder: (_, index) {
                          final item = schedules[index];
                          // Formatar a data da tarefa
                          String formattedTime = '${item.dayWeek}, ${item.time}';
                          return ListTile(
                            title: Text(
                              item.subjectName ?? '',
                              style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.titlePurple),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedTime,
                                  style: AppTextStyles.smallerText.copyWith(
                                      color: AppColors.gray,
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(height: 8),
                                if (item.room != null)
                                  Text(
                                    'Sala: ${item.room}',
                                    style: AppTextStyles.smallerText.copyWith(
                                        color: AppColors.gray,
                                        fontWeight: FontWeight.w400),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.titlePurple),
                                  onPressed: () async {
                                    final token = await AuthService.getToken();
                                    if (token != null) {
                                      _showEditModal(item, token);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.titlePurple),
                                  onPressed: () async {
                                    final token = await AuthService.getToken();
                                    if (token != null) {
                                      _confirmDeleteSchedule(item, token);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 26.0,
          right: 26.0,
          child: GestureDetector(
            onTap: () async {
              final token = await AuthService.getToken();
              _showAddModal(token);
            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.titlePurple,
              ),
              child: const Icon(
                Icons.add,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SchedulePage(),
      ),
    );

    setState(() {
      futureSchedules = ScheduleHelper.fetchSchedules();
    });
  }

  void _showAddModal(String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewSchedulePage();
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _showEditModal(ScheduleModel schedule, String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditScheduleModal(schedule: schedule);
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _confirmDeleteSchedule(ScheduleModel schedule, String? token) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Excluir horário',
          style: AppTextStyles.smallText.copyWith(color: AppColors.titlePurple),
        ),
        content: Text(
          'Tem certeza que deseja excluir este horário"?',
          style: AppTextStyles.smallerText.copyWith(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: AppTextStyles.smallerText
                  .copyWith(color: AppColors.titlePurple),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule(schedule.id);
            },
            child: Text(
              'Excluir',
              style: AppTextStyles.smallerText
                  .copyWith(color: AppColors.titlePurple),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSchedule(String taskId) {
    store.deleteSchedule(taskId).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.scheduleDeleteSuccess);
      _updateAndReloadPage();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleDeleteError);
    });
  }
}