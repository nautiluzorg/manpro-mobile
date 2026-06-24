class Post {
  final String id_employee;
  final String nrp;
  final String full_name;
  final String division;

  Post({
    required this.id_employee,
    required this.nrp,
    required this.full_name,
    required this.division,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id_employee: json['id_employee'],
      nrp: json['nrp'],
      full_name: json['full_name'],
      division: json['division'],
    );
  }
}
