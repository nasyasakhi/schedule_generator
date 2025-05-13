import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/models/task.dart';

class GeminiService {
  //untuk gerbang awal antara klien dan server
  // client --> kode project
  // server --> gemini API
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final String apiKey;
  // ini sebuah ternary operator untuk memastikan API key ada nilainya(tersedia) atau tidak(kosong)
  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot is missing');
    }
  }

  // Logika untuk generate input result dari input yang diberikan
  // klo pake _ namanya static
  Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);

    // variable yg digunakan untuk menampung prompt request yang akan dieksekusi AI
    final prompt = _buildPrompt(tasks);
    //percobaan pengiriman request ke AI
    try {
      print("Prompt: \n$prompt");
      // variabel untuk menampung respon dari request ke API AI
      final response = await http.post(
          // starting point untuk penggunaan endpoint dari API
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "contents": [
              {
                // role disini adalah seorang yang memberikan instruksi kepada AI melalui prompt
                "role": "user",
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          }));
          return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }

  String _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    /* Switch adalah salah satu cabang dari perkondisian yang berisi statement general
    yang dapat dieksekusi oleh berbagai macam action, tanpa harus bergantung pada 
    single-statement yang dimiliki oleh setiap action yang ada pada parameter "case"
    */
    switch (response.statusCode) {
      case 200:
          return data["candidates"][0]["content"]["parts"][0]["text"];
      case 404:
          throw ArgumentError("Server Not Found");
      case 500:
          throw ArgumentError("Internal Server Error");
      default:
      throw ArgumentError('Unknown Error: ${response.statusCode}');
    }
    }

    String _buildPrompt(List<Task> task) {
      //berfungsi untuk menyetting format tanggal dan waktu lokal(indonesia)
      initializeDateFormatting();
      final dateFormatter = DateFormat("dd mm yyy 'pukul' hh:mm, 'id_ID");

      final taskList = task.map((task) {
        final formatDeadline = dateFormatter.format(task.deadline);

        return " - ${task.name} (Duration: ${task.duration} minutes, Deadline: $formatDeadline)";
      });
     // multiple string dengan multiple approaches
    // menggunakan framework RTA(role, task, action) untuk buat prompt
      return '''
      Saya adalah seorang siswa, dan saya memiliki daftar sebagai berikut:

      $taskList

      Tolong susun jadwal yang optimal dan efisien berdasarkan daftar tugas tersebut.
      Tolong tentukan prioritasnya berdasarkan *deadline yang paling dekat* dan durasi tugas.
      Tolong buat jadwal yang sistematis dari pagi hari, sampai malam hari.
      Tolong pastikan semua tugas dapat selesai sebelum deadlline.

      Tolong buatkan output jadwal dalam format list per jam, misalnya:
      - 07.00 - 08.00 : Melaksanakan piket kamar
      ''';
    }

    void _validateTasks(List<Task> task) {
      //ini merupakan bentuk dari single statement dari if-else condition
      if(task.isEmpty) throw ArgumentError("Please input your task before generating");
    }

  }

  /* KESIMPULAN :
  1. klo mau buat apk yg ada api wajib ada service dan  model
  - Apiservice : service
  - Apiclient : model
  */
