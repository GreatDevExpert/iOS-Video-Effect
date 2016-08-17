//
//  VideoManager.m
//  VideoEffect
//
//  Created by iDeveloper on 12/7/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VideoManager.h"
#import "UIImage+Resize.h"
#import "ImageUtils.h"

@implementation VideoManager

@synthesize delegate;

#define VIDEO_TYPE AVFileTypeQuickTimeMovie

#define FRAME_PER_SCREEN 30 // fps
#define EFFECT_FRAME_COUNT (3 * FRAME_PER_SCREEN)
#define INSERT_TIME1
#define PREFIX_SOURCE_NAME @"monster_source"
#define PREFIX_ALPHA_NAME @"monster_alpha"
#define PREFIX_EFFECT_NAME @"rendred"

+ (VideoManager *)sharedManager
{
    static VideoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[VideoManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)mergeVideoWithHandler:(NSURL *)videoURL effectIndex:(int)effectIndex completionHandler:(VideoManagerCompletionHandler)handler
{
    dispatch_queue_t queue = dispatch_queue_create("com.videoeffect", 0);
    dispatch_async(queue, ^{
        isEffectVideoExtract = YES;
        currentProgress = 0.0f;
        [self extractEffectVideo:effectIndex];
        [self mergeVideo:videoURL videoIndex:effectIndex];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            BOOL success = YES;
            handler(success, nil);
        });
    });
}

- (void)showCurrentProgress
{
//    [SVProgressHUD showProgress:currentProgress status:@"" maskType:SVProgressHUDMaskTypeClear];
    [delegate changedProgress:currentProgress];
}

- (void)mergeVideo:(NSURL *)videoURL videoIndex:(int)videoIndex
{
    NSString *extractPath = NSTemporaryDirectory();
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *effectPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"effect%d", videoIndex]];

    AVURLAsset *streamAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];

    NSError *error = nil;
    AVAssetReader *streamReader = [[AVAssetReader alloc] initWithAsset:streamAsset error:&error];
    AVAssetTrack *videoTrack = [[streamAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *streamOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    [streamReader addOutput:streamOutput];
    [streamReader setTimeRange:CMTimeRangeMake(kCMTimeZero, streamAsset.duration)];
    [streamReader startReading];

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

    int insertVideoStartTime = _sinceInsertVideo * FRAME_PER_SCREEN;
    int insertVideoEndTime = insertVideoStartTime + EFFECT_FRAME_COUNT;

    NSString *resultURL = [extractPath stringByAppendingPathComponent:@"temp.mov"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:resultURL]) {

        [[NSFileManager defaultManager] removeItemAtPath:resultURL error:nil];
    }

    NSLog(@"Write Started at %@", resultURL);

    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:resultURL] fileType:VIDEO_TYPE
                                                              error:&error];
    NSParameterAssert(videoWriter);

    if(error) {

        NSLog(@"error creating AssetWriter = %@", [error localizedDescription]);
    }

    Float64 durationSeconds = streamAsset.duration.value / streamAsset.duration.timescale;
    currentVideoFrameCount = durationSeconds * FRAME_PER_SCREEN;
    if (isEffectVideoExtract) {
        incrementProgressValue = (double)0.3f / currentVideoFrameCount;
    } else {
        incrementProgressValue = (double)1.0f / currentVideoFrameCount;
    }

    AVAssetWriterInput* videoWriterInput = nil;
    AVAssetWriterInputPixelBufferAdaptor *adaptor;
    __block BOOL success = NO;

    int i = 0;
    while (1) {

        if ([streamReader status] == AVAssetReaderStatusReading) {

            @autoreleasepool {

                if (videoWriterInput != nil && ![videoWriterInput isReadyForMoreMediaData]) {

                    continue;
                }

//                NSLog(@"%d", i);
                
                CMSampleBufferRef sampleBuffer = [streamOutput copyNextSampleBuffer];
                if (sampleBuffer == NULL) {

                    // finish
                    //Finish the session:
                    [videoWriterInput markAsFinished];
                    [videoWriter finishWritingWithCompletionHandler:^{

                        NSLog(@"Write Ended");
                        success = YES;
                    }];

                    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                    break;
                }
                else {

                    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer

                    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);   // Get information of the image
                    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
                    size_t width = CVPixelBufferGetWidth(imageBuffer);
                    size_t height = CVPixelBufferGetHeight(imageBuffer);

                    if (i == 0) {

                        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                                       [NSNumber numberWithInt:width], AVVideoWidthKey,
                                                       [NSNumber numberWithInt:height], AVVideoHeightKey,
                                                       nil];

                        videoWriterInput = [[AVAssetWriterInput
                                                                 assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                 outputSettings:videoSettings] retain];

                        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
                        [attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
                        [attributes setObject:[NSNumber numberWithInt:width] forKey:(NSString *)kCVPixelBufferWidthKey];
                        [attributes setObject:[NSNumber numberWithInt:height] forKey:(NSString *)kCVPixelBufferHeightKey];

                        adaptor = [[AVAssetWriterInputPixelBufferAdaptor
                                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                                         sourcePixelBufferAttributes:attributes] retain];

                        NSParameterAssert(videoWriterInput);
                        NSParameterAssert([videoWriter canAddInput:videoWriterInput]);

                        [videoWriter addInput:videoWriterInput];

                        // fixes all errors
                        videoWriterInput.expectsMediaDataInRealTime = YES;

                        //Start a session:
                        BOOL start = [videoWriter startWriting];
                        NSLog(@"Session started? %d", start);

                        [videoWriter startSessionAtSourceTime:kCMTimeZero];
                    }

                    CVPixelBufferRef buffer = nil;
                    if (i >= insertVideoStartTime && i < insertVideoEndTime) {

                        CVPixelBufferRef pixelBuffer = NULL;
                        CVPixelBufferPoolCreatePixelBuffer (kCFAllocatorDefault, adaptor.pixelBufferPool, &pixelBuffer);

                        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                        void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);

                        memcpy(pxdata, baseAddress, bytesPerRow * height);

                        CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                        height, 8, bytesPerRow, rgbColorSpace,
                                                        kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);

                        NSString *sourceFile = [effectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", PREFIX_EFFECT_NAME, i - insertVideoStartTime]];
                        UIImage *effectImg = [UIImage imageWithContentsOfFile:sourceFile];
                        if (width < 1280 || height < 720) {
                            effectImg = [effectImg resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(width*0.8f, height*0.8f) interpolationQuality:kCGInterpolationDefault];
                        }
                        
                        CGContextDrawImage(context, CGRectMake(0, 0, width, height), effectImg.CGImage);
                        CGContextRelease(context);

                        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

                        buffer = pixelBuffer;//[self pixelBufferFromCGImage:image size:CGSizeMake(width, height)];
                    }
                    else {

                        buffer = imageBuffer;
                    }

                    CMTime frameTime = CMTimeMake(1, FRAME_PER_SCREEN);
                    CMTime lastTime = CMTimeMake(i, FRAME_PER_SCREEN);
                    CMTime presentTime = CMTimeAdd(lastTime, frameTime);

                    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];

                    if (result == NO) { //failes on 3GS, but works on iphone 4

                        NSLog(@"failed to append buffer");
                        NSLog(@"The error is %@", [videoWriter error]);
                    }

                    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                    if (buffer != imageBuffer) {

                        CVBufferRelease(buffer);
                    }

                    i += 1;
                    
                    currentProgress += incrementProgressValue;
                    [self performSelectorOnMainThread:@selector(showCurrentProgress) withObject:nil waitUntilDone:NO];
                }

                CFRelease(sampleBuffer);
            }
        }
    }

    CGColorSpaceRelease(rgbColorSpace);
    
    while (!success) {
        [NSThread sleepForTimeInterval:0.1f];
    }
    
    [NSThread sleepForTimeInterval:0.5f];

//    UISaveVideoAtPathToSavedPhotosAlbum(resultURL, nil, nil, nil);
    [self compileFilesToMakeMovie:videoIndex];
}

- (BOOL)writeImagesAsGif:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gifFile = [path stringByAppendingString:@"result.gif"];
	if ( [fileManager fileExistsAtPath:gifFile] )
		[fileManager removeItemAtPath:gifFile error:nil];
    
    NSString *filePath = [path stringByAppendingPathComponent:@"merged0.png"];
    UIImage *frame = [UIImage imageWithContentsOfFile:filePath];
    
    int videoFrameCount = EFFECT_FRAME_COUNT;
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:gifFile], kUTTypeGIF, videoFrameCount, NULL);
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:(float)1.f/FRAME_PER_SCREEN] forKey:(NSString*)kCGImagePropertyGIFDelayTime] forKey:(NSString*)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount] forKey:(NSString*)kCGImagePropertyGIFDictionary];
    
    for (int i = 0; i < videoFrameCount; i++)
	{
        filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"merged%d.png", i]];
        frame = [UIImage imageWithContentsOfFile:filePath];
        CGImageDestinationAddImage(destination, frame.CGImage, (CFDictionaryRef)frameProperties);
    }

    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSLog(@"animated GIF file created at %@", gifFile);

    return YES;
}

- (void)compileFilesToMakeMovie:(int)videoIndex
{
    @try {
        NSLog(@"chae start");
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scream_monster_%02d", videoIndex] ofType:@"mp3"];
        AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioPath] options:nil];
        
        AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:
                                                                  [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]] options:nil];
        
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        
        int insertVideoStartTime = _sinceInsertVideo * videoAsset.duration.timescale;
        CMTime atTime = CMTimeMake(insertVideoStartTime, videoAsset.duration.timescale);
        
        [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                            ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                             atTime:atTime error:nil];
        
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                        atTime:kCMTimeZero error:nil];
        
        AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                             presetName:AVAssetExportPresetPassthrough];
        
        // export video
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *galleryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"gallery"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![[NSFileManager defaultManager] fileExistsAtPath:galleryPath]) {
            [fileManager createDirectoryAtPath:galleryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *resultURL = [galleryPath stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"video_%@.mov", [_globalData convertDateToString:[NSDate date] format:@"yyyyMMddHHmmss"]]];
        
        assetExport.outputFileType = VIDEO_TYPE;
        assetExport.outputURL = [NSURL fileURLWithPath:resultURL];
        assetExport.shouldOptimizeForNetworkUse = YES;
        _globalData.currentVideoURL = [NSURL fileURLWithPath:resultURL];
        NSLog(@"saved video : %@", _globalData.currentVideoURL);
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
            if(assetExport.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"Success Audio Compose");
                //            UISaveVideoAtPathToSavedPhotosAlbum(exportPath, nil, nil, nil);

            } else {
                NSLog(@"Faild Audio Compose");
            }
            
            [assetExport release];
        }];
        [audioAsset release];
        [videoAsset release];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@",exception);
    }
}

- (void)extractEffectVideo:(int)index
{
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *effectURL = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"effect%d", index]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([[NSFileManager defaultManager] fileExistsAtPath:[effectURL stringByAppendingPathComponent:
                                                         [NSString stringWithFormat:@"%@%d.png", PREFIX_EFFECT_NAME, FRAME_PER_SCREEN]]]) { // already exists effect frame
        isEffectVideoExtract = NO;
        return;
    }
    
    [fileManager createDirectoryAtPath:effectURL withIntermediateDirectories:YES attributes:nil error:nil];

    // extract effect frames
    NSURL *sourceFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"monster_%02d", index] ofType:@"mov"]];
    [self extractVideo:sourceFile extractPath:effectURL prefixName:PREFIX_SOURCE_NAME];
    
    [NSThread sleepForTimeInterval:0.3];
    
    // extract effect frames
    NSURL *sourceAlphaFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"monster_alpha_%02d", index] ofType:@"mov"]];
    [self extractVideo:sourceAlphaFile extractPath:effectURL prefixName:PREFIX_ALPHA_NAME];
    
    [NSThread sleepForTimeInterval:0.3];
    
    // generate alpha effect frame
    int frameCount = EFFECT_FRAME_COUNT;
    incrementProgressValue = (double)0.2f / frameCount;
    
    for (int i = 0; i < frameCount; i++) {
        @autoreleasepool {
            
            NSString *sourceFile = [effectURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", PREFIX_SOURCE_NAME, i]];
            UIImage *sourceImg = [[UIImage imageWithContentsOfFile:sourceFile] retain];

            NSString *alphaFile = [effectURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", PREFIX_ALPHA_NAME, i]];
            UIImage *alphaImg = [[UIImage imageWithContentsOfFile:alphaFile] retain];
            
            CGSize sourceSize = [sourceImg size];
            CGRect rect = CGRectMake(0, 0, sourceSize.width, sourceSize.height);
            
            UIGraphicsBeginImageContext(sourceSize);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSaveGState(context);
            
            // transform
            CGContextTranslateCTM(context, 0, sourceSize.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            // mask
            CGContextClipToMask(context, rect, [alphaImg CGImage]);
            
            // transform
            CGContextTranslateCTM(context, 0.0, sourceSize.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            [sourceImg drawInRect:rect];
            
            CGContextRestoreGState(context);
            
            UIImage *maskedImg = UIGraphicsGetImageFromCurrentImageContext();
            
            CGContextSaveGState(context);
            
            NSString *filePath = [effectURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", PREFIX_EFFECT_NAME,i]];
            if (![UIImagePNGRepresentation(maskedImg) writeToFile:filePath atomically:YES]) {
                NSLog(@"alpha frame error : %d", i/FRAME_PER_SCREEN);
            }
            
            [sourceImg release];
            [alphaImg release];
//            CGContextRelease(context);
            
            UIGraphicsEndImageContext();
        }
        
        currentProgress += incrementProgressValue;
        [self performSelectorOnMainThread:@selector(showCurrentProgress) withObject:nil waitUntilDone:NO];

        [NSThread sleepForTimeInterval:0.005];
    }
}

- (void)extractVideo:(NSURL *)videoURL extractPath:(NSString *)extractPath prefixName:(NSString *)prefixName
{
    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    [imageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
	[imageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
	[imageGenerator setAppliesPreferredTrackTransform:YES];
    
    Float64 durationSeconds = myAsset.duration.value / myAsset.duration.timescale;
    int frameCount = durationSeconds * FRAME_PER_SCREEN;//myAsset.duration.timescale;
    
    NSError *error = nil;
    CMTime actualTime;
    
    incrementProgressValue = (double)0.2f / frameCount;
    
    for (int i = 0; i < frameCount; i++) {
//        CMTime frameTime = CMTimeMake(i, myAsset.duration.timescale);
        CMTime frameTime = CMTimeMake(i, FRAME_PER_SCREEN);
        CGImageRef image = [imageGenerator copyCGImageAtTime:frameTime actualTime:&actualTime error:&error];
        UIImage *currentImg = [[UIImage alloc] initWithCGImage:image];
        NSString *filePath = [extractPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png", prefixName, i]];
        if (![UIImageJPEGRepresentation(currentImg, 1) writeToFile:filePath atomically:YES]) {
            NSLog(@"extract frame : %d", i/FRAME_PER_SCREEN);
        }
        [currentImg release];
        CGImageRelease(image);
        [NSThread sleepForTimeInterval:0.005];
        
        currentProgress += incrementProgressValue;
        [self performSelectorOnMainThread:@selector(showCurrentProgress) withObject:nil waitUntilDone:NO];
    }
    
    [myAsset release];
}

- (void)extractAsyncVideo:(NSURL *)videoURL
{
    NSString *extractPath = NSTemporaryDirectory();
    __block int frameSequence = 1;
    
    AVURLAsset *myAsset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    
    // Assume: @property (strong) AVAssetImageGenerator *imageGenerator;
    
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    
    
    Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
    int loopCount = durationSeconds * FRAME_PER_SCREEN;

    NSMutableArray *times = [NSMutableArray array];
    
    for (int i = 0; i < loopCount; i++) {
        CMTime time = CMTimeMakeWithSeconds(i/FRAME_PER_SCREEN, 1);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                             AVAssetImageGeneratorResult result, NSError *error) {
                                             
                                             NSString *requestedTimeString = (NSString *)
                                             
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
                                             
                                             NSString *actualTimeString = (NSString *)
                                             
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                                             
                                             NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
                                             
                                             if (result == AVAssetImageGeneratorSucceeded) {
                                                 
                                                 // Do something interesting with the image.
                                                 UIImage *currentImg = [[UIImage alloc] initWithCGImage:image];
                                                 NSString *filePath = [extractPath stringByAppendingString:[NSString stringWithFormat:@"extract%d", frameSequence++]];
                                                 if (![UIImageJPEGRepresentation(currentImg, 1) writeToFile:filePath atomically:YES]) {
                                                     NSLog(@"extract frame error : %d", frameSequence/FRAME_PER_SCREEN);
                                                 }
                                                 [currentImg release];
                                             }
                                             
                                             if (result == AVAssetImageGeneratorFailed) {
                                                 
                                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                                                 
                                             }
                                             
                                             if (result == AVAssetImageGeneratorCancelled) {
                                                 
                                                 NSLog(@"Canceled");
                                                 
                                             }
                                             
                                         }];
}

- (void)saveVideo:(NSURL *)file
{
    NSURL *videoURL = file;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mov"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];

    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [videoData writeToFile:outputURL atomically:YES];
}

//- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
//{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    
//    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
//                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
//                        &pxbuffer);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
//                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
//                                                 kCGImageAlphaNoneSkipFirst);
//    
//    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
//    
//    CGAffineTransform flipVertical = CGAffineTransformMake(
//                                                           1, 0, 0, -1, 0, CGImageGetHeight(image)
//                                                           );
//    CGContextConcatCTM(context, flipVertical);
//    
//    
//    
//    CGAffineTransform flipHorizontal = CGAffineTransformMake(
//                                                             -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0
//                                                             );
//    
//    CGContextConcatCTM(context, flipHorizontal);
//    
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                           CGImageGetHeight(image)), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
    // CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)clearTempDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

@end
