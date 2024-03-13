// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:clinica_ulagos_app/screens/inicioSesionValido/mis_reservas.dart';
import 'package:firebase_auth/firebase_auth.dart'; //Autenticacion de usuario
import 'package:flutter/material.dart';
import 'theme/colors.dart'; //Paleta de colores de la app
import 'screens/olvide_mi_clave.dart';
import 'screens/registrarse.dart';
import 'package:clinica_ulagos_app/funcionesValidaciones/validaciones.dart';
import 'package:clinica_ulagos_app/consultasFirebase/consultas.dart';
import 'package:clinica_ulagos_app/administrarSesiones/sesiones.dart';

//Importaciones de firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//Se inicializa la aplicacion
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinica Ulagos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        //Se verifica si tiene una sesion activa
        future: verificarSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return snapshot.data == true
                ? const MisReservasScreen() //Si se cumple lo redirige a la interfaz de mis reservas
                : const LoginPage(); //Si no se cumple lo redirige a la interfaz principal
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscureText = true; //Variable para manejar el mostrar y ocultar clave
  //Controladores para manejear las entradas de texto en los campos
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String correoValue = '';
  String claveValue = '';
  //Tipos de errores
  bool errorCorreoVacio = false;
  bool errorCorreoInvalido = false;
  bool errorCorreoExiste = false;
  bool errorClave = false;
  bool errorClaveVacia = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blue_400, AppColors.blue_900],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        //Probando si no cambiar ListView por column y eliminar el controller
        child: ListView(
          controller: _scrollController,
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'lib/img/logoClinica.png',
              height: 200.0,
              width: double.infinity,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 35.0,
                          top: 30.0,
                        ),
                        child: const Text(
                          'Correo electrónico',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 30.0, top: 10.0, right: 30.0),
                    child: TextFormField(
                      controller: _correoController,
                      onSaved: (value) {
                        correoValue = value ?? '';
                      },
                      onChanged: (value) {
                        //Manejo de errores en tiempo real, se verifica si tiene formato de correo
                        if (!validarCorreo(value)) {
                          setState(() {
                            errorCorreoInvalido = true;
                            errorCorreoExiste = false;
                            errorCorreoVacio = false;
                            errorClave = false;
                            errorClaveVacia = false;
                          });
                        } else {
                          setState(() {
                            errorCorreoInvalido = false;
                            errorCorreoExiste = false;
                            errorCorreoVacio = false;
                            errorClaveVacia = false;
                            errorClave = false;
                          });
                        }
                      },
                      validator: (value) {
                        //Validacion para el formulario
                        if (value == null || value.isEmpty) {
                          setState(() {
                            errorCorreoVacio = true;
                            errorClaveVacia = false;
                          });
                        } else if (!validarCorreo(value)) {
                          setState(() {
                            errorCorreoInvalido = true;
                            errorCorreoVacio = false;
                            errorClaveVacia = false;
                            errorClave = false;
                          });
                        } else {
                          //Se verifica si el correo existe ya en nuestra base de datos
                          checkIfCorreoExists(value).then((correoExists) {
                            if (correoExists) {
                              setState(() {
                                errorCorreoExiste = false;
                                errorCorreoVacio = false;
                                errorCorreoInvalido = false;
                                errorClaveVacia = false;
                                errorClave = false;
                              });
                            } else {
                              setState(() {
                                errorCorreoExiste = true;
                                errorCorreoVacio = false;
                                errorCorreoInvalido = false;
                                errorClaveVacia = false;
                                errorClave = false;
                              });
                            }
                          });
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'correo@dominio.cl',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person, color: AppColors.icons),
                      ),
                    ),
                  ),
                  //Manejo de errores, para mostrar el error que corresponda debajo del textFormField
                  if (errorCorreoVacio ||
                      errorCorreoExiste ||
                      errorCorreoInvalido)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7.0, left: 30.0),
                        //Disntos mensajes de error
                        child: Text(
                          errorCorreoVacio
                              ? 'Por favor, ingrese un correo electrónico.'
                              : errorCorreoInvalido
                                  ? 'Ingrese un correo electrónico válido.'
                                  : 'El correo electrónico no está registrado en el sistema.',
                          style: const TextStyle(color: AppColors.error2),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 35.0,
                          top: 30.0,
                        ),
                        child: const Text(
                          'Contraseña',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 30.0,
                          top: 30.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      top: 10.0,
                      right: 30.0,
                    ),
                    child: TextFormField(
                      controller: _claveController,
                      onSaved: (value) {
                        claveValue = value ?? '';
                      },
                      validator: (value) {
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: 'Ingrese su contraseña',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        fillColor: Colors.white,
                        prefixIcon:
                            const Icon(Icons.lock, color: AppColors.icons),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              obscureText =
                                  !obscureText; //Actualiza la variable, para mostrar o ocultar clave
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                                //Cambiar el icono del ojo para mostrar contrasenia segun corresponda
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.icons),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Erroes para la clave
                  if (errorClaveVacia || errorClave)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7.0, left: 30.0),
                        child: Text(
                          errorClaveVacia
                              ? 'Por favor, ingrese una contraseña.'
                              : 'Contraseña incorrecta',
                          style: const TextStyle(color: AppColors.error2),
                        ),
                      ),
                    ),
                  //Seccion de olvide mi contrasenia
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 30.0, top: 10.0, right: 30.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OlvideMiClaveScreen(), //Redirige a la interfaz de olvideMiClave al hacer click
                            ),
                          );
                        },
                        splashColor: Colors.blue.withOpacity(0.5),
                        child: const Text(
                          'Olvidé mi contraseña',
                          style: TextStyle(
                            color: AppColors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  //Seccion para ingresar a tu cuenta
                  Align(
                    alignment: Alignment.center,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.blue,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () async {
                          //Se verifica la validacion del formulario
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            try {
                              //Verifica si hay un usuario con esta credencial en nuestro servicio de autenticacion
                              UserCredential userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                email: correoValue.trim(),
                                password: claveValue,
                              );

                              //Si es distinto de null, quiere decir que si existe un usuario con los datos que se le pasaron
                              if (userCredential.user != null) {
                                //Se obtiene el rut del usuario a travez de su correo, gracias al documento donde tenemos guardados estos datos.
                                String rutUsuario =
                                    await obtenerRutUsuario(correoValue);
                                //Pasamos el rut del usuario para guardar una sesion en la app.
                                await guardarSesion(rutUsuario);
                                //Redirige a la interfaz de mis reservas
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MisReservasScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Manejo del error si la autenticación falla
                              //Se despliega un snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error, contraseña incorrecta.',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        splashColor: Colors.blueAccent,
                        child: Container(
                          height: 75,
                          width: 200,
                          padding: const EdgeInsets.all(16.0),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ingresar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            //Seccion para registrarse
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegistrarseScreen(), //Redirige a la interfaz de registrarse
                    ),
                  );
                },
                splashColor: Colors.blue.withOpacity(0.5),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta?',
                      style: TextStyle(
                        color: AppColors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.white,
                      ),
                    ),
                    Text(
                      'Regístrate aquí',
                      style: TextStyle(
                        color: AppColors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
