class UserProperties {
  final String id;
  List<String> cid = [];
  UserProperties({required this.id});
  factory UserProperties.fromMap(String id, Map<String, dynamic> data) {
    return UserProperties(
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cid': cid,
    };
  }
}
