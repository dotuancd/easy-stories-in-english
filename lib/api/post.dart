import 'dart:convert';

import 'package:esie/models/post.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

enum SortedBy {
  desc,
  asc,
}

Future<List<Post>> fetchPosts(http.Client client, {int categoryId, SortedBy sortedBy = SortedBy.desc}) async {
//  final response = await client.get('https://easystoriesinenglish.com/wp-json/wp/v2/posts');
  Map<String, String> queryParameters = {};

  queryParameters['orderby'] = 'modified';
  queryParameters['order'] = sortedBy == SortedBy.asc ? 'asc' : 'desc';

  if (categoryId != null) {
    queryParameters['categories'] = categoryId.toString();
  }

  final String uri = copyFromUri(Uri.parse("https://easystoriesinenglish.com/wp-json/wp/v2/posts"), queryParameters: queryParameters).toString();

  print({"uri": uri});

//  final response = await client.get(uri);
//
//  final body = response.body;
//
//  final parsed = json.decode(body);

  final body = await fetchFromFile();

  final parsed = json.decode(body).cast<Map<String, dynamic>>();

  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

Uri copyFromUri(Uri uri,
{String scheme,
String userInfo,
String host,
int port,
String path,
Iterable<String> pathSegments,
String query,
Map<String, dynamic /*String|Iterable<String>*/ > queryParameters,
String fragment}
) {
  return Uri(
      scheme: scheme != null ? scheme : uri.scheme,
      userInfo: userInfo != null ? userInfo : uri.userInfo,
      host: host != null ? host : uri.host,
      port: port != null ? port : uri.port,
      path: path != null ? path : uri.path,
      query: query != null? query : uri.query,
      queryParameters: queryParameters != null ? queryParameters : uri.queryParameters,
      fragment: fragment != null ? fragment : (uri.hasFragment ? uri.fragment : null),
  );
}

Future<String> fetchFromFile() async {
    return rootBundle.loadString('data/posts.json');
}

