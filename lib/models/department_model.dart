class DepartmentModel {
  String id;
  String name;

  DepartmentModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    return DepartmentModel(
      id: id,
      name: map['name'],
    );
  }
}
