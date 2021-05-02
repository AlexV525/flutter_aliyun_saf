///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-05-02 15:24
///
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

class AliyunSAF {
  factory AliyunSAF() => _instance;

  AliyunSAF._();

  static late final AliyunSAF _instance = AliyunSAF._();

  late final String _accessKeyId;
  late final String _accessKeySecret;

  String? _ip;

  /// 初始化方法，传入对应的 key 和 secret。
  void init(String key, String secret) {
    _accessKeyId = key;
    _accessKeySecret = secret;
  }

  /// 请求风险识别
  ///
  /// ip 初始化失败时不允许请求。
  Future<SAFResponse<SAFLoginProData>?> request(String mobile) async {
    if (_ip == null) {
      await updateIP();
    }
    if (_ip == null) {
      throw AssertionError(
        'Failed to get IP address. Try again or Call updateIP again.',
      );
    }
    final DateTime now = DateTime.now();
    final Map<String, String> params = getParams(mobile, now);
    final String canonicalizationString = canonicalize(params);
    final String signature = _sign('POST', canonicalizationString);
    return _getData(getParams(mobile, now, needsEncode: false), signature);
  }

  /// 获取 ip
  Future<void> updateIP() async {
    final Response res = await get(Uri.parse('https://api.myip.com'));
    final Map<String, dynamic> data = jsonDecode(
      res.body,
    ) as Map<String, dynamic>;
    _ip = data['ip'] as String?;
  }

  Future<SAFResponse<SAFLoginProData>?> _getData(
    Map<String, dynamic> params,
    String signature,
  ) async {
    params['Signature'] = signature;
    try {
      final Response res = await post(
        Uri(
          scheme: 'https',
          host: 'saf.cn-shanghai.aliyuncs.com',
          path: '/',
          queryParameters: params,
        ),
      );
      return SAFResponse<SAFLoginProData>.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  /// 登录风险识别业务参数
  /// https://help.aliyun.com/document_detail/90966.html
  Map<String, String> getServicesParameters(String mobile, DateTime now) {
    return <String, String>{
      'ip': _ip!,
      'mobile': mobile,
      'operateTime': now.toUtc().millisecondsSinceEpoch.toString(),
    };
  }

  /// 公共参数构建
  /// https://help.aliyun.com/document_detail/70058.html
  ///
  /// 注意此处已经将参数按照字母顺序排列，请勿随意更改顺序。
  Map<String, String> getParams(
    String mobile,
    DateTime now, {
    bool needsEncode = true,
  }) {
    return <String, String>{
      'AccessKeyId': _accessKeyId,
      'Action': 'ExecuteRequest',
      'Format': 'JSON',
      'Service': 'account_takeover_pro',
      'ServiceParameters': jsonEncode(getServicesParameters(mobile, now)),
      'SignatureMethod': 'Hmac-SHA1',
      'SignatureNonce': const Uuid().v5(
        Uuid.NAMESPACE_URL,
        now.millisecondsSinceEpoch.toString(),
      ),
      'SignatureVersion': '1.0',
      'Timestamp': getDateString(now),
      'Version': '2020-07-06',
    };
  }

  String getDateString(DateTime now) {
    return now
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'.\d{6}Z$'), 'Z') // 移除多出的毫秒
        .replaceAll(RegExp(r'.\d{3}Z$'), 'Z'); // 移除为 0 时多出的毫秒
  }

  String canonicalize(Map<String, String> _params) {
    final List<String> keys = _params.keys.toList()..sort();
    final Map<String, String> parameters = <String, String>{
      for (final String key in keys) key: _params[key]!,
    };
    String _result = '';
    for (final MapEntry<String, String> entry in parameters.entries) {
      // 先编码 value，再整体进行编码。
      _result += _encode('${entry.key}=${_encode(entry.value)}&');
    }
    // 移除末尾的「&」。
    if (_result.endsWith('%26')) {
      _result = _result.substring(0, _result.length - 3);
    }
    // 全局替换编码出的多余的「25」。
    return _result.replaceAll('%25253A', '%253A');
  }

  /// 编码方法
  /// https://help.aliyun.com/document_detail/94270.htm#topic1854
  ///
  /// 除了文档中说的转换方法以外，还要将所有的「:」转换为「%3A」。
  String _encode(String value) {
    return Uri.encodeComponent(value.replaceAll(':', '%3A'))
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  /// 签名方法
  /// https://help.aliyun.com/document_detail/94270.htm#topic1854
  String _sign(String method, String query) {
    final String waitForSign = '$method&%2F&$query';
    final List<int> key = utf8.encode('$_accessKeySecret&');
    final List<int> bytes = utf8.encode(waitForSign);
    final Hmac hmacSha1 = Hmac(sha1, key);
    final Digest digest = hmacSha1.convert(bytes);
    return base64.normalize(base64Encode(digest.bytes));
  }
}
