
import 'package:esie/api/category.dart';
import 'package:esie/api/post.dart';
import 'package:esie/models/category.dart';
import 'package:esie/models/post.dart';
import 'package:esie/screens/components/home/top_filters.dart';
import 'package:esie/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Easy Stories in English'),
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
            trailing: IconButton(
              onPressed: () {
              },
              icon: Icon(
                Icons.favorite_border, color: Colors.green,
              ),
            ),
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