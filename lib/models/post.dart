
class Post {
  final int id;

  final String title;

  final String excerpt;

  final String content;

  final int categoryId;

  final DateTime modifiedAt;

  Post({this.id, this.title, this.excerpt, this.content, this.categoryId, this.modifiedAt});

  factory Post.fromJson(Map<String, dynamic>json) {

    return Post(
      id: json['id'],
      title: json['title']['rendered'],
      excerpt: json['excerpt']['rendered'],
      content: json['content']['rendered'],
      categoryId: json['categories'].first,
      modifiedAt: DateTime.parse(json['modified_gmt'])
    );
  }
}