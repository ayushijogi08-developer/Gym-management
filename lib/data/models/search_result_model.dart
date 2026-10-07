import 'package:flutter/material.dart';
class SearchResultModel {
  final String id;
  final String category; // "member", "payment", "plan", "trainer", "attendance"
  final String title;
  final String? subtitle;
  final IconData icon;
  final dynamic relatedRecord; // The actual object for navigation

  SearchResultModel({
    required this.id,
    required this.category,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.relatedRecord,
  });
}