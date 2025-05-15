class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? telephone;
  final String? specialite;
  final String? profilePicture;
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.telephone,
    this.specialite,
    this.profilePicture,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      telephone: json['telephone'],
      specialite: json['specialite'],
      profilePicture: json['profilePicture'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'telephone': telephone,
      'specialite': specialite,
      'profilePicture': profilePicture,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
}
