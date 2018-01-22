//
//  PauseScene.h
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import "CCScene.h"

@interface PauseLayer : CCLayer
{
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_junksLabel;
    CCLabelTTF *_combosLabel;
}

- (void)tappedResume:(id)sender;
- (void)tappedQuit:(id)sender;


@end
