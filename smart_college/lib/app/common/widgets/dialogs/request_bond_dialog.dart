import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/models/university_model.dart';
import 'package:smart_college/app/common/constants/app_snack_bar.dart';
import 'package:smart_college/app/data/repositories/bond_repository.dart';
import 'package:smart_college/app/data/repositories/user_repository.dart';
import 'package:smart_college/app/pages/user/user_page.dart';

class RequestBondDialog extends StatefulWidget {
  final String userId;

  const RequestBondDialog({super.key, required this.userId});

  @override
  _RequestBondDialogState createState() => _RequestBondDialogState();
}

class _RequestBondDialogState extends State<RequestBondDialog> {
  bool isLoading = true;
  UniversityModel? selectedUniversity;
  List<UniversityModel> universities = [];
  final BondRepository bondRepository = BondRepository(client: HttpClient());
  final UserRepository userRepository = UserRepository(client: HttpClient());
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailCoordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  Future<void> _fetchUniversities() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');

      final response = await http.get(
        Uri.parse(AppRoutes.universities),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          universities = data.map((e) => UniversityModel.fromMap(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao buscar universidades: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestBond() async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final emailCoord = _emailCoordController.text;
    final universityId = selectedUniversity?.id;
    final userName = _userNameController.text;

    final Map<String, dynamic> requestData = {
      'emailCoord': emailCoord,
      'name': userName,
      'universityId': universityId,
    };

    if (universityId != null && emailCoord.isNotEmpty) {
      try {
        bool success = await bondRepository.requestBond(requestData, token);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.requestBondSuccess);
          Navigator.of(context).pop();
          _updateAndReloadPage();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(AppSnackBar.requestBondError);
          throw Exception('Falha ao enviar a solicitação de vínculo.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.fillFields);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitar Vínculo'),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<UniversityModel>(
                    hint: const Text('Selecione uma Universidade'),
                    value: selectedUniversity,
                    onChanged: (UniversityModel? newValue) {
                      setState(() {
                        selectedUniversity = newValue;
                      });
                    },
                    items: universities.map<DropdownMenuItem<UniversityModel>>(
                      (UniversityModel university) {
                        return DropdownMenuItem<UniversityModel>(
                          value: university,
                          child: Text(university.name),
                        );
                      },
                    ).toList(),
                  ),
                  TextField(
                    controller: _emailCoordController,
                    decoration: const InputDecoration(
                        labelText: 'E-mail do Coordenador'),
                  ),
                  TextField(
                    controller: _userNameController,
                    decoration: const InputDecoration(labelText: 'Nome do Usuário'),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _requestBond,
          child: const Text('Solicitar Vínculo'),
        ),
      ],
    );
  }

  Future<void> _updateAndReloadPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UserPage(),
      ),
    );
  }
}
