// ignore_for_file: avoid_print, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

//Funcion que verifica en la base de datos si existe el rut
Future<bool> checkIfRutExists(String rut) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('paciente')
        .where('rut', isEqualTo: rut)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (error) {
    // ignore: avoid_print
    print('Error al verificar el Rut: $error');
    return false;
  }
}

//Funcion que verifica en la base de datos si existe el correo

Future<bool> checkIfCorreoExists(String correo) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('paciente')
        .where('correo', isEqualTo: correo)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (error) {
    // ignore: avoid_print
    print('Error al verificar el Rut: $error');
    return false;
  }
}

//Funcion que obtiene el rut del usuario mediante el correo

Future<String> obtenerRutUsuario(String correo) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('paciente')
        .where('correo', isEqualTo: correo)
        .get();

    // Verificar si hay datos en la consulta
    if (querySnapshot.size > 0) {
      // Obtener el primer documento (asumiendo que solo hay uno)
      var pacienteData = querySnapshot.docs[0].data();

      // Obtener el valor del campo 'rut_paciente'
      String rutPaciente = pacienteData['rut'];

      return rutPaciente;
    } else {
      // No se encontraron datos para el correo proporcionado
      return '';
    }
  } catch (error) {
    // ignore: avoid_print
    print('Error al verificar el Rut: $error');
    return '';
  }
}

//Funcion para verificar si el telefono ya esta registrado en la base de datos
Future<bool> checkIfTelefonoExists(String telefono) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('paciente')
        .where('telefono', isEqualTo: telefono)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (error) {
    // ignore: avoid_print
    print('Error al verificar el Rut: $error');
    return false;
  }
}

//Funcion para obtener los datos del usuario mediante el rut
Future<Map<String, dynamic>?> obtenerDatosUsuario(String rut) async {
  try {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('paciente')
        .where('rut', isEqualTo: rut)
        .get();

    if (query.docs.isNotEmpty) {
      QueryDocumentSnapshot<Map<String, dynamic>> usuario = query.docs.first;
      Map<String, dynamic> datosUsuario = usuario.data();

      return datosUsuario;
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error al obtener datos del usuario: $e");
  }

  return null;
}

//Funcion que obtiene la reservas del usuario mediante el rut, se obtienen todos los datos que necesitamos mostrar en pantalla en las interfaces
Future<List<Map<String, dynamic>>> obtenerReservasUsuarios(String rut) async {
  try {
    DateTime fechaActual = DateTime.now();
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('rut_paciente', isEqualTo: rut)
        .where('fecha', isGreaterThan: Timestamp.fromDate(fechaActual))
        .orderBy('fecha', descending: false)
        .get();

    List<Map<String, dynamic>> datosReservaUsuarios = [];

    if (query.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> usuario in query.docs) {
        Map<String, dynamic> datosReservaUsuario = usuario.data();

        String idEspecialidad = datosReservaUsuario['especialidad'];

        DocumentSnapshot<Map<String, dynamic>> especialidadSnapshot =
            await FirebaseFirestore.instance
                .collection('especialidad')
                .doc(idEspecialidad)
                .get();

        Map<String, dynamic>? datosEspecialidad = especialidadSnapshot.data();
        datosReservaUsuario['nombre_especialidad'] =
            datosEspecialidad?['nombre'];

        // Consulta a la colección 'profesional' usando el 'rut_profesional'
        datosReservaUsuario['id_cita'] = usuario.id;

        String rutProfesional = datosReservaUsuario['rut_profesional'];
        DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
            await FirebaseFirestore.instance
                .collection('profesional')
                .doc(rutProfesional)
                .get();

        if (profesionalSnapshot.exists) {
          // Agregar los datos del profesional al mapa 'datosUsuario'
          Map<String, dynamic>? datosProfesional = profesionalSnapshot.data();
          if (datosProfesional != null) {
            datosReservaUsuario['nombre_profesional'] =
                datosProfesional['nombre'];
            datosReservaUsuario['apellido_paterno_profesional'] =
                datosProfesional['apellido_paterno'];
            datosReservaUsuario['apellido_materno_profesional'] =
                datosProfesional['apellido_materno'];
          } else {
            // ignore: avoid_print
            print(
                "El documento profesional no existe para el rut: $rutProfesional");
          }
        }

        datosReservaUsuarios.add(datosReservaUsuario);
      }
      print('Número de documentos en la lista: ${datosReservaUsuarios.length}');
      print(datosReservaUsuarios);
      return datosReservaUsuarios;
    }
  } catch (e) {
    // Manejo de errores...
    // ignore: avoid_print
    print("Error al obtener datos del usuario: $e");
  }

  return []; // O puedes devolver null o cualquier otra cosa según tu lógica.
}

//Funcion para obtener el historial del usuaario mediante el rut, se obtienen todos los datos que necesitamos mostrar en pantalla en las interfaces
Future<List<Map<String, dynamic>>> obtenerHistorialUsuarios(String rut) async {
  try {
    DateTime fechaActual = DateTime.now();
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('rut_paciente', isEqualTo: rut)
        .where('fecha', isLessThan: Timestamp.fromDate(fechaActual))
        .orderBy('fecha', descending: true)
        .get();

    List<Map<String, dynamic>> datosHistorialUsuarios = [];

    if (query.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> usuario in query.docs) {
        Map<String, dynamic> datosHistorialUsuario = usuario.data();

        String idEspecialidad = datosHistorialUsuario['especialidad'];

        DocumentSnapshot<Map<String, dynamic>> especialidadSnapshot =
            await FirebaseFirestore.instance
                .collection('especialidad')
                .doc(idEspecialidad)
                .get();

        Map<String, dynamic>? datosEspecialidad = especialidadSnapshot.data();
        datosHistorialUsuario['nombre_especialidad'] =
            datosEspecialidad?['nombre'];

        // Consulta a la colección 'profesional' usando el 'rut_profesional'
        String rutProfesional = datosHistorialUsuario['rut_profesional'];
        DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
            await FirebaseFirestore.instance
                .collection('profesional')
                .doc(rutProfesional)
                .get();

        if (profesionalSnapshot.exists) {
          // Agregar los datos del profesional al mapa 'datosUsuario'
          Map<String, dynamic>? datosProfesional = profesionalSnapshot.data();
          if (datosProfesional != null) {
            datosHistorialUsuario['nombre_profesional'] =
                datosProfesional['nombre'];
            datosHistorialUsuario['apellido_paterno_profesional'] =
                datosProfesional['apellido_paterno'];
            datosHistorialUsuario['apellido_materno_profesional'] =
                datosProfesional['apellido_materno'];
          } else {
            // ignore: avoid_print
            print(
                "El documento profesional no existe para el rut: $rutProfesional");
          }
        }

        datosHistorialUsuarios.add(datosHistorialUsuario);
      }
      return datosHistorialUsuarios;
    }
  } catch (e) {
    // Manejo de errores...
    // ignore: avoid_print
    print("Error al obtener datos del usuario: $e");
  }

  return []; // O puedes devolver null o cualquier otra cosa según tu lógica.
}

//SE OBTIENEN LOS DATOS DE TODAS LAS ESPECIALIDADES
Future<List<Map<String, dynamic>>> obtenerEspecialidades() async {
  try {
    QuerySnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance.collection('especialidad').get();

    List<Map<String, dynamic>> datosEspecialidades = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosEspecialidad = documentSnapshot.data();
      datosEspecialidad['id_especialidad'] = documentSnapshot.id;
      datosEspecialidades.add(datosEspecialidad);
    }
    print(datosEspecialidades);
    return datosEspecialidades;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
  }
  return [];
}

//SE OBTIENEN LOS DATOS DE TODOS LOS PROFESIONALES
Future<List<Map<String, dynamic>>> obtenerProfesionales() async {
  try {
    QuerySnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance.collection('profesional').get();

    List<Map<String, dynamic>> datosProfesionales = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosProfesional = documentSnapshot.data();
      datosProfesionales.add(datosProfesional);
    }
    print(datosProfesionales);
    return datosProfesionales;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
  }
  return [];
}

//SE OBTIENEN LAS CITAS MEDICAS MAS CERCANAS FILTRADOS POR RUT Y SE OBTIENEN TODOS LOS DATOS NECESARIOS
Future<List<Map<String, dynamic>>> obtenerCitasMedicasMasProximaPorRut(
    String? rut) async {
  try {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('rut_profesional', isEqualTo: rut)
        .orderBy('fecha')
        .get();

    List<Map<String, dynamic>> datosCitasMedicas = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = query.docs;
    String idEspecialidad = docs[0]['especialidad'];

    Map<String, dynamic>? datosEspecialidad =
        await obtenerDatosEspecialidad(idEspecialidad);

    String rutProfesional = docs[0]['rut_profesional'];
    DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
        await FirebaseFirestore.instance
            .collection('profesional')
            .doc(rutProfesional)
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosCitaMedica = documentSnapshot.data();
      DateTime fechaCita = datosCitaMedica['fecha'].toDate();
      String fechaCitaFormateada = DateFormat('dd/MM/yyyy').format(fechaCita);

      String horaCita =
          '${fechaCita.hour.toString().padLeft(2, '0')}:${fechaCita.minute.toString().padLeft(2, '0')}';
      String idCitaMedica = documentSnapshot.id;

      datosCitaMedica['horas'] = [horaCita];
      datosCitaMedica['idCita'] = [idCitaMedica];

      datosCitaMedica['nombre_especialidad'] =
          datosEspecialidad?['nombre'] ?? 'Nombre no disponible';

      datosCitaMedica['id_cita'] = [documentSnapshot.id];

      if (profesionalSnapshot.exists) {
        // Agregar los datos del profesional al mapa 'datosUsuario'
        Map<String, dynamic>? datosProfesional = profesionalSnapshot.data();
        if (datosProfesional != null) {
          datosCitaMedica['nombre_profesional'] = datosProfesional['nombre'];
          datosCitaMedica['apellido_paterno_profesional'] =
              datosProfesional['apellido_paterno'];
          datosCitaMedica['apellido_materno_profesional'] =
              datosProfesional['apellido_materno'];
        } else {
          // ignore: avoid_print
          print(
              "El documento profesional no existe para el rut: $rutProfesional");
        }
      }

      print('Fecha del documento: $fechaCita');

      if (datosCitasMedicas.isEmpty) {
        datosCitasMedicas.add(datosCitaMedica);
      } else if (DateFormat('dd/MM/yyyy')
              .format(datosCitasMedicas[0]['fecha'].toDate()) ==
          fechaCitaFormateada) {
        datosCitasMedicas[0]['horas'].add(horaCita);
        datosCitasMedicas[0]['idCita'].add(idCitaMedica);
      }
    }

    print(datosCitasMedicas);
    return datosCitasMedicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN LAS CITAS MEDICAS MAS CERCANAS FILTRADOS POR ESPECIALIDAD Y SE OBTIENEN TODOS LOS DATOS NECESARIOS

Future<List<Map<String, dynamic>>> obtenerCitasMedicasMasProximaPorEspecialidad(
    String? especialidad) async {
  try {
    final stopwatch = Stopwatch()..start();
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('especialidad', isEqualTo: especialidad)
        .orderBy('rut_profesional')
        .orderBy('fecha')
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = query.docs;

    List<Map<String, dynamic>> datosCitasMedicas = [];
    String actualRutProfesional = '';
    int index = -1;
    String? primeraCita;
    String idEspecialidad = docs[0]['especialidad'];
    Map<String, dynamic>? datosEspecialidad =
        await obtenerDatosEspecialidad(idEspecialidad);

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosCitaMedica = documentSnapshot.data();

      DateTime fechaCita = datosCitaMedica['fecha'].toDate();
      String fechaCitaFormateada = DateFormat('dd/MM/yyyy').format(fechaCita);

      primeraCita ??= fechaCitaFormateada;

      String horaCita =
          '${fechaCita.hour.toString().padLeft(2, '0')}:${fechaCita.minute.toString().padLeft(2, '0')}';
      String idCitaMedica = documentSnapshot.id;

      datosCitaMedica['horas'] = [horaCita];
      datosCitaMedica['idCita'] = [idCitaMedica];

      datosCitaMedica['nombre_especialidad'] =
          datosEspecialidad?['nombre'] ?? 'Nombre no disponible';

      datosCitaMedica['id_cita'] = [documentSnapshot.id];

      if (actualRutProfesional != datosCitaMedica['rut_profesional'] &&
          primeraCita == fechaCitaFormateada) {
        String rutProfesional = datosCitaMedica['rut_profesional'];
        DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
            await FirebaseFirestore.instance
                .collection('profesional')
                .doc(rutProfesional)
                .get();

        if (profesionalSnapshot.exists) {
          // Agregar los datos del profesional al mapa 'datosUsuario'
          Map<String, dynamic>? datosProfesional = profesionalSnapshot.data();
          if (datosProfesional != null) {
            datosCitaMedica['nombre_profesional'] = datosProfesional['nombre'];
            datosCitaMedica['apellido_paterno_profesional'] =
                datosProfesional['apellido_paterno'];
            datosCitaMedica['apellido_materno_profesional'] =
                datosProfesional['apellido_materno'];
          } else {
            // ignore: avoid_print
            print(
                "El documento profesional no existe para el rut: $rutProfesional");
          }
        }
        datosCitasMedicas.add(datosCitaMedica);
        actualRutProfesional = datosCitaMedica['rut_profesional'];
        index++;
        print('Fecha del documento: $fechaCita');
      } else if (primeraCita == fechaCitaFormateada) {
        datosCitasMedicas[index]['horas'].add(horaCita);
        datosCitasMedicas[index]['idCita'].add(idCitaMedica);
      }
    }
    stopwatch.stop();
    print('Tiempo de ejecución: ${stopwatch.elapsedMilliseconds} ms');
    print(datosCitasMedicas);
    return datosCitasMedicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN LA FECHA EN LAS CUALES HAY CITAS MEDICAS DISPONIBLES MEDIANTE EL RUT DEL PROFESIONAL
Future<List<String>> obtenerDiasCitasMedicasPorRut(String? rut) async {
  try {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('rut_profesional', isEqualTo: rut)
        .orderBy('fecha')
        .get();

    List<String> fechasUnicas = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosDiaCitaMedica = documentSnapshot.data();
      Timestamp fechaTimestamp = datosDiaCitaMedica['fecha'];
      DateTime fecha = fechaTimestamp.toDate();
      String fechaString =
          "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year.toString().padLeft(2, '0')}"; // Formato dd/mm/yyyy
      // Verificar si ya hemos procesado una cita para esta fecha
      if (!fechasUnicas.contains(fechaString)) {
        fechasUnicas.add(fechaString); // Marcar la fecha como procesada
      }
    }

    print(fechasUnicas);
    return fechasUnicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN LA FECHA EN LAS CUALES HAY CITAS MEDICAS DISPONIBLES MEDIANTE LA ESPECIALIDAD

Future<List<String>> obtenerDiasCitasMedicasPorEspecialidad(
    String? especialidad) async {
  try {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('especialidad', isEqualTo: especialidad)
        .orderBy('fecha')
        .get();

    List<String> fechasUnicas = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosDiaCitaMedica = documentSnapshot.data();
      Timestamp fechaTimestamp = datosDiaCitaMedica['fecha'];
      DateTime fecha = fechaTimestamp.toDate();
      String fechaString =
          "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year.toString().padLeft(2, '0')}"; // Formato dd/mm/yyyy
      // Verificar si ya hemos procesado una cita para esta fecha
      if (!fechasUnicas.contains(fechaString)) {
        fechasUnicas.add(fechaString); // Marcar la fecha como procesada
      }
    }

    print(fechasUnicas);
    return fechasUnicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN LAS CITAS MEDICAS PARA EL DIA SELECCIONADO FILTRADO POR EL RUT DEL PROFESIONAL Y SE OBTIENEN TODOS LOS DATOS NECESARIO A UTILIZAR
Future<List<Map<String, dynamic>>> obtenerCitasMedicasDiaSeleccionadoPorRut(
    String? rut, DateTime fechaCita) async {
  try {
    final stopwatch = Stopwatch()..start();
    DateTime inicioDelDia =
        DateTime(fechaCita.year, fechaCita.month, fechaCita.day);
    DateTime finDelDia =
        DateTime(fechaCita.year, fechaCita.month, fechaCita.day, 23, 59, 59);

    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('rut_profesional', isEqualTo: rut)
        .where('fecha',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
        .orderBy('fecha')
        .get();

    List<Map<String, dynamic>> datosCitasMedicas = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = query.docs;

    String idEspecialidad = docs[0]['especialidad'];

    Map<String, dynamic>? datosEspecialidad =
        await obtenerDatosEspecialidad(idEspecialidad);

    String rutProfesional = docs[0]['rut_profesional'];
    DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
        await FirebaseFirestore.instance
            .collection('profesional')
            .doc(rutProfesional)
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in query.docs) {
      Map<String, dynamic> datosCitaMedica = documentSnapshot.data();

      DateTime fechaCita = datosCitaMedica['fecha'].toDate();
      String fechaCitaFormateada = DateFormat('dd/MM/yyyy').format(fechaCita);

      String horaCita =
          '${fechaCita.hour.toString().padLeft(2, '0')}:${fechaCita.minute.toString().padLeft(2, '0')}';
      String idCitaMedica = documentSnapshot.id;

      datosCitaMedica['horas'] = [horaCita];
      datosCitaMedica['idCita'] = [idCitaMedica];

      datosCitaMedica['nombre_especialidad'] =
          datosEspecialidad?['nombre'] ?? 'Nombre no disponible';

      if (profesionalSnapshot.exists) {
        // Agregar los datos del profesional al mapa 'datosUsuario'
        Map<String, dynamic>? datosProfesional = profesionalSnapshot.data();
        if (datosProfesional != null) {
          datosCitaMedica['nombre_profesional'] = datosProfesional['nombre'];
          datosCitaMedica['apellido_paterno_profesional'] =
              datosProfesional['apellido_paterno'];
          datosCitaMedica['apellido_materno_profesional'] =
              datosProfesional['apellido_materno'];
        } else {
          // ignore: avoid_print
          print(
              "El documento profesional no existe para el rut: $rutProfesional");
        }
      }

      print('Fecha del documento: $fechaCita');

      if (datosCitasMedicas.isEmpty) {
        datosCitasMedicas.add(datosCitaMedica);
      } else if (DateFormat('dd/MM/yyyy')
              .format(datosCitasMedicas[0]['fecha'].toDate()) ==
          fechaCitaFormateada) {
        datosCitasMedicas[0]['horas'].add(horaCita);
        datosCitasMedicas[0]['idCita'].add(idCitaMedica);
      }
    }

    stopwatch.stop();
    print('Tiempo de ejecución: ${stopwatch.elapsedMilliseconds} ms');
    return datosCitasMedicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN LAS CITAS MEDICAS PARA EL DIA SELECCIONADO FILTRADO POR LA ESPECIALIDAD Y SE OBTIENEN TODOS LOS DATOS NECESARIO A UTILIZAR
Future<List<Map<String, dynamic>>>
    obtenerCitasMedicasDiaSeleccionadoPorEspecialidad(
        String? especialidad, DateTime fechaCita) async {
  try {
    final stopwatch = Stopwatch()..start();
    DateTime inicioDelDia =
        DateTime(fechaCita.year, fechaCita.month, fechaCita.day);
    DateTime finDelDia =
        DateTime(fechaCita.year, fechaCita.month, fechaCita.day, 23, 59, 59);

    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('cita_medica')
        .where('disponible', isEqualTo: true)
        .where('especialidad', isEqualTo: especialidad)
        .where('fecha',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = query.docs;

    // Ordenar los resultados después de la consulta
    docs.sort((a, b) {
      int rutComparison = a['rut_profesional'].compareTo(b['rut_profesional']);
      if (rutComparison != 0) {
        return rutComparison;
      } else {
        DateTime fechaA = a['fecha'].toDate();
        DateTime fechaB = b['fecha'].toDate();
        return fechaA.compareTo(fechaB);
      }
    });

    List<Map<String, dynamic>> datosCitasMedicas = [];
    String actualRutProfesional = '';
    int index = -1;
    String idEspecialidad = docs[0]['especialidad'];

    Map<String, dynamic>? datosEspecialidad =
        await obtenerDatosEspecialidad(idEspecialidad);

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot in docs) {
      Map<String, dynamic> datosCitaMedica = documentSnapshot.data();

      DateTime fechaCita = datosCitaMedica['fecha'].toDate();
      String horaCita =
          '${fechaCita.hour.toString().padLeft(2, '0')}:${fechaCita.minute.toString().padLeft(2, '0')}';
      String idCitaMedica = documentSnapshot.id;

      datosCitaMedica['horas'] = [horaCita];
      datosCitaMedica['idCita'] = [idCitaMedica];
      datosCitaMedica['nombre_especialidad'] =
          datosEspecialidad?['nombre'] ?? 'Nombre no disponible';

      if (actualRutProfesional != datosCitaMedica['rut_profesional']) {
        String rutProfesional = datosCitaMedica['rut_profesional'];
        Map<String, dynamic>? datosProfesional =
            await obtenerDatosProfesional(rutProfesional);

        if (datosProfesional != null) {
          datosCitaMedica
            ..['nombre_profesional'] = datosProfesional['nombre']
            ..['apellido_paterno_profesional'] =
                datosProfesional['apellido_paterno']
            ..['apellido_materno_profesional'] =
                datosProfesional['apellido_materno'];
        } else {
          print(
              "El documento profesional no existe para el rut: $rutProfesional");
        }

        datosCitasMedicas.add(datosCitaMedica);
        actualRutProfesional = datosCitaMedica['rut_profesional'];
        index++;
      } else {
        datosCitasMedicas[index]['horas'].add(horaCita);
        datosCitasMedicas[index]['idCita'].add(idCitaMedica);
      }
    }

    // Detener el cronómetro
    stopwatch.stop();
    print('Tiempo de ejecución: ${stopwatch.elapsedMilliseconds} ms');

    return datosCitasMedicas;
  } catch (e) {
    print("Error al obtener datos de la especialidad: $e");
    return [];
  }
}

//SE OBTIENEN TODOS LOS DATOS DE ESPECIALIDAD FILTRADO POR SU ID
Future<Map<String, dynamic>?> obtenerDatosEspecialidad(
    String idEspecialidad) async {
  DocumentSnapshot<Map<String, dynamic>> especialidadSnapshot =
      await FirebaseFirestore.instance
          .collection('especialidad')
          .doc(idEspecialidad)
          .get();

  return especialidadSnapshot.data();
}

Future<Map<String, dynamic>?> obtenerDatosProfesional(
    String rutProfesional) async {
  DocumentSnapshot<Map<String, dynamic>> profesionalSnapshot =
      await FirebaseFirestore.instance
          .collection('profesional')
          .doc(rutProfesional)
          .get();

  return profesionalSnapshot.exists ? profesionalSnapshot.data() : null;
}
