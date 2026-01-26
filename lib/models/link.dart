class TvLink {
  final int id;
  final String name;
  final String url;

  TvLink({
    required this.id,
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  factory TvLink.fromMap(Map<String, dynamic> map) {
    return TvLink(
      id: map['id'],
      name: map['name'],
      url: map['url'],
    );
  }
}
