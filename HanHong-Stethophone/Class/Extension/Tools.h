//
//  Tools.h
//  YuanYu
//
//  Created by  on 2019/5/14.
//  Copyright © 2019 ZhiLun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPSessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject

+ (instancetype)getInstance;
+ (AFHTTPSessionManager *)httpSessionManager;
+ (BOOL)isBlankString:(NSString *)string;
+ (BOOL) IsPhoneNumber:(NSString *)number;
+ (BOOL) IsEmail:(NSString *)email;
#pragma 正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password;
#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName;
#pragma 正则匹配验证码,6位数字
+ (BOOL)checkCodeNumber : (NSString *) number;

+ (BOOL)checkPrice:(NSString *)price;
#pragma 电话号码
+ (BOOL)isTelNum:(NSString *)telNum;

#pragma 正则匹配数字
+ (BOOL)checkNumber:(NSString *)number;
+ (BOOL)checkIntegerNumber:(NSString *)number;

#pragma 正则匹配用户身份证号15或18位
+ (BOOL)checkUserIdCard: (NSString *) idCard;

#pragma 正则匹员工号,12位的数字
+ (BOOL)checkEmployeeNumber : (NSString *) number;

#pragma 正则匹配URL
+ (BOOL)checkURL : (NSString *) url;
// 设置状态栏颜色
+ (void)setStatusBarBackgroundColor:(UIColor *)color;
// 不可变数组转可变数组
+ (NSMutableArray *)arrayToMutableArray:(NSArray *)array;
// 可变数组转不可变数组
+ (NSArray *)mutableArrayToArray:(NSMutableArray *)mutableArray;
// 获取当前版本号
+ (NSString *)getAppVersion;
// 对象转字符串
+ (NSString *)convertToJsonData:(id)dict;
// 字典转NSD啊他
+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;
// 计算年龄
+ (NSString *)calculateAgeStr:(NSString *)dateStr;
// 字符串转字典
+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData;
+ (NSArray *)jsonData2Array:(NSString *)jsonData;
// 计算字符串长度 通过分别计算中文和其他字符来计算长度 中文算2个字符
+ (NSUInteger)getContentLength:(NSString*)content;
// jpg格式图片转Base64字符串
+ (NSString *)jpegImageToString:(UIImage *)image;
// png格式图片转Base64字符串
+ (NSString *)pngImageToString:(UIImage *)image;
// 整型转字符串
+ (NSString *)intToString:(NSInteger)data;
// jpg格式图片转NSData
+ (NSData *)zipNSDataWithImage:(UIImage *)sourceImage;
// 显示提示
+ (void)showWithStatus:(nullable NSString *)string;
// 缩放图片
+ (UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size;
// 图片高斯模糊
+ (UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur;
// 获取字符串的MD5
+ (NSString *) md5 : (NSString *) str;
// 获取当前UIViewController
+ (UIViewController*) currentViewController;
// 获取当前UIViewController的名称
+ (NSString*) currentViewControllerString;
// 返回16位大小写字母和数字
+ (NSString *)returnNumber:(NSInteger)length;
// 获取房间号F
+ (NSInteger)getRoomId;
// 保存图片
+ (void)saveImage:(NSString *)imagePath andImageName:(NSString *)imageName;
// 根据路径删除缓存中的文件
+ (void)deleteFile:(NSString *)path;
// 图片模糊效果
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
// 根据颜色和大小生成图片
+ (UIImage *)viewImageFromColor:(UIColor *)color rect:(CGRect)rect;
// 获取名称的长度
+ (NSInteger)checkNameLength:(NSString *)checkString;
// 根据图片二进制流获取图片格式
+ (NSString *)imageTypeWithData:(NSData *)data;
// 获取6位随机数字串
+ (NSString *)getRamdomString;
// 根据图片名获取缓存中的图片
+ (UIImage *)getCacheImage:(NSString *)imageName;
//year年前的今天
+ (NSDate *)dateWithYearsBeforeNow:(NSInteger)year;
// 时间+分钟
+ (NSString *)dateAddMinuteYMDHM:(NSDate *)date minute:(NSInteger)minute;
+ (NSString *)dateAddMinuteYMD:(NSDate *)date mouth:(NSInteger)mouth;
+ (NSString *)dateAddMinuteYMDHMS:(NSDate *)date minute:(NSInteger)minute;
// 时间字符串转成 yyyy-MM-dd HH:mm:ss
+ (NSDate *)stringToDateYMDHMS:(NSString *)string;
+ (NSDate *)stringToDateHM:(NSString *)string;
+ (NSDate *)stringToDateYMDHM:(NSString *)string;
+ (NSDate *)stringToDateYMD:(NSString *)string;

// 生日时间是否小于最小时间
+ (BOOL)comparisonTimeMinAndBirthDay:(NSDate *)dateMin andDay:(NSString *)birthDay;
// 当前时间转yyyy年MM月
+ (NSString *)dateTransformToTimeStringMonth;
+ (NSString *)dateTransformToTimeStringMonthLine;
// 时间转为yyyy-MM-dd
+ (NSString *)dateToStringYMD:(NSDate *)date;
// 时间转成yyyy-MM
+ (NSString *)dateToStringYM:(NSDate *)date;
+ (NSString *)dateToTimeStringHM:(NSDate *)date;
+ (NSString *)dateToTimeStringYMDHM:(NSDate *)date;
+ (NSString *)dateToTimeStringYMDHMS:(NSDate *)date;
// 时间戳转时间yyyy-MM-dd HH:mm:ss
+ (NSString *)convertTimestampToStringYMDHMS:(long)timestamp;
+ (NSString *)convertTimestampToStringYMDHM:(long)timestamp;

// 时间戳转时间dd HH:mm:ss
+ (NSString *)convertTimestampToStringD:(long)timestamp;
// 当前时间转 yyyyMMdd
+ (NSString *)dateTransformToTimeString;
//根据生日计算年龄
+ (NSDictionary *)getAgeFromBirthday:(NSString *)birthday;
//传入 秒  得到  xx分钟xx秒
+ (NSString *)getMMSSFromSS:(NSInteger)totalTime;
// 获取当前时间戳精确到秒
+ (NSString *)getNowTimeTimestampSecond;
// 获取当前时间yyyy-MM-dd HH:mm:ss
+ (NSString *)getCurrentTimes;
// 获取当前时间戳精确到毫秒
+ (NSString *)getNowTimeTimestampMilliSecond;
+ (long)getTimestampSecond:(NSDate *)date;
+ (long)getTimestampMilliSecond:(NSDate *)date;
// 退出登录
+ (void)logout:(NSString *)message;
// 设置UITextField边框
+ (void)setTextFieldBoard:(UITextField *)textFild;
//获取字符串的高度
+ (CGFloat)getLableHeight:(NSString *)message yyLabel:(YYLabel *)lable lineSpacing:(CGFloat)lineSpace stringFont:(UIFont *)font;
//获取字符串的宽度
+ (CGFloat)getLableWidth:(NSString *)message yyLabel:(YYLabel *)lable stringFont:(UIFont *)font;
//获取富文本
+ (NSMutableAttributedString *)setAttring:(NSString *)text andColor:(nullable UIColor *)color andFont:(nullable UIFont *)font;
//根据地区ID获取地区名
+ (NSString *)getAddressForCode:(NSString *)code;
// 给图片添加文字水印：
+ (UIImage *)jx_WaterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed;
+ (UIImage *)jx_WaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect;
//生成二维码
+ (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size;
//二维码清晰
+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size;
//获取字符串的宽度
+ (CGFloat) widthForString:(NSString *)value fontSize:(CGFloat)fontSize andHeight:(CGFloat)height;
//打开链接
+ (void)openUrl:(NSString *)url;
+ (NSString *)converDataToMacStr:(NSString *)mac;
// 显示提示框
+ (void)showAlertView:(nullable NSString *)title andMessage:(NSString *)message andTitles:(NSArray *)titles andColors:(nullable NSArray *)colors sure:(void (^)(void))completionSure cancel:(nullable void (^)(void))completionCancel;
//获取当前是第几小时
+ (NSInteger)getCurrentHour;
//获取HTTP请求URL中的参数
+ (NSString *)paramerWithURL:(NSURL *) url andParams:(NSString *)param;

+ (BOOL)checkLogisticsCode:(NSString *) logisticsCode;
+(NSString *)base64DecodeString:(NSString *)string;

+ (void)actionToCallCompanyPhone;
+ (NSString *)chineseToPinyin:(NSString *)string;
//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstCharactor:(NSString *)aString;
//计算两个时间的差
+ (NSInteger)insertStarTimeo:(NSString *)time1 andInsertEndTime:(NSString *)time2;
+ (BOOL)validateStr:(NSString *)string withRegex:(NSString *)regex;
+ (NSInteger)compareDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
