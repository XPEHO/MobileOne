import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesDao {
  Future<List<Map<String, dynamic>>> getCategories(String userUuid) async {
    List<Map<String, dynamic>> categories = [];

    await FirebaseFirestore.instance
        .collection("defaultCategories")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()["id"] != null && element.data()["label"] != null) {
          categories.add(element.data());
        }
      });
    });

    await FirebaseFirestore.instance
        .collection("userCategory")
        .doc(userUuid)
        .get()
        .then((value) {
      if (value != null && value.data() != null) {
        value.data().forEach((key, value) {
          if (value["id"] != null && value["label"] != null) {
            categories.add(value);
          }
        });
      }
    });

    return categories;
  }

  Future<void> addCategory(
      String userUuid, String categoryUuid, String categoryLabel) async {
    await FirebaseFirestore.instance
        .collection("userCategory")
        .doc(userUuid)
        .set(
      {
        categoryUuid: {
          'id': categoryUuid,
          'label': categoryLabel,
        }
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteCategory(String userUuid, String categoryUuid) async {
    await FirebaseFirestore.instance
        .collection("userCategory")
        .doc(userUuid)
        .update({categoryUuid: FieldValue.delete()});
  }

  Future<void> updateCategory(
      String userUuid, String categoryUuid, String categoryLabel) async {
    await FirebaseFirestore.instance
        .collection("userCategory")
        .doc(userUuid)
        .update({
      categoryUuid: {
        "id": categoryUuid,
        "label": categoryLabel,
      }
    });
  }
}
