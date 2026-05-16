class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? address;
  final String? phone;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'address': address,
      'phone': phone,
    };
  }
}
