import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/data/helpers/fetch_tasks.dart';
import 'package:smart_college/app/common/widgets/drawer/custom_drawer.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';

class MetricsPage extends StatefulWidget {
  const MetricsPage({super.key});

  @override
  State<MetricsPage> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    tasks = await TaskHelper.fetchTasks();
    setState(() {});
  }

  int getTotalTasksCount() {
    return tasks.length;
  }

  int getPendingTasksCount() {
    return tasks.where((task) => task.status != 'Concluída').length;
  }

  int getInProgressTasksCount() {
    return tasks.where((task) => task.status == 'Em andamento').length;
  }

  int getTasksCountByCategory(String category) {
    return tasks.where((task) => task.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final totalTasksCount = getTotalTasksCount();
    final pendingTasksCount = getPendingTasksCount();
    final inProgressTasksCount = getInProgressTasksCount();
    final atividadeCount = getTasksCountByCategory('Atividade');
    final avaliacaoCount = getTasksCountByCategory('Avaliação');
    final estudoCount = getTasksCountByCategory('Estudo');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MÉTRICAS',
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
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRoundedText('Atividade', atividadeCount, totalTasksCount),
              const SizedBox(height: 10),
              buildRoundedText('Avaliação', avaliacaoCount, totalTasksCount),
              const SizedBox(height: 10),
              buildRoundedText('Estudo', estudoCount, totalTasksCount),
              const SizedBox(height: 60),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Tarefas Pendentes',
                          style: AppTextStyles.smallerTextBold.copyWith(color: AppColors.inputText),
                        ),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: pendingTasksCount.toDouble(),
                                  color: AppColors.titlePurple,
                                  title: '', 
                                ),
                                PieChartSectionData(
                                  value: (totalTasksCount - pendingTasksCount).toDouble(),
                                  color: AppColors.lightGray,
                                  title: '', 
                                ),
                              ],
                              centerSpaceRadius: 30,
                              sectionsSpace: 1,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Tarefas em Andamento',
                          style: AppTextStyles.smallerTextBold.copyWith(color: AppColors.inputText),
                        ),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: inProgressTasksCount.toDouble(),
                                  color: AppColors.logoPink,
                                  title: '',
                                ),
                                PieChartSectionData(
                                  value: (totalTasksCount - inProgressTasksCount).toDouble(),
                                  color: AppColors.lightGray,
                                  title: '', 
                                ),
                              ],
                              centerSpaceRadius: 30,
                              sectionsSpace: 1,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoundedText(String label, int count, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.2),
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.smallTextBold.copyWith(color: AppColors.inputText),
          ),
          Text(
            '$count/$totalCount',
            style: AppTextStyles.smallTextBold.copyWith(color: AppColors.inputText),
          ),
        ],
      ),
    );
  }
}