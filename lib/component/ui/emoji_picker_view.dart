import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// ignore: implementation_imports, unnecessary_import
import 'package:emoji_picker_flutter/src/category_emoji.dart' show CategoryEmoji;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// EmojiPicker Implementation
class EmojiPickerView extends EmojiPickerBuilder {
  /// Constructor
  EmojiPickerView(
    Config config,
    EmojiViewState state,
    this.handleSendPressed, {Key? key,}
  ) : super(config, state,key: key,);

  @override
  // ignore: library_private_types_in_public_api
  _EmojiPickerViewState createState() => _EmojiPickerViewState();

  /// See [AttachmentButton.onPressed]
  final void Function()? handleSendPressed;
}

class _EmojiPickerViewState extends State<EmojiPickerView>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;
  TabController? _tabController;

  @override
  void initState() {
    var initCategory = widget.state.categoryEmoji.indexWhere(
        (element) => element.category == widget.config.initCategory);
    if (initCategory == -1) {
      initCategory = 0;
    }
    _tabController = TabController(
        initialIndex: initCategory,
        length: widget.state.categoryEmoji.length,
        vsync: this);
    _pageController = PageController(initialPage: initCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.getEmojiSize(constraints.maxWidth);

        return Container(
          color: widget.config.bgColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      labelColor: widget.config.iconColorSelected,
                      indicatorColor: widget.config.indicatorColor,
                      unselectedLabelColor: widget.config.iconColor,
                      controller: _tabController,
                      labelPadding: EdgeInsets.zero,
                      onTap: (index) {
                        _pageController!.jumpToPage(index);
                      },
                      tabs: widget.state.categoryEmoji
                          .asMap()
                          .entries
                          .map<Widget>((item) =>
                              _buildCategory(item.key, item.value.category))
                          .toList(),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(bottom: 2),
                    icon: Icon(
                      Icons.backspace,
                      color: widget.config.backspaceColor,
                    ),
                    onPressed: () {
                      widget.state.onBackspacePressed!();
                    },
                  ),
                  // IconButton(
                  //   // iconSize: 16,
                  //   onPressed: () {
                  //     widget.handleSendPressed!();
                  //   },
                  //   // backgroundColor: Colors.lightGreen,
                  //   icon: Icon(Icons.send),
                  // ),
                ],
              ),
              Flexible(
                child: PageView.builder(
                  itemCount: widget.state.categoryEmoji.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    _tabController!.animateTo(
                      index,
                      duration: widget.config.tabIndicatorAnimDuration,
                    );
                  },
                  itemBuilder: (context, index) =>
                      _buildPage(emojiSize, widget.state.categoryEmoji[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategory(int index, Category category) {
    return Tab(
      icon: Icon(
        widget.config.getIconForCategory(category),
      ),
    );
  }

  Widget _buildButtonWidget(
      {required VoidCallback onPressed, required Widget child}) {
    if (widget.config.buttonMode == ButtonMode.MATERIAL) {
      return TextButton(
        onPressed: onPressed,
        // ignore: sort_child_properties_last
        child: child,
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      );
    }
    return CupertinoButton(
        padding: EdgeInsets.zero, onPressed: onPressed, child: child);
  }

  Widget _buildPage(double emojiSize, CategoryEmoji categoryEmoji) {
    // Display notice if recent has no entries yet
    if (categoryEmoji.category == Category.RECENT &&
        categoryEmoji.emoji.isEmpty) {
      return _buildNoRecent();
    }
    // Build page normally
    return GridView.count(
      scrollDirection: Axis.vertical,
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      primary: true,
      padding: const EdgeInsets.all(0),
      crossAxisCount: widget.config.columns,
      mainAxisSpacing: widget.config.verticalSpacing,
      crossAxisSpacing: widget.config.horizontalSpacing,
      children: categoryEmoji.emoji
          .map<Widget>((item) => _buildEmoji(emojiSize, categoryEmoji, item))
          .toList(),
    );
  }

  Widget _buildEmoji(
    double emojiSize,
    CategoryEmoji categoryEmoji,
    Emoji emoji,
  ) {
    return _buildButtonWidget(
        onPressed: () {
          widget.state.onEmojiSelected(categoryEmoji.category, emoji);
        },
        child: FittedBox(
          fit: BoxFit.fill,
          child: Text(
            emoji.emoji,
            textScaleFactor: 1.0,
            style: TextStyle(
              fontSize: emojiSize,
              backgroundColor: Colors.transparent,
            ),
          ),
        ));
  }

  Widget _buildNoRecent() {
    return Center(
        child: Text(
      'No Recents'.tr,
      style: const TextStyle(fontSize: 20, color: Colors.black26),
      textAlign: TextAlign.center,
    ),);
  }
}
