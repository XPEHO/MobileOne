class UserPicture {
  String path;
  String name;

  UserPicture.fromMap(Map<String, dynamic> properties) {
    this.path = properties["path"];
    this.name = properties["name"];
  }
}
