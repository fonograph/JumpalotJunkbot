//
//  JunkMeter.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-08.
//
//

#import "JunkMeter.h"
#import "Score.h"

@implementation JunkMeter

- (id)init
{
    if ( self = [super init] )
    {
        _label = [CCLabelTTF labelWithString:@"" fontName:FONT_D3_ALPHABET fontSize:20];
        _label.position = ccp([CCDirector sharedDirector].screenSize.width-5, 0);
        _label.anchorPoint = ccp(1, 0);
        [self addChild:_label];
        
        self.contentSize = CGSizeMake([CCDirector sharedDirector].screenSize.width, 20);
        
     //   _showing = YES;
    }
    return self;
}

- (void)update:(ccTime)delta
{
    if ( _score.junksToLevelUp > 0 )
        _label.string = [NSString stringWithFormat:@"%d/%d", _score.junks, _score.junksToLevelUp];
    else
        _label.string = [NSString stringWithFormat:@"%d", _score.junks];
    //_label.string = [NSString stringWithFormat:@"%d junk to advance", _score.junksRemainingToLevelUp];
}

//- (void)show
//{
////    _showing = YES;
////    [_label runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(self.contentSize.width, 0)]];
//}
//
//- (void)hide
//{
////    _showing = NO;
////    [_label runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(self.contentSize.width + 200, 0)]];
//}

@end
