import 'package:flutter/material.dart';
import 'package:clinica_ulagos_app/theme/colors.dart';
import 'package:clinica_ulagos_app/administrarSesiones/sesiones.dart';

class DetalleCitaScreen extends StatefulWidget {
  const DetalleCitaScreen({
    Key? key,
    required this.citaDetalle,
    required this.fullNameProfesional,
    required this.fullDateCita,
    required this.fullHourCita,
    required this.especialidad,
  }) : super(key: key);

  final String citaDetalle;
  final String fullNameProfesional;
  final String fullDateCita;
  final String fullHourCita;
  final String especialidad;
  @override
  // ignore: library_private_types_in_public_api
  _DetalleCitaScreenState createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final SessionManager _sessionManager = SessionManager();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //Se inicializa el temporizador de la sesion
    _sessionManager.startSessionTimer(context);
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
          'Detalle cita médica',
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
      body: Center(
        child: ListView(controller: _scrollController, children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(
                    color: AppColors.grey, // Color del borde
                    width: 1.0, // Ancho del borde
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.blue_500,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
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
                            widget.fullDateCita,
                            style: const TextStyle(
                                color: AppColors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      //Imagen del profesional en este caso default
                      children: [
                        const SizedBox(width: 10),
                        Image.asset('lib/img/default.png', height: 100),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Nombre del profesional
                            Text(
                              widget.fullNameProfesional,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            //Especialidad del profesional
                            Text(
                              widget.especialidad,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.blue_400,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 4.0,
                                    bottom: 4.0),
                                decoration: BoxDecoration(
                                    color: AppColors.blue_500,
                                    borderRadius: BorderRadius.circular(8)),
                                //Hora de la cita
                                child: Text(
                                  widget.fullHourCita,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                )),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                )),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: AppColors.grey, // Color del borde
                  width: 1.0, // Ancho del borde
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.blue_500,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Center(
                      //DETALLE DE LA CITA
                      child: Text(
                        'Detalle',
                        style: TextStyle(color: AppColors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      widget.citaDetalle.replaceAll(". ", ".\n"),
                      textAlign: TextAlign.justify,
                      style:
                          const TextStyle(color: AppColors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
