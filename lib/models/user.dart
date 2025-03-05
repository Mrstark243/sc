class User {
  final String id;
  final String name;
  final String password;
  final String role;
  final String? subject; // Optional for teachers

  User({
    required this.id,
    required this.name,
    required this.password,
    required this.role,
    this.subject,
  });
}
