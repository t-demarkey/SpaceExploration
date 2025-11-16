import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:space_exploration/pages/find_image.dart'; // helps with the dates and times

class NasaPage extends StatefulWidget {  
  const NasaPage({super.key});  

  @override
  NasaPageState createState() => NasaPageState();  
}

class NasaPageState extends State<NasaPage> {  
  final String nasaBase = 'https://apod.nasa.gov/apod/';
  String generatedLink = 'https://apod.nasa.gov/apod/ap250323.html';
  DateTime? selectedDate; // nullable

  String? imageUrl;
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _generateNasaLink();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995, 6, 16),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _generateNasaLink() async {
    if (selectedDate != null) {
      final String yy = DateFormat('yy').format(selectedDate!);
      final String mm = DateFormat('MM').format(selectedDate!);
      final String dd = DateFormat('dd').format(selectedDate!);
      setState(() {
        generatedLink = '${nasaBase}ap$yy$mm$dd.html';
        imageUrl = null;
      });

      String? imgSrc = await findImageElement(generatedLink);
      if (imgSrc != null) {
        setState(() {
          imageUrl = imgSrc;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NASA Pic of the Day')), 
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Photo of the Day:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            SelectableText(
              generatedLink,
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text('Select a date:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null
                      ? 'No date selected'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateNasaLink,
              child: const Text('Generate Photo'),
            ),
            const SizedBox(height: 20),

            if (imageUrl != null)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(12),
                child:Center(
                  child:Image.network(
                imageUrl!,
                width: 400,
                height: 400,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Failed to load image'),
              )))
            else
              const Text('No image loaded'),
              
          ],
        ),
      ),
    );
  }
}
