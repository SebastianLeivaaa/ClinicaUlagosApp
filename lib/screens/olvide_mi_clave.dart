// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:clinica_ulagos_app/consultasFirebase/consultas.dart';
import 'package:clinica_ulagos_app/screens/envio_correo_exitoso.dart';
import 'package:clinica_ulagos_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OlvideMiClaveScreen extends StatefulWidget {
  const OlvideMiClaveScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OlvideMiClaveScreenState createState() => _OlvideMiClaveScreenState();
}

class _OlvideMiClaveScreenState extends State<OlvideMiClaveScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; //Se crea una instancia de firebaseAuth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue_900,
        title: const Text(
          'REGISTRARSE',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.white,
          size: 36,
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
              child: const Text('Ingresa tu correo electrónico',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 24,
                  )),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 30.0,
                    top: 30.0,
                  ),
                  child: const Text(
                    'Correo electrónico',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 60,
              padding:
                  const EdgeInsets.only(left: 30.0, top: 10.0, right: 30.0),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  hintText: 'correo@dominio.cl',
                  hintStyle: TextStyle(color: AppColors.placeholders),
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.blue_400,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  fillColor: AppColors.inputs,
                ),
              ),
            ),
            const SizedBox(height: 75.0),
            ElevatedButton(
                onPressed: () async {
                  //Se verifica si el correo esta registrado en nuestra base de datos
                  bool correoExiste =
                      await checkIfCorreoExists(_emailController.text);
                  //Si existe se envia un correo con el restablecimiento de la clave al usuario con el servicio de autenticacion de firebase
                  if (correoExiste) {
                    _sendPasswordResetEmail();
                  } else {
                    //Si no muestra un snackbar con mensaje de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error, este correo no esta asociado a una cuenta.',
                          style: TextStyle(color: AppColors.white),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: AppColors.buttons,
                    padding: const EdgeInsets.all(10.0),
                    fixedSize: const Size(275, 60),
                    foregroundColor: AppColors.blue_900),
                child: const Row(
                  children: [
                    Text(
                      'Restablecer contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.lock_open_rounded,
                      color: AppColors.white,
                      size: 30,
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  //Funcion que envia el correo de restablecimiento de clave
  Future<void> _sendPasswordResetEmail() async {
    try {
      //Se le pasa como parametro el correo del usuario
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      //Si no hubo ningun error redirige a la interfaz de envioCorreoExitoso
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EnvioCorreoExitosoScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        //Si hay error se despliega un snackbar indicando el error
        const SnackBar(
          content: Text(
            'Error, no se ha podido enviar el correo de restablecimiento.',
            style: TextStyle(color: AppColors.white),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: AppColors.error,
        ),
      );
      print('Error: $e');
    }
  }
}
