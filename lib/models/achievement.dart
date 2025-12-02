import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int requiredValue;
  final int currentValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.requiredValue,
    required this.currentValue,
  });

  double get progress => currentValue / requiredValue;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'unlocked': unlocked,
      'requiredValue': requiredValue,
      'currentValue': currentValue,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      unlocked: json['unlocked'],
      requiredValue: json['requiredValue'],
      currentValue: json['currentValue'],
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    bool? unlocked,
    int? requiredValue,
    int? currentValue,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}