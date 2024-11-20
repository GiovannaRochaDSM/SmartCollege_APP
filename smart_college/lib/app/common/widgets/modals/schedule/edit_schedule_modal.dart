import 'package:flutter/material.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_colors.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/common/constants/app_text_styles.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';
import 'package:smart_college/app/common/widgets/buttons/custom_elevated_button.dart';

class EditScheduleModal extends StatefulWidget {
  final ScheduleModel schedule;

  const EditScheduleModal({super.key, required this.schedule});

  @override
  _EditScheduleModalState createState() => _EditScheduleModalState();
}

class _EditScheduleModalState extends State<EditScheduleModal> {
  late TextEditingController _roomController;
  late TimeOfDay _selectedTime;
  String? _selectedDayOfWeek;
  late IHttpClient _httpClient;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: widget.schedule.room ?? '');
    _selectedTime = _parseTimeOfDay(widget.schedule.time);
    _selectedDayOfWeek = widget.schedule.dayWeek;
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
              'Editar Horário',
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
              text: 'Salvar',
              onPressed: () {
                _editSchedule(context);
              },
              buttonColor: AppNewColors.darkBlue,
              borderColor: AppNewColors.darkBlue,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSchedule(BuildContext context) async {
    try {
      if (_selectedDayOfWeek == null || _roomController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha todos os campos'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      ScheduleModel updatedSchedule = ScheduleModel(
        id: widget.schedule.id,
        dayWeek: _selectedDayOfWeek!,
        room: _roomController.text,
        time: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        subjectId: widget.schedule.subjectId,
      );

      await _performUpdate(updatedSchedule);

      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleUpdateSuccess);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.scheduleUpdateError);
    }
  }

  Future<void> _performUpdate(ScheduleModel updatedSchedule) async {
    try {
      final ScheduleRepository scheduleRepository = ScheduleRepository(client: _httpClient);
      String? token = await AppStrings.secureStorage.read(key: 'token');

      await scheduleRepository.updateSchedule(updatedSchedule, token);
    } catch (e) {
      throw Exception("Erro ao atualizar horário no servidor.");
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
