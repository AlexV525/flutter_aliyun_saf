///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-05-02 15:24
///
import 'dart:convert';

/// 公共返回参数
/// https://help.aliyun.com/document_detail/70058.html#title-p3k-n83-m6f
class SAFResponse {
  const SAFResponse({
    required this.code,
    required this.message,
    required this.requestId,
    this.data,
  });

  factory SAFResponse.fromJson(Map<String, dynamic> json) {
    return SAFResponse(
      requestId: json['RequestId'] as String,
      code: json['Code'] as int,
      message: json['Message'] as String,
      data: json['Data'] != null
          ? SAFData.fromJson(json['Data'] as Map<String, dynamic>)
          : null,
    );
  }

  final int code;
  final String message;
  final String requestId;
  final SAFData? data;

  bool get isSucceed => code == 200 && message == 'OK';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'RequestId': requestId,
      'Code': code,
      'Message': message,
      'Data': data?.toString(),
    }..removeWhere((_, dynamic v) => v == null);
  }

  @override
  String toString() => jsonEncode(toJson());
}

/// 事件返回内容
///
/// 某些事件可能不包含 [score] 字段，默认值为 0。
class SAFData {
  const SAFData({required this.score, required this.tags});

  factory SAFData.fromJson(Map<String, dynamic> json) {
    return SAFData(
      score: json['score'] as num? ?? 0,
      tags: json['tags'] as String,
    );
  }

  final num score;
  final String tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'score': score, 'tags': tags};
  }

  @override
  String toString() => jsonEncode(toJson());
}
