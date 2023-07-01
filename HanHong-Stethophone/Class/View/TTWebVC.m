//
//  TTWebVC.m
//  YuanYu
//
//  Created by mac on 2019/8/15.
//  Copyright © 2019 ZhiLun. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "TTWebVC.h"

#define canGoBackKeyPath            @"canGoBack"

@interface TTWebVC ()<WKNavigationDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) WKWebView *webView;
@property (nonatomic, strong) UIProgressView * progressView;

@end

@implementation TTWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    [self initWebView];
    if([Tools isBlankString:self.webTitle]){
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        self.title = self.webTitle;
    }
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    [self.webView addObserver:self forKeyPath:canGoBackKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.backgroundColor = WHITECOLOR;
    //[self.navigationController.navigationBar setBackgroundImage:StatusBgViewImage forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    //[self.webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    UIView *viewStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, kStatusBarHeight)];
    viewStatusBar.backgroundColor = WHITECOLOR;
    [self.view addSubview:viewStatusBar];
    
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView) {
        DDLogInfo(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
//        NSInteger total = _webView.estimatedProgress*10000/100;
//        [SVProgressHUD showProgress:_webView.estimatedProgress status:[NSString stringWithFormat:@"%@%%",[@(total) stringValue]]];
        if (_webView.estimatedProgress >= 1.0f) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
//                [SVProgressHUD dismiss];
//            });
        }
    } else if([keyPath isEqualToString:canGoBackKeyPath] && object == _webView){
//        BOOL newValue = [change[NSKeyValueChangeNewKey] boolValue];
//        self.navigationController.interactivePopGestureRecognizer.enabled = !newValue;
//        self.gk_interactivePopDisabled = newValue;
    }else if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView) {

    }else if([keyPath isEqualToString:@"title"] && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)initWebView{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    
    //用于进行JavaScript注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:wkUScript];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH - kBottomSafeHeight) configuration:config];
    [self.view addSubview:_webView];
    _webView.navigationDelegate = self;
    
    
    if ([self.webUrl hasPrefix:@"http://"]||[self.webUrl hasPrefix:@"https://"]) {
        self.webUrl = [self.webUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
        [request addValue:[self readCurrentCookieWithDomain:self.webUrl] forHTTPHeaderField:@"Cookie"];
        [_webView loadRequest:request];
    } else {
        NSString *htmlString = [[NSString alloc]initWithContentsOfFile:self.webUrl encoding:NSUTF8StringEncoding error:nil];
        //加载本地html文件
        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    
    _webView.scrollView.delegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    
    [self.view addSubview:self.progressView];
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (void)dealloc{
    [_webView removeObserver:self forKeyPath:canGoBackKeyPath];
    if([Tools isBlankString:self.webTitle]){
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}

    
//解决第一次进入的cookie丢失问题
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    
    return cookieString;
}
- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, screenW, Ratio2)];
        _progressView.tintColor = MainColor;
        //_progressView.hidden = YES;
        _progressView.trackTintColor = UIColor.clearColor;
    }
    return _progressView;
}


@end
