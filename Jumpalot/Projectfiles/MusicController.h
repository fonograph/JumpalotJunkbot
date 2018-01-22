//
//  MusicController.h
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import <Foundation/Foundation.h>

@interface MusicController : NSObject
{
    BOOL _started;
}

+ (MusicController *)sharedController;
- (void)preload;
- (void)startWithLevel:(int)level;
- (void)setLevel:(int)level;
- (void)stop;
- (void)pause;
- (void)resume;


@end
