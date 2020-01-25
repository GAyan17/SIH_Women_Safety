import 'package:flutter/material.dart';
import 'package:story_view/story_controller.dart';
import 'package:story_view/story_view.dart';

import './assets.dart' as assets;

class MoreStories extends StatefulWidget {
  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Stories'),
      ),
      body: StoryView(
        [
          StoryItem.inlineImage(AssetImage(assets.img1),
              caption: Text("Be Safe")),
          StoryItem.inlineImage(AssetImage(assets.img2),
              caption: Text("Be Safe")),
          StoryItem.inlineImage(AssetImage(assets.img3),
              caption: Text("Be Safe")),
          StoryItem.inlineImage(AssetImage(assets.img4),
              caption: Text("Be Safe")),
          StoryItem.inlineImage(AssetImage(assets.img5),
              caption: Text("Be Safe")),
        ],
        onStoryShow: (s) {
          print('showing story');
        },
        onComplete: () {
          print('story completed');
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ),
    );
  }
}
