import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/pages/task_timeline.dart';

class TaskListModal extends StatefulWidget {
  final String? subjectId;

  const TaskListModal({super.key, this.subjectId});

  @override
  State<TaskListModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskListModal> {
  late Future<List<TaskModel>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = getFilteredTasks();
  }

  Future<List<TaskModel>> getFilteredTasks() async {
    List<TaskModel> tasks = await TaskHelper.fetchAllTasks();
    if (widget.subjectId != null) {
      tasks = tasks.where((task) => task.subjectId == widget.subjectId).toList();
    }
    tasks = tasks.where((task) =>
        task.status == 'Pendente' || task.status == 'Em progresso').toList();
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppNewColors.white,
      body: FutureBuilder<List<TaskModel>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar tarefas: ${snapshot.error}',
                style: AppNewTextStyles.poppinsMedium.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma tarefa pendente ou em progresso.',
                  style: AppNewTextStyles.poppinsMedium.copyWith(
                    color: AppNewColors.lightGray,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0, bottom: 0.0),
                    child: Center(
                      child: Text(
                        'Tarefas',
                        style: AppNewTextStyles.mediumBalooTitle
                            .copyWith(color: AppNewColors.darkBlue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: AppNewColors.lightGray,
                      thickness: 1.5,
                      height: 20,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: tasks.length,
                      itemBuilder: (_, index) {
                        final item = tasks[index];

                        String formattedDeadline = item.deadline != null
                            ? DateFormat('dd/MM/yy').format(item.deadline!)
                            : 'Sem data';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskTimelinePage(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: AppNewTextStyles.balooTitle.copyWith(
                                          color: AppNewColors.darkBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formattedDeadline,
                                      style: AppNewTextStyles.smallBalooTitle.copyWith(
                                        color: AppNewColors.lightGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item.description ?? '',
                                    style: AppNewTextStyles.smallExtraLight.copyWith(
                                      color: AppNewColors.textGray,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.category ?? 'Sem categoria',
                                      style: AppNewTextStyles.smallExtraLight.copyWith(
                                        color: AppNewColors.textGray,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Image.asset(
                                      item.priority == 'Alta'
                                          ? 'assets/images/high-priority.png'
                                          : item.priority == 'Média'
                                              ? 'assets/images/mean-priority.png'
                                              : 'assets/images/low-priority.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: AppNewColors.lightGray,
                                thickness: 1.5,
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          } else {
            return Center(
              child: Text(
                'Nenhuma tarefa encontrada.',
                style: AppNewTextStyles.poppinsMedium.copyWith(
                  color: AppNewColors.lightGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
