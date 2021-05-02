# 阿里云风险识别

https://help.aliyun.com/product/69981.html

## 使用步骤

### 初始化

`AliyunSAF().init(ACCESS_KEY_ID, ACCESS_KEY_SECRET);`

### 调用请求

`final SAFResponse<SAFLoginProData>? res = await AliyunSAF().request(${手机号});`
