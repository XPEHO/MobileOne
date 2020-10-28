class Categories {
  String id;
  String label;
  bool isDefaultCategory;

  Categories.fromMap(String id, String label, bool isDefaultCategory) {
    this.id = id;
    this.label = label;
    this.isDefaultCategory = isDefaultCategory;
  }
}
