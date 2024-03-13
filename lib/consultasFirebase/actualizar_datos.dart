import 'package:cloud_firestore/cloud_firestore.dart';

//Funcion que almacena el nuevo registro de un usuario
Future<bool> enviarDatosAFirebase(
  String rut,
  String nombres,
  String apellidoPat,
  String apellidoMat,
  String fechaNacimiento,
  String genero,
  String correo,
  String telefono,
) async {
  try {
    CollectionReference paciente = FirebaseFirestore.instance
        .collection('paciente'); //Referencia a la coleccion

    String idPaciente = rut;

    // Verifica si el documento ya existe antes de intentar agregarlo
    bool existeDocumento =
        await paciente.doc(idPaciente).get().then((doc) => doc.exists);

    if (!existeDocumento) {
      // Si el documento no existe se agrega
      await paciente.doc(idPaciente).set({
        'rut': rut,
        'nombres': nombres,
        'apellido_paterno': apellidoPat,
        'apellido_materno': apellidoMat,
        'fecha_nacimiento': fechaNacimiento,
        'genero': genero,
        'correo': correo,
        'telefono': telefono,
      });
      return true;
    } else {
      // ignore: avoid_print
      print(
          'El documento con el Rut $idPaciente ya existe en la base de datos.');
      return false;
    }
  } catch (e) {
    // ignore: avoid_print
    print(rut);
    // ignore: avoid_print
    print('Error al enviar datos a Firebase: $e');
    return false;
  }
}

//Funcion para guardar la cita medica del usuario
Future<bool> guardarCitaMedica(String idCita, String rutPaciente) async {
  try {
    CollectionReference citasMedicas = FirebaseFirestore.instance
        .collection('cita_medica'); //Referencia a la coleccion

    DocumentReference citaMedica = citasMedicas
        .doc(idCita); //Se obtiene la referencia del documento a cambiar

    //Se actualiza la cita medica, marcandola como no disponible e insertando el rut del paciente
    await citaMedica.update({
      'rut_paciente': rutPaciente,
      'disponible': false,
    });

    return true;
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar la reserva: $e');
    return false;
  }
}

//Funcion para anular hora

Future<void> anularHora(String documentId) async {
  try {
    FirebaseFirestore firestore =
        FirebaseFirestore.instance; //Se crea una instancia de firebase

    // Referencia al documento que deseas eliminar
    DocumentReference citaMedica =
        firestore.collection('cita_medica').doc(documentId);

    //Se actualiza la cita medica se elimina el rut del paciente y se vuelve a marcar como disponible la cita
    await citaMedica.update({
      'rut_paciente': '',
      'disponible': true,
    });
  } catch (error) {
    // ignore: avoid_print
    print('Error al eliminar el documento: $error');
  }
}
