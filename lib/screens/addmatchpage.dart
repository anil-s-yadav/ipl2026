import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipl2026/services/auth_service.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedmatchTime = "afternoon";
  bool isLoading = false;

  void _submitData() async {
    if (_teamAController.text.isEmpty ||
        _teamBController.text.isEmpty ||
        _selectedDate == null ||
        _selectedmatchTime.isEmpty) {
      return;
    }

    await AuthService().insertMatch(
      _selectedDate!,
      _teamAController.text,
      _teamBController.text,
      _selectedmatchTime,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Success!")),
    );
    _teamAController.clear();
    _teamBController.clear();
    // _selectedmatch = null;
    _selectedDate = null;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Match")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamAController,
              decoration: InputDecoration(labelText: "Team A"),
            ),
            TextField(
              controller: _teamBController,
              decoration: InputDecoration(labelText: "Team B"),
            ),
            SizedBox(height: 10),
            if (isLoading) CircularProgressIndicator(),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? "Pick Match Date"
                    : DateFormat('dd MMM yyyy').format(_selectedDate!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedmatchTime,
              decoration: InputDecoration(labelText: "Time Slot"),
              items: ["afternoon", "evening"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedmatchTime = newValue!;
                });
              },
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null ||
                    _teamAController.text.isNotEmpty ||
                    _teamBController.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });
                  _submitData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("All field required!!"),
                    ),
                  );
                }
              },
              child: Text("Insert into DB"),
            ),
          ],
        ),
      ),
    );
  }
}
