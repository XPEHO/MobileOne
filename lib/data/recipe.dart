import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String label;
  Timestamp timestamp;
  String recipeUuid;

  Recipe.fromMap(String recipeUuid, Map<String, dynamic> properties) {
    this.recipeUuid = recipeUuid;
    this.label = properties["label"];
    this.timestamp = properties["timestamp"];
  }
}
