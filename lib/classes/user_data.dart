class UserData {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  List<String> cid = [];

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = "",
  });

  factory UserData.fromMap(String id, Map<String, dynamic> data) {
    return UserData(
      id: id,
      name: data['name'] ?? "",
      email: data['email'] ?? "",
      photoUrl: data['photoUrl'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'cid': cid,
    };
  }
}
