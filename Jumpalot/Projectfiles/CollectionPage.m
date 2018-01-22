//
//  CollectionPage.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//

#import "CollectionPage.h"
#import "JunkCategory.h"
#import "JunkType.h"
#import "UserData.h"
#import "CCLabelStroker.h"

@implementation CollectionPage

- (id)initWithJunkCategory:(JunkCategory *)category delegate:(id<CollectionPageDelegate>)delegate
{
    if ( self = [super init] )
    {
        _category = category;
        _delegate = delegate;
        
        float scrollViewBottom = [CCDirector sharedDirector].winSize.height - 335;
        
        _title = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@ JUNK", [_category.title uppercaseString]]
                                    fontName:FONT_D3_ALPHABET
                                    fontSize:20];
        _title.color = _category.color;
        _title.position = ccp([CCDirector sharedDirector].winSize.width/2, 267 + scrollViewBottom);
        [self addChild:_title];
        
        _icons = [CCArray array];
        
        for ( NSUInteger i=0; i<_category.types.count; i++ )
        {
            JunkType *type = [_category.types objectAtIndex:i];
            
            CCNode *icon = [[CCNode alloc] init];
            icon.contentSize = CGSizeMake(50, 50);
            
            CCSprite *bg = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"junkhalo%d.png", arc4random()%5+1]];
            bg.color = _category.color;
            bg.scaleX = 45 / bg.contentSize.width;
            bg.scaleY = 45 / bg.contentSize.height;
            bg.rotation = arc4random() % 360;
            
            CCNode<CCRGBAProtocol> *junk;
            
            if ( [[UserData sharedData] junkCountForType:type] ) 
            {
                junk = type.spriteSmall;
                //junk.opacity = 200;
                junk.scale = 35 / junk.contentSize.width;
                bg.opacity = 200;
            }
            else
            {
                junk = [CCLabelTTF labelWithString:@"?" fontName:FONT_D3_ALPHABET fontSize:27];
                //junk.opacity = 200;
                bg.opacity = 100;
            }
            junk.opacity = 200;
            
            [icon addChild:bg z:0 tag:1];
            [icon addChild:junk z:0 tag:2];
            
            if ( [[UserData sharedData] junkCountForType:type] && ![[UserData sharedData] junkViewed:type] )
            {
                CCLabelTTF *new = [CCLabelTTF labelWithString:@"NEW" fontName:FONT_D3_ALPHABET fontSize:12];
                new.color = _category.color;
                new.color = ccc3((new.color.r+255)/2, (new.color.g+255)/2, (new.color.b+255)/2);
                [icon addChild:new z:5 tag:3];
                
                CCRenderTexture *newStroke = [CCLabelStroker createStroke:new size:1 color:ccBLACK];
                newStroke.sprite.opacity = 200;
                [icon addChild:newStroke z:4 tag:4];
            }
            
            CGFloat x = 10 + (i%6)*50 + icon.contentSize.width/2;
            CGFloat y = 250 - (10 + (i/6)*50 + icon.contentSize.height/2) + scrollViewBottom;
            icon.position = ccp(x, y);
            
            [self addChild:icon];
            [_icons addObject:icon];
        }
        
        _iconsRect = CGRectMake(0, scrollViewBottom, [CCDirector sharedDirector].winSize.width, 250);
        
        self.touchEnabled = YES;
    }
    return self;
}

- (void)registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:kCCMenuHandlerPriority swallowsTouches:YES];
}

- (void)onEnter
{
    [super onEnter];
}

- (void)onExit
{
    [super onExit];
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

- (void)resetSelection
{
    if ( _selectedIcon )
        [self setIconUnselected:_selectedIcon];
    _selectedIcon = nil;
}

- (void)setIconSelected:(CCNode *)icon
{
    CCSprite *bg = (CCSprite *)[icon getChildByTag:1];
    bg.opacity = 255;
    
    CCSprite *junk = (CCSprite *)[icon getChildByTag:2];
    junk.opacity = 255;
    junk.scale *= 1.2;
}

- (void)setIconUnselected:(CCNode *)icon
{
    CCSprite *bg = (CCSprite *)[icon getChildByTag:1];
    bg.opacity = 200;
    
    CCSprite *junk = (CCSprite *)[icon getChildByTag:2];
    junk.opacity = 200;
    junk.scale /= 1.2;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
    if ( !_tapTouch && CGRectContainsPoint(_iconsRect, pt) )
    {
        for ( CCNode *icon in _icons )
        {
            CGRect bounds = CGRectMake(icon.position.x-icon.contentSize.width/2, icon.position.y-icon.contentSize.height/2,
                                       icon.contentSize.width, icon.contentSize.height);
            if ( CGRectContainsPoint(bounds, pt) )
            {
                _tapIcon = icon;
                _tapTouch = touch;

//                JunkType *type = [_category.types objectAtIndex:[_icons indexOfObject:_tapIcon]];
//                [_delegate collectionPageDidSelectJunkType:type];
                
                return YES;
            }
        }
    }
    return NO;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
    if ( _tapTouch == touch )
    {
        CGRect bounds = CGRectMake(_tapIcon.position.x-_tapIcon.contentSize.width/2, _tapIcon.position.y-_tapIcon.contentSize.height/2,
                                   _tapIcon.contentSize.width, _tapIcon.contentSize.height);
        if ( CGRectContainsPoint(bounds, pt) )
        {
            JunkType *type = [_category.types objectAtIndex:[_icons indexOfObject:_tapIcon]];
            if ( [[UserData sharedData] junkCountForType:type] )
            {
                [_delegate collectionPageDidSelectJunkType:type];
                
                if ( _selectedIcon )
                    [self setIconUnselected:_selectedIcon];
                _selectedIcon = _tapIcon;
                [self setIconSelected:_selectedIcon];
                
                if ( ![[UserData sharedData] junkViewed:type] )
                {
                    [[UserData sharedData] setJunkViewed:type];
                    [[_selectedIcon getChildByTag:3] removeFromParentAndCleanup:YES]; // remove new label and stroke
                    [[_selectedIcon getChildByTag:4] removeFromParentAndCleanup:YES];
                }
            }
        }
        _tapTouch = nil;
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( _tapTouch == touch )
    {
        _tapTouch = nil;
    }
}


@end
