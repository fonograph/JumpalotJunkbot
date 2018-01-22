//
//  PropAreaTemplate.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-16.
//
//

#define PROP_AREA_TEMPLATE_LENGTH 1000
#define PROP_AREA_TEMPLATE_MARGIN 50

#import "PropAreaTemplate.h"

@implementation BlockConfig

+ (BlockConfig *)blockConfigWithPosition:(CGPoint)p size:(CGSize)s angle:(CGFloat)a repel:(BOOL)r
{
    p.x += PROP_AREA_TEMPLATE_MARGIN;
    p.y += PROP_AREA_TEMPLATE_MARGIN;
    
    BlockConfig *config = [[BlockConfig alloc] init];
    config.position = p;
    config.size = s;
    config.angle = a;
    config.repel = r;
    
    return config;
}

@end

@implementation JunkConfig

+ (JunkConfig *)junkConfigWithPosition:(CGPoint)p type:(int)t
{
    p.x += PROP_AREA_TEMPLATE_MARGIN;
    p.y += PROP_AREA_TEMPLATE_MARGIN;
    
    JunkConfig *config = [[JunkConfig alloc] init];
    config.position = p;
    config.type = t;
    
    return config;
}

@end

@implementation ZoomerConfig

+ (ZoomerConfig *)zoomerConfigWithPosition:(CGPoint)p size:(CGSize)s
{
    p.x += PROP_AREA_TEMPLATE_MARGIN;
    p.y += PROP_AREA_TEMPLATE_MARGIN;

    ZoomerConfig *config = [[ZoomerConfig alloc] init];
    config.position = p;
    config.size = s;
    
    return config;
}

@end

@implementation BombConfig

+ (BombConfig *)bombConfigWithPosition:(CGPoint)p size:(CGSize)s attract:(BOOL)a
{
    p.x += PROP_AREA_TEMPLATE_MARGIN;
    p.y += PROP_AREA_TEMPLATE_MARGIN;
    
    BombConfig *config = [[BombConfig alloc] init];
    config.position = p;
    config.size = s;
    config.attract = a;
    
    return config;
}

@end

@implementation PropAreaTemplate

+ (CGFloat)length
{
    return PROP_AREA_TEMPLATE_LENGTH + PROP_AREA_TEMPLATE_MARGIN * 2;
}

- (id)init
{
    if ( self = [super init] )
    {
        _blockConfigs = [CCArray array];
        _junkConfigs = [CCArray array];
        _zoomerConfigs = [CCArray array];
        _bombConfigs = [CCArray array];
    }
    return self;
}

@end
