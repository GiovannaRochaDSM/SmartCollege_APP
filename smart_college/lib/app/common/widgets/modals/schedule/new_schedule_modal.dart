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

class NewSchedulePage extends StatefulWidget {
  const NewSchedulePage({super.key});

  @override
  _NewSchedulePageState createState() => _NewSchedulePageState();
}

class _NewSchedulePageState extends State<NewSchedulePage> {
  late TextEditingController _roomController;
  late TimeOfDay _selectedTime;
  String? _selectedSubjectId;
  String? _selectedDayOfWeek;
  List<SubjectModel> _subjects = [];
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController();
    _selectedTime = TimeOfDay.now().replacing(minute: 0);
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
        title: Text(
          'Novo Horário',
          style: AppTextStyles.smallTextBold.copyWith(color: AppColors.white),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(labelText: 'Sala',
              labelStyle:
                    AppTextStyles.smallText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hora',
                  labelStyle:
                    AppTextStyles.smallText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _formatTimeOfDay(_selectedTime),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  _selectedDayOfWeek = value;
                });
              },
              decoration: InputDecoration(labelText: 'Dia da Semana', labelStyle:
                    AppTextStyles.smallText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),),
            ),
            const SizedBox(height: 20),
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
              decoration: InputDecoration(labelText: 'Matéria', labelStyle:
                    AppTextStyles.smallText.copyWith(color: AppColors.gray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.pink, width: 3.0),
                ),),
            ),
            const SizedBox(height: 60),
            PrimaryButton(
              text: 'Adicionar',
              onPressed: () async {
                await _addSchedule(context);
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

  Future<void> _addSchedule(BuildContext context) async {
    try {
      if (_selectedDayOfWeek == null || _selectedSubjectId == null || _roomController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha todos os campos'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      ScheduleModel newSchedule = ScheduleModel(
        id: '',
        dayWeek: _selectedDayOfWeek!,
        room: _roomController.text,
        time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        subjectId: _selectedSubjectId!,
      );

      await _performAdd(newSchedule);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleAddSuccess);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleAddError);
    }
  }

  Future<void> _performAdd(ScheduleModel newSchedule) async {
    final ScheduleRepository scheduleRepository = ScheduleRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');
    await scheduleRepository.addSchedule(newSchedule, token);
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
}

void showNewSchedulePage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return const NewSchedulePage();
      },
    ),
  );
}