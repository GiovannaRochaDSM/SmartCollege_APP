import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/data/helpers/fetch_subjects.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/common/widgets/buttons/primary_button.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';

class EditScheduleModal extends StatefulWidget {
  final ScheduleModel schedule;

  const EditScheduleModal({super.key, required this.schedule});

  @override
  _EditScheduleModalState createState() => _EditScheduleModalState();
}

class _EditScheduleModalState extends State<EditScheduleModal> {
  late TextEditingController _roomController;
  late TimeOfDay _selectedTime;
  String? _selectedSubjectId;
  late String _selectedDayOfWeek; 
  List<SubjectModel> _subjects = [];
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: widget.schedule.room ?? '');
    _selectedTime = _parseTimeOfDay(widget.schedule.time);
    _selectedSubjectId = widget.schedule.subjectId;
    _selectedDayOfWeek = widget.schedule.dayWeek;
    _httpClient = HttpClient();

    _fetchSubjects();
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          'EDITAR HORÁRIO',
          style: AppTextStyles.normalText.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
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
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 70, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Sala',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hora',
                  labelStyle:
                      AppTextStyles.normalText.copyWith(color: AppColors.gray),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                  ),
                ),
                child: Text(
                  _formatTimeOfDay(_selectedTime),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            const SizedBox(height: 45),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              items: _subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Matéria',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            DropdownButtonFormField<String>(
              value: _selectedDayOfWeek,
              items: [
                'Segunda-feira',
                'Terça-feira',
                'Quarta-feira',
                'Quinta-feira',
                'Sexta-feira',
                'Sábado',
                'Domingo',
              ].map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDayOfWeek = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Dia da Semana',
                labelStyle:
                    AppTextStyles.normalText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
              ),
            ),
            const SizedBox(height: 80),
            PrimaryButton(
              text: 'Salvar',
              onPressed: () async {
                await _editSchedule(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSubjects() async {
    List<SubjectModel> subjects = await SubjectHelper.fetchSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _editSchedule(BuildContext context) async {
    try {
      if (_selectedSubjectId == null ||
          _roomController.text.isEmpty ||
          _selectedDayOfWeek.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha todos os campos'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      ScheduleModel updatedSchedule = ScheduleModel(
        id: widget.schedule.id,
        dayWeek: _selectedDayOfWeek,
        room: _roomController.text,
        time:
            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        subjectId: _selectedSubjectId!,
      );

      await _performUpdate(updatedSchedule);

      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.scheduleUpdateSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(AppSnackBar.scheduleUpdateError);
    }
  }

  Future<void> _performUpdate(ScheduleModel updatedSchedule) async {
    final ScheduleRepository scheduleRepository =
        ScheduleRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await scheduleRepository.updateSchedule(updatedSchedule, token);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString != null && timeString.isNotEmpty) {
      List<String> parts = timeString.split(':');
      if (parts.length == 2) {
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return TimeOfDay.now().replacing(minute: 0);
  }
}

void showEditScheduleModal(BuildContext context, ScheduleModel schedule) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return EditScheduleModal(schedule: schedule);
    },
  );
}
