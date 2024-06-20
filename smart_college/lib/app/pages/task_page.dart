import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/services/auth_service.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/stores/task_store.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/widgets/modals/task/new_task_modal.dart';
import 'package:smart_college/app/common/widgets/modals/task/edit_task_modal.dart';

class TaskPage extends StatefulWidget {
  final String? subjectId;

  const TaskPage({super.key, this.subjectId});

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
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    futureTasks = getFilteredTasks();
    _fetchSubjects();
    selectedSubjectId = widget.subjectId;
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
      return tasks;
    }
  }

  Future<List<TaskModel>> getTasksByStatus(String? status) async {
    final tasks = await TaskHelper.fetchTasks();
    if (status != null) {
      return tasks.where((task) => task.status == status).toList();
    } else {
      return tasks;
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
      futureTasks = TaskHelper.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'TAREFAS',
          style: AppTextStyles.smallTextBold.copyWith(color: AppColors.white),
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
            icon: const Icon(Icons.filter_alt, color: AppColors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: const BorderSide(color: Colors.grey),
            ),
            onSelected: (String? subjectId) {
              if (subjectId == 'Todas as matérias') {
                _showAllTasks();
              } else {
                _updateTasksForSubject(subjectId!);
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [];

              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'Todas as matérias',
                  child: Text('Todas as matérias'),
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
          IconButton(
            icon:
                const Icon(Icons.help_outline_rounded, color: AppColors.white),
            onPressed: _showClassificationAlert,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pendente'),
                  selected: selectedStatus == 'Pendente',
                  selectedColor: AppColors.purple,
                  onSelected: (_) {
                    if (selectedStatus == 'Pendente') {
                      _showAllTasks();
                    } else {
                      _updateTasksForStatus('Pendente');
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: AppColors.titlePurple),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Em progresso'),
                  selected: selectedStatus == 'Em progresso',
                  selectedColor: AppColors.purple,
                  onSelected: (_) {
                    if (selectedStatus == 'Em progresso') {
                      _showAllTasks();
                    } else {
                      _updateTasksForStatus('Em progresso');
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: AppColors.titlePurple),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Concluída'),
                  selected: selectedStatus == 'Concluída',
                  selectedColor: AppColors.purple,
                  onSelected: (_) {
                    if (selectedStatus == 'Concluída') {
                      _showAllTasks();
                    } else {
                      _updateTasksForStatus('Concluída');
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: AppColors.titlePurple),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: futureTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                          const SizedBox(height: 16),
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final item = tasks[index];

                        Color priorityColor = Colors.black;
                        if (item.priority == 'Alta') {
                          priorityColor = Colors.red;
                        } else if (item.priority == 'Média') {
                          priorityColor =
                              const Color.fromARGB(255, 231, 210, 18);
                        } else if (item.priority == 'Baixa') {
                          priorityColor = Colors.green;
                        }

                        String categoryInitials =
                            item.category != null && item.category!.isNotEmpty
                                ? item.category!.substring(0, 2).toUpperCase()
                                : '';

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
                              Icons.delete_outline_rounded,
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
                                              AppSnackBar.taskAddSuccess);
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
                                      const SizedBox(width: 2),
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
                                                  item.name,
                                                  style: AppTextStyles.smallText
                                                      .copyWith(
                                                    color: AppColors.lightBlack,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 13,
                                                      vertical: 4),
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  decoration: BoxDecoration(
                                                    color: priorityColor
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Text(
                                                    categoryInitials,
                                                    style: const TextStyle(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
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
                                                      const SizedBox(height: 4),
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
                                                        margin: const EdgeInsets
                                                            .only(top: 5),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .purple
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Text(
                                                          item.subjectName ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            color: AppColors
                                                                .titlePurple,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 20,
                                                  right: 20,
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
                                                              getFilteredTasks();
                                                        });
                                                      });
                                                    },
                                                    child: const CircleAvatar(
                                                      backgroundColor:
                                                          AppColors.pink,
                                                      radius: 26,
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 30,
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
        ],
      ),
      floatingActionButton: Positioned(
        bottom: 55.0,
        right: 55.0,
        child: GestureDetector(
          onTap: () async {
            final token = await AuthService.getToken();
            _showAddModal(token);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 40,
              color: AppColors.white,
            ),
          ),
        ),
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
        return const NewTaskModal();
      },
    ).then((result) {
      if (result != null && result == true) {
        _updateAndReloadPage();
      }
    });
  }

  void _showClassificationAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Classificação de Tarefas',
              style: AppTextStyles.normalTextBold
                  .copyWith(color: AppColors.titlePurple)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('O elemento cujo conteúdo:',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.inputText)),
                Text('- É vermelho: Prioridade ALTA',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- É amarelo: Prioridade MÉDIA',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- É verde: Prioridade BAIXA',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- AV: Tarefa de AVALIAÇÃO',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- AT: Tarefa de ATIVIDADE',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
                Text('- ES: Tarefa de ESTUDOS',
                    style: AppTextStyles.smallerText
                        .copyWith(color: AppColors.gray)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
