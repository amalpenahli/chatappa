import 'package:chatapp/const/button_style.dart';
import 'package:chatapp/auth/add_name_age.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/provider.dart';
import 'package:provider/provider.dart';


class VerificationPage extends StatefulWidget {
  final String? phone;
  final String? verificationId;
  const VerificationPage({
    Key? key,
    required this.phone,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController pinPutController = TextEditingController();
  late FirebaseAuth _firebaseAuth;
  late final User? currentUser;

  @override
  void initState() {
    _firebaseAuth = FirebaseAuth.instance;
    currentUser = _firebaseAuth.currentUser;

    super.initState();
  }

  //late String _verificationCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/phone_otp.png",
                width: 350,
                height: 350,
              ),
              Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "Verification",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 15,
              ),
              Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                      "Enter the OTP send to number ${Provider.of<MyProvider>(context, listen: false).phoneNumber.text}")),
              const SizedBox(
                height: 15,
              ),
              Pinput(
                length: 6,
                controller: pinPutController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(30, 60, 87, 1),
                      fontWeight: FontWeight.w600),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromRGBO(114, 178, 238, 1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                submittedPinTheme: const PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(30, 60, 87, 1),
                      fontWeight: FontWeight.w600),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(234, 239, 243, 1),
                  ),
                ),
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onSubmitted: (pin) async {
                  // await FirebaseAuth.instance
                  //     .signInWithCredential(PhoneAuthProvider.credential(
                  //         verificationId: _verificationCode, smsCode: pin))
                  //     .then((value) async {
                  //   if (value.user != null) {
                  //     print("go home");
                  //   }
                  // });
                },
              ),
              Row(
                children: [
                  const Text("Code not sent?"),
                  TextButton(onPressed: () {}, child: const Text("resend"))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStylee.otpSubmit,
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      // ignore: use_build_context_synchronously
                      pref.setString(
                          "phone",
                          // ignore: use_build_context_synchronously
                          Provider.of<MyProvider>(context, listen: false)
                              .phone);
                      // ignore: unused_local_variable
                      var phone = pref.getString("phone");
                      
                      singIn();
                      print(currentUser!.uid);
                    },
                    child: const Text("submit")),
              )
            ],
          ),
        ),
      ),
    ));
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 1),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  Future singIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: pinPutController.text);

      // ignore: unused_local_variable
      final UserCredential userData =
          await auth.signInWithCredential(credential);
      // ignore: unused_local_variable
      final User? currentUser = auth.currentUser;
      // assert(userData.user!.uid == currentUser!.uid);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterNameAge()),
      );
      debugPrint("istifadeci yaradildi");
    } catch (e) {
      debugPrint("sehv$e");
    }
  }
}
