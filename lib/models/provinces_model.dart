class ProvincesModel {
  String id;
  String name;

  ProvincesModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory ProvincesModel.fromMap(String id, Map<String, dynamic> map) {
    return ProvincesModel(
      id: id,
      name: map['name'],
    );
  }
}
