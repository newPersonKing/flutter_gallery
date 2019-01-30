
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/*typedef 定义一个方法 dart 语言 方法是最高级的元素*/
typedef UpdateUrlFetcher = Future Function();

class Updater extends StatefulWidget{

  const Updater({ @required this.updateUrlFetcher, this.child, Key key })
      : assert(updateUrlFetcher != null),
        super(key: key);

  final UpdateUrlFetcher updateUrlFetcher;
  final Widget child;

  @override
  State<StatefulWidget> createState()=>UpdaterState();
}

class UpdaterState extends State<Updater>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _checkForUpdates();
  }

  static DateTime _lastUpdateCheck;
  Future<void> _checkForUpdates() async{
    // Only prompt once a day
    if(_lastUpdateCheck!=null &&
       DateTime.now().difference(_lastUpdateCheck)<const Duration(days: 1)){
      return;
    }
    _lastUpdateCheck = DateTime.now();

    final String updateUrl = await widget.updateUrlFetcher();

    if (updateUrl != null) {
      final bool wantsUpdate = await showDialog<bool>(context: context, builder: _buildDialog);
      if (wantsUpdate != null && wantsUpdate)
        launch(updateUrl);
    }
  }

  Widget _buildDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
    theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return AlertDialog(
      title: const Text('Update Flutter Gallery?'),
      content: Text('A newer version is available.', style: dialogTextStyle),
      actions: <Widget>[
        FlatButton(
          child: const Text('NO THANKS'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('UPDATE'),
          onPressed: () {
            Navigator.pop(context, true); /*关闭当前页面  并返回一个值 这里返回的就是  true*/
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
   return  widget.child;
  }
}

