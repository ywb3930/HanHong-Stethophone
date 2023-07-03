//
//  Tools.m
//  YuanYu
//
//  Created by  on 2019/5/14.
//  Copyright © 2019 ZhiLun. All rights reserved.
//

#import "Tools.h"
#import "AppDelegate.h"
#import <Accelerate/Accelerate.h>
#import <CommonCrypto/CommonDigest.h>

@implementation Tools
static id _instance;
+ (instancetype)getInstance{
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}
+ (NSString *) md5 : (NSString *) str {
    // 判断传入的字符串是否为空
    if (! str) return nil;
    // 转成utf-8字符串
    const char *cStr = str.UTF8String;
    // 设置一个接收数组
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    // 对密码进行加密
    CC_MD5(cStr, (CC_LONG) strlen(cStr), result);
    NSMutableString *md5Str = [NSMutableString string];
    // 转成32字节的16进制
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}



+(BOOL)isBlankString:(NSString *)string{
    NSString * newSelf = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(nil == self
       || string.length ==0
       || [string isEqualToString:@""]
       || [string isEqualToString:@"<null>"]
       || [string isEqualToString:@"(null)"]
       || [string isEqualToString:@"null"]
       || newSelf.length ==0
       || [newSelf isEqualToString:@""]
       || [newSelf isEqualToString:@"<null>"]
       || [newSelf isEqualToString:@"(null)"]
       || [newSelf isEqualToString:@"null"]
       || [self isKindOfClass:[NSNull class]] ){
        
        return YES;
        
    }else{
        // <object returned empty description> 会来这里
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [string stringByTrimmingCharactersInSet:set];
        
        return [trimedString isEqualToString: @""];
    }
    
    return NO;
}

+(NSMutableArray *)arrayToMutableArray:(NSArray *)array{
    NSArray *mutableArray = [array mutableCopy];
    return [NSMutableArray arrayWithArray:mutableArray];
}
+(NSArray *)mutableArrayToArray:(NSMutableArray *)mutableArray{
    NSArray *array = [mutableArray copy];
    return [NSArray arrayWithArray: array];
}

+ (BOOL) IsEmail:(NSString *)email{
    NSString *emailRegex1=@"^[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$";
    NSPredicate *emailTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex1];
    return  [emailTest1 evaluateWithObject:email];
}
#pragma 正则手机号
+ (BOOL) IsPhoneNumber:(NSString *)number
{
    NSString *phoneRegex1=@"^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|191|(147))\\d{8}$";
    NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
    return  [phoneTest1 evaluateWithObject:number];
}
#pragma 电话号码
+ (BOOL)isTelNum:(NSString *)telNum{
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextesTel = [NSPredicate predicateWithFormat:@"SELF     MATCHES %@", PHS];
    if ([regextesTel evaluateWithObject:telNum]) {
        return YES;
    }else{
        return NO;
    }
}
// MARK: 正则表达式车牌号
+ (BOOL)IsCarNumber:(NSString *)carNum{
    NSString *carRegex1=@"^([京津晋冀蒙辽吉黑沪苏浙皖闽赣鲁豫鄂湘粤桂琼渝川贵云藏陕甘青宁新][ABCDEFGHJKLMNPQRSTUVWXY][1-9DF][1-9ABCDEFGHJKLMNPQRSTUVWXYZ]\\d{3}[1-9DF]|[京津晋冀蒙辽吉黑沪苏浙皖闽赣鲁豫鄂湘粤桂琼渝川贵云藏陕甘青宁新][ABCDEFGHJKLMNPQRSTUVWXY][\\dABCDEFGHJKLNMxPQRSTUVWXYZ]{5})$";
    NSPredicate *carTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex1];
    return [carTest1 evaluateWithObject:carNum];
}

+ (BOOL)checkPassword:(NSString *) password
{
    //8-20位字母和数字组合 
    NSString*pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,20}";
    //NSString *pattern = @"^[\\w_-]{8,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

+ (BOOL)checkLogisticsCode:(NSString *) logisticsCode{
    NSString *pattern = @"^[0-9a-zA-Z]+$";
    //NSString *pattern = @"^[\\w_-]{8,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:logisticsCode];
    return isMatch;
}

+(BOOL)checkPrice:(NSString *)price{
    NSString *pattern = @"^([1-9]\\d*|0)(\\.\\d?[1-9])?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:price];
    return isMatch;
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
     if (@available(iOS 13.0, *)) {
         if(![HHLoginManager sharedManager].statusBar){
             [[HHLoginManager sharedManager] initStatusBar];
         }
         [HHLoginManager sharedManager].statusBar.backgroundColor = color;
     } else {
         UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
         if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
             statusBar.backgroundColor = color;
         }
     }
}

+(NSString *)getAppVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

+(AFHTTPSessionManager *)httpSessionManager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 1.0f;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

+(NSString *)getNowTimeTimestampSecond{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

+ (long)getTimestampSecond:(NSDate *)date{
    return (long)[date timeIntervalSince1970];
}

+ (long)getTimestampMilliSecond:(NSDate *)date{
    return (long)([date timeIntervalSince1970]*1000);
}

+(NSString *)getNowTimeTimestampMilliSecond{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}

+(NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            DDLogError(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        DDLogError(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+(NSString *)convertToJsonData:(id)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        DDLogError(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}


+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        DDLogError(@"Json parse failed: %@", jsonData);
        return nil;
    }
    return dic;
}

+ (NSArray *)jsonData2Array:(NSString *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![array isKindOfClass:[NSArray class]]) {
        DDLogError(@"Json parse failed: %@", jsonData);
        return nil;
    }
    return array;
}


//通过分别计算中文和其他字符来计算长度
+ (NSUInteger)getContentLength:(NSString*)content {
    size_t length = 0;
    for (int i = 0; i < [content length]; i++){
        unichar ch = [content characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff){
            length += 2;
        }
        else {
            length++;
        }
    }
    
    return length;
}

//#pragma 正则匹配用户密码8-18位数字和字母组合
//+ (BOOL)checkPassword:(NSString *) password
//{
//    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,18}";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
//    BOOL isMatch = [pred evaluateWithObject:password];
//    return isMatch;
//}

#pragma 正则匹配用户姓名,20位的中文或英文
//+ (BOOL)checkUserName : (NSString *) userName
//{
//    NSString *pattern = @"^[\\w\\-－＿[０-９]\u4e00-\u9fa5\uFF21-\uFF3A\uFF41-\uFF5A]+$";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
//    BOOL isMatch = [pred evaluateWithObject:userName];
//    return isMatch;
//}
#pragma 请输入2-18位汉字和英文字母字符
+ (BOOL)checkUserName:(NSString *) userName
{
    NSString *pattern = @"[\u4e00-\u9fa5_a-zA-Z]{2,18}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:userName];
    return isMatch;
    
}

#pragma 正则匹配用户身份证号15或18位
+ (BOOL)checkUserIdCard:(NSString *) idCard
{
    //NSString *pattern1 = @"^(\\d{14}|\\{17})(\\d|[xX])$";
    NSString *pattern = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCard];
    return isMatch;
}

#pragma 正则匹验证码,6位的数字
+ (BOOL)checkCodeNumber:(NSString *) number
{
    NSString *pattern = @"^[0-9]{6}";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:number];
    return isMatch;
    
}

#pragma 正则匹员工号,12位的数字
+ (BOOL)checkEmployeeNumber:(NSString *) number
{
    NSString *pattern = @"^[0-9]{12}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:number];
    return isMatch;
    
}
#pragma 正则匹配数字
+(BOOL)checkNumber:(NSString *)number {
    if (number.length == 0)
        return NO;
    NSString *regex = @"^[0-9]+([.]{0,1}[0-9]+){0,1}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:number];
}

+ (BOOL)checkIntegerNumber:(NSString *)number{
    NSString *regex = @"^+?[1-9][0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:number];
}


#pragma 正则匹配URL
+ (BOOL)checkURL : (NSString *) url
{
    NSString *reg = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return [urlPredicate evaluateWithObject:url];
}

//计算年龄
+(NSString *)calculateAgeStr:(NSString *)dateStr{
    //截取身份证的出生日期并转换为日期格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-mm-dd";
    NSDate *birthDate =  [formatter dateFromString:dateStr];
    NSTimeInterval dateDiff = [birthDate timeIntervalSinceNow];
    
    // 计算年龄
    int age  =  trunc(dateDiff/(60*60*24))/365;
    NSString *ageStr = [NSString stringWithFormat:@"%d", -age];
    
    return ageStr;
}

+(NSString *)jpegImageToString:(UIImage *)image {
    NSData *imagedata = [self zipNSDataWithImage:image];//UIImagePNGRepresentation(image);
    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return image64;
}

+(NSString *)pngImageToString:(UIImage *)image {
    NSData *imagedata = UIImagePNGRepresentation(image);
    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return image64;
}

+(NSString *)intToString:(NSInteger)data{
    return [NSString stringWithFormat:@"%li",(long)data];
}

+(NSData *)zipNSDataWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    
//    sourceImage = [self jx_WaterImageWithImage:sourceImage text:@"易得宝" textPoint:CGPointMake(width - 50, height-40) attributedString:@{NSForegroundColorAttributeName:WHITECOLOR,NSBackgroundColorAttributeName:HEXCOLOR(0x333333, 0.4),NSFontAttributeName:Font13}];
    
    //1.宽高大于MAXLENGTH(宽高比不按照2来算，按照1来算)
    if (width>MAXLENGTH||height>MAXLENGTH) {
        if (width>height) {
            CGFloat scale = height/width;
            width = MAXLENGTH;
            height = width*scale;
        }else{
            CGFloat scale = width/height;
            height = MAXLENGTH;
            width = height*scale;
        }
        
    }else if(width<MAXLENGTH&&height<MAXLENGTH){
        //2.宽大于MAXLENGTH高小于MAXLENGTH
    }
    else if(width>MAXLENGTH||height<MAXLENGTH){
        CGFloat scale = height/width;
        width = MAXLENGTH;
        height = width*scale;
        //3.宽小于MAXLENGTH高大于MAXLENGTH
    }else if(width<MAXLENGTH||height>MAXLENGTH){
        CGFloat scale = width/height;
        height = MAXLENGTH;
        width = height*scale;
        //4.宽高都小于MAXLENGTH
    }else{
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(newImage, 1.0);
    NSInteger i = 1;
   // while (data.length > 10 * 1024) {
        data=UIImageJPEGRepresentation(newImage, 0.1);
       // i++;
   // }
//    if (data.length>10*1024) {
//        if (data.length>1024*1024) {//1M以及以上
//
//        }else if (data.length>512*1024) {//0.5M-1M
//            data=UIImageJPEGRepresentation(newImage, 0.8);
//        }else if (data.length>200*1024) {
//            //0.25M-0.5M
//            data=UIImageJPEGRepresentation(newImage, 0.9);
//        }
//    }
    return data;
}

+(void)showWithStatus:(NSString *)string{
    [SVProgressHUD showWithStatus:string];
}


//创建高斯模糊效果图片
+ (UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        DDLogError(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        DDLogError(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}


/**
 *缩放图片
 */
+ (UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *裁剪图片
 */
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}


+(NSString *)dateTransformToTimeString
{
    NSDate *currentDate = [NSDate date];//获得当前时间为UTC时间 2014-07-16 07:54:36 UTC  (UTC时间比标准时间差8小时)
    //转为字符串
    NSDateFormatter*df = [[NSDateFormatter alloc]init];//实例化时间格式类
    [df setDateFormat:@"yyyyMMdd"];//格式化
    //2014-07-16 07:54:36(NSString类)
    NSString *timeString = [df stringFromDate:currentDate];
    return timeString;
}

+(NSString *)dateTransformToTimeStringMonth{
    NSDate *currentDate = [NSDate date];//获得当前时间为UTC时间 2014-07-16 07:54:36 UTC  (UTC时间比标准时间差8小时)
    //转为字符串
    NSDateFormatter*df = [[NSDateFormatter alloc]init];//实例化时间格式类
    [df setDateFormat:@"yyyy年MM月"];//格式化
    //2014-07-16 07:54:36(NSString类)
    NSString *timeString = [df stringFromDate:currentDate];
    return timeString;
}

//根据生日计算年龄
+ (NSDictionary *)getAgeFromBirthday:(NSString *)birthday{
    NSDate *birthdayDate = [Tools stringToDateYMD:birthday];
    NSDate *now = [NSDate now];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //NSCalendarUnitMinute
    NSDateComponents *componentsAge = [calendar components:NSCalendarUnitYear fromDate:birthdayDate toDate:now options:0];
    NSDateComponents *componentsMonth = [calendar components:NSCalendarUnitMonth fromDate:birthdayDate toDate:now options:0];
        
    return @{@"age": [@(componentsAge.year) stringValue], @"month": [@(componentsMonth.month-componentsAge.year*12) stringValue]};
}

+(NSString *)dateTransformToTimeStringMonthLine{
    NSDate *currentDate = [NSDate date];//获得当前时间为UTC时间 2014-07-16 07:54:36 UTC  (UTC时间比标准时间差8小时)
    //转为字符串
    NSDateFormatter*df = [[NSDateFormatter alloc]init];//实例化时间格式类
    [df setDateFormat:@"yyyy-MM"];//格式化
    //2014-07-16 07:54:36(NSString类)
    NSString *timeString = [df stringFromDate:currentDate];
    return timeString;
}

//传入 秒  得到  xx分钟xx秒
+(NSString *)getMMSSFromSS:(NSInteger)totalTime{
    //NSInteger seconds = [totalTime integerValue];
    //NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(totalTime%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",totalTime%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}


+(UIViewController*) findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        return vc;
    }
}

+(UIViewController*) currentViewController {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}

+(NSString*) currentViewControllerString{
    UIViewController *view = [self currentViewController];
    return NSStringFromClass([view class]);
}


//返回16位大小写字母和数字
+(NSString *)returnNumber:(NSInteger)length{
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789";
    //定义一个结果
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < length; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
}

+(NSInteger)getRoomId{
    NSString *time = [self getNowTimeTimestampSecond];
    NSString *time5 = [time substringWithRange:NSMakeRange(5, 5)];
    NSString *stringRandom = [self returnNumber:4];
    NSString *result = [NSString stringWithFormat:@"%@%@",time5,stringRandom];
    return [result integerValue];
}

// 保存背景 聊天背景 图片
+ (void)saveImage:(NSString *)imagePath andImageName:(NSString *)imageName{
    NSURL *url = [NSURL URLWithString:imagePath];
    __weak typeof(self) ws = self;
    [self downLoadImage:url imageBlock:^(UIImage *image) {
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *preferencePath =[[libraryPaths lastObject] stringByAppendingPathComponent:@"Preferences"];
        [ws saveImage:image withFileName:imageName ofType:@".jpg" inDirectory:preferencePath ];
    } errorBlock:^{
        
    }];
}

+(UIImage *)getCacheImage:(NSString *)imageName{
   // NSString *imageName = [[NSUserDefaults standardUserDefaults] objectForKey:@"imbgView"];
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *preferencePath =[[libraryPaths lastObject] stringByAppendingPathComponent:@"Preferences"];
    NSString *filePath = [preferencePath stringByAppendingPathComponent:imageName];
    // 2. 是否是文件夹，默认不是
    BOOL isDirectory = NO;
    // 3. 判断文件是否存在
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isExist && ![Tools isBlankString:imageName]) {
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        return [[UIImage alloc] initWithData:imageData];
    } else {
        return nil;
    }
}

+ (void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath{
    NSString *filePath = [NSString stringWithFormat:@"%@.%@", imageName, @"jpg"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:filePath] options:NSAtomicWrite error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:@"imbgView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void)downLoadImage:(NSURL *)url imageBlock:(void (^)(UIImage *image))imageBlock errorBlock:(void (^)(void))errorBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image != nil) {
                imageBlock(image);
            } else {
                errorBlock();
            }
        });
    });
}

+(void)deleteFile:(NSString *)path{
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSString *filePath = nil;
    NSError *error = nil;
    for (NSString *subPath in subPathArr)
    {
        filePath = [path stringByAppendingPathComponent:subPath];
        //删除子文件夹
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
        }
    }
}
//时间戳变为格式时间
+(NSString *)convertTimestampToStringYMDHMS:(long)timestamp{
    //long long time=[timestamp longLongValue];
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}
+ (NSString *)convertTimestampToStringYMDHM:(long)timestamp{
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}

+(NSString *)convertTimestampToStringD:(long)timestamp{
    //long long time=[timestamp longLongValue];
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"dd"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}

+ (NSDate *)stringToDateYMD:(NSString *)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

+(NSDate *)stringToDateYMDHMS:(NSString *)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

+(NSDate *)stringToDateHM:(NSString *)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

+(NSDate *)stringToDateYMDHM:(NSString *)string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        DDLogError(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

+(UIImage *)viewImageFromColor:(UIColor *)color rect:(CGRect)rect{
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSDate *)converAdd8HourNowDate{
    NSDate *currentDate  = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8*60*60];
    [formatter setTimeZone:timeZone];;
    NSString *s = [formatter stringFromDate:currentDate];
    NSDate *date = [Tools stringToDateYMDHMS:s];
    return date;
}


+ (NSString *)converDataToMacStr:(NSString *)mac{
    NSString *result = [[NSString alloc] init];
    mac = [mac substringFromIndex:4];
    for(int i = 0; i < mac.length/2; i++) {
        NSString *y = [mac substringWithRange:NSMakeRange(i*2, 2)];
        
        result = [result stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"%@:",y]];
    }
    result = [result substringToIndex:result.length - 1];
    result = [result uppercaseString];
    return result;
}

+(NSDate *)dateWithYearsBeforeNow:(NSInteger)year{
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
    [dateComponents setYear:year * -1];
   
    return [calendar dateByAddingComponents:dateComponents toDate:date options:0];
}

+ (NSString *)dateAddMinuteYMD:(NSDate *)date mouth:(NSInteger)mouth{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:date];
    [dateComponents setMonth:mouth];
    NSDate *moutheDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return [self dateToTimeStringYMD:moutheDate];
}

+(NSString *)dateToTimeStringYMD:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}


+ (NSString *)dateAddMinuteYMDHM:(NSDate *)date minute:(NSInteger)minute{
    //NSDate *currentDate  = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:date];
    [dateComponents setMinute:minute];
    NSDate *minuteDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return [self dateToTimeStringYMDHM:minuteDate];
}

+ (NSString *)dateAddMinuteYMDHMS:(NSDate *)date minute:(NSInteger)minute{
    //NSDate *currentDate  = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:date];
    [dateComponents setMinute:minute];
    NSDate *minuteDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return [self dateToTimeStringYMDHMS:minuteDate];
}

+(BOOL)IsChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i]; if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    } return NO;
}


+(NSString *)dateToStringYMD:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

+(NSString *)dateToTimeStringYMDHMS:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

+(NSString *)dateToTimeStringYMDHM:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

+(NSString *)dateToTimeStringHM:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"HH:mm"];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
   // [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

+(NSString *)dateToStringYM:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy-MM"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //现在时间,你可以输出来看下是什么格式
    //----------将nsdate按formatter格式转成nsstring
    return [formatter stringFromDate:date];
}

+(BOOL)comparisonTimeMinAndBirthDay:(NSDate *)dateMin andDay:(NSString *)birthDay{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyyMMdd"];
    //现在时间,你可以输出来看下是什么格式
    birthDay = [birthDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //----------将nsdate按formatter格式转成nsstring
    NSString *minString = [formatter stringFromDate:dateMin];
    int minValue = [minString intValue];
    int birthValue = [birthDay intValue];
    return minValue > birthValue;
}


+(NSInteger)checkNameLength:(NSString *)checkString{
    NSInteger length = 0;
    for(int i = 0; i < checkString.length;i++){
        NSString *idx = [checkString substringWithRange:NSMakeRange(i, 1)];
        if([self IsChinese:idx]){
            length += 3;
        }else{
            length += 1;
        }
    }
    return length;
}

/** 根据图片二进制流获取图片格式 */
+(NSString *)imageTypeWithData:(NSData *)data {
    uint8_t type;
    [data getBytes:&type length:1];
    switch (type) {
        case 0xFF:
            return @".jpeg";
        case 0x89:
            return @".png";
        case 0x47:
            return @".gif";
        case 0x49:
        case 0x4D:
            return @".tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @".webp";
            }
            return nil;
    }
    return nil;
}

+(NSString *)getRamdomString{
    int ramdom = arc4random() % 1000;
    NSString *result = [NSString stringWithFormat:@"%04d", ramdom];
    return result;
}

+(void)logout:(NSString *)message{
    [SVProgressHUD dismiss];
    LoginData = nil;
    [[HHLoginManager sharedManager] setCurrentHHLoginData:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:login_broadcast object:nil userInfo:@{@"type": @"0"}];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"auto_login"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)setTextFieldBoard:(UITextField*)textFild{
    textFild.layer.borderWidth = 1.f;
    textFild.layer.borderColor = BorderCGColor;
    textFild.layer.cornerRadius = 4.f;
}

+ (CGFloat)getLableHeight:(NSString *)message yyLabel:(YYLabel *)lable lineSpacing:(CGFloat)lineSpace stringFont:(UIFont *)font{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:message];

    introText.yy_font = font;
    introText.yy_lineSpacing = lineSpace;//行间距
    //lable.attributedText = introText;
    CGSize introSize = CGSizeMake(lable.frame.size.width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    //lable.textLayout = layout;
    CGFloat introHeight = layout.textBoundingSize.height;
    return introHeight;
}


+ (CGFloat)getLableWidth:(NSString *)message yyLabel:(YYLabel *)lable stringFont:(UIFont *)font{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:message];
    introText.yy_font = font;
    //lable.attributedText = introText;
    CGSize introSize = CGSizeMake(CGFLOAT_MAX, lable.frame.size.height);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    //lable.textLayout = layout;
    CGFloat introWidth = layout.textBoundingSize.width;
    return introWidth;
}

+ (NSMutableAttributedString *)setAttring:(NSString *)text andColor:(UIColor *)color andFont:(UIFont *)font{
    color = (color ? color : HEXCOLOR(0xCCCCCC, 1));
    font = (font ? font : SystemFont);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:
                                             @{NSForegroundColorAttributeName:color,NSFontAttributeName:font}];
    return attrString;
}


+ (NSString *)getAddressForCode:(NSString *)code{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic1 in array) {
        NSString *name1 = dic1[@"name"];
        if ([dic1[@"disId"] isEqualToString:code]) {
            return name1;
        } else{
            NSArray *children1 = dic1[@"children"];
            for (NSDictionary *dic2 in children1) {
                NSString *name2 = dic2[@"name"];
                if ([dic2[@"disId"] isEqualToString:code]) {
                    return [NSString stringWithFormat:@"%@ %@",name1, name2];
                } else{
                    NSArray *children2 = dic2[@"children"];
                    for (NSDictionary *dic3 in children2) {
                        NSString *name3 = dic3[@"name"];
                        if ([dic3[@"disId"] isEqualToString:code]) {
                            return [NSString stringWithFormat:@"%@ %@ %@",name1, name2, name3];
                        }
                    }
                }
            }
        }
    }
    return @"";
}

// 给图片添加文字水印：
+ (UIImage *)jx_WaterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed{
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //2.绘制图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //添加水印文字
    [text drawAtPoint:point withAttributes:attributed];
    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

// 给图片添加图片水印
+ (UIImage *)jx_WaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect{
    
    //1.获取图片
    
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //3.绘制背景图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //绘制水印图片到当前上下文
    [waterImage drawInRect:rect];
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}


//生成二维码
+ (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size
{
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image WithSize:size];
    return img;
}

//二维码清晰
+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
// 获取字符串宽度
+ (CGFloat) widthForString:(NSString *)value fontSize:(CGFloat)fontSize andHeight:(CGFloat)height
{
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.width;
}

+ (void)openUrl:(NSString *)url{
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *string = [url substringToIndex:4];
    if(![string isEqualToString:@"http"]){
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    NSURL *nsurl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:nsurl]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:nsurl options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:nsurl];
        }
    } else {
        [kAppWindow makeToast:@"链接无效" duration:showToastViewErrorTime position:CSToastPositionCenter];
    }
    
}

+ (void)showAlertView:(nullable NSString *)title andMessage:(NSString *)message andTitles:(NSArray *)titles andColors:(nullable NSArray *)colors sure:(void (^)(void))completionSure cancel:(nullable void (^)(void))completionCancel{
    MLAlertView *alert = [[MLAlertView alloc] initWithTitle:title andMessage:message andMessageAlignment:NSTextAlignmentCenter andItem:titles andMessageFontSize:Ratio15 andSelectBlock:^(NSInteger index) {
        if (titles.count == 1) {
            completionSure();
        } else if(titles.count == 2){
            if(index == 1){
                completionSure();
            } else if(index == 0 && completionCancel){
                completionCancel();
            }
        }
        
    }];
    //横线和竖线的颜色
    alert.lineViewColor = HEXCOLOR(0xE6E6E6, 1);
    alert.titleLabelFont = [UIFont systemFontOfSize:20];

    //副标题或描述的字体颜色
    alert.titleLabelColor = MainBlack;
    alert.messageFont = SystemFont;
    alert.buttonFont = SystemFont;
    //按钮item的颜色数组 按顺序取 实际最多只有3个按钮 如果颜色数组只有两个颜色，则最后一个颜色按钮是默认色，如果颜色数组颜色多了，只取前3个值
    alert.itemTitleColorArr = !colors ? @[MainGray, MainRed] : colors;

    //副标题或描述的颜色
    alert.messageLabelColor = MainGray;

    [alert showWithView:kAppWindow];
    
   
}



+ (NSInteger)getCurrentHour{
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | //年
    NSCalendarUnitMonth | //月份
    NSCalendarUnitDay | //日
    NSCalendarUnitHour |  //小时
    NSCalendarUnitMinute |  //分钟
    NSCalendarUnitSecond;  // 秒
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:nowDate];

    return [dateComponent hour];
}

+(NSString *)paramerWithURL:(NSURL *) url andParams:(NSString *)param{
    NSMutableDictionary *paramer = [[NSMutableDictionary alloc]init];
    //创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    //遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [paramer setObject:obj.value forKey:obj.name];
    }];
   
    return [paramer objectForKey:param];
}

+(NSString *)base64DecodeString:(NSString *)string{
    //注意：该字符串是base64编码后的字符串
    //1、转换为二进制数据（完成了解码的过程）
    NSData *data=[[NSData alloc]initWithBase64EncodedString:string options:0];
    //2、把二进制数据转换成字符串
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)chineseToPinyin:(NSString *)string{
    NSMutableString *ms = [[NSMutableString alloc] initWithString:string];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
        NSLog(@"Pingying: %@", ms); // wǒ shì zhōng guó rén
    }
    return [NSString stringWithFormat:@"%@", ms];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

+ (void)actionToCallCompanyPhone{
    
}

+ (NSInteger)insertStarTimeo:(NSString *)time1 andInsertEndTime:(NSString *)time2{
    // 1.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendarUnit type = NSCalendarUnitMinute;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    // 4.输出结果
    return cmps.minute;
}


@end
