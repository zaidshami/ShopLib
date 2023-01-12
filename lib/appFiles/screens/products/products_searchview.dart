import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard;
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/category_model.dart';
import '../../models/filter_attribute_model.dart';
import '../../models/filter_tags_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common/drag_handler.dart';
import '../search/widgets/recent/recent_search_custom.dart';
import '../search/widgets/search_box.dart';
import '../search/widgets/search_results_custom.dart';

class ProductSearchView extends StatefulWidget {
  final Widget Function(ScrollController) builder;
  final Widget Function(ScrollController) filterMenu;
  final Widget? bottomSheet;
  final Widget? titleFilter;
  final Function? onSort;
  final Function onFilter;
  final Function onSearch;
  final bool enableSearchHistory;

  const ProductSearchView({
    required this.builder,
    required this.filterMenu,
    required this.onSearch,
    this.bottomSheet,
    this.titleFilter,
    this.onSort,
    required this.onFilter,
    this.enableSearchHistory = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductSearchView> createState() => _ProductSearchViewState();
}

class _ProductSearchViewState extends State<ProductSearchView>
    with AutomaticKeepAliveClientMixin<ProductSearchView> {
  @override
  bool get wantKeepAlive => true;

  final ScrollController controller = ScrollController();

  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  // bool isVisibleSearch = false;
  bool _showResult = false;
  List<String>? _suggestSearch;

  String get _searchKeyword => _searchFieldController.text;

  List<String> get suggestSearch =>
      _suggestSearch
          ?.where((s) => s.toLowerCase().contains(_searchKeyword.toLowerCase()))
          .toList() ??
      <String>[];

  void _onFocusChange() {
    if (_searchKeyword.isEmpty && !_searchFieldNode.hasFocus) {
      _showResult = false;
    } else {
      _showResult = !_searchFieldNode.hasFocus;
    }

    // Delayed keyboard hide and show
    // Future.delayed(const Duration(milliseconds: 120), () {
    //   setState(() {
    //     isVisibleSearch = _searchFieldNode.hasFocus;
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    printLog('[SearchScreen] initState');
    _searchFieldNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    printLog('[SearchScreen] dispose');
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    if (value.isEmpty) {
      _showResult = false;
      setState(() {});
      return;
    }
    if (_searchFieldNode.hasFocus) {
      if (suggestSearch.isEmpty) {
        setState(() {
          _showResult = true;
          EasyDebounce.debounce('searchCategory',
              const Duration(milliseconds: 200), () => widget.onSearch(value));
        });
      } else {
        setState(() {
          _showResult = false;
        });
      }
    }
  }

  Color get labelColor => Colors.black;

  bool showSticky = true;

  bool get isLoggedIn =>
      Provider.of<UserModel>(context, listen: false).loggedIn;

  Widget _getStickyWidget() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState:
          showSticky ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      secondChild: const SizedBox(width: double.maxFinite),
      firstChild: Container(
        alignment: Alignment.center,
        height: 44,
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            widget.titleFilter ?? const SizedBox(),
            const Spacer(),
            const SizedBox(width: 5),
            const VerticalDivider(width: 15, indent: 8, endIndent: 8),
            const SizedBox(width: 5),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Text(S.of(context).filter,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_down, size: 13),
                ],
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.2,
                      maxChildSize: 0.9,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                ),
                                color: Theme.of(context).backgroundColor,
                              ),
                              child: Stack(
                                children: [
                                  const DragHandler(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: widget.filterMenu(scrollController),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  bool _onChangeDirection(scrollNotification) {
    /// scroll down
    if (controller.position.userScrollDirection == ScrollDirection.reverse &&
        controller.offset > 80 &&
        showSticky == true) {
      setState(() {
        showSticky = false;
      });
      return true;
    }

    /// scroll up
    if (controller.position.userScrollDirection == ScrollDirection.forward &&
        showSticky == false) {
      setState(() => showSticky = true);
    }
    return true;
  }

  void onSearch(String value) {
    EasyDebounce.debounce('searchCategory', const Duration(milliseconds: 200),
        () => widget.onSearch(value));
  }

  Material buildResult() {
    return Material(
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onChangeDirection,
            child: widget.builder(controller),
          ),
          _getStickyWidget(),
          Align(
            alignment: Alignment.bottomRight,
            child: widget.bottomSheet,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _suggestSearch =
        Provider.of<AppModel>(context).appConfig!.searchSuggestion ?? [''];

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: false,
      // appBar: _renderAppbar(screenSize),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // _renderHeader(),
            SearchBox(
              // width: widthSearchBox,
              autoFocus: true,
              controller: _searchFieldController,
              focusNode: _searchFieldNode,
              onChanged: _onSearchTextChange,
              onSubmitted: _onSubmit,
              onCancel: () {
                // setState(() {
                //   isVisibleSearch = false;
                // });
              },
            ),
            Expanded(
              child: AutoHideKeyboard(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: _showResult
                        ? buildResult()
                        : Align(
                            alignment: Alignment.topCenter,
                            child: Consumer<FilterTagModel>(
                              builder: (context, tagModel, child) {
                                return Consumer<CategoryModel>(
                                  builder: (context, categoryModel, child) {
                                    return Consumer<FilterAttributeModel>(
                                      builder:
                                          (context, attributeModel, child) {
                                        var child = _buildRecentSearch();

                                        if (_searchFieldNode.hasFocus &&
                                            suggestSearch.isNotEmpty) {
                                          child = _buildSuggestions();
                                        }

                                        return child;
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _renderHeader() {
  //   final screenSize = MediaQuery.of(context).size;
  //   Widget headerContent = const SizedBox(height: 10.0);
  //   headerContent = AnimatedContainer(
  //     height: isVisibleSearch ? 0.1 : 58,
  //     padding: const EdgeInsets.only(
  //       left: 10,
  //       top: 10,
  //       bottom: 10,
  //     ),
  //     duration: const Duration(milliseconds: 150),
  //     curve: Curves.easeInOut,
  //     child: Row(
  //       mainAxisSize: MainAxisSize.max,
  //       children: <Widget>[
  //         Text(
  //           S.of(context).search,
  //           style: Theme.of(context).textTheme.headline5!.copyWith(
  //                 fontWeight: FontWeight.w700,
  //               ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   return SizedBox(
  //     width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
  //     child: headerContent,
  //   );
  // }

  Widget _buildRecentSearch() {
    return RecentSearchesCustom(onTap: _onSubmit);
  }

  Widget _buildSuggestions() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).primaryColorLight,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        itemCount: suggestSearch.length,
        itemBuilder: (_, index) {
          final keyword = suggestSearch[index];

          if (index == 0 && suggestSearch.length > 1) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Text(
                keyword,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                    ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _onSubmit(keyword),
            child: ListTile(
              title: Text(keyword),
            ),
          );
        },
      ),
    );
  }

  Widget buildResult2() {
    return SearchResultsCustom(
      name: _searchKeyword,
    );
  }

  void _onSubmit(String name) {
    _searchFieldController.text = name;
    // final userId = Provider.of<UserModel>(context, listen: false).user?.id;
    setState(() {
      _showResult = true;
      // _searchModel.loadProduct(name: name, userId: userId);

      EasyDebounce.debounce('searchCategory', const Duration(milliseconds: 200),
          () => widget.onSearch(name));
    });
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
