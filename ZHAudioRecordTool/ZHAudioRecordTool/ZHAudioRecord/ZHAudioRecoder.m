//
//  ZHAudioRecoder.m
//  ZHAudioRecord
//
//  Created by zhuhoulin on 16/6/6.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "ZHAudioRecoder.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

@interface ZHAudioRecoder()<AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    NSString *_mp3FilePath;
}

@property (nonatomic, strong) AVAudioRecorder *recorder;                         /** 录音器 */
@property (nonatomic, strong) CADisplayLink *disLink;                            /** 定时器 */
@property (nonatomic, assign) CFTimeInterval slientDuration;                     /** 静音时间 */
@property (nonatomic, assign) CFTimeInterval totalDuration;                      /** 录制的总时间 */
@property (nonatomic, copy) NSString *localRecordString;                         /** 录制时的存放时间 */
@property (nonatomic, strong) AVAudioPlayer *player;                             /** 播放器 */

@end

@implementation ZHAudioRecoder

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -initial

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.slientDuration = 0;
        self.totalDuration = 0;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -action

// 更新测量值
- (void)updateMeter {
    // 更新录音器的测量值
    [self.recorder updateMeters];
    
    // 获取平均分贝
    float avePower = pow(10, 0.05 * [self.recorder averagePowerForChannel:0]) ;
    // 小于30分贝时,视为静音模式
    if (avePower <= -20) {
        
        self.slientDuration += self.disLink.duration;
        if (self.slientDuration >= 3.0) {
            [self.recorder stop];
            
            // 销毁计时器
            [self.disLink invalidate];
            self.disLink = nil;
        }
    }
    else {
        if (self.slientDuration != 0) {
            self.slientDuration = 0;
        }
        self.totalDuration += self.disLink.duration;
        if (self.returnRecordingState) {
            self.returnRecordingState(self.totalDuration, (CGFloat)avePower);
        }
    }
}

// 停止录制
- (void)stopRecodAudio {
    [self.disLink invalidate];
    self.disLink = nil;
    [self.recorder stop];
    self.recorder = nil;
    [self audio_PCMtoMP3];
    if (self.returnTimerBlock) {
        self.returnTimerBlock(self.totalDuration + 1.0,_mp3FilePath);
        self.slientDuration = 0;
        self.totalDuration = 0;
    }
    
}

// 开始录制
- (void)startRecodAudioWithUrlString:(NSString *)urlString {
    self.localRecordString = urlString;
    
    // 缓冲
    [self.recorder prepareToRecord];
    
    // 开始分贝测量
    self.recorder.meteringEnabled = YES;
    
    // 录音
    [self.recorder record];
    self.disLink.paused = NO;
}

// 开始录制-返回时间长短
- (void)startRecodAudioWithUrlString:(NSString *)urlString andWithReturnTimeBlock:(void (^)(NSTimeInterval time, NSString *path))block {
    if (block) {
        self.returnTimerBlock = block;
    }
    
    [self startRecodAudioWithUrlString:urlString];
}

// 暂停录制
- (void)pauseRecodAudio {
    self.disLink.paused = YES;
    [self.recorder pause];
}

// 播放录制的文件
- (void)startPlayAudio {
    self.player = nil;
    
    if (!self.localRecordString) {
        NSLog(@"录制音频的URL不存在");
        return;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    NSURL *url = [NSURL fileURLWithPath:self.localRecordString];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player = player;
    player.volume = 1;
    if (error) {
        NSLog(@"%@",error);
    }
    [player play];
}

// 开始播放本地文件
- (void)startPlayLocalAudioWithLocalString:(NSString *)localUrlString {
    self.player = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    NSURL *url = [NSURL fileURLWithPath:localUrlString];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player = player;
    self.player.delegate = self;
    player.volume = 1;
    if (error) {
        NSLog(@"%@",error);
    }
    [player play];

}

// 开始播放远程文件
- (void)startPlayRemoteAudioWithUrlString:(NSString *)remoteUrlString {
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    // 录制正常结束
    if (flag) {
    
    
    }
    else {
        
    }

}

#pragma mark -AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        if (self.returnPlayComplete) {
            self.returnPlayComplete();
        }
        self.player = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -getter
- (AVAudioRecorder *)recorder {
    if (!_recorder) {

        NSURL *url = [NSURL fileURLWithPath:self.localRecordString];
        
        // 设置录音器属性
        NSMutableDictionary *dicts = [NSMutableDictionary new];
        
        // 音频格式
        dicts[AVFormatIDKey] = @(kAudioFormatLinearPCM);

        // 音频采样率(电话的采样率)
        dicts[AVSampleRateKey] = @(8000);
        
        // 音频通道数
        dicts[AVNumberOfChannelsKey] = @(2);
        
        // 采样位数
//        dicts[AVLinearPCMBitDepthKey] = @(8);
        
        // 设置数据是从高位存储还是从低位存储
//        dicts[AVLinearPCMIsBigEndianKey] = @(1);

        // 设置采样信号是浮点数还是整点数
//        dicts[AVLinearPCMIsFloatKey] = @(0);
        
        // 设置音频质量
        dicts[AVEncoderAudioQualityKey] = @(AVAudioQualityMin);
        
        // error
        NSError *error;
#warning 后期补错误处理
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
       
        if(setCategoryError){
            NSLog(@"%@", [setCategoryError description]);
        }
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:dicts error:nil];
        
        _recorder.delegate = self;

    }
    return _recorder;
}

- (CADisplayLink *)disLink {
    if (!_disLink) {
        _disLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
        _disLink.paused = YES;
        [_disLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _disLink;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -转码
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    
    _mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:_mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([_mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
    }
}


@end



























