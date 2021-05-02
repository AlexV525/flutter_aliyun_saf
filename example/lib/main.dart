import 'package:aliyun_saf/aliyun_saf.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _appKeyTEC = TextEditingController();
  final TextEditingController _accessKeyIdTEC = TextEditingController();
  final TextEditingController _accessKeySecretTEC = TextEditingController();
  final TextEditingController _mobileTEC = TextEditingController();

  String get appKey => _appKeyTEC.text;

  String get accessKeyId => _accessKeyIdTEC.text;

  String get accessKeySecret => _accessKeySecretTEC.text;

  String get mobile => _mobileTEC.text;

  void _showSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(content)),
    );
  }

  Future<void> init(BuildContext context) async {
    if (appKey.isEmpty || accessKeyId.isEmpty || accessKeySecret.isEmpty) {
      _showSnackBar(context, '字段未填写完整');
      return;
    }
    await AliyunSAF().init(appKey, accessKeyId, accessKeySecret);
    _showSnackBar(context, 'Inited.');
  }

  Future<void> getSession(BuildContext context) async {
    try {
      _showSnackBar(context, await AliyunSAF().getSession());
    } catch (e) {
      _showSnackBar(context, 'Error when getting session: $e');
    }
  }

  Future<void> request(BuildContext context) async {
    if (mobile.isEmpty) {
      _showSnackBar(context, 'Cannot request empty mobile.');
    }
    final SAFResponse? res = await AliyunSAF().request(mobile);
    if (res == null) {
      _showSnackBar(context, 'Error when requesting since it returns null.');
      return;
    }
    _showSnackBar(context, '${res.data}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Builder(
          builder: (BuildContext c) => Column(
            children: <Widget>[
              TextField(
                controller: _appKeyTEC,
                decoration: const InputDecoration(labelText: 'AppKey'),
              ),
              TextField(
                controller: _accessKeyIdTEC,
                decoration: const InputDecoration(labelText: 'AccessKeyId'),
              ),
              TextField(
                controller: _accessKeySecretTEC,
                decoration: const InputDecoration(labelText: 'AccessKeySecret'),
              ),
              TextButton(
                onPressed: () => init(c),
                child: const Text('Init'),
              ),
              TextButton(
                onPressed: () => getSession(c),
                child: const Text('getSession'),
              ),
              TextField(
                controller: _mobileTEC,
                decoration: const InputDecoration(labelText: 'Mobile number'),
              ),
              TextButton(
                onPressed: () => request(c),
                child: const Text('request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
