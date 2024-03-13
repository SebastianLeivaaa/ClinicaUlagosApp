import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:clinica_ulagos_app/main.dart';

class RegistrarseExitosoScreen extends StatefulWidget {
  const RegistrarseExitosoScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegistrarseExitosoScreenState createState() =>
      _RegistrarseExitosoScreenState();
}

class _RegistrarseExitosoScreenState extends State<RegistrarseExitosoScreen> {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 400,
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle,
              color: AppColors.check,
              size: 400,
            ),
          ),
          const Text(
            '¡Te has registrado éxitosamente!',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 70),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(), //Redirige a la interfaz principal
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
        ],
      ),
    );
  }
}
