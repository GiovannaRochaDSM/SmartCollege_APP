import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:intl/intl.dart';
import 'package:smart_college/app/common/widgets/modals/task/edit_task_modal.dart';
import 'package:smart_college/app/common/widgets/modals/task/new_task_modal.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/data/stores/task_store.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/data/helpers/fetch_schedules.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';

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

  Future<void> _updateAndReloadPage() async {
    setState(() {
      futureTasks = getFilteredTasks();
    });
  }

  void _showAddTaskModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewTaskModal();
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  Future<void> _completeTask(TaskModel task, int index) async {
    if (token == null) await _loadToken();
    await store.updateTaskStatus(task.id, 'Concluída', token!);
    setState(() {
      futureTasks = getFilteredTasks();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa concluída!')),
    );
  }

  Future<void> _deleteTask(TaskModel task, int index) async {
    if (token == null) await _loadToken();
    await store.deleteTask(task.id);
    setState(() {
      futureTasks = getFilteredTasks();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa excluída!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        iconTheme: const IconThemeData(color: Colors.white, size: 25),
        title: const Text(
          'TAREFAS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          EasyDateTimeLine(
            initialDate: selectedDate,
            onDateChange: _onDateChanged,
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
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: schedules.map((schedule) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B7CC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.time ?? 'Sem horário',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule.room ?? 'Sem sala',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              schedule.subjectName ?? 'Sem matéria',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                title: const Text(
                                  'Excluir tarefa',
                                  style: TextStyle(color: Colors.purple),
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  'Tem certeza que deseja excluir a tarefa "${task.name}"?',
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(true);
                                      await _deleteTask(task, index);
                                    },
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                            return confirmDelete ?? false;
                          }
                          return false;
                        },
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditTaskModal(task: task),
                            ).then((result) {
                              if (result == true) {
                                _updateAndReloadPage();
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.name,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.description ?? '',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedDeadline,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.purple
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              task.subjectName ?? '',
                                              style: const TextStyle(
                                                color: Colors.purple,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    isCompleted ? 'CONCLUÍDA' : 'NÃO CONCLUÍDA',
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
 