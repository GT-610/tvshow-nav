class TvLink {
  final int? id;
  final String name;
  final String url;

  const TvLink({
    this.id,
    required this.name,
    required this.url,
  });

  TvLink copyWith({
    int? id,
    String? name,
    String? url,
  }) {
    return TvLink(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'url': url,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory TvLink.fromMap(Map<String, dynamic> map) {
    return TvLink(
      id: map['id'],
      name: map['name'],
      url: map['url'],
    );
  }
}
