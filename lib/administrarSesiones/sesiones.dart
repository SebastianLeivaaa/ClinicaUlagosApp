// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:clinica_ulagos_app/main.dart';
import 'package:clinica_ulagos_app/consultasFirebase/consultas.dart';

//Se va verificando la sesion cada cierto tiempo
class SessionManager {
  late Timer _timer;

  void startSessionTimer(BuildContext context) {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _verificarSesionAutomaticamente(context);
    });
  }

  void stopSessionTimer() {
    _timer.cancel();
  }

  //Funcion que verifica la sesion automaticammente
  Future<void> _verificarSesionAutomaticamente(BuildContext context) async {
    if (!(await verificarSesion())) {
      // La sesión ha expirado, redirige a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }
}

//Funcion que guarda la sesion, y guarda datos del usuario
Future<void> guardarSesion(String rutUsuario) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('sesion', true);
  prefs.setString('horaInicioSesion', DateTime.now().toIso8601String());
  Map<String, dynamic>? datosUsuario = await obtenerDatosUsuario(rutUsuario);

  if (datosUsuario != null) {
    prefs.setString('rutUsuario', rutUsuario);
    prefs.setString('nombreUsuario', datosUsuario['nombres']);
    prefs.setString('apePatUsuario', datosUsuario['apellido_paterno']);
    prefs.setString('apeMatUsuario', datosUsuario['apellido_materno']);
    prefs.setString('correoUsuario', datosUsuario['correo']);
    prefs.setString('fecNacUsuario', datosUsuario['fecha_nacimiento']);
    prefs.setString('telefonoUsuario', datosUsuario['telefono']);
  }
}

//Funcion para verificar si hay una sesion
Future<bool> verificarSesion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool sesionActiva = prefs.getBool('sesion') ?? false;

  if (sesionActiva) {
    String horaInicioSesion = prefs.getString('horaInicioSesion') ?? "";
    if (horaInicioSesion.isNotEmpty) {
      DateTime inicioSesion = DateTime.parse(horaInicioSesion);
      // Duración de sesión deseada en minutos
      int duracionSesionMinutos = 30;
      // Compara la diferencia en minutos
      return DateTime.now().difference(inicioSesion).inMinutes <
          duracionSesionMinutos;
    }
  }

  return false;
}

//Funcion para cerrar sesion
Future<void> cerrarSesion(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ),
  );
}
