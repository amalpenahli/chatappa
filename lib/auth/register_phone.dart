import 'package:chatapp/const/textstyle.dart';
import 'package:chatapp/screen/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../provider/provider.dart';
import 'package:provider/provider.dart';



class RegisterPhone extends StatefulWidget {
  const RegisterPhone({super.key});

  @override
  State<RegisterPhone> createState() => _RegisterPhoneState();
}

class _RegisterPhoneState extends State<RegisterPhone> {
  String phoneCode = "";
  late String verifyId = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/amalo.jpeg"),
                fit: BoxFit.cover),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Please enter phone number", style: registerInputText),
              const SizedBox(height: 20),
              SizedBox(
                  child: IntlPhoneField(
                controller:
                    Provider.of<MyProvider>(context, listen: false).phoneNumber,
                decoration: const InputDecoration(
                  //decoration for Input Field
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                  initialCountryCode: 'AZ', //default contry code, NP for Nepal
                  onChanged: (phone) {
                phoneCode = phone.countryCode ;
               
                  },
              )),
              Container(
                margin: const EdgeInsets.only(
                    top: 20), //make submit button 100% width
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async{
                     
                        verifyPhone();
                        
                    },
                    child: const Text("register"),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Future verifyPhone() async {
    Provider.of<MyProvider>(context, listen: false).phone =
        "$phoneCode${Provider.of<MyProvider>(context, listen: false).phoneNumber.text}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: Provider.of<MyProvider>(context, listen: false).phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('completed');
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.message.toString());
      },
      codeSent: (String id, int? token) {
        verifyId = id;
        print(verifyId);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VerificationPage(phone: "", verificationId: verifyId)));
      },
      codeAutoRetrievalTimeout: (String id) {
       verifyId =id;
      },
      timeout: const Duration(seconds: 60),
    );
  }
}
