import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';

class NewScheduleModal extends StatefulWidget {
  final BuildContext parentContext;
  final String subjectId;

  const NewScheduleModal({super.key, required this.parentContext, required this.subjectId});

  @override
  _NewScheduleModalState createState() => _NewScheduleModalState();
}

class _NewScheduleModalState extends State<NewScheduleModal> {
  late TextEditingController _roomController;
  late TimeOfDay _selectedTime;
  String? _selectedDayOfWeek;

  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController();
    _selectedTime = TimeOfDay.now().replacing(minute: 0);
    _httpClient = HttpClient();
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Novo Horário',
              style: AppNewTextStyles.balooTitle.copyWith(color: AppNewColors.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Sala',
                labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 45),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hora',
                  labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                  ),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _formatTimeOfDay(_selectedTime),
                  style: Theme.of(context).textTheme.titleMedium,
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
                  _selectedDayOfWeek = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Dia da Semana',
                labelStyle: AppNewTextStyles.mediumExtraLight.copyWith(color: AppNewColors.textGray),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppNewColors.textGray, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomElevatedButton(
              text: 'Adicionar',
              onPressed: () {
                _addSchedule(context);
              },
              buttonColor: AppNewColors.darkBlue,
              borderColor: AppNewColors.darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSchedule(BuildContext context) async {
  try {
    if (_selectedDayOfWeek == null || _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preencha todos os campos'),
        duration: Duration(seconds: 2),
      ));
      print("Campos obrigatórios não preenchidos.");
      return;
    }

    ScheduleModel newSchedule = ScheduleModel(
      id: '',
      dayWeek: _selectedDayOfWeek!,
      room: _roomController.text,
      time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      subjectId: widget.subjectId,
    );
    await _performAdd(newSchedule);

    ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleAddSuccess);
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleAddError);
  }
}


  Future<void> _performAdd(ScheduleModel newSchedule) async {
  try {
    final ScheduleRepository scheduleRepository = ScheduleRepository(client: _httpClient);
    String? token = await AppStrings.secureStorage.read(key: 'token');

    await scheduleRepository.addSchedule(newSchedule, token);
  } catch (e) {
    throw Exception("Erro ao adicionar horário no servidor.");
  }
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
