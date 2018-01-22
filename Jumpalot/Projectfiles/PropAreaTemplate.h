//
//  PropAreaTemplate.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-16.
//
//

#import <Foundation/Foundation.h>

@interface BlockConfig : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat angle;
@property (nonatomic) BOOL repel;

+ (BlockConfig *)blockConfigWithPosition:(CGPoint)p size:(CGSize)s angle:(CGFloat)a repel:(BOOL)r;

@end

@interface JunkConfig : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) int type;

+ (JunkConfig *)junkConfigWithPosition:(CGPoint)p type:(int)t;

@end

@interface ZoomerConfig : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGSize size;

+ (ZoomerConfig *)zoomerConfigWithPosition:(CGPoint)p size:(CGSize)s;

@end

@interface BombConfig : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL attract;
@property (nonatomic) CGSize size;

+ (BombConfig *)bombConfigWithPosition:(CGPoint)p size:(CGSize)s attract:(BOOL)a;

@end

@interface PropAreaTemplate : NSObject

@property (strong, nonatomic, readonly) CCArray *blockConfigs;
@property (strong, nonatomic, readonly) CCArray *junkConfigs;
@property (strong, nonatomic, readonly) CCArray *zoomerConfigs;
@property (strong, nonatomic, readonly) CCArray *bombConfigs;

+ (CGFloat)length;

@end
