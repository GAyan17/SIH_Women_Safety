import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import './routing_assets.dart' as routeAsset;

class StroyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) Navigator.of(context).pop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: Text('Self Defence'),
        ),
        body: Container(
          margin: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Container(
                height: 300,
                child: StoryView(
                  [
                    StoryItem.inlineImage(AssetImage('assets/flutter.jpg'),
                        caption: Text(
                          'Be Safe',
                          style: TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                              fontSize: 17),
                        )),
                  ],
                  onStoryShow: (s) {
                    print('showing a story');
                  },
                  onComplete: () {
                    print('completed a story');
                  },
                  progressPosition: ProgressPosition.bottom,
                  repeat: false,
                  inline: true,
                ),
              ),
              Material(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(routeAsset.MoreStoriesScreen);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'View more stories',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
