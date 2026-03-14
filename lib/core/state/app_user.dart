import 'dart:io';

class AppUser {
  static String name = "User";
  static String email = "";
  static String? phone;
  static File? image;

  static void update({
    String? newName,
    String? newEmail,
    String? newPhone,
    File? newImage,
  }) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newPhone != null) phone = newPhone;
    if (newImage != null) image = newImage;
  }

  static void clear() {
    name = "User";
    email = "";
    phone = null;
    image = null;
  }
}
