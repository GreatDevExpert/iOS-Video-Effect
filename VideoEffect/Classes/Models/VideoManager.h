//
//  VideoManager.h
//  VideoEffect
//
//  Created by iDeveloper on 12/7/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoManagerDelegate <NSObject>

- (void)changedProgress:(float)value;

@end

@interface VideoManager : NSObject {
    BOOL isEffectVideoExtract;
    double currentVideoFrameCount;
    double currentProgress;
    float incrementProgressValue;
}

@property (nonatomic, assign) id <VideoManagerDelegate> delegate;

+ (VideoManager *)sharedManager;

- (void)extractAsyncVideo:(NSURL *)videoURL;

typedef void (^VideoManagerCompletionHandler)(BOOL success, NSURL *url);

- (void)saveVideo:(NSURL *)file;

- (void)mergeVideoWithHandler:(NSURL *)videoURL effectIndex:(int)effectIndex completionHandler:(VideoManagerCompletionHandler)handler;

- (void)clearTempDirectory;

@end
