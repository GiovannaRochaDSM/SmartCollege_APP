import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/stores/task_store.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/data/helpers/fetch_schedules.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/modals/task/new_task_modal.dart';
import 'package:smart_college/app/common/widgets/modals/task/edit_task_modal.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late Future<List<TaskModel>> futureTasks;
  late Future<List<ScheduleModel>> futureSchedules;
  final TaskStore store = TaskStore(
    repository: TaskRepository(
      client: HttpClient(),
    ),
  );
  DateTime selectedDate = DateTime.now();
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    futureTasks = getFilteredTasks();
    futureSchedules = fetchSchedulesForDay(selectedDate);
  }

  Future<void> _loadToken() async {
    token = await AuthService.getToken();
  }

  Future<List<TaskModel>> getFilteredTasks() async {
    return await TaskHelper.fetchTasksByDate(selectedDate: selectedDate);
  }

  Future<List<ScheduleModel>> fetchSchedulesForDay(DateTime date) async {
    String dayOfWeek = getWeekdayString(date.weekday);
    final schedules = await ScheduleHelper.fetchSchedules();
    return schedules
        .where((schedule) => schedule.dayWeek == dayOfWeek)
        .toList();
  }

  String getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      futureSchedules = fetchSchedulesForDay(selectedDate);
      futureTasks = getFilteredTasks();
    });
  }

  bool isLate(DateTime? deadline, String status) {
    if (deadline == null || status == 'Concluída') return false;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return deadline.isBefore(today);
  }

  Future<void> _completeTask(TaskModel task, int index) async {
    if (token == null) await _loadToken();
    await store.updateTaskStatus(task.id, 'Concluída', token!);
    setState(() {
      futureTasks = getFilteredTasks();
    });
    ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskCompleted);
  }

  Future<void> _deleteTask(TaskModel task, int index) async {
    if (token == null) await _loadToken();
    await store.deleteTask(task.id);
    setState(() {
      futureTasks = getFilteredTasks();
    });
     ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskDeletedSuccess); 
  }

void _showClassificationAlert() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppNewColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          'Classificação de Tarefas',
          style: AppNewTextStyles.balooTitle
              .copyWith(color: AppNewColors.lightBlue),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              _buildClassificationItem(
                  text: 'Vermelho: Prioridade ALTA',
                  color: AppNewColors.red),
              _buildClassificationItem(
                  text: 'Amarelo: Prioridade MÉDIA',
                  color: Colors.yellow),
              _buildClassificationItem(
                  text: 'Verde: Prioridade BAIXA',
                  color: Colors.green),
              _buildClassificationItem(text: '\nAV: Tarefa de AVALIAÇÃO'),
              _buildClassificationItem(text: 'AT: Tarefa de ATIVIDADE'),
              _buildClassificationItem(text: 'ES: Tarefa de ESTUDOS'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              side: const BorderSide(
                color: AppNewColors.lightBlue,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: AppNewTextStyles.smallPoppinsRegular
                  .copyWith(color: AppNewColors.lightBlue), 
            ),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      );
    },
  );
}

  Widget _buildClassificationItem({required String text, Color? color}) {
    return Row(
      children: <Widget>[
        if (color != null)
          Icon(
            Icons.circle,
            color: color,
            size: 16,
          ),
        if (color != null) const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppNewTextStyles.smallPoppinsRegular
                .copyWith(color: AppNewColors.textGray),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: Text(
          'Agenda',
          style: AppNewTextStyles.balooTitle.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
        ),
        backgroundColor: AppNewColors.darkBlue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.white,
                size: 25,
              ),
              onPressed: _showClassificationAlert,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: EasyDateTimeLine(
              initialDate: selectedDate,
              onDateChange: _onDateChanged,
              activeColor: AppNewColors.darkGray,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<ScheduleModel>>(
            future: futureSchedules,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Erro ao carregar os horários.'));
              } else {
                final schedules = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: schedules.map((schedule) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        decoration: const BoxDecoration(
                          color:Color(0xFF64B7CC),
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.time ?? 'Sem horário',
                              style: AppNewTextStyles.smallerPoppinsRegular
                                  .copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              schedule.room ?? 'Sem sala',
                              style: AppNewTextStyles.smallerPoppinsRegular
                                  .copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              schedule.subjectName ?? 'Sem matéria',
                              style: AppNewTextStyles.smallerPoppinsRegular
                                  .copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: futureTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas.'));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma tarefa encontrada.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      final task = snapshot.data![index];
                      bool isCompleted = task.status == 'Concluída';
                      String categoryInitials =
                          task.category != null && task.category!.isNotEmpty
                              ? task.category!.substring(0, 2).toUpperCase()
                              : '';

                      Color priorityColor = Colors.black;
                      if (task.priority == 'Alta') {
                        priorityColor = Colors.red;
                      } else if (task.priority == 'Média') {
                        priorityColor = const Color.fromARGB(255, 231, 210, 18);
                      } else if (task.priority == 'Baixa') {
                        priorityColor = Colors.green;
                      }
                      String formattedDeadline = task.deadline != null
                          ? DateFormat('dd/MM/yyyy').format(task.deadline!)
                          : 'Sem data';

                      return Dismissible(
                        key: Key(task.id),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _completeTask(task, index);
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            final confirmDelete = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title:  Text(
                                  'Excluir tarefa',
                                  textAlign: TextAlign.center,
                                   style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
                                ),
                                content: Text(
                                  'Tem certeza que deseja excluir a tarefa "${task.name}"?',
                                  style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancelar',
                                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.textGray),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(true);
                                      await _deleteTask(task, index);
                                    },
                                    style: TextButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppNewColors.red,
                                      width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                    child: Text(
                                      'Excluir', 
                                      style: AppNewTextStyles.smallPoppinsRegular.copyWith(color: AppNewColors.red),),
                                  ),
                                ],
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            );
                            return confirmDelete ?? false;
                          }
                          return false;
                        },
                        child: GestureDetector(
                          onTap: () {
                            showEditTaskPage(context, task);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppNewColors.lightGray,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.name,
                                      style: AppNewTextStyles
                                          .mediumPoppinsMedium
                                          .copyWith(
                                        color: AppNewColors.textGray,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 13, vertical: 4),
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        categoryInitials,
                                        style: AppNewTextStyles
                                            .mediumPoppinsMedium
                                            .copyWith(
                                                color: AppNewColors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.description ?? '',
                                            style: AppNewTextStyles
                                                .smallExtraLight
                                                .copyWith(
                                                    color:
                                                        AppNewColors.textGray),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            formattedDeadline,
                                            style: AppNewTextStyles
                                                .smallExtraLight
                                                .copyWith(
                                                    color:
                                                        AppNewColors.textGray),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppNewColors.lightBlue,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        task.subjectName ?? '',
                                        style: AppNewTextStyles
                                            .smallPoppinsRegular
                                            .copyWith(
                                                color: AppNewColors.white),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isCompleted)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: Positioned(
        bottom: 55.0,
        right: 55.0,
        child: GestureDetector(
          onTap: () async {
            showAddTaskModal(context);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppNewColors.darkBlue,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 50,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  void showEditTaskPage(BuildContext context, TaskModel task) {
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
            constraints: const BoxConstraints(maxHeight: 920),
            child: EditTaskModal(task: task),
          ),
        );
      },
    ).whenComplete(() {
      _updateAndReloadPage();
    });
  }

  void showAddTaskModal(BuildContext context) {
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
            constraints: const BoxConstraints(maxHeight: 920),
            child: const NewTaskModal(),
          ),
        );
      },
    ).whenComplete(() {
      _updateAndReloadPage();
    });
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskPage(),
      ),
    );

    setState(() {
      futureTasks = TaskHelper.fetchAllTasks();
    });
  }
}
