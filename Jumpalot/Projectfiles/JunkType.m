//
//  JunkType.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//

#import "JunkType.h"
#import "JunkCategory.h"

@implementation JunkType

- (CCSprite *)spriteSmall {
    return [CCSprite spriteWithSpriteFrameName:_spriteName];
}

- (CCSprite *)spriteLarge {
    return [CCSprite spriteWithSpriteFrameName:_spriteName];
}

- (NSString *)tweetText
{
    return [NSString stringWithFormat:@"%@: %@ #jumpbot", _name.uppercaseString, _desc];
}


- (id)initWithCategory:(JunkCategory *)category name:(NSString *)name sprite:(NSString *)sprite description:(NSString *)description
{
    if ( self = [super init] )
    {
        _category = category;
        _name = name;
        _spriteName = sprite;
        _identifier = name;
        _desc = description;
    }
    return self;
}

@end
