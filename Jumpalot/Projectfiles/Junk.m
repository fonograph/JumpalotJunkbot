//
//  Junk.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-25.
//
//


#define SCORE_1 5
#define SCORE_2 10
#define SCORE_3 15
#define SCORE_4 20

#define RADIUS 15

#import "Junk.h"
#import "ActionLayer.h"
#import "GameScene.h"
#import "Score.h"
#import "SimpleAudioEngine.h"
#import "JunkCategory.h"
#import "JunkType.h"
#import "UserData.h"

@implementation Junk

static NSTimeInterval lastCollectTime;
static float lastCollectPitch;

+ (CGFloat)radius
{
    return RADIUS;
}

- (id)initWithCategory:(JunkCategory *)category type:(JunkType *)type
{
    if ( self = [super init] )
    {
        _radius = RADIUS;
        _category = category;
        _type = type;
        
        ccColor3B color = _category.color;
        
        _sprite = type.spriteSmall;
        _sprite.rotation = arc4random() % 360;
        _sprite.color = ccc3(255-(255-color.r)/2, 255-(255-color.g)/2, 255-(255-color.b)/2);
        _sprite.scale = 0.5;
        [[ActionLayer sharedActionLayer] addJunkSprite:_sprite];

        _haloSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"junkhalo%d.png", arc4random()%5+1]];;
        _haloSprite.rotation = arc4random() % 360;
        _haloSprite.scale = 0.66 + (_category.level-1) * 0.33;
        _haloSprite.color = color;
        _haloSprite.opacity = 117;
        [[ActionLayer sharedActionLayer] addSpriteToForeground:_haloSprite z:ForegroundZJunkHalo];
        
        if ( ![[UserData sharedData] junkCountForType:type] && category.level > 1 )
        {
            _idleNewParticles = [CCParticleSystemQuad particleWithFile:@"junkIdleNew.plist"];
            _idleNewParticles.startColor = ccc4f(color.r/255.0, color.g/255.0, color.b/255.0, 0.5);
            _idleNewParticles.endColor = ccc4f((color.r+255)/2.0/255.0, (color.g+255)/2/255.0, (color.b+255)/2.0/255.0, 0);
            _idleNewParticles.positionType = kCCPositionTypeGrouped;
            [[ActionLayer sharedActionLayer] addParticlesToForeground:_idleNewParticles];
        }

    }
    return self;
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    _sprite.position = position;
    _haloSprite.position = position;
    _collectParticles.position = position;
    _idleNewParticles.position = position;
}

- (void)onExit
{
    [super onExit];
    
    [self remove];
}

- (void)collect
{
    _collected = YES;
    
    int score;
    switch ( _category.level )
    {
        case 1:
            score = SCORE_1;
            break;
        case 2:
            score = SCORE_2;
            break;
        case 3:
            score = SCORE_3;
            break;
        case 4:
            score = SCORE_4;
            break;
            
    }
    
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", score] fontName:FONT_D3_ALPHABET fontSize:60];
    _scoreLabel.rotation = CC_RADIANS_TO_DEGREES([ActionLayer sharedActionLayer].viewAngle);
    _scoreLabel.color = ccc3(255, 255, 255);
    _scoreLabel.opacity = 128;
    _scoreLabel.scale = 0;
    [self addChild:_scoreLabel z:-1];
    
    if ( _idleNewParticles )
    {
        _newLabel = [CCLabelTTF labelWithString:@"NEW" fontName:FONT_D3_ALPHABET fontSize:80];
        _newLabel.rotation = _scoreLabel.rotation;
        _newLabel.color = _category.color;
        _newLabel.opacity = 215;
        _newLabel.scale = 0;
        [self addChild:_newLabel z:-1];
    }
    
    [_sprite runAction:[CCFadeOut actionWithDuration:0.2]];
    [_haloSprite runAction:[CCScaleTo actionWithDuration:0.2 scale:0]];
    
    [_newLabel runAction:[CCMoveTo actionWithDuration:0.2 position:ccpRotateByAngle(ccp(0, 80), CGPointZero, -CC_DEGREES_TO_RADIANS(_newLabel.rotation))]];
    [_newLabel runAction:[CCSequence actions:
                          [CCScaleTo actionWithDuration:0.2 scale:1],
                          [CCDelayTime actionWithDuration:0.3],
                          [CCFadeTo actionWithDuration:0.2 opacity:0],
                          nil]];
    
    [_scoreLabel runAction:[CCSequence actions:
                            [CCScaleTo actionWithDuration:0.2 scale:1],
                            [CCDelayTime actionWithDuration:0.3],
                            [CCFadeTo actionWithDuration:0.2 opacity:0],
                            [CCCallFunc actionWithTarget:self selector:@selector(onCollectComplete)],
                            nil]];
    
    [[GameScene sharedGameScene].score addPoints:score];
    [GameScene sharedGameScene].score.junks++;
    
    [[UserData sharedData] addToJunkCountForType:_type];
    
    // particles
    
    _collectParticles = [CCParticleSystemQuad particleWithFile:@"junkCollect.plist"];
    _collectParticles.endRadius = kCCParticleStartRadiusEqualToEndRadius;
    _collectParticles.autoRemoveOnFinish = YES;
    _collectParticles.positionType = kCCPositionTypeGrouped;
    [[ActionLayer sharedActionLayer] addParticlesToForeground:_collectParticles];
    
    [_idleNewParticles stopSystem];
    
    
    // sound
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceReferenceDate];
    float pitch = 1.0;
    
    if ( time - lastCollectTime < 0.5 )
        pitch = lastCollectPitch + 0.2;
    
    lastCollectTime = time;
    lastCollectPitch = pitch;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"collect.caf" pitch:pitch pan:0.0f gain:0.7f];
}

- (void)onCollectComplete
{
    [self remove];
}

- (void)remove
{
    [_sprite removeFromParentAndCleanup:YES];
    [_haloSprite removeFromParentAndCleanup:YES];
    [_collectParticles removeFromParentAndCleanup:YES];
    [_idleNewParticles removeFromParentAndCleanup:YES];
}

- (void)fadeIn:(ccTime)length
{
    GLubyte spriteOpacity = _sprite.opacity;
    GLubyte haloOpacity = _haloSprite.opacity;
    
    _sprite.opacity = 0;
    _haloSprite.opacity = 0;
    
    [_sprite runAction:[CCFadeTo actionWithDuration:length opacity:spriteOpacity]];
    [_haloSprite runAction:[CCFadeTo actionWithDuration:length opacity:haloOpacity]];
}

@end
