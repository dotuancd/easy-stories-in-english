
import 'dart:convert';
import 'package:esie/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

Future<List<Category>> fetchCategories(http.Client client) async {
//  final response = await client.get('https://easystoriesinenglish.com/wp-json/wp/v2/categories');

//  if (response.statusCode != 200) {
//    throw Exception('Failed to load categories');
//  }

//  final parsed = json.decode(response.body);
  final body = await fetchFromFile();

  final parsed = json.decode(body).cast<Map<String, dynamic>>();

  return parsed.map<Category>((json) => Category.fromJson(json)).toList();
}

Future<String> fetchFromFile() async {
  return await rootBundle.loadString('data/categories.json');
}
