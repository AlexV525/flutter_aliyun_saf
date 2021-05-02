///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-05-02 15:24
///
import 'dart:convert';

/// 如果需要扩展更多的业务参数，将实例在此处映射，以便在请求返回后直接实例化。
final Map<Type, Function> dataModelFactories = <Type, DataFactory>{
  SAFLoginProData: (Map<String, dynamic> json) =>
      SAFLoginProData.fromJson(json),
};

/// 公共返回参数
/// https://help.aliyun.com/document_detail/70058.html#title-p3k-n83-m6f
class SAFResponse<T extends SAFData> {
  const SAFResponse({
    required this.code,
    required this.message,
    required this.requestId,
    this.data,
  });

  factory SAFResponse.fromJson(Map<String, dynamic> json) {
    return SAFResponse<T>(
      requestId: json['RequestId'] as String,
      code: json['Code'] as int,
      message: json['Message'] as String,
      data: json['Data'] != null ? makeModel<T>(json['Data']) : null,
    );
  }

  final int code;
  final String message;
  final String requestId;
  final T? data;

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

abstract class SAFData {
  const SAFData();

  Map<String, dynamic> toJson() => <String, dynamic>{};

  @override
  String toString() => jsonEncode(toJson());
}

class SAFLoginProData extends SAFData {
  const SAFLoginProData({required this.score, required this.tags});

  factory SAFLoginProData.fromJson(Map<String, dynamic> json) {
    return SAFLoginProData(
      score: json['score'] as num,
      tags: json['tags'] as String,
    );
  }

  final num score;
  final String tags;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'score': score, 'tags': tags};
  }
}

typedef DataFactory<T extends SAFData> = T Function(Map<String, dynamic> json);

T makeModel<T extends SAFData>(dynamic json) {
  if (!dataModelFactories.containsKey(T)) {
    print(
      'You\'re reflecting an unregistered/abnormal model type: $T',
    );
    throw TypeError();
  }
  return dataModelFactories[T]!(json) as T;
}
