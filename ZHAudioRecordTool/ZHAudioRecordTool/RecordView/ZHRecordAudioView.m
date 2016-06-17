//
//  ZHRecordAudioView.m
//  ZHAudioRecord
//
//  Created by zhuhoulin on 16/6/16.
//  Copyright © 2016年 personal. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define VOICERECORDMP3LOCALPAATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"]

#import "ZHRecordAudioView.h"
#import "ZHAudioRecoder.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@interface ZHRecordAudioButton : UIButton
@property (nonatomic, copy) void (^startRecord)();       /** 开始录制的回调 */
@property (nonatomic, copy) void (^stopRecord)();        /** 停止录制的回调 */
@end

@interface ZHRecordBackView :UIView
@end

@interface ZHRecordVoiceAnimationView : UIView
@property (nonatomic, strong) UIImageView *microPhoneView;
@property (nonatomic, strong) UIImageView *volumeImageView;
@property (nonatomic, assign) NSInteger currentImageIndex;
- (void)changeVoiceWithPower:(CGFloat)power;
@end

@interface ZHRecordAudioView ()
@property (nonatomic, strong) ZHAudioRecoder *recorder;                                  /** 录音器 */
@property (nonatomic, strong) ZHRecordBackView *whiteBackView;                           /** 白色底 */
@property (nonatomic, strong) UILabel *noteLable;                                        /** 提示文字 */
@property (nonatomic, strong) ZHRecordAudioButton *recordBtn;                            /** 语音录制按钮 */
@property (nonatomic, strong) ZHRecordVoiceAnimationView *recordingAnimationView;        /** 录音动画 */
@property (nonatomic, strong) UIImageView *audioImageView;                               /** 语音条 */
@property (nonatomic, strong) UIImageView *audioAnimationView;                           /** 小喇叭 */
@property (nonatomic, strong) UILabel *timeLengthLabel;                                  /** 语音时长 */
@property (nonatomic, strong) UIView *lineView;                                          /** 竖线 */
@property (nonatomic, strong) UIButton *resetBtn;                                        /** 重新录制 */
@property (nonatomic, strong) UIButton *useAudioBtn;                                     /** 立即使用 */
@property (nonatomic, assign) BOOL isResetRecord;                                        /** 是否是重新录制 */
@property (nonatomic, assign) BOOL isPlaying;                                            /** 是否正在播放音频文件 */
@end

@implementation ZHRecordAudioView

+ (instancetype)initial {
    ZHRecordAudioView *audioView = [ZHRecordAudioView new];
    if (audioView) {
        [audioView setupUI];
        [audioView setAction];
    }
    return audioView;
}

// 初始化设置
- (void)setupUI {
    self.isResetRecord = NO;
    self.isPlaying = NO;
    self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0];
    self.frame = [UIScreen mainScreen].bounds;
    // 添加控件
    [self addSubview:self.whiteBackView];
    [self addSubview:self.recordingAnimationView];
    
    [self.whiteBackView addSubview:self.noteLable];
    [self.whiteBackView addSubview:self.recordBtn];
    [self.whiteBackView addSubview:self.audioImageView];
    [self.audioImageView addSubview:self.audioAnimationView];
    [self.whiteBackView addSubview:self.timeLengthLabel];
    [self.whiteBackView addSubview:self.resetBtn];
    [self.whiteBackView addSubview:self.useAudioBtn];
    [self.whiteBackView addSubview:self.lineView];
    
    // 设置Frame
    self.whiteBackView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 205);
    self.noteLable.frame = CGRectMake(0, 28, SCREEN_WIDTH, 23);
    self.recordBtn.frame = CGRectMake(SCREEN_WIDTH * 0.5 - 37, 79, 74, 74);
    
    self.audioImageView.frame = CGRectMake(24, 57, 80, 60);
    self.timeLengthLabel.frame = CGRectMake(CGRectGetMaxX(self.audioImageView.frame), 67, 50, 50);
    self.audioAnimationView.frame = CGRectMake(20, 24, 20, 20);
    self.resetBtn.frame = CGRectMake(0, 156, SCREEN_WIDTH * 0.5, 49);
    self.useAudioBtn.frame = CGRectMake(SCREEN_WIDTH * 0.5, 156, SCREEN_WIDTH * 0.5, 49);
    self.lineView.frame = CGRectMake(SCREEN_WIDTH * 0.5 - 0.5, 161, 1, 39);
    
    // 初始化状态
    self.whiteBackView.alpha = 0;
    self.audioImageView.alpha = 0;
    self.audioAnimationView.alpha = 0;
    self.timeLengthLabel.alpha = 0;
    self.resetBtn.alpha = 0;
    self.useAudioBtn.alpha = 0;
    self.lineView.alpha = 0;
    self.recordingAnimationView.alpha = 0;
}

- (void)setAction {
    __weak typeof(self) weakSelf = self;
    self.recordBtn.startRecord = ^(){
        [weakSelf.recorder startRecodAudioWithUrlString:VOICERECORDMP3LOCALPAATH];
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.recordingAnimationView.alpha = 1;
        }];
    };
    
    self.recordBtn.stopRecord = ^(){
        [weakSelf.recorder stopRecodAudio];
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.recordingAnimationView.alpha = 0;
            weakSelf.noteLable.alpha = 0;
            weakSelf.recordBtn.alpha = 0;
            weakSelf.whiteBackView.alpha = 1;
            weakSelf.audioImageView.alpha = 1;
            weakSelf.audioAnimationView.alpha = 1;
            weakSelf.timeLengthLabel.alpha = 1;
            weakSelf.resetBtn.alpha = 1;
            weakSelf.useAudioBtn.alpha = 1;
            weakSelf.lineView.alpha = 1;
        }];
    };
}

//*****************************************************************
// MARK: - action
//*****************************************************************

//
- (void)show {

    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        self.whiteBackView.frame = CGRectMake(0, SCREEN_HEIGHT - 205, SCREEN_WIDTH, 205);
        self.whiteBackView.alpha = 1;
    }];
}

//
- (void)hide {
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0];
        self.whiteBackView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 205);
        self.whiteBackView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 重新录制
- (void)reSetRecrod:(UIButton *)resetRecordBtn {
    [UIView animateWithDuration:0.25 animations:^{
        self.noteLable.alpha = 1;
        self.recordBtn.alpha = 1;
        self.audioImageView.alpha = 0;
        self.audioAnimationView.alpha = 0;
        self.timeLengthLabel.alpha = 0;
        self.resetBtn.alpha = 0;
        self.useAudioBtn.alpha = 0;
        self.lineView.alpha = 0;
    }];
}

// 保存语音
- (void)saveAudio:(UIButton *)useBtn {
    [self hide];
}

// 播放语音
- (void)playAudio{
    // 播放语音、播放动画
    if (self.isPlaying) {
        self.audioAnimationView.image = [UIImage imageNamed:@"vioce_03"];
        [self.audioAnimationView stopAnimating];
        [self.recorder stopRecodAudio];
        self.isPlaying = NO;
    }
    else {
        // 开始播放Gif
        [self.recorder startPlayLocalAudioWithLocalString:VOICERECORDMP3LOCALPAATH];
        self.audioAnimationView.animationImages = [self turnGifToImages];
        self.audioAnimationView.animationDuration = 2.0f;
        self.audioAnimationView.animationRepeatCount = 100;
        // 播放动图
        [self.audioAnimationView startAnimating];
    }
    
    [self.recorder startPlayLocalAudioWithLocalString:VOICERECORDMP3LOCALPAATH];
}

- (NSString *)calculateTime:(NSInteger )countT{
    NSString  *timeString ;
    NSInteger second  = (countT+1)%60;
    NSInteger mintiue = countT/60;
    timeString = [NSString stringWithFormat:@"%02ld:%02ld“",(long)mintiue,(long)second];
    return timeString;
}

// 获取gif帧
- (NSArray *)turnGifToImages{
    NSData *gifDatas = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice-1" ofType:@"gif"]];
    CGImageSourceRef gifsource = CGImageSourceCreateWithData((__bridge CFDataRef)gifDatas, NULL);
    
    // 获取的gif的帧数
    size_t gifFrameCount = CGImageSourceGetCount(gifsource);
    
    // 遍历获取每一帧动画
    NSMutableArray *gifImages = [NSMutableArray new];
    for (size_t i = 0; i < gifFrameCount; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifsource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [gifImages addObject:image];
        // 内存释放
        CGImageRelease(imageRef);
    }
    CFRelease(gifsource);
    return gifImages;
}

// 计算语音条长度
- (CGFloat)calculateaudioImageViewWidthWith:(NSTimeInterval)timeLength {
    
    if ((80 + (CGFloat)(timeLength - 1.0)) * 3 > (SCREEN_WIDTH - 100)) {
        return (SCREEN_WIDTH - 100);
    }
    else {
        return 80 + (CGFloat)(timeLength - 1.0) * 3;
    }
}

// 播放音频帧动画

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hide];
}

//*****************************************************************
// MARK: - getter
//*****************************************************************

- (ZHAudioRecoder *)recorder {
    if (!_recorder) {
        _recorder = [ZHAudioRecoder new];
        __weak typeof(self) weakSelf = self;
        _recorder.returnTimerBlock = ^(NSTimeInterval timeLength, NSString *path) {
            weakSelf.timeLengthLabel.text = [weakSelf calculateTime:(NSInteger)timeLength];
            CGFloat width = [weakSelf calculateaudioImageViewWidthWith:timeLength];
            weakSelf.audioImageView.frame = CGRectMake(24, 57, width, 60);
            weakSelf.timeLengthLabel.frame = CGRectMake(CGRectGetMaxX(weakSelf.audioImageView.frame), 67, 50, 50);
        };
        _recorder.returnRecordingState = ^(NSTimeInterval timeLength, CGFloat power){
            [weakSelf.recordingAnimationView changeVoiceWithPower:power];
        };
        _recorder.returnPlayComplete = ^(){
            [weakSelf.audioAnimationView stopAnimating];
            weakSelf.audioAnimationView.image = [UIImage imageNamed:@"vioce_03"];
        };
    }
    return _recorder;
}

- (ZHRecordBackView *)whiteBackView
{
    if (!_whiteBackView) {
        _whiteBackView = [ZHRecordBackView new];
        _whiteBackView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteBackView;
}

- (UILabel *)noteLable
{
    if (!_noteLable) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"长按开始录制";
        label.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:16.0f];
        _noteLable = label;
    }
    return _noteLable;
}

- (ZHRecordAudioButton *)recordBtn
{
    if (!_recordBtn) {
        _recordBtn = [ZHRecordAudioButton new];
        [_recordBtn setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    }
    return _recordBtn;
}


- (UIImageView *)audioImageView
{
    if (!_audioImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:@"voiceLengthBG"];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAudio)];
        [imageView addGestureRecognizer:gesture];
        _audioImageView = imageView;
    }
    return _audioImageView;
}

- (UIImageView *)audioAnimationView
{
    if (!_audioAnimationView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:@"vioce_03"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        _audioAnimationView = imageView;
    }
    return _audioAnimationView;
}

- (ZHRecordVoiceAnimationView *)recordingAnimationView
{
    if (!_recordingAnimationView) {
        _recordingAnimationView = [[ZHRecordVoiceAnimationView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5 - 100, 100, 200, 200)];
    }
    return _recordingAnimationView;
}


- (UILabel *)timeLengthLabel
{
    if (!_timeLengthLabel) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:15.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"00:00“";
        _timeLengthLabel = label;
    }
    return _timeLengthLabel;
}


- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:0.3];
    }
    return _lineView;
}


- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        UIButton *button = [[UIButton alloc]init];
        button.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [button setTitle:@"重新录制" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reSetRecrod:) forControlEvents:UIControlEventTouchUpInside];
        _resetBtn = button;
    }
    return _resetBtn;
}

- (UIButton *)useAudioBtn
{
    if (!_useAudioBtn) {
        UIButton *button = [[UIButton alloc]init];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        button.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
        [button setTitle:@"立即使用" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:126.0/255.0 green:211.0/255.0 blue:33.0/255.0 alpha:1]  forState:UIControlStateNormal];
        [button addTarget:self action:@selector(saveAudio:) forControlEvents:UIControlEventTouchUpInside];
        _useAudioBtn = button;
    }
    return _useAudioBtn;
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -ZHRecordAudioButton

@implementation ZHRecordAudioButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

// 开始录制
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.startRecord) {
        // 开始录制
        self.startRecord();
    }
}

// 结束录制
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.stopRecord) {
        // 停止录制
        self.stopRecord();
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -ZHRecordBackView

@implementation ZHRecordBackView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{}
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -ZHRecordVoiceAnimationView
@implementation ZHRecordVoiceAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.currentImageIndex = 0;
    self.layer.cornerRadius = 10;
    // 添加控件
    [self addSubview:self.microPhoneView];
    [self addSubview:self.volumeImageView];
    
    // 约束
    CGFloat selfCenterX = self.frame.size.width * 0.5;
    CGFloat selfCenterY = self.frame.size.height * 0.5;
    CGFloat microPhoneViewW = self.microPhoneView.frame.size.width;
    CGFloat microPhoneViewH = self.microPhoneView.frame.size.height;
    CGFloat microPhoneViewX = selfCenterX - self.microPhoneView.frame.size.width;
    CGFloat microPhoneViewY = selfCenterY - self.microPhoneView.frame.size.height * 0.5;
    self.microPhoneView.frame = CGRectMake(microPhoneViewX, microPhoneViewY, microPhoneViewW, microPhoneViewH);
}

- (void)changeVoiceWithPower:(CGFloat)power {
    NSInteger volume = (NSInteger)((power / 0.001) / 10.0);
    if (volume > 6) {
        volume = 6;
    }
    if (self.currentImageIndex == volume) {
        return;
    }
    
    UIImage *tmpimage = [UIImage imageNamed:[NSString stringWithFormat:@"volume_%ld",volume]];
    CGFloat volumeViewW = tmpimage.size.width;
    CGFloat volumeViewH = tmpimage.size.height;
    CGFloat volumeViewX = self.frame.size.width * 0.5;
    CGFloat volumeViewY = CGRectGetMaxY(self.microPhoneView.frame) - volumeViewH;
    
    self.volumeImageView.image = tmpimage;
    self.volumeImageView.frame = CGRectMake(volumeViewX + 10, volumeViewY, volumeViewW, volumeViewH);
    self.currentImageIndex = volume;
}

//*****************************************************************
// MARK: - getter
//*****************************************************************
- (UIImageView *)microPhoneView {
    if (!_microPhoneView) {
        _microPhoneView = [UIImageView new];
        _microPhoneView.image = [UIImage imageNamed:@"microphone"];
        [_microPhoneView sizeToFit];
    }
    return _microPhoneView;
}
- (UIImageView *)volumeImageView {
    if (!_volumeImageView) {
        _volumeImageView = [UIImageView new];
        [_volumeImageView sizeToFit];
    }
    return _volumeImageView;
}
@end















