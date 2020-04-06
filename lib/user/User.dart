class User {
  String key;
  String profilePictureURL;
  bool isNew;
  bool isLoggedIn = false;

  User();

  void logIn(userStatus) {
    this.isLoggedIn = true;
    this.isNew = userStatus.isNew;
  }

}