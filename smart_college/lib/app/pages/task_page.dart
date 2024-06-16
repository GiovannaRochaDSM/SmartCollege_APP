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

  @override
  void initState() {
    super.initState();
    futureTasks = TaskHelper.fetchTasks();
    _fetchSubjects();
    selectedSubjectId = widget.subjectId; // Inicializa com o subjectId recebido
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
      return tasks; // Retorna todas as tarefas se subjectId for null
    }
  }

  void _updateTasksForSubject(String subjectId) {
    setState(() {
      selectedSubjectId = subjectId;
      futureTasks = getTasksBySubject(subjectId); // Atualiza para tarefas da matéria selecionada
    });
  }

  void _showAllTasks() {
    setState(() {
      selectedSubjectId = null;
      futureTasks = TaskHelper.fetchTasks(); // Atualiza para todas as tarefas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TAREFAS',
          style: AppTextStyles.normalText.copyWith(color: AppColors.white),
          textAlign: TextAlign.start,
        ),
        backgroundColor: AppColors.purple,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: AppColors.white),
            onSelected: (String? subjectId) {
              if (subjectId == 'Todas') {
                _showAllTasks();
              } else {
                _updateTasksForSubject(subjectId!); // Atualiza para tarefas da matéria selecionada
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [];

              // Adicionar opção "Todas"
              menuItems.add(
                const PopupMenuItem<String>(
                  value: 'Todas',
                  child: Text('Todas'),
                ),
              );

              // Adicionar as matérias restantes
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
                child: FutureBuilder<List<TaskModel>>(
                  future: getTasksBySubject(selectedSubjectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar tarefas: ${snapshot.error}',
                          style: AppTextStyles.mediumText.copyWith(
                              color: Colors.red, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final tasks = snapshot.data!;
                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            'Oops...Nenhuma tarefa cadastrada.',
                            style: AppTextStyles.mediumText.copyWith(
                                color: AppColors.gray,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
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
                            // Formatar a data da tarefa
                            String formattedDeadline = item.deadline != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(item.deadline!)
                                : 'Sem data';

                            // Determinar a cor com base na prioridade
                            Color priorityColor = Colors
                                .black; // Cor padrão para prioridades diferentes de 'Alta'
                            if (item.priority == 'Alta') {
                              priorityColor = Colors.red;
                            } else if (item.priority == 'Média') {
                              priorityColor = Colors.yellow;
                            } else if (item.priority == 'Baixa') {
                              priorityColor = Colors.green;
                            }

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(29.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.pink.withOpacity(0.2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyles.smallText.copyWith(
                                            color: AppColors.titlePurple),
                                      ),
                                      // Espaçamento entre o nome e a tag da matéria
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.priority ?? '', // Mostra a prioridade associada como tag
                                          style: TextStyle(
                                            color: priorityColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    
                                    children: [
                                      
                                      Text(
                                        
                                        item.description ?? '',
                                        style: AppTextStyles.smallerText.copyWith(
                                          
                                            color: AppColors.gray,
                                            fontWeight: FontWeight.w400),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        margin: EdgeInsets.only(top: 4), // Espaço entre a tag de matéria e a de prioridade
                                        decoration: BoxDecoration(
                                          color: AppColors.pink,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.subjectName ?? '', // Mostra a matéria associada como tag
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Limite:',
                                            style: AppTextStyles.smallerText.copyWith(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            formattedDeadline,
                                            style: AppTextStyles.smallerText.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.gray,),
                                                
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.titlePurple, width: 1.0),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit, color: AppColors.titlePurple,),
                                                  onPressed: () async {
                                                    final token =
                                                        await AuthService.getToken();
                                                    if (token != null) {
                                                      _showEditModal(item, token);
                                                    }
                                                  },
                                                  color: AppColors.gray,
                                                ),
                                              ),
                                              SizedBox(width: 8), // Espaçamento entre os botões
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.titlePurple, width: 1.0),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete, color: AppColors.titlePurple),
                                                  onPressed: () async {
                                                    final token =
                                                        await AuthService.getToken();
                                                    if (token != null) {
                                                      _confirmDeleteTask(item, token);
                                                    }
                                                  },
                                                  color: AppColors.gray,
                                                ),
                                              ),
                                              SizedBox(width: 8), // Espaçamento entre os botões
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: AppColors.titlePurple, width: 1.0),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.visibility, color: AppColors.titlePurple),
                                                  onPressed: () {
                                                    _showViewModal(item);
                                                  },
                                                  color: AppColors.gray,
                                                ),
                                              ),
                                            ],
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

  void _showEditModal(TaskModel task, String? token) {
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

  void _confirmDeleteTask(TaskModel task, String? token) {
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
