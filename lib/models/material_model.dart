import 'package:flutter/material.dart';

enum ResourceType { book, onlineResource }

/// ResourceModel represents a textbook or online learning resource from the GTU syllabus.
class ResourceModel {
  final String id;
  final String title;
  final ResourceType type;
  final String authorOrOrg;
  final String description;
  final String? url;
  final IconData iconData;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.authorOrOrg,
    required this.description,
    this.url,
    required this.iconData,
  });
}

/// TopicModel represents an individual sub-topic within a GTU syllabus unit.
class TopicModel {
  final String id; // e.g. "1.1"
  final String title; // e.g. "Introduction to Artificial Intelligence"
  final List<String> subtopics; // Detailed bullet items
  final String? learningNotes; // Educational summary notes

  const TopicModel({
    required this.id,
    required this.title,
    required this.subtopics,
    this.learningNotes,
  });
}

/// UnitModel represents one of the 5 GTU syllabus units for AIPE.
class UnitModel {
  final int id;
  final String number; // e.g. "01"
  final String title; // Official unit title
  final String shortDescription;
  final int hours; // Sourced from syllabus (e.g. 6)
  final List<TopicModel> topics;
  bool isCompleted;

  UnitModel({
    required this.id,
    required this.number,
    required this.title,
    required this.shortDescription,
    required this.hours,
    required this.topics,
    this.isCompleted = false,
  });

  UnitModel copyWith({bool? isCompleted}) {
    return UnitModel(
      id: id,
      number: number,
      title: title,
      shortDescription: shortDescription,
      hours: hours,
      topics: topics,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
