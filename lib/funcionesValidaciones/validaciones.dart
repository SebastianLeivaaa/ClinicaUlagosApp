//Funcion para validar el formato del telefono
bool validarTelefono(String telefono) {
  RegExp regex = RegExp(r'^9\d{8}$');
  return regex.hasMatch(telefono);
}

//Funcion para validar el formato del correo
bool validarCorreo(String correo) {
  RegExp regex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return regex.hasMatch(correo);
}

//Funcion para validar el rut
bool validarRut(String input) {
  RegExp regex = RegExp(r'^\d{7,8}-[\dkK]$');

  if (regex.hasMatch(input)) {
    List<String> rutSplit = input.split('-');
    String rut = rutSplit[0];
    String digV = rutSplit[1];
    int sum = 0;
    int j = 2;

    if (digV == 'K') {
      digV = 'k';
    }

    for (int i = rut.length - 1; i >= 0; i--) {
      sum += int.parse(rut[i]) * j;
      j++;
      if (j > 7) {
        j = 2;
      }
    }

    int vDiv = sum ~/ 11;
    int vMult = vDiv * 11;
    int vRes = sum - vMult;
    int vFinal = 11 - vRes;

    if (digV == 'k' && vFinal == 10) {
      return true;
    } else if (digV == '0' && vFinal == 11) {
      return true;
    } else if (int.parse(digV) == vFinal) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
