//
//  PropAreaTemplatesManager.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-16.
//
//

#define BLOCK_TAG 1
#define BLOCK_REPEL_TAG 10
#define JUNK_TAG 2
#define ZOOMER_TAG 3
#define BOMB_TAG 4
#define BOMB_ATTRACT_TAG 40

#import "PropAreaTemplatesManager.h"
#import "CCBReader.h"
#import "PropAreaTemplate.h"

static PropAreaTemplatesManager *sharedManager;

@interface PropAreaTemplatesManager()

- (void)loadTemplatesFromSet:(int)i intoArray:(CCArray *)array;
- (PropAreaTemplate *)loadTemplate:(NSString *)name;

@end

@implementation PropAreaTemplatesManager

+ (PropAreaTemplatesManager *)sharedManager
{
    if ( !sharedManager )
        sharedManager = [[PropAreaTemplatesManager alloc] init];
    return sharedManager;
}

- (id)init
{
    if ( self = [super init] )
    {
    }
    return self;
}

- (void)loadTemplates
{
    _templatesA = [CCArray array];
    _templatesB = [CCArray array];
    _templatesC = [CCArray array];
    _templatesD = [CCArray array];
    _templatesE = [CCArray array];
    _templatesF = [CCArray array];
    _templatesZ = [CCArray array];
    
    [self loadTemplatesFromSet:0 intoArray:_templatesA];
    [self loadTemplatesFromSet:1 intoArray:_templatesB];
    [self loadTemplatesFromSet:2 intoArray:_templatesC];
    [self loadTemplatesFromSet:3 intoArray:_templatesD];
    [self loadTemplatesFromSet:4 intoArray:_templatesE];
    [self loadTemplatesFromSet:5 intoArray:_templatesF];
    [self loadTemplatesFromSet:25 intoArray:_templatesZ];
    
    _startingTemplate = [self loadTemplate:@"PropArea0.ccbi"];
}

- (void)loadTemplatesFromSet:(int)i intoArray:(CCArray *)array
{
    unichar set = [@"A" characterAtIndex:0] + i;
    int num = 1;
    
    while ( [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"PropArea%C%d", set, num] ofType:@"ccbi"] )
    {
        PropAreaTemplate *template = [self loadTemplate:[NSString stringWithFormat:@"PropArea%C%d.ccbi", set, num]];
        [array addObject:template];
        
        num++;
    }
}

- (PropAreaTemplate *)loadTemplate:(NSString *)name
{
    PropAreaTemplate *template = [[PropAreaTemplate alloc] init];
    
    CCScene *scene = [CCBReader sceneWithNodeGraphFromFile:name owner:nil parentSize:CGSizeMake(1000, 1000)];
    CCLayer *layer = [scene.children objectAtIndex:0];
    for ( CCNode *node in layer.children )
    {
        if ( node.tag == BLOCK_TAG || node.tag == BLOCK_REPEL_TAG )
        {
            [template.blockConfigs addObject:[BlockConfig blockConfigWithPosition:node.position
                                                                             size:CGSizeMake(node.contentSize.width * node.scaleX,
                                                                                             node.contentSize.height * node.scaleY)
                                                                            angle:-CC_DEGREES_TO_RADIANS(node.rotation)
                                                                            repel:node.tag==BLOCK_REPEL_TAG
                                              ]];
        }
        else if ( node.tag == JUNK_TAG )
        {
            [template.junkConfigs addObject:[JunkConfig junkConfigWithPosition:node.position
                                                                          type:1
                                             ]];
        }
        else if ( node.tag == ZOOMER_TAG )
        {
            [template.zoomerConfigs addObject:[ZoomerConfig zoomerConfigWithPosition:node.position
                                                                                size:CGSizeMake(node.contentSize.width * node.scaleX,
                                                                                                node.contentSize.height * node.scaleY)
                                               ]];
        }
        else if ( node.tag == BOMB_TAG || node.tag == BOMB_ATTRACT_TAG )
        {
            [template.bombConfigs addObject:[BombConfig bombConfigWithPosition:node.position
                                                                          size:CGSizeMake(node.contentSize.width * node.scaleX,
                                                                                          node.contentSize.height * node.scaleY)
                                                                       attract:node.tag==BOMB_ATTRACT_TAG
                                             ]];
        }
    }

    return template;
}

- (PropAreaTemplate *)randomTemplateFromSet:(int)set
{
    return [self randomTemplateFromSet:set limit:-1];
}

- (PropAreaTemplate *)randomTemplateFromSet:(int)set limit:(int)limit
{
    CCArray *templates;
    if ( set == 0 )
        templates = _templatesZ;
    else if ( set == 1 )
        templates = _templatesA;
    else if ( set == 2 )
        templates = _templatesB;
    else if ( set == 3 )
        templates = _templatesC;
    else if ( set == 4 )
        templates = _templatesD;
    else if ( set == 5 )
        templates = _templatesE;
    else if ( set == 6 )
        templates = _templatesF;
    
    if ( limit == -1 )
        limit = templates.count;
        
    return [templates objectAtIndex:arc4random()%limit];
}

@end
