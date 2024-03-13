import 'package:clinica_ulagos_app/administrarSesiones/sesiones.dart';
import 'package:clinica_ulagos_app/consultasFirebase/actualizar_datos.dart';
import 'package:clinica_ulagos_app/consultasFirebase/consultas.dart';
import 'package:clinica_ulagos_app/screens/inicioSesionValido/reserva_exitosa.dart';
import 'package:clinica_ulagos_app/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultadosBusquedaScreen extends StatefulWidget {
  //Se inicializa el constructor con sus parametros
  const ResultadosBusquedaScreen({
    Key? key,
    required this.rutProfesional,
    required this.especialidad,
  }) : super(key: key);

  final String? rutProfesional;
  final String? especialidad;

  @override
  // ignore: library_private_types_in_public_api
  _ResultadosBusquedaScreenState createState() =>
      _ResultadosBusquedaScreenState();
}

class _ResultadosBusquedaScreenState extends State<ResultadosBusquedaScreen> {
  final SessionManager _sessionManager =
      SessionManager(); //Para manejar la sesion
  final CarouselController _carouselController =
      CarouselController(); //Controller para el carrousel
  int currentPage = 0;
  List<String> datosDiasCitasMedicas =
      []; //Se almacenas los datos de dias que hay disponibles citasMedicas
  List<Map<String, dynamic>> datosCitasMedicasDiaSeleccionado =
      []; //Se almacenan los datos para las citas medicas del dia seleccionado
  String? rutUsuario;
  String? correoUsuario;

  @override
  void initState() {
    super.initState();
    //Se inicializa el temporizador de la sesion
    _sessionManager.startSessionTimer(context);
    //Carga de datos
    cargarDatosDiasCitasMedicas();
    cargarDatosCitasMedicasMasProxima();
    cargarDatosUsuario();
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
        title: const Text(
          'Resultado(s) de búsqueda',
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
      body: Column(
        children: [
          Row(
            children: [
              Container(
                color: AppColors.blue_500,
                width: 20,
                height: 130,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 5, top: 30),
                  child: Center(
                    //Boton para retroceder la pagina del carousel
                    child: InkWell(
                      onTap: () {
                        _carouselController.previousPage();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width - 40,
                  color: AppColors.blue_500,
                  child: CarouselSlider(
                    carouselController:
                        _carouselController, //controller carousel
                    //Se genera una litsta con diez elementos
                    items: List.generate(10, (groupIndex) {
                      // Dividir la lista en grupos de 7 elementos cada uno para los dias de la semana
                      List<DateTime> group = List.generate(7, (index) {
                        return DateTime.now()
                            .add(Duration(days: groupIndex * 7 + index));
                      });
                      //Se obtiene el mes, anio, del primer y ultimo dia de la semana
                      String monthFirstDayWeek = getMonthName(group[0].month);
                      int yearFirstDayWeek = group[0].year;
                      String monthLastDayWeek = getMonthName(group[6].month);
                      int yearLastDayWeek = group[6].year;
                      return Container(
                        margin: const EdgeInsets.only(
                            left: 0, right: 0, bottom: 0, top: 10),
                        child: Column(
                          children: [
                            Center(
                              //Se manejan los distintos casos para mostrar el mes y el anio en el que se encuentra respectivamente
                              child: (monthFirstDayWeek == monthLastDayWeek)
                                  ? Text('$monthFirstDayWeek $yearFirstDayWeek',
                                      style: const TextStyle(
                                          color: AppColors.white))
                                  : Text(
                                      '$monthFirstDayWeek $yearFirstDayWeek - $monthLastDayWeek $yearLastDayWeek',
                                      style: const TextStyle(
                                          color: AppColors.white),
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //Se genera otra lista para los dias (numeros)
                              children: List.generate(7, (index) {
                                DateTime currentDate = group[index];

                                return Container(
                                  margin: const EdgeInsets.only(
                                      left: 0, right: 0, top: 20),
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue_500,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        getDayOfWeek(currentDate.weekday),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      //Se verifica si la fecha actual se encuentra en la lista de datos en los cuales hay citas disponibles
                                      //Y si es el caso se crea un inkWell(boton)
                                      (datosDiasCitasMedicas.contains(
                                              '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().padLeft(2, '0')}'))
                                          ? InkWell(
                                              onTap: () async {
                                                try {
                                                  List<Map<String, dynamic>>
                                                      result;
                                                  //Al hacer click segun el filtro que tenga se obtienen los datos de citas medicas para el dia seleccionado
                                                  if (widget.rutProfesional !=
                                                      null) {
                                                    result =
                                                        await obtenerCitasMedicasDiaSeleccionadoPorRut(
                                                      widget.rutProfesional,
                                                      currentDate,
                                                    );
                                                  } else {
                                                    result =
                                                        await obtenerCitasMedicasDiaSeleccionadoPorEspecialidad(
                                                      widget.especialidad,
                                                      currentDate,
                                                    );
                                                  }
                                                  //SE actualizan los datos
                                                  setState(() {
                                                    datosCitasMedicasDiaSeleccionado =
                                                        result;
                                                  });
                                                } catch (e) {
                                                  // ignore: avoid_print
                                                  print(
                                                      "Error al obtener datos de citas médicas: $e");
                                                }
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 0, right: 0),
                                                padding:
                                                    const EdgeInsets.all(13),
                                                decoration: BoxDecoration(
                                                  //Se llama la funcion de color, para cambiar el color de fondo segun corresponda si hay cita disponible
                                                  //o si es la mas proxima
                                                  color:
                                                      getCellColor(currentDate),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Text(
                                                  '${currentDate.day}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          //Si no hay citas para ese dia devuelve solamente el container
                                          : Container(
                                              margin: const EdgeInsets.only(
                                                  left: 0, right: 0),
                                              padding: const EdgeInsets.all(13),
                                              decoration: BoxDecoration(
                                                color: AppColors.blue_500,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                '${currentDate.day}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    //Opciones carousel
                    options: CarouselOptions(
                      height: 200,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: false,
                      viewportFraction: 1,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.blue_500,
                width: 20,
                height: 130,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(right: 5, top: 30),
                  child: Center(
                      child: InkWell(
                    onTap: () {
                      _carouselController
                          .nextPage(); //Cambia a la pagina siguiente del carousel
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.white,
                    ),
                  )),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: AppColors.blue_800,
                  size: 24,
                ),
                SizedBox(width: 4),
                Text('Día con la cita médica más próxima'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 10),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: AppColors.warning2,
                  size: 24,
                ),
                SizedBox(width: 4),
                Text('Día con cita médica disponible'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              height: 400,
              //Si no para el dia seleccionado hay citas se crea un listView de tipo constructor
              //Que va ir generando las reservas para cada profesional y su hora correspondiente
              //Se agrupan las reservas por profesional en un card
              child: datosCitasMedicasDiaSeleccionado.isNotEmpty
                  ? ListView.builder(
                      itemCount: datosCitasMedicasDiaSeleccionado.length,
                      itemBuilder: (BuildContext context, int index) {
                        final citaMedica =
                            datosCitasMedicasDiaSeleccionado[index];
                        return MiWidget(
                          //Se le pasan todos estos datos a la clase MiWidget
                          rutPaciente: rutUsuario!,
                          correoPaciente: correoUsuario!,
                          nombreProfesional: citaMedica['nombre_profesional'],
                          apellidoPatProfesional:
                              citaMedica['apellido_paterno_profesional'],
                          apellidoMatProfesional:
                              citaMedica['apellido_materno_profesional'],
                          fechaCita: citaMedica['fecha'],
                          especialidad: citaMedica['nombre_especialidad'],
                          horasCita: citaMedica['horas'],
                          idCita: citaMedica['idCita'],
                        );
                      },
                    )
                  : Container(
                      //Si no hay citas muestrar el siguiente mensaje
                      margin: const EdgeInsets.only(top: 200),
                      height: double.infinity,
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                color: AppColors.blue_500, size: 30),
                            Text('No hay citas medicas disponibles',
                                style: TextStyle(
                                    color: AppColors.blue_500, fontSize: 24)),
                          ],
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  // funcion que obtine los dias de la semana
  String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  //Funcion que obtiene el nombre del mes

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return 'Mes no válido';
    }
  }

  //Carga de datos
  void cargarDatosDiasCitasMedicas() {
    if (widget.rutProfesional != null) {
      obtenerDiasCitasMedicasPorRut(widget.rutProfesional)
          .then((List<String> result) {
        setState(() {
          datosDiasCitasMedicas = result;
        });
      });
    } else {
      obtenerDiasCitasMedicasPorEspecialidad(widget.especialidad)
          .then((List<String> result) {
        setState(() {
          datosDiasCitasMedicas = result;
        });
      });
    }
  }

  //Carga los datos para la cita mas proxima, esta va si o si al comienzo al buscar citas medicas
  void cargarDatosCitasMedicasMasProxima() {
    if (widget.rutProfesional != null) {
      obtenerCitasMedicasMasProximaPorRut(widget.rutProfesional)
          .then((List<Map<String, dynamic>> result) {
        setState(() {
          datosCitasMedicasDiaSeleccionado = result;
        });
      });
    } else {
      obtenerCitasMedicasMasProximaPorEspecialidad(widget.especialidad)
          .then((List<Map<String, dynamic>> result) {
        setState(() {
          datosCitasMedicasDiaSeleccionado = result;
        });
      });
    }
  }

  //Cambia el color de fondo del calendario segun corresponda para cada caso
  Color getCellColor(DateTime currentDate) {
    for (int i = 0; i < datosDiasCitasMedicas.length; i++) {
      var cita = datosDiasCitasMedicas[i];

      if (cita ==
          '${currentDate.day.toString().padLeft(2, '0')}/${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year.toString().padLeft(2, '0')}') {
        if (i == 0) {
          return AppColors.blue_800;
        } else {
          return AppColors.warning2;
        }
      }
    }
    return AppColors.blue_500;
  }

  //CARGA DATOS USUARIO
  Future<void> cargarDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      rutUsuario = prefs.getString('rutUsuario');
      correoUsuario = prefs.getString('correoUsuario');
    });
  }
}

//AcA SE GENERAN LAS CITAS MEDICAS AGRUPADAS POR PROFESIONAL
class MiWidget extends StatelessWidget {
  final String rutPaciente;
  final String correoPaciente;
  final String nombreProfesional;
  final String apellidoPatProfesional;
  final String apellidoMatProfesional;
  final Timestamp fechaCita;
  final String especialidad;
  final List<String> horasCita;
  final List<String> idCita;

  const MiWidget({
    super.key,
    required this.rutPaciente,
    required this.correoPaciente,
    required this.nombreProfesional,
    required this.apellidoPatProfesional,
    required this.apellidoMatProfesional,
    required this.fechaCita,
    required this.especialidad,
    required this.horasCita,
    required this.idCita,
  });

  @override
  Widget build(BuildContext context) {
    //sE OBITENEN ESTOS DATOS PARA MOSTRAR LOS DATOS DE LA CITA EN EL FORMATO QUE QUEREMOS
    DateTime fecha = fechaCita.toDate();
    int numeroDia = fecha.day;
    int anio = fecha.year;
    int numeroDiaDeLaSemana = fecha.weekday;
    int numeroMes = fecha.month;
    int index = 0;
    final nombreDia = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo"
    ];
    final nombreMes = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];

    return Builder(
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          child: SizedBox(
            width: 400,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: AppColors.grey,
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.blue_500,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.calendar_month_sharp,
                          color: AppColors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          //Muestra las fechas de las citas
                          '${nombreDia[numeroDiaDeLaSemana - 1]} ${numeroDia.toString().padLeft(2, '0')} de ${nombreMes[numeroMes - 1]} del ${anio.toString()}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset('lib/img/default.png', height: 100),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Nombre del profesional
                          Text(
                            '$nombreProfesional $apellidoPatProfesional ${apellidoMatProfesional.substring(0, 1)}.',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            especialidad,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.blue_400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        //Generamos todos los botones paras las horas que hay disponible
                        children: horasCita.map((
                          hora,
                        ) {
                          int currentIndex = index;
                          String idCitaActual = idCita[currentIndex];
                          index++;
                          return Container(
                            margin: const EdgeInsets.only(left: 12, right: 5),
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                //Se muestra un bottomSheet al hacer click en la hora.
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight:
                                                    Radius.circular(10.0))),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 150,
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Row(
                                                  //Se muestran los datos de la cita medica seleccionada
                                                  children: [
                                                    const SizedBox(width: 20),
                                                    Image.asset(
                                                      'lib/img/default.png',
                                                      height: 125,
                                                      width: 125,
                                                    ),
                                                    const SizedBox(width: 20),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        //Nombre profesional
                                                        Text(
                                                          '$nombreProfesional $apellidoPatProfesional ${apellidoMatProfesional.substring(0, 1)}.',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          especialidad,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: AppColors
                                                                .blue_400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 20, left: 20),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_sharp,
                                                      color: AppColors.blue_500,
                                                      size: 30,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      //Fecha
                                                      '${nombreDia[numeroDiaDeLaSemana - 1]} ${numeroDia.toString()} de ${nombreMes[numeroMes - 1]} del ${anio.toString()}',
                                                      style: const TextStyle(
                                                        color: AppColors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 20),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8.0,
                                                                top: 4.0,
                                                                bottom: 4.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: AppColors
                                                                    .blue_500,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        //Hora de la cita
                                                        child: Text(
                                                          hora,
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .white),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 20, left: 20),
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warning_rounded,
                                                      color: AppColors.warning,
                                                      size: 30,
                                                    ),
                                                    SizedBox(width: 8),
                                                    //Mensajes de alerta
                                                    Expanded(
                                                      child: Text(
                                                        'RECUERDA que puedes anular tu hora con una antelación mínima de 48 horas',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 40,
                                                    left: 20,
                                                    right: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        //AL HACER CLICK EN RESERVAR SE GUARDA LA CITA MEDICA, Y SE REGISTRA EN LA BASE DE DATOS
                                                        bool exito =
                                                            await guardarCitaMedica(
                                                                idCitaActual,
                                                                rutPaciente);

                                                        if (exito) {
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.push(
                                                            context,
                                                            //Si se registro correctamente redirige a la interfaz de ReservaExitosa y se pasan los siguientes datos
                                                            MaterialPageRoute(
                                                              builder: (context) => ReservaExitosaScreen(
                                                                  correoPaciente:
                                                                      correoPaciente,
                                                                  nombreCompletoProfesional:
                                                                      '$nombreProfesional $apellidoPatProfesional ${apellidoMatProfesional.substring(0, 1)}.',
                                                                  especialidad:
                                                                      especialidad,
                                                                  fechaCita:
                                                                      '${nombreDia[numeroDiaDeLaSemana - 1]} ${numeroDia.toString()} de ${nombreMes[numeroMes - 1]} del ${anio.toString()}',
                                                                  horaCita:
                                                                      hora),
                                                            ),
                                                          );
                                                        } else {
                                                          // Manejar el caso en que la operación no fue exitosa, por ejemplo, mostrar un mensaje al usuario.
                                                          // ignore: avoid_print
                                                          print(
                                                              'No se pudo realizar la reserva.');
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        backgroundColor:
                                                            AppColors.buttons3,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        fixedSize:
                                                            const Size(150, 50),
                                                        foregroundColor:
                                                            AppColors.blue_900,
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        child: Center(
                                                          child: Text(
                                                            'Reservar hora',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      //Al hacer click en el buton se cierra el bottomsheet
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        backgroundColor:
                                                            AppColors.error,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        fixedSize:
                                                            const Size(150, 50),
                                                        foregroundColor:
                                                            AppColors.blue_900,
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        child: Center(
                                                          child: Text(
                                                            'Cancelar',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: AppColors.blue_500,
                                padding: const EdgeInsets.all(0.0),
                                foregroundColor: AppColors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Text(
                                    hora,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
