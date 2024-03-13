// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

//YA NO SE USA ESTA FUNCION, SE USABA ANTES DE UTILIZAR LA AUTENTICACION DE FIREBASE
//IGNORAR
Future<bool> autenticarUsuario(String rut, String clave) async {
  try {
    // Consultar la colección de usuarios en Firestore
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('paciente')
        .where('rut', isEqualTo: rut)
        .get();
    if (query.docs.isNotEmpty) {
      // Usuario encontrado, verificar la contraseña
      QueryDocumentSnapshot<Map<String, dynamic>> usuario = query.docs.first;
      String claveUsuario = usuario['clave'];

      if (claveUsuario == clave) {
        return true;
      }
    } else {
      return false;
    }
  } catch (e) {
    print("Error al autenticar: $e");
    return false;
  }
  return false;
}
