//
//  JunkType.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//

#import <Foundation/Foundation.h>

@class JunkCategory;

@interface JunkType : NSObject
{
}

@property (readonly, nonatomic) JunkCategory *category;
@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) CCSprite *spriteSmall;
@property (readonly, nonatomic) CCSprite *spriteLarge;
@property (readonly, nonatomic) NSString *spriteName;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *desc;
@property (readonly, nonatomic) NSString *tweetText;

- (id)initWithCategory:(JunkCategory *)category name:(NSString *)name sprite:(NSString *)sprite description:(NSString *)description;

@end
