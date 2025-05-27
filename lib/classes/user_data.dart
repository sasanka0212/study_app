import 'package:flutter/material.dart';

class UserData {
  final String id;
  final String name;
  final String email;

  UserData({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserData.fromMap(String id, Map<String, dynamic> data) {
    return UserData(
      id: id,
      name: data['name'] ?? "",
      email: data['email'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
