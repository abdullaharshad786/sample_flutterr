import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/todo.dart';

class CrudTodo with ChangeNotifier {
  final Map<DateTime, List<Todo>> _taskItemsMap = {};

  Map<DateTime, List<Todo>> get taskItemsMap {
    return _taskItemsMap;
  }

  Future<void> putTaskItemsToServer(Todo taskItem) async {
    final db = FirebaseFirestore.instance;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        db
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            .add(taskItem.toJson());
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> updateTaskItemToServer(Todo taskItem) async {
    final db = FirebaseFirestore.instance;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        db
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            .doc(taskItem.id)
            .update(taskItem.toJson());
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> deleteTaskItemToServer(Todo taskItem) async {
    final db = FirebaseFirestore.instance;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        db
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            .doc(taskItem.id)
            .delete();
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Stream<List<Todo>>? getTaskItemsFromServer() {
    Stream<List<Todo>>? streamTodos;
    final db = FirebaseFirestore.instance;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        streamTodos = db
            .collection('users')
            .doc(user.uid)
            .collection('todos')
            .snapshots()
            .map((event) => event.docChanges.map((docRef) {
                  if (docRef.type == DocumentChangeType.added) {
                    final doc = docRef.doc.data();
                    Todo todo = Todo.fromJson(doc!);
                    todo.id = docRef.doc.id;
                    final localDate = todo.createdAt.toLocal();
                    final dateKey = DateTime(
                        localDate.year, localDate.month, localDate.day);
                    List<Todo> todos = _taskItemsMap[dateKey] ?? [];
                    todos.add(todo);
                    _taskItemsMap[dateKey] = todos;
                    return todo;
                  } else if (docRef.type == DocumentChangeType.modified) {
                    final doc = docRef.doc.data();
                    Todo todo = Todo.fromJson(doc!);
                    todo.id = docRef.doc.id;
                    final localDate = todo.createdAt.toLocal();
                    final dateKey = DateTime(
                        localDate.year, localDate.month, localDate.day);
                    List<Todo> todos = _taskItemsMap[dateKey] ?? [];
                    todos.removeWhere((task) => task.id == todo.id);
                    todos.add(todo);
                    _taskItemsMap[dateKey] = todos;
                    return todo;
                  } else {
                    final doc = docRef.doc.data();
                    Todo todo = Todo.fromJson(doc!);
                    todo.id = docRef.doc.id;
                    final localDate = todo.createdAt.toLocal();
                    final dateKey = DateTime(
                        localDate.year, localDate.month, localDate.day);
                    List<Todo> todos = _taskItemsMap[dateKey] ?? [];
                    todos.removeWhere((task) => task.id == todo.id);
                    _taskItemsMap[dateKey] = todos;
                    return todo;
                  }
                }).toList());
        notifyListeners();
      }
    } catch (error) {
      debugPrint(error.toString());
    }
    return streamTodos;
  }
}
