// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'package:clinica_ulagos_app/consultasFirebase/actualizar_datos.dart';
import 'package:clinica_ulagos_app/consultasFirebase/consultas.dart';
import 'package:clinica_ulagos_app/screens/inicioSesionValido/busqueda_de_hora.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clinica_ulagos_app/theme/colors.dart';
import 'package:clinica_ulagos_app/administrarSesiones/sesiones.dart';
import 'package:clinica_ulagos_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinica_ulagos_app/screens/inicioSesionValido/mi_historial_medico.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({Key? key}) : super(key: key);

  @override
  _MisReservasScreenState createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  final SessionManager _sessionManager = SessionManager();
  List<Map<String, dynamic>> datosReservaUsuario =
      []; //Para almacenar los datos de reserva del usuario
  //Para almacenar los datos del usuario
  String? rutUsuario;
  String? nombreUsuario;
  String? correoUsuario;
  String? apePatUsuario;
  String? apeMatUsuario;
  String? fecNacUsuario;
  String? telefonoUsuario;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    //Se inicializa el temporizador de la sesion
    _sessionManager.startSessionTimer(context);
    //Al iniciar se cargan los datos del usuario
    cargarDatos();
  }

  @override
  void dispose() {
    //Se detiene el temporizador de la sesion
    _sessionManager.stopSessionTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue_900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'lib/img/logoClinica.png',
              height: 45,
            ),
            //Boton para cerrar sesion y volver a la interfaz principal de login
            ElevatedButton(
                onPressed: () async {
                  await cerrarSesion(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.white,
                  fixedSize: const Size(150, 40),
                  padding: const EdgeInsets.all(10.0),
                  foregroundColor: AppColors.blue_1000,
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(color: AppColors.buttons),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.buttons,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<bool>(
        //Se verifica la sesion
        future: verificarSesion(),
        builder: (context, snapshot) {
          //Se muestra una pantalla de carga mientras se verifica si es el caso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppColors.blue_900,
              body: Center(
                child: Image.asset('lib/img/logoClinica.png'),
              ),
            );
          } else {
            if (snapshot.data == true) {
              // La sesión está activa, muestra el contenido de la pantalla
              return Scaffold(
                body: Column(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: AppColors.blue_400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              'BIENVENIDO',
                              style: TextStyle(
                                fontSize: 22,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          //Se muestra en la interfaz el nombre y apellidos del usuario segun corresponda
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text('$nombreUsuario',
                                style: const TextStyle(
                                    fontSize: 28, color: AppColors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              '$apePatUsuario' ' $apeMatUsuario',
                              style: const TextStyle(
                                  fontSize: 28, color: AppColors.white),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            //Boton para buscar hora
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BusquedaHoraScreen(), //Redirige a la interfaz busqueda de hora
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: AppColors.buttons2,
                                padding: const EdgeInsets.all(10.0),
                                fixedSize: const Size(250, 60),
                                foregroundColor: AppColors.error,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reservar Hora',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    Icons.access_time_filled,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 150, maxHeight: 40),
                              child: GestureDetector(
                                onTap: () {
                                  // No hay acción cuando se hace clic ya que se encuentra en esta interfaz
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.buttons,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Center(
                                      child: Text(
                                        'Mis reservas',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 8),
                          Container(
                            // Puedes ajustar el ancho máximo de la caja aquí
                            constraints: const BoxConstraints(
                                maxWidth: 200, maxHeight: 40),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MiHistorialMedicoScreen(), //Al hacer click redirige a la interfaz de miHistorialMedico
                                  ),
                                );
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Center(
                                    child: Text(
                                      'Mi historial médico',
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Padding(
                      padding: EdgeInsets.only(left: 28.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        //Muestra el contenido de las reservas agendas
                        child: Text(
                          'Reservas agendadas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    //Si los datos de reserva del usuario no estan vacios se crea un carrousel
                    if (datosReservaUsuario.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0.0,
                        ),
                        child: CarouselSlider(
                            options: CarouselOptions(
                              height: 275.0,
                              autoPlay: false,
                              enableInfiniteScroll: false,
                              viewportFraction: 0.90,
                            ),
                            //Se crean tantos items como reservas tenga el usuario, va generando las reservas segun la cantidad que tenga
                            items: datosReservaUsuario.map(
                              (i) {
                                //Obtenemos el id de la cita para posteriormente si queremos anular hora, poder anularla con el id
                                String idCita = i['id_cita'];
                                //Obtenmos la fecha
                                Timestamp formatoTimeStamp = i['fecha'];
                                //Cambiamos el formato de timeStamp a DateTime
                                DateTime fecha = formatoTimeStamp.toDate();
                                //Creamos una variavle para manejar el periodo de dos dias de antelacion para anular hora
                                DateTime fechaEnDosDias =
                                    DateTime.now().add(const Duration(days: 2));
                                //Creamos una lista con los nombres de los dias
                                List<String> nombreDia = [
                                  'Lunes',
                                  'Martes',
                                  'Miércoles',
                                  'Jueves',
                                  'Viernes',
                                  'Sábado',
                                  'Domingo'
                                ];
                                //Lo mismo para los meses
                                List<String> nombreMes = [
                                  'Enero',
                                  'Febrero',
                                  'Marzo',
                                  'Abril',
                                  'Mayo',
                                  'Junio',
                                  'Julio',
                                  'Agosto',
                                  'Septiembre',
                                  'Octubre',
                                  'Noviembre',
                                  'Diciembre'
                                ];
                                //Obtenemos los distintos datos de la fecha
                                int numeroDia = fecha.day;
                                int anio = fecha.year;
                                int numeroDiaDeLaSemana = fecha.weekday;
                                int numeroMes = fecha.month;
                                int hora = fecha.hour;
                                int minutos = fecha.minute;

                                //Retornamos un constructor
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3.0),
                                        child: SizedBox(
                                          width: 400,
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                side: const BorderSide(
                                                  color: AppColors.grey,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.blue_500,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                20.0),
                                                        topRight:
                                                            Radius.circular(
                                                                20.0),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .calendar_month_sharp,
                                                          color:
                                                              AppColors.white,
                                                          size: 30,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        //Mostramos la fecha de la reserva con el formato que quiero Ej: Martes 19 de diciembre del 2023
                                                        Text(
                                                          '${nombreDia[numeroDiaDeLaSemana - 1]} ${numeroDia.toString().padLeft(2, '0')} de ${nombreMes[numeroMes - 1]} del ${anio.toString()}',
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 10),
                                                      //Imagen del profesional, en este caso default
                                                      Image.asset(
                                                          'lib/img/default.png',
                                                          height: 100),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //Mostramos nombre y apellido del profesional.
                                                          Text(
                                                            '${i['nombre_profesional']} ${i['apellido_paterno_profesional']} ${i['apellido_materno_profesional'].substring(0, 1)}.',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          //Mostramos la especialidad
                                                          Text(
                                                            i['nombre_especialidad']
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: AppColors
                                                                  .blue_400,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          //Mostramos la hora y minutos de la cita
                                                          Container(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left: 8.0,
                                                                  right: 8.0,
                                                                  top: 4.0,
                                                                  bottom: 4.0),
                                                              decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .blue_500,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                '${hora.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}',
                                                                style: const TextStyle(
                                                                    color: AppColors
                                                                        .white),
                                                              )),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  //Verificamos que la cita tenga una antelacion minima de 2 dias para poder habilitar el boton de anular hora
                                                  if (fecha
                                                      .isAfter(fechaEnDosDias))
                                                    Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 50,
                                                            width: 200,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                _mostrarVentanaEmergente(
                                                                    //Se abre ventana emergente para anular hora
                                                                    context,
                                                                    idCita);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                backgroundColor:
                                                                    AppColors
                                                                        .error,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        0.0),
                                                                fixedSize:
                                                                    const Size(
                                                                        250,
                                                                        60),
                                                                foregroundColor:
                                                                    AppColors
                                                                        .blue_900,
                                                              ),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                child: Center(
                                                                  child: Text(
                                                                    'Anular Hora',
                                                                    style:
                                                                        TextStyle(
                                                                      color: AppColors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                  const SizedBox(height: 20),
                                                ],
                                              )),
                                        ));
                                  },
                                );
                              },
                            ).toList()),
                      )
                  ],
                ),
              );
            } else {
              // La sesión ha expirado, redirige a la pantalla de inicio de sesión
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
              return Container();
            }
          }
        },
      ),
    );
  }

  //Se cargan los datos del usuario
  Future<List<Map<String, dynamic>>> cargarDatosUsuario() async {
    //Se inicializar una instancia de sesion
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Actualiazamos los datos
    setState(() {
      rutUsuario = prefs.getString('rutUsuario');
      nombreUsuario = prefs.getString('nombreUsuario');
      nombreUsuario = nombreUsuario?.toUpperCase();
      apePatUsuario = prefs.getString('apePatUsuario');
      apePatUsuario = apePatUsuario?.toUpperCase();
      apeMatUsuario = prefs.getString('apeMatUsuario');
      apeMatUsuario = apeMatUsuario?.toUpperCase();
      correoUsuario = prefs.getString('correoUsuario');
      telefonoUsuario = prefs.getString('telefonoUsuario');
      fecNacUsuario = prefs.getString('fecNacUsuario');
    });
    //Obtenemos los datos de reserva para el usuario que inicio sesion
    List<Map<String, dynamic>> datosReservaUsuario =
        await obtenerReservasUsuarios(rutUsuario!);

    return datosReservaUsuario;
  }

  //Ventana emergente de anular hora
  void _mostrarVentanaEmergente(BuildContext context, String idCita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          content: const SizedBox(
            height: 150.0, // Ajusta la altura según tus necesidades
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Centra verticalmente
              children: [
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centra horizontalmente
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppColors.warning,
                        size: 35,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Atención',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '¿Estas seguro que desea anular esta reserva médica?',
                  style: TextStyle(color: AppColors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    //Al hacer click en si, se anula la hora, gracias el id de la cita que le pasamos como parametro
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await anularHora(idCita);
                      setState(() {
                        cargarDatos();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 45, right: 45),
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text(
                      'Si',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const Spacer(), // Añade un Spacer para el espacio entre los botones
                  TextButton(
                    //Si selecciona que no se cierra la ventana emergente
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 45, right: 45),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //Se cargan los datos del usuario
  void cargarDatos() {
    cargarDatosUsuario().then((List<Map<String, dynamic>> result) {
      setState(() {
        datosReservaUsuario = result;
      });
    });
  }
}
