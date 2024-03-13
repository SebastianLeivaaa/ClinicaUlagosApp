import 'package:clinica_ulagos_app/screens/inicioSesionValido/mis_reservas.dart';
import 'package:clinica_ulagos_app/theme/colors.dart';
import 'package:flutter/material.dart';

class ReservaExitosaScreen extends StatefulWidget {
  const ReservaExitosaScreen(
      //Se inicializa el constructor
      {Key? key,
      required this.correoPaciente,
      required this.nombreCompletoProfesional,
      required this.especialidad,
      required this.fechaCita,
      required this.horaCita})
      : super(key: key);

  final String correoPaciente;
  final String nombreCompletoProfesional;
  final String especialidad;
  final String fechaCita;
  final String horaCita;

  @override
  // ignore: library_private_types_in_public_api
  _ReservaExitosaScreenState createState() => _ReservaExitosaScreenState();
}

class _ReservaExitosaScreenState extends State<ReservaExitosaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue_900,
        title: Center(
          child: Image.asset('lib/img/logoClinica.png', height: 45),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            '¡Se ha registrado con éxito su reserva!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Image.asset(
                  'lib/img/default.png',
                  height: 125,
                  width: 125,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Datos de la cita medica
                    Text(
                      widget.nombreCompletoProfesional,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.especialidad,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.blue_400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_sharp,
                  color: AppColors.blue_500,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.fechaCita,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 20),
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                    decoration: BoxDecoration(
                        color: AppColors.blue_500,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      widget.horaCita,
                      style: const TextStyle(color: AppColors.white),
                    )),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: AppColors.warning,
                  size: 30,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RECUERDA que puedes anular tu hora con una antelación mínima de 48 horas.',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Center(
              child: Column(
                children: [
                  Text(
                      'Le hemos enviado un correo electrónico a ${widget.correoPaciente} con la confirmación y respectivo detalle de la reserva.',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                          color: AppColors.black, fontSize: 15)),
                  const SizedBox(
                    height: 8,
                  ),
                  const Icon(Icons.email, color: AppColors.blue_500, size: 75)
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 60),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MisReservasScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppColors.buttons,
                padding: const EdgeInsets.all(10.0),
                fixedSize: const Size(250, 60),
                foregroundColor: AppColors.blue_900,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Volver al inicio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
