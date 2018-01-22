//
//  PropsManager.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-23.
//
//

//#define TEMPLATE_SET_INCREMENT_TIME 30
//#define TEMPLATE_SETS_MAX 3
//#define TEMPLATE_SETS_MIN 2


#import "PropAreasManager.h"
#import "PropArea.h"
#import "PropAreaGlobal.h"
#import "PropAreaTemplatesManager.h"
#import "GameScene.h"
#import "Score.h"
#import "PropAreaRandomizer.h"
#import "Player.h"

@interface PropAreasManager()

//- (void)incrementDifficulty;
- (void)repopulateArea:(PropArea *)area startingTemplate:(BOOL)starting;

@end

@implementation PropAreasManager

- (id)initWithDynamic:(BOOL)isDynamic
{
    if ( self = [super init] )
    {
        _generateCounter = 0;
        _areas = [CCArray array];
        _isDynamic = isDynamic;

        for ( int row=0; row<4; row++ )
        {
            for ( int col=0; col<4; col++ )
            {
                PropArea *area = [[PropArea alloc] init];
                
                [self repopulateArea:area startingTemplate:YES];
//                if ( row == col == 1 )
//                {
//                    // starting tile
//                    PropAreaTemplate *template = [PropAreaTemplatesManager sharedManager].startingTemplate;
//                    PropAreaRandomizer *randomizer = [PropAreaRandomizer sharedRandomizer];
//                    [area repopulateWithTemplate:template randomizer:randomizer];
//                }
//                else
//                {
//                    [self repopulateArea:area];
//                }
                area.position = ccp(col * [PropArea length], row * [PropArea length]);
                [_areas addObject:area];
                [self addChild:area];
            }
        }
        
        self.contentSize = CGSizeMake(3 * [PropArea length], 3 * [PropArea length]);
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        _globalArea = [[PropAreaGlobal alloc] initWithSize:self.contentSize];
        _globalArea.position = CGPointZero;
        _globalArea.isDynamic = _isDynamic;
        [_areas addObject:_globalArea];
        [self addChild:_globalArea];
    }
    return self;
}

- (void)setIsDynamic:(BOOL)isDynamic
{
    _isDynamic = isDynamic;
    _globalArea.isDynamic = _isDynamic;
}

- (PropArea *)areaWithPoint:(CGPoint)point
{
    if ( _isDynamic )
        return _globalArea;
    
    for ( PropArea *area in _areas )
    {
        if ( area != _globalArea && CGRectContainsPoint(area.boundingBox, point) )
            return area;        
    }
    return nil;
}

- (void)scroll:(CGPoint)delta
{
    for ( PropArea *area in _areas )
    {
        if ( area == _globalArea )
            continue;
        
        CGPoint pos = area.position;
        pos.x += delta.x;
        pos.y += delta.y;
        
        BOOL repopulate = NO;
        
        if ( pos.x < -area.contentSize.width )
        {
            pos.x += self.contentSize.width + area.contentSize.width;
            repopulate = YES;
        }
        else if ( pos.x > self.contentSize.width )
        {
            pos.x -= self.contentSize.width + area.contentSize.width;
            repopulate = YES;
        }
        
        if ( pos.y < -area.contentSize.height )
        {
            pos.y += self.contentSize.height + area.contentSize.height;
            repopulate = YES;
        }
        else if ( pos.y > self.contentSize.height )
        {
            pos.y -= self.contentSize.height + area.contentSize.height;
            repopulate = YES;
        }
        
        area.position = pos;
        
        // repopulate if we've played in the area a bit and it's out of view
        if ( area.consumptionLevel > 0.25 )
        {
            CGFloat areaRadius = ccpLength(ccp(area.contentSize.width/2, area.contentSize.height/2));
            CGPoint areaCenter = ccp(area.position.x + area.contentSize.width/2, area.position.y + area.contentSize.height/2);
            CGFloat visibleRadius = [ActionLayer sharedActionLayer].visibleRadius;
            CGPoint playerPos = [self convertToNodeSpace:[ActionLayer sharedActionLayer].player.position];
            if ( ccpDistance(areaCenter, playerPos) > areaRadius + visibleRadius )
            {
                repopulate = YES;
            }
        }
        
        if ( repopulate )
        {
            [self repopulateArea:area startingTemplate:NO];
        }
        
        [area updatePositionRelativeToTopContainer:ccp(area.position.x-self.contentSize.width/2, area.position.y-self.contentSize.height/2)];
    }
    
    _globalArea.position = CGPointZero;
    [_globalArea scroll:delta];
    [_globalArea updatePositionRelativeToTopContainer:ccp(_globalArea.position.x-self.contentSize.width/2, _globalArea.position.y-self.contentSize.height/2)];
}

- (void)resetAndRepopulateAreas
{
    [_globalArea reset];
    
    int row=0;
    int col=0;
    for ( PropArea *area in _areas )
    {
        if ( area != _globalArea )
        {
            area.position = ccp(col * [PropArea length], row * [PropArea length]);
            [self repopulateArea:area startingTemplate:YES];
            
            [area updatePositionRelativeToTopContainer:ccp(area.position.x-self.contentSize.width/2, area.position.y-self.contentSize.height/2)];            
            
            col++;
            if ( col == 4 )
            {
                col = 0;
                row++;
            }
        }
    }
}

- (void)repopulateArea:(PropArea *)area startingTemplate:(BOOL)starting
{
    if ( !_isDynamic )
    {
        int templateSetToUse = [GameScene sharedGameScene].score.level - 1;
        
        PropAreaTemplate *template;
        if ( starting )
            template = [[PropAreaTemplatesManager sharedManager] randomTemplateFromSet:templateSetToUse limit:3];
        else
            template = [[PropAreaTemplatesManager sharedManager] randomTemplateFromSet:templateSetToUse];
        
        PropAreaRandomizer *randomizer = [PropAreaRandomizer sharedRandomizer];
        
        [area repopulateWithTemplate:template randomizer:randomizer];
    }
}

- (void)generateGlobalProps:(ccTime)delta
{
    _generateCounter -= delta;
    
    if ( _generateCounter <= 0 )
    {
        int asteroids = 0;
        if ( [GameScene sharedGameScene].score.level == 6 )
            asteroids = 1;
        if ( [GameScene sharedGameScene].score.level == 7 )
            asteroids = 2;
        
        [_globalArea generateAsteroids:asteroids];
        
        _generateCounter = 1;
    }
}

 - (void)cleanupGlobalProps
{
    [_globalArea cleanupProps];
}

- (void)updateDynamicProps
{
    [_globalArea updateDynamicProps];
}



@end
