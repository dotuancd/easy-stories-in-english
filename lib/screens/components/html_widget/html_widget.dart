import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

class HtmlWidget extends StatelessWidget {
  final String html;

  const HtmlWidget({@required this.html});

  @override
  Widget build(BuildContext context) {
    final document = parse(html);

    List<String> images = [];
    document.querySelectorAll('img').forEach((element) {
      images.add(element.attributes['src']);
      element.replaceWith(dom.Text("{{PLACE_HOLDER_FOR_IMAGE}}"));
    });

    final components = document.body.text.split(
        RegExp(r"{{PLACE_HOLDER_FOR_IMAGE}}")
    );

    final List<Widget> widgets = [];
    for (var i = 0; i < components.length; ++i) {
      var text = components[i];

      var editor = Text(text);

      widgets.add(
        TextSelectionGestureDetector(
          child: editor,
          onSingleLongTapStart: (LongPressStartDetails details) {
            print('onSingleLongTapStart');
            TextSelection(baseOffset: 0, extentOffset: 100);
            RelativeRect position = RelativeRect.fromLTRB(
                details.globalPosition.dx, details.globalPosition.dy, -10, -20
            );
            
            showMenu(context: context, position: position, items: [
                    PopupMenuItem(child: Row(children: <Widget>[
                      PopupMenuItem(child: Text("Add to builder"),)
                    ],),)
              ]);
            print(details);
          },
        )
//            onLongPress: () {
//              print('long_pressed');
//              showMenu(
//                  context: context,
//                  position: RelativeRect.fromLTRB(0, 100, 0, 0),
//                  items: [
//                    PopupMenuItem(child: Row(children: <Widget>[
//                      PopupMenuItem(child: Text("Add to builder"),)
//                    ],),)
//                  ]
//              );
//            },
//          )
      );
      if (i < images.length) {
        widgets.add(Image(image: NetworkImage(images[i]),));
      }
    }

    return Column(
      children: widgets,
    );
  }
}


class CustomToolbarOptions extends ToolbarOptions {
  final bool search;

  CustomToolbarOptions({
    this.search = false,
    copy = false,
    cut = false,
    paste = false,
    selectAll = false,
  }) : super(copy: copy, cut: cut, paste: paste, selectAll: selectAll);
}
