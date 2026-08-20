class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? avatarUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? json['userName'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'avatarUrl': avatarUrl,
      };
}