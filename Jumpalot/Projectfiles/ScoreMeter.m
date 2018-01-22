//
//  ScoreMeter.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "ScoreMeter.h"
#import "Score.h"

@implementation ScoreMeter

- (id)init
{
    if ( self = [super init] )
    {
        _label = [CCLabelTTF labelWithString:@"" fontName:FONT_D3_ALPHABET fontSize:20];
        _label.position = ccp(5, 0);
        _label.anchorPoint = CGPointZero;
        [self addChild:_label];
        
        self.contentSize = CGSizeMake([CCDirector sharedDirector].screenSize.width, 20);
    }
    return self;
}

- (void)update:(ccTime)delta
{
    _label.string = [NSString stringWithFormat:@"%d", _score.points];
}

@end
