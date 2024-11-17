import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/modals/home/legend_item.dart';

class TaskProgressChart extends StatelessWidget {
  final int pendingTasksCount;
  final int inProgressTasksCount;
  final int completedTasksCount;
  final int totalTasksCount;

  const TaskProgressChart({super.key, 
    required this.pendingTasksCount,
    required this.inProgressTasksCount,
    required this.completedTasksCount,
    required this.totalTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    bool hasTasks = totalTasksCount > 0;
    double pendingPercentage = hasTasks
        ? (pendingTasksCount / totalTasksCount) * 100
        : 0.0;
    double inProgressPercentage = hasTasks
        ? (inProgressTasksCount / totalTasksCount) * 100
        : 0.0;
    double completedPercentage = hasTasks
        ? (completedTasksCount / totalTasksCount) * 100
        : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  'Progresso das Tarefas',
                  style: AppNewTextStyles.mediumPoppinsRegular.copyWith(color: AppNewColors.black),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (hasTasks) ...[
                        PieChartSectionData(
                          value: pendingTasksCount.toDouble(),
                          color: AppColors.titlePurple,
                          title: '${pendingPercentage.toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: AppTextStyles.smallerText.copyWith(color: Colors.white),
                        ),
                      ] else ...[
                        PieChartSectionData(
                          value: 1.0,
                          color: AppNewColors.darkGray,
                          title: '0%',
                          radius: 60,
                          titleStyle: AppTextStyles.smallerText.copyWith(color: Colors.white),
                        ),
                      ],

                      if (hasTasks) ...[
                        PieChartSectionData(
                          value: inProgressTasksCount.toDouble(),
                          color: AppColors.logoPink,
                          title: '${inProgressPercentage.toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: AppTextStyles.smallerText.copyWith(color: Colors.white),
                        ),
                      ],

                      if (hasTasks) ...[
                        PieChartSectionData(
                          value: completedTasksCount.toDouble(),
                          color: Colors.green,
                          title: '${completedPercentage.toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: AppTextStyles.smallerText.copyWith(color: Colors.white),
                        ),
                      ],
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

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LegendItem(color: AppColors.titlePurple, label: 'Pendentes'),
              SizedBox(height: 20),
              LegendItem(color: AppColors.logoPink, label: 'Em Andamento'),
              SizedBox(height: 20),
              LegendItem(color: Colors.green, label: 'Concluídas'),
            ],
          ),
        ),
      ],
    );
  }
}
