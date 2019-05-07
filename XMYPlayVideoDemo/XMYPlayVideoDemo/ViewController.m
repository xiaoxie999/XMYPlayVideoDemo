//
//  ViewController.m
//  XMYPlayVideoDemo
//
//  Created by apple on 2019/5/7.
//  Copyright © 2019 xiaoxie. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

/* 相关技术文章链接：
 https://www.jianshu.com/p/226f7f62bf8e
 https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos/playing_audio_from_a_video_asset_in_the_background?language=objc
 */

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

@interface ViewController () {
    NSURL * _fileURL;
}

@property (weak, nonatomic) IBOutlet UIView *bgVideoView;

@property (nonatomic, strong) AVPlayer * avplayer;
@property (nonatomic, strong) AVPlayerLayer * avplayerLayer;
@property (nonatomic, strong) AVPlayerViewController * playerViewVC;

@end

@implementation ViewController

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNotification];
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"mijia_printer" ofType:@"mp4"];
    _fileURL = [NSURL fileURLWithPath:filePath];
    
    [self addPlayerViewVC];  // 使用AVPlayerViewController播放视频
//    [self addAVPlayer];      // 使用AVPlayer播放视频
    
}

-(void)applicationDidEnterBackground {
    // If presenting video with AVPlayerViewController
    
    if (_playerViewVC) {
        _playerViewVC.player = nil;
    }
    
    if (_avplayerLayer) {
        _avplayerLayer.player = nil;
    }
}

-(void)applicationWillEnterForeground {
    // If presenting video with AVPlayerViewController
    
    if (_avplayerLayer) {
        _avplayerLayer.player = self.avplayer;
    }
    
    if (_playerViewVC) {
        _playerViewVC.player = self.avplayer;
    }
}

-(void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)addAVPlayer {
    
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:_fileURL];
    self.avplayer = [AVPlayer playerWithPlayerItem:item];
    
    self.avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    self.avplayerLayer.frame = self.bgVideoView.layer.bounds;
    self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.bgVideoView.layer addSublayer:self.avplayerLayer];
}

-(void)addPlayerViewVC {

    _playerViewVC = [[AVPlayerViewController alloc] init];
    _playerViewVC.videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.avplayer = [AVPlayer playerWithURL:_fileURL];
    _playerViewVC.player = self.avplayer;
    _playerViewVC.view.frame = self.bgVideoView.bounds;
    _playerViewVC.showsPlaybackControls = YES;
    
    [self.bgVideoView addSubview:_playerViewVC.view];
}

- (IBAction)playVideo:(id)sender {
    
    if (_avplayerLayer) {
        [self.avplayer play];
    }
    
    if (_playerViewVC) {
        [self.playerViewVC.player play];
    }
}

#pragma mark - Rotation
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    @WeakObj(self);
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if(size.width > size.height){
            NSLog(@"横屏");
        }else{
            NSLog(@"竖屏");
        }
        
        if (selfWeak.avplayerLayer) {
            selfWeak.avplayerLayer.frame = selfWeak.bgVideoView.layer.bounds;
        }
        
        if (selfWeak.playerViewVC) {
            selfWeak.playerViewVC.view.frame = selfWeak.bgVideoView.bounds;
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"动画播放完之后处理");
        
    }];
}

@end
