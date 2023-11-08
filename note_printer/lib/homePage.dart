
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_printer/printerPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController noteController = TextEditingController();

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Printer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Enter Note'),
              maxLines: 2, // Set the maximum lines to 2
              keyboardType: TextInputType.multiline,
            ),

            SizedBox(height: 20,),


            Text(getCurrentDateTime(),style: TextStyle(fontSize: 14,color: Colors.grey),)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrinterPage(note: noteController.text),
            ),
          );
        },
        child: Icon(Icons.print),
      ),
    );
  }
}


