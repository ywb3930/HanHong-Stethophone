//
//  ViewController+extension.m
//  HXW框架
//
//  Created by hxw on 16/4/13.
//  Copyright © 2016年 hxw. All rights reserved.
//

#import "ViewController+extension.h"
#import <objc/runtime.h>


@implementation UIViewController(extension)

+(void)load
{
//    Method Swizzling
    //保证交换方法只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//
        //获取这个类的viewDidLoad
        Method viewDidLoad = class_getInstanceMethod([self class], @selector(viewDidLoad));
        //获取自己写的viewDidLoaded
        Method viewDidLoaded = class_getInstanceMethod([self class], @selector(viewDidLoaded));
        //交换方法的实现
        method_exchangeImplementations(viewDidLoad, viewDidLoaded);
        //获取方法的实现地址
//        IMP imp1 = method_getImplementation(viewDidLoad);
//        IMP imp2 = method_getImplementation(viewDidLoaded);
//        method_setImplementation(viewDidLoad, imp2);
//        method_setImplementation(viewDidLoaded, imp1);
//        
    
//        Method viewDidLoaded = class_getInstanceMethod([self class], @selector(viewDidLoaded));
//        Method viewDidLoad = class_getInstanceMethod([self class], @selector(viewDidLoad));
////        method_setImplementation(viewDidLoad, imp_implementationWithBlock(id block))
//        class_replaceMethod([self class], @selector(viewDidLoad), method_getImplementation(viewDidLoaded), method_getTypeEncoding(viewDidLoaded));
//        class_replaceMethod([self class], @selector(viewDidLoaded), method_getImplementation(viewDidLoad), method_getTypeEncoding(viewDidLoad));
    });
}

-(void)viewDidLoaded
{
    [self viewDidLoaded];
    NSLog(@"练习RunTime所加的viewDidLoaded打印%@",[self class]);
}

@end
