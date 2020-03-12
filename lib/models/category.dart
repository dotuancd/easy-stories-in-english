class Category {
  final int id;
  final int count;
  final String description;
  final String link;
  final String name;
  final String taxonomy;
  final int parent;
  final String slug;

  Category({this.id, this.count, this.description, this.link, this.name, this.taxonomy, this.parent, this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      count: json['count'],
      description: json['description'],
      link: json['link'],
      name: json['name'],
      taxonomy: json['taxonomy'],
      parent: json['parent'],
      slug: json['slug'],
    );
  }
}