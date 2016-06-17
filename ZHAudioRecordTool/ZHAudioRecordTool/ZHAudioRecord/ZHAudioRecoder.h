//
//  ZHAudioRecoder.h
//  ZHAudioRecord
//
//  Created by zhuhoulin on 16/6/6.
//  Copyright © 2016年 personal. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ZHAudioRecoder : NSObject

@property (nonatomic, copy) void (^returnTimerBlock)(NSTimeInterval time, NSString *localPath);                /** 返回录制时间Block */

@property (nonatomic, copy) void (^returnRecordingState)(NSTimeInterval timeLength, CGFloat power); /** 实时返回录制时长 */

@property (nonatomic, copy) void (^returnPlayComplete)();

/**
 *  @brief 开始录音
 *
 *  @param urlString 录音文件存储在本地的路径
 */
- (void)startRecodAudioWithUrlString:(NSString *)urlString;

/**
 *  @brief 开始录音
 *
 *  @param urlString 录音文件存储在本地的路径
 *  @param block     返回录制的总时间
 */
- (void)startRecodAudioWithUrlString:(NSString *)urlString andWithReturnTimeBlock:(void (^)(NSTimeInterval time, NSString *path ))block;

/**
 *  @brief 停止录制
 */
- (void)stopRecodAudio;

/**
 *  @brief 暂停录制
 */
- (void)pauseRecodAudio;

/**
 *  @brief 播放刚刚录制的音频
 */
- (void)startPlayAudio;

/**
 *  @brief 播放本地视频
 *
 *  @param localUrlString 文件的路径
 */
- (void)startPlayLocalAudioWithLocalString:(NSString *)localUrlString;

/**
 *  @brief 播放远程音频
 *
 *  @param remoteUrlString 远程的url-path
 */
- (void)startPlayRemoteAudioWithUrlString:(NSString *)remoteUrlString;



@end
