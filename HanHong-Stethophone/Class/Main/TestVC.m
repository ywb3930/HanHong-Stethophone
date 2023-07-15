//
//  TestVC.m
//  HanHong-Stethophone
//
//  Created by 袁文斌 on 2023/7/14.
//

#import "TestVC.h"
#import "WaveView.h"

@interface TestVC (){
    NSURL *recordSaveFile;
    NSTimer *recordTimer;
    
    AVAudioPlayer *audioPlayer;
    
    WaveView *wv;
}

@end

@implementation TestVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSLog(@"url is %@", url);
    audioPlayer = [[AVAudioPlayer alloc] init];
    [audioPlayer initWithContentsOfURL:url error:nil];
    NSLog(@"player is %@", audioPlayer);
    // LiMo Linux Mobile

    [audioPlayer setMeteringEnabled:YES];
    // 通过setMeteringEnabled:YES] 开启波形
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
    wv = [[WaveView alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 300.0f, 100.0f)];
    [wv setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:wv];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}


#define XMAX    20.0f
- (void) refreshWaveView:(id) arg{
    [audioPlayer updateMeters];
#if 0
    // 通知audioPlayer 说我们要去平均波形和最大波形
    float a = [audioPlayer averagePowerForChannel:0];
    float p = [audioPlayer peakPowerForChannel:0];
    a = (fabsf(a)+XMAX)/XMAX;
    p = (fabsf(p)+XMAX)/XMAX;
    [wv addAveragePoint:a*50 andPeakPoint:p*50];
#else
    float aa = pow(10, (0.05 * [audioPlayer averagePowerForChannel:0]));
    float pp = pow(10, (0.05 * [audioPlayer peakPowerForChannel:0]));
    
    NSLog(@"average is %f peak %f", aa, pp);
    [wv addAveragePoint:aa andPeakPoint:pp];
#endif
}


@end
