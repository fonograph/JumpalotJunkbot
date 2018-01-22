//
//  GameOverLayer.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-22.
//
//

#import "CCLayer.h"
#import "CCBAnimationManager.h"

@interface GameOverLayer : CCLayer <CCBAnimationManagerDelegate>
{
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_junksLabel;
    
    CCLabelTTF *_topScoreLabel;
    CCLabelTTF *_topTimeLabel;
    CCLabelTTF *_topJunksLabel;
    
    CCLabelTTF *_unlockModelLabel;
    CCParticleSystemQuad *_unlockParticles;
    
    CCNode *_unlockPreviewContainer;
    CCLabelTTF *_unlockPreviewLine1;
    CCLabelTTF *_unlockPreviewLine2;
}

@property (nonatomic) BOOL showUnlock1;
@property (nonatomic) BOOL showUnlock2;
@property (nonatomic) BOOL showUnlock3;

@property (nonatomic) BOOL topScore;
@property (nonatomic) BOOL topTime;
@property (nonatomic) BOOL topJunks;

@end
