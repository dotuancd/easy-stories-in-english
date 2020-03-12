
import 'package:esie/models/post.dart';
import 'package:esie/screens/components/html_widget/html_widget.dart';
import 'package:esie/screens/components/player/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final PostScreenArguments args = ModalRoute.of(context).settings.arguments;

    final Post post = args.post;

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: HtmlWidget(html: post.content),
            ),
          ),

          // Audio will be appearing here
          AudioFutureBuilder(post: post,)
        ],
      ),
    );
  }
}

class AudioFutureBuilder extends StatelessWidget {

  final Post post;

  AudioFutureBuilder({this.post});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: () async {
          final response = await http.get('https://easystoriesinenglish.com/?powerpress_pinw=${post.id}-podcast');

          final source = parse(response.body).querySelector('.wp-audio-shortcode source');

          return source != null ? source.attributes['src'] : '';
        }(),
        builder: (context, snapshot) {

          final bool isMissingAudio = snapshot.hasData && snapshot.data.isEmpty;

          if (snapshot.hasError || isMissingAudio) {
            return Container();
          }

          if (snapshot.hasData) {
            return Container(
              child: PlayerWidget(url: snapshot.data,),
              height: 70,
            );
          }

          return LinearProgressIndicator();
        });
  }
}

class PostScreenArguments {
  final Post post;

  PostScreenArguments(this.post);
}