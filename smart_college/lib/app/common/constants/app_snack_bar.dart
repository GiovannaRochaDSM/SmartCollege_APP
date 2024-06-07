import 'package:flutter/material.dart';

class AppSnackBar {
  static const invalidEmailOrPassword = SnackBar(
    content: Text(
      'E-mail ou senha inválidos',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const removePhotoSuccess = SnackBar(
    content: Text(
      'Foto removida com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const removePhotoError = SnackBar(
    content: Text(
      'Erro ao remover a foto',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const userUpdatedSuccess = SnackBar(
    content: Text(
      'Informações atualizadas com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const userUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar as informações',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectDeletedSuccess = SnackBar(
    content: Text(
      'Matéria excluída com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectDeletedError = SnackBar(
    content: Text(
      'Erro ao excluir matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectUpdatedSuccess = SnackBar(
    content: Text(
      'Matéria atualizada com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectUpdatedError = SnackBar(
    content: Text(
      'Erro ao atualizar matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const subjectAddSuccess = SnackBar(
    content: Text(
      'Matéria adicionada com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const subjectAddError = SnackBar(
    content: Text(
      'Erro ao adicionar matéria',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const emailResetPasswordSuccess = SnackBar(
    content: Text(
      'Um e-mail foi enviado para resetar sua senha',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const emailResetPasswordError = SnackBar(
    content: Text(
      'Por favor, insira seu e-mail',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const forgotPasswordError = SnackBar(
    content: Text(
      'Erro ao redefinir senha. Por favor, tente novamente',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const userAddSuccess = SnackBar(
    content: Text(
      'Cadastro realizado com sucesso',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.green,
  );

  static const userAddError = SnackBar(
    content: Text(
      'Erro ao se cadastrar',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );

  static const fillFields = SnackBar(
    content: Text(
      'Por favor, preencha todos os campos',
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  );
}