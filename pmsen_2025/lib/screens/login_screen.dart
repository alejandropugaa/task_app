import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController conUser = TextEditingController();
  TextEditingController conPwd = TextEditingController();
  bool isValidating = false;
  @override
  Widget build(BuildContext context) {
    final txtUser = TextField(
      keyboardType: TextInputType.emailAddress,
      controller: conUser,
      decoration: InputDecoration(hintText: 'Usuario'),
    );
    final txtPwd = TextField(
      obscureText: true,
      controller: conPwd,
      decoration: InputDecoration(hintText: 'Contraseña'),
    );
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/fondo2.jpg"),
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 200,
              child: Text(
                'SOLDADO 117',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontFamily: 'Blona',
                ),
              ),
            ),
            Positioned(
              top: 300,
              child: Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    txtUser,
                    SizedBox(height: 20),
                    txtPwd,
                    SizedBox(height: 30),
                    IconButton(
                      onPressed: () {
                        isValidating = true;
                        setState(() {});
                        Future.delayed(Duration(milliseconds: 2000)).then(
                          (value) => Navigator.pushNamed(context, '/home'),
                        );
                      },
                      icon: Icon(Icons.login, size: 35),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 300,
              child: isValidating
                  ? Lottie.asset(
                      'assets/loading.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
