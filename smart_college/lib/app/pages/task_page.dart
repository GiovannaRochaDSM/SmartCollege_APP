import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/modals/task/edit_task_modal.dart';
import 'package:smart_college/app/common/widgets/modals/task/new_task_modal.dart';
import 'package:smart_college/app/common/widgets/modals/task/view_task_modal.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/data/stores/task_store.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/services/auth_service.dart';

class TaskPage extends StatefulWidget {
  final String? subjectId;

  const TaskPage({Key? key, this.subjectId}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late Future<List<TaskModel>> futureTasks;
  final TaskStore store = TaskStore(
    repository: TaskRepository(
      client: HttpClient(),
    ),
  );
  String? selectedSubjectId;
  List<SubjectModel> subjects = [];
  String? selectedStatus; // Selected status for filtering

  @override
  void initState() {
    super.initState();
    futureTasks = getFilteredTasks();
    _fetchSubjects();
    selectedSubjectId = widget.subjectId; // Initialize with received subjectId
  }

  Future<void> _fetchSubjects() async {
    List<SubjectModel> fetchedSubjects = await SubjectHelper.fetchSubjects();
    setState(() {
      subjects = fetchedSubjects;
    });
  }

  Future<List<TaskModel>> getTasksBySubject(String? subjectId) async {
    final tasks = await TaskHelper.fetchTasks();
    if (subjectId != null) {
      return tasks.where((task) => task.subjectId == subjectId).toList();
    } else {
      return tasks; // Return all tasks if subjectId is null
    }
  }

  Future<List<TaskModel>> getTasksByStatus(String? status) async {
    final tasks = await TaskHelper.fetchTasks();
    if (status != null) {
      return tasks.where((task) => task.status == status).toList();
    } else {
      return tasks; // Return all tasks if status is null
    }
  }

  void _updateTasksForSubject(String subjectId) {
    setState(() {
      selectedSubjectId = subjectId;
      futureTasks = getFilteredTasks();
    });
  }

  Future<List<TaskModel>> getFilteredTasks() async {
    List<TaskModel> tasks = await TaskHelper.fetchTasks();

    if (selectedSubjectId != null) {
      tasks =
          tasks.where((task) => task.subjectId == selectedSubjectId).toList();
    }

    if (selectedStatus != null) {
      tasks = tasks.where((task) => task.status == selectedStatus).toList();
    }

    return tasks;
  }

  void _updateTasksForStatus(String status) {
    setState(() {
      selectedStatus = status;
      futureTasks = getFilteredTasks();
    });
  }

  void _showAllTasks() {
    setState(() {
      selectedSubjectId = null;
      selectedStatus = null;
      futureTasks = TaskHelper.fetchTasks(); // Update to fetch all tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TAREFAS',
          style:
              AppTextStyles.smallTextBold.copyWith(color: AppColors.lightBlack),
          textAlign: TextAlign.right,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.purple, AppColors.pink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: AppColors.purple,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: AppColors.lightBlack),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  15.0), // Ajuste o valor conforme desejado
              side: BorderSide(color: Colors.grey), // Opcional, adicionar borda
            ),
            onSelected: (String? subjectId) {
              if (subjectId == 'Todas as matérias') {
                _showAllTasks();
              } else {
                _updateTasksForSubject(
                    subjectId!); // Update to tasks of selected subject
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [];

              // Add "All subjects" option
              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'Todas as matérias',
                  child: Text('Todas as matérias'),
                ),
              );

              // Add remaining subjects
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChoiceChips for filtering by status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 8), // Espaçamento à esquerda
                ChoiceChip(
                  label: Text('Pendente'),
                  selected: selectedStatus == 'Pendente',
                  onSelected: (_) {
                    if (selectedStatus == 'Pendente') {
                      _showAllTasks(); // Mostra todas as tarefas se já estiver selecionado
                    } else {
                      _updateTasksForStatus('Pendente');
                    }
                  },
                ),
                ChoiceChip(
                  label: Text('Em progresso'),
                  selected: selectedStatus == 'Em progresso',
                  onSelected: (_) {
                    if (selectedStatus == 'Em progresso') {
                      _showAllTasks(); // Mostra todas as tarefas se já estiver selecionado
                    } else {
                      _updateTasksForStatus('Em progresso');
                    }
                  },
                ),
                ChoiceChip(
                  label: Text('Concluída'),
                  selected: selectedStatus == 'Concluída',
                  onSelected: (_) {
                    if (selectedStatus == 'Concluída') {
                      _showAllTasks(); // Mostra todas as tarefas se já estiver selecionado
                    } else {
                      _updateTasksForStatus('Concluída');
                    }
                  },
                ),
                SizedBox(width: 8), // Espaçamento à direita
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: futureTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar tarefas: ${snapshot.error}',
                      style: AppTextStyles.mediumText.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Oops... Nenhuma tarefa cadastrada.',
                              style: AppTextStyles.normalText.copyWith(
                                color: AppColors.gray,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'assets/images/wind.png',
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.separated(
                      padding: const EdgeInsets.all(19),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final item = tasks[index];

                        // Determine color based on priority
                        Color priorityColor = Colors
                            .black; // Default color for priorities other than 'High'
                        if (item.priority == 'Alta') {
                          priorityColor = Colors.red;
                        } else if (item.priority == 'Média') {
                          priorityColor = Color.fromARGB(255, 231, 210,
                              18); // Exemplo de cor para prioridade média
                        } else if (item.priority == 'Baixa') {
                          priorityColor = Colors.green;
                        }

                        // Get initial of category
                        String categoryInitials =
                            item.category != null && item.category!.isNotEmpty
                                ? item.category!.substring(0, 2).toUpperCase()
                                : '';

                        // Format task deadline date
                        String formattedDeadline = item.deadline != null
                            ? DateFormat('dd/MM/yy').format(item.deadline!)
                            : 'Sem data';

                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (DismissDirection direction) async {
                            return await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  'Excluir tarefa',
                                  style: AppTextStyles.smallText
                                      .copyWith(color: AppColors.titlePurple),
                                ),
                                content: Text(
                                  'Tem certeza que deseja excluir a tarefa "${item.name}"?',
                                  style: AppTextStyles.smallerText
                                      .copyWith(color: AppColors.gray),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      'Cancelar',
                                      style: AppTextStyles.smallerText.copyWith(
                                          color: AppColors.titlePurple),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context, true);
                                      await store.deleteTask(item.id);
                                      setState(() {
                                        tasks.removeAt(index);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              AppSnackBar.taskDeletedError);
                                    },
                                    child: Text(
                                      'Confirmar',
                                      style: AppTextStyles.smallerText
                                          .copyWith(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item.name ?? '',
                                                  style: AppTextStyles.smallText
                                                      .copyWith(
                                                    color:
                                                        AppColors.titlePurple,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 13,
                                                      vertical: 4),
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  decoration: BoxDecoration(
                                                    color: priorityColor
                                                        .withOpacity(
                                                            0.8), // Cor de fundo com base na prioridade
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Text(
                                                    categoryInitials,
                                                    style: TextStyle(
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                            
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.description ?? '',
                                                        style: AppTextStyles
                                                            .smallerText
                                                            .copyWith(
                                                          color: AppColors.gray,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        formattedDeadline,
                                                        style: AppTextStyles
                                                            .smallerText
                                                            .copyWith(
                                                          color: AppColors.gray,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 4),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .purple
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          item.subjectName ??
                                                              '', // Nome do assunto como tag
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .titlePurple,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 15,
                                                  right: 15,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            EditTaskModal(
                                                                task: item),
                                                      ).then((value) {
                                                        setState(() {
                                                          futureTasks =
                                                              getFilteredTasks(); // Atualiza as tarefas após a edição
                                                        });
                                                      });
                                                    },
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          AppColors.purple,
                                                      radius: 20,
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                           } else {
              return Center(
                child: Text(
                  'Nenhuma tarefa encontrada.',
                  style: AppTextStyles.mediumText.copyWith(
                    color: AppColors.gray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
          },
        ),
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
        builder: (context) => const TaskPage(),
      ),
    );

    setState(() {
      futureTasks = TaskHelper.fetchTasks();
    });
  }

  void _showAddModal(String? token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewTaskPage();
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _showEditModal(TaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTaskModal(task: task);
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _showViewModal(TaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewTaskModal(task: task);
      },
    );
  }

  void _confirmDeleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Excluir tarefa',
          style: AppTextStyles.smallText.copyWith(color: AppColors.titlePurple),
        ),
        content: Text(
          'Tem certeza que deseja excluir a tarefa "${task.name}"?',
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
              _deleteTask(task.id);
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

  void _deleteTask(String taskId) {
    store.deleteTask(taskId).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.taskDeletedSuccess);
      _updateAndReloadPage();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.taskDeletedError);
    });
  }
}
