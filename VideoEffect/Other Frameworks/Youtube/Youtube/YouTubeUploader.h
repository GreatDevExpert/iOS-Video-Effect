//
//  YouTubeUploader.h
//  YouTubeSample_iOS
//
//  Created by Manuel Carrasco Molina on 08.01.12.
//  Copyright (c) 2012 Pomcast. All rights reserved.
//

// +----------------------------------------------------------------------------------------+
// | See http://hoishing.wordpress.com/2011/08/23/gdata-objective-c-client-setup-in-xcode-4 |
// +----------------------------------------------------------------------------------------+

#import <Foundation/Foundation.h>
#import "GData.h"
// This "GoogleCredentials.h" file contains
#define DEV_KEY          @"AI39si7kS6bNkIMGWVehZsMbO7FHQaclnrBcJnRHMw6qYmoX23x8Y5dfjQk_-d0ZCsJR2LtVmXpZ-hpkHFzz9nGzgUGj6RuFsg"
//#define CLIENT_ID        @"482626834412.apps.googleusercontent.com"
//#define CLIENT_SECRET    @"T9zCvVFfQwK5dbDfDUYrZ30Y"
// The Google API console is also where you can set your Product Name and Logo (Image) that will be used in the Modal OAuth Window.

//#define CLIENT_ID        @"482626834412.apps.googleusercontent.com"
//#define CLIENT_SECRET    @"gNX2vme9kzOmoo3w5y_pdPDh"

#define CLIENT_ID        @"482626834412-68bo8s4jbkes5omqor0g4bcgrfqrq8mf.apps.googleusercontent.com"
#define CLIENT_SECRET    @"OX-u1pHTw2qsX1aC6EbrrMSe"
//


// Localizable Strings Variables
#define UPLOADED_VIDEO_TITLE            @"Takling Emoji!"
#define UPLOADED_VIDEO_MESSAGE          @"Video are uploaded Successfully!"
#define ERROR_UPLOAD_VIDEO_TITLE        @"Video are Failed to uploading"

@interface YouTubeUploader : NSObject {
}

@property (retain, nonatomic) UIProgressView *uploadProgressView;
@property (assign) UIViewController *delegate;
@property (nonatomic, retain) NSString *mediaTitle;
@property (nonatomic, retain) NSString *mediaDescription;

- (void)logout;
- (void)uploadVideoFile:(NSString*)path;

@end
