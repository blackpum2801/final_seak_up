class User {
  final String id;
  final String typeLogin;
  final String tokenLogin;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String? password;
  final String refreshToken;
  final String avatar;
  final String role;
  final int level;
  final int totalScore;
  final String gender;
  final String address;
  final String? phoneNumber;
  final String? passwordResetToken;
  final int? passwordResetExpires;
  final String? passwordChangedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.typeLogin,
    required this.tokenLogin,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.password,
    required this.refreshToken,
    required this.avatar,
    required this.role,
    required this.level,
    required this.totalScore,
    required this.gender,
    required this.address,
    this.phoneNumber,
    this.passwordResetToken,
    this.passwordResetExpires,
    this.passwordChangedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        typeLogin: json['typeLogin'],
        tokenLogin: json['tokenLogin'],
        username: json['username'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        password: json['password'],
        refreshToken: json['refreshToken'],
        avatar: json['avatar'],
        role: json['role'],
        level: json['level'],
        totalScore: json['total_score'],
        gender: json['gender'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        passwordResetToken: json['passwordResetToken'],
        passwordResetExpires: json['passwordResetExpires'],
        passwordChangedAt: json['passwordChangedAt'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'typeLogin': typeLogin,
        'tokenLogin': tokenLogin,
        'username': username,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'refreshToken': refreshToken,
        'avatar': avatar,
        'role': role,
        'level': level,
        'total_score': totalScore,
        'gender': gender,
        'address': address,
        'phoneNumber': phoneNumber,
        'passwordResetToken': passwordResetToken,
        'passwordResetExpires': passwordResetExpires,
        'passwordChangedAt': passwordChangedAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
