import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../provider/provider.dart';

class AudioCallPage extends StatefulWidget {
  final String callerId;
  final String receiverId;

  const AudioCallPage({super.key, required this.callerId, required this.receiverId});

  @override
  // ignore: library_private_types_in_public_api
  _AudioCallPageState createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late DatabaseReference _callsRef;

  @override
  void initState() {
    super.initState();
    _callsRef = FirebaseDatabase.instance.ref().child('calls');
    _initiateCall();
  }

  void _initiateCall() {
    // Create a new call record in the database
    DatabaseReference newCallRef = _callsRef.push();

    // Set initial call data
    newCallRef.set({
      'callerId':Provider.of<MyProvider>(context, listen: false).callerId ,
      //'receiverId': Provider.of<MyProvider>(context, listen: false).uid,
      'status': 'ringing',
    });

    // Listen for changes in call status
    newCallRef.onValue.listen((event) {
      // Handle changes in call status
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> callData = snapshot.value as Map<dynamic, dynamic>;
      String callStatus = callData['status'];

      if (callStatus == 'answered') {
        // Call answered, display audio call UI
        // Implement audio call functionality here
      } else if (callStatus == 'ended') {
        // Call ended, cleanup call record and exit audio call UI
        newCallRef.remove();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Audio Call'),
      ),
      body:const Center(
        child: Text('Initiating audio call...'),
      ),
    );
  }
}
