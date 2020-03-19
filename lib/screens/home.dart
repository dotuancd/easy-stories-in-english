
import 'dart:convert';
import 'dart:io';

import 'package:esie/api/category.dart';
import 'package:esie/api/post.dart';
import 'package:esie/models/category.dart';
import 'package:esie/models/post.dart';
import 'package:esie/screens/components/home/top_filters.dart';
import 'package:esie/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: null,
              decoration: BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.green),
              title: Text("Favorite"),
              enabled: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event_note, color: Colors.green),
              title: Text("Vocabulary Builder"),
              enabled: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title: Text("Settings"),
              enabled: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.green),
              title: Text("Rate us"),
              enabled: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  title: Text("Version 1.1.2"),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Easy Stories in English'),
//        leading: ButtonB,
      ),
      body: HomeScreenWidget(),
    );
  }
}

class HomeScreenWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State {

  int levelFilter;

  SortedBy sortedBy;

  List<Post> posts = new List<Post>();

  bool hasMoreContent = true;

  Map<int, Category> categories = Map<int, Category>();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPosts();
    FavoriteArticleRepository.getInstance().initialize();

    _scrollController.addListener(() {
      final scrolledToBottom = _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
      if (scrolledToBottom && hasMoreContent) {
        _fetchPosts();
        hasMoreContent = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  this.categories.isNotEmpty ? LevelFilter(categories: this.categories.values.toList(), onChanged: (value) {
                    if (this.levelFilter != value) {
                      this.levelFilter = value;
                      this._clearPosts();
                      this._fetchPosts();
                    }
                  },) : Center()
                  ,
                  SortOptionsDropdownButton(onChanged: (value) {
                    if (value != this.sortedBy) {
                      sortedBy = value;
                      this._clearPosts();
                      this._fetchPosts();
                    }
                  },)
                ],
            ),
            Expanded(
              child: this.posts.isNotEmpty
                  ? ArticleList(posts: this.posts, categories: this.categories, controller: _scrollController)
                  : Center(child: CircularProgressIndicator(),),
            )
          ],
        ),
      );
  }

  _clearPosts() {
    setState(() {
      this.posts.clear();
    });
  }

  _fetchPosts() async {
      final posts = await fetchPosts(http.Client(), sortedBy: this.sortedBy, categoryId: this.levelFilter);

      setState(() {
        this.posts.addAll(posts);
      });
  }

  void _fetchCategories() async {
    final categories = await fetchCategories(http.Client());
    categories.insert(0, Category(id: null, name: "All"));

    setState(() {
      this.categories = Map.fromIterable(categories, key: (e) => e.id, value: (e) => e);
    });
  }
}

class ArticleList extends StatelessWidget {

  final List<Post> posts;

  final Map<int, Category> categories;

  final ScrollController controller;

  ArticleList({this.posts, this.categories, this.controller});

  @override
  Widget build(BuildContext context) {

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GridView.count(
      controller: controller,
      crossAxisCount: isLandscape ? 3 : 2,
      childAspectRatio: 3/4,
//      primary: true,
      padding: EdgeInsets.all(10),
      children: this.posts
          .map((Post post) {
          return ArticleItem(post: post, category: this.categories[post.categoryId]);
        }).toList()
    );
  }
}

class ArticleItem extends StatelessWidget {

  final Post post;

  final TextStyle textStyle;

  final Category category;

  ArticleItem({this.post, this.category, this.textStyle});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/posts', arguments: PostScreenArguments(post));
        print('Tapped');
      },
      child: Card(
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.white,
            subtitle: Text(DateFormat('yMd').format(this.post.modifiedAt), style: TextStyle(color: Colors.black54),),
            title: Text(this.category.name, style: TextStyle(color: Colors.black87)),
            trailing: FavouriteArticle(post: this.post),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(this.post.title, style: Theme.of(context).textTheme.headline6, maxLines: 5,),
                Padding(padding: EdgeInsets.symmetric(vertical: 5),),
                Expanded(child: Text(
                  parse(this.post.excerpt).body.text,
                  textAlign: TextAlign.justify,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                ),
                Padding(padding: EdgeInsets.only(top: 10),),
              ],
            ),
          ),
        ),
      ),
    )
    ;
  }
}

class FavouriteArticle extends StatefulWidget {

  final Post post;

  const FavouriteArticle({this.post});

  @override
  State<StatefulWidget> createState() {
    return FavoriteArticleState(post: this.post);
  }
}

class FavoriteArticleRepository {

  static final FavoriteArticleRepository _instance = FavoriteArticleRepository();

  static FavoriteArticleRepository getInstance() {
    return _instance;
  }

  Map<String, dynamic> favorites = {};

  Future<File> get _file async {
    return new File(join((await getApplicationSupportDirectory()).path, "favorites.json"));
  }

  void initialize() async {
    final file = await _file;

    Map<String, dynamic> decoded = json.decode(await file.readAsString());

    favorites.addAll(decoded);

    print(favorites);
  }

  void save() async {
    final file = await _file;
    final json = jsonEncode(favorites);
    file.writeAsString(json);
  }

  FavoriteArticleRepository add(Post post) {
    favorites.addEntries([MapEntry(post.id.toString(), true)]);
    return this;
  }

  FavoriteArticleRepository remove(Post post) {
    favorites.remove(post.id.toString());
    return this;
  }

  FavoriteArticleRepository toggle(Post post) {
    if (this.has(post)) {
      this.remove(post);
    } else {
      this.add(post);
    }

    this.save();

    return this;
  }

  bool has(Post post) {
    return favorites.containsKey(post.id.toString());
  }
}

class FavoriteArticleState extends State {

  bool favorite;

  final Post post;

  final _favoriteRepository = FavoriteArticleRepository.getInstance();

  FavoriteArticleState({this.post});

  @override
  void initState() {
    favorite = _favoriteRepository.has(post);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.red,
      onPressed: () {

        _favoriteRepository.toggle(this.post);

        setState(() {
          this.favorite = !this.favorite;
        });
      },
      icon: Icon(
        favorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.green,
      ),
    );
  }
}

class ArticleListBuilder extends StatelessWidget {

  final String levelFilter;

  final String sortedBy;

  const ArticleListBuilder({this.levelFilter, this.sortedBy});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Post>>(
      future: fetchPosts(http.Client()),
      builder: (context, snapshots) {
        if (snapshots.hasError) {
          print(snapshots.error);
        }

        return snapshots.hasData
            ? ArticleList(posts: snapshots.data,)
            : Center(child: CircularProgressIndicator(),);
      },
    );
  }
}