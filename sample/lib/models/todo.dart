import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  String? id;
  DateTime createdAt;
  String title;
  bool isReminder;
  bool isDone;
  int? notificationId;

  Todo({
    this.id,
    required this.createdAt,
    required this.title,
    required this.isReminder,
    required this.isDone,
    this.notificationId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  @override
  String toString() {
    return 'Todo{title: $title}';
  }
}
