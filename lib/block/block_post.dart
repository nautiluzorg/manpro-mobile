import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/model/post_model.dart';

class BlockPost extends ChangeNotifier {
  List<Post> _post = [];
  List<Post> get listpost => _post;

  set listpost(List<Post> val) {
    _post = val;
    notifyListeners();
  }

//Detail Employee
  Post? _detail;
  Post? get detailpost => _detail;

  set detailpost(Post? val) {
    _detail = val;
    notifyListeners();
  }

  String _id = "";
  String get idPost => _id;

  set idPost(String val) {
    _id = val;
    notifyListeners();
  }

  Future<void> fetchPost() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.12.86:3000/employees'), // Ganti <IP-address>
      );

      if (response.statusCode == 200) {
        List res = jsonDecode(response.body);

        List<Post> data = [];

        for (var item in res) {
          var post = Post.fromJson(item);
          data.add(post);
        }

        listpost = data;
      } else {
        throw Exception(
            'Failed to load posts. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      rethrow;
    }
  }

  Future<Post?> getDetail() async {
    final response = await http.get(
      Uri.parse('http://192.168.12.86:8000/api/employee-detail/$_id'),
    );
    if (response.statusCode == 200) {
      detailpost = Post.fromJson(jsonDecode(response.body));
      return detailpost; // Mengembalikan nilai yang sudah di-set
    } else {
      // Jika response tidak valid, return null atau handle error sesuai kebutuhan
      return null;
    }
  }
}
