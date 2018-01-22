//
//  CollectionLayer.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import "CollectionLayer.h"
#import "JunkCategory.h"
#import "UserData.h"
#import "JunkType.h"
#import "CCLabelStroker.h"
#import "SimpleAudioEngine.h"
#import "MainMenuScene.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface CollectionLayer()

- (void)showStats;

@end

@implementation CollectionLayer

- (id)init
{
    if ( self = [super init] )
    {
        CCDirector *director = [CCDirector sharedDirector];
        
        // SCROLLING CONTENTS
        
        CollectionPage *page1 = [[CollectionPage alloc] initWithJunkCategory:[JunkCategory categoryForIndex:1] delegate:self];
        CollectionPage *page2 = [[CollectionPage alloc] initWithJunkCategory:[JunkCategory categoryForIndex:2] delegate:self];
        CollectionPage *page3 = [[CollectionPage alloc] initWithJunkCategory:[JunkCategory categoryForIndex:3] delegate:self];
        CollectionPage *page4 = [[CollectionPage alloc] initWithJunkCategory:[JunkCategory categoryForIndex:4] delegate:self];
        
        _bgLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 76) width:director.winSize.width height:270];
        _bgLayer.position = ccp(0, director.winSize.height - 357);
        [self addChild:_bgLayer];
        
        _scrollLayer = [[CCScrollLayer alloc] initWithLayers:@[page1, page2, page3, page4] widthOffset:0];
        _scrollLayer.showPagesIndicator = NO;
        //_scrollLayer.pagesIndicatorPosition = ccp(director.winSize.width/2, _bgLayer.position.y - 10);
        _scrollLayer.delegate = self;
        [self addChild:_scrollLayer];
        
        _scrollLayer.visible = NO;
        
        // DETAIL AREA
        
        _statsContainer = [[CCNode alloc] init];
        _statsContainer.contentSize = CGSizeMake(director.winSize.width, _bgLayer.position.y);
        _statsContainer.position = ccp(0, 0);
        [self addChild:_statsContainer];
        
        NSString *cat1Perc = [NSString stringWithFormat:@"%d%%", [[UserData sharedData] junkPercentageForCategory:[JunkCategory categoryForIndex:1]]];
        _percentageLabel = [CCLabelTTF labelWithString:cat1Perc
                                              fontName:FONT_D3_ALPHABET
                                              fontSize:40];
        _percentageLabel.position = ccp(director.winSize.width/2, _statsContainer.contentSize.height - _percentageLabel.contentSize.height/2 - 3);
        [_statsContainer addChild:_percentageLabel];
        
        _objectiveLabel = [CCLabelTTF labelWithString:[[UserData sharedData] nextUnlockDescription]
                                                      dimensions:CGSizeMake(280, 40)
                                                      hAlignment:kCCTextAlignmentCenter
                                                      vAlignment:kCCVerticalTextAlignmentCenter
                                                        fontName:FONT_D3_ROUND
                                                        fontSize:15];
        _objectiveLabel.position = ccp(director.winSize.width/2, _statsContainer.contentSize.height * 0.4 );
        [_statsContainer addChild:_objectiveLabel];
        
//        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HI-SCORE %d", [[UserData sharedData] highScore]]
//                                                    fontName:FONT_D3_ROUND_ITALIC
//                                                    fontSize:24];
//        scoreLabel.opacity = 178;
//        scoreLabel.position = ccp(director.winSize.width/2, 15);
//        [_statsContainer addChild:scoreLabel];
        
//        int minutes = (int)[[UserData sharedData] longestTime] / 60;
//        int seconds = (int)[[UserData sharedData] longestTime] % 60;
//        CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"LONGEST SURVIVAL %d:%02d", minutes, seconds]
//                                                    fontName:FONT_D3_ROUND_ITALIC
//                                                    fontSize:15];
//        timeLabel.opacity = 178;
//        timeLabel.position = ccp(director.winSize.width/2, 15);
//        [_statsContainer addChild:timeLabel];
        
        
        // DETAIL
        
        _detailContainer = [[CCNode alloc] init];
        _detailContainer.contentSize = _statsContainer.contentSize;
        _detailContainer.position = _statsContainer.position;
        [self addChild:_detailContainer];
        
        _detailTitle = [CCLabelTTF labelWithString:@" "
                                        dimensions:CGSizeMake(_detailContainer.contentSize.width-40, 20)
                                        hAlignment:kCCTextAlignmentCenter
                                        vAlignment:kCCVerticalTextAlignmentBottom
                                          fontName:FONT_D3_ROUND_ITALIC
                                          fontSize:20];
        _detailTitle.anchorPoint = ccp(0.5, 1);
        _detailTitle.position = ccp(_detailContainer.contentSize.width/2, _detailContainer.contentSize.height * 0.87);
        [_detailContainer addChild:_detailTitle z:10];
        
        _detailDescription = [CCLabelTTF labelWithString:@" "
                                              dimensions:CGSizeMake(_detailTitle.dimensions.width, 47)
                                              hAlignment:kCCTextAlignmentLeft
                                              vAlignment:kCCVerticalTextAlignmentCenter
                                                fontName:@"GillSans-Bold"
                                                fontSize:11];
        _detailDescription.anchorPoint = ccp(0.5, 1);
        _detailDescription.position = ccp(_detailTitle.position.x, CGRectGetMinY(_detailTitle.boundingBox)-5);
        [_detailContainer addChild:_detailDescription z:10];
        
        CCSprite *tweetSprite = [CCSprite spriteWithFile:@"collection_tweet.png"];
        CCSprite *tweetSpriteSel = [CCSprite spriteWithFile:@"collection_tweet.png"]; tweetSpriteSel.color = ccc3(127, 127, 127);
        _tweetButton = [CCMenuItemSprite itemWithNormalSprite:tweetSprite selectedSprite:tweetSpriteSel target:self selector:@selector(tappedTweet:)];
        _tweetButton.anchorPoint = ccp(1, 1);
        _tweetButton.position = ccp(CGRectGetMaxX(_detailDescription.boundingBox), CGRectGetMinY(_detailDescription.boundingBox));
        _tweetButton.opacity = 170;
        _tweetMenu = [CCMenu menuWithItems:_tweetButton, nil];
        _tweetMenu.position = CGPointZero;
        _tweetMenu.opacity = 0;
        [_detailContainer addChild:_tweetMenu z:9];
        
        
        _showingStats = YES;
        _showingDetail = NO;
        
        
        // MENU
        
        CCSprite *upSprite = [CCSprite spriteWithFile:@"mainmenu_up.png"];
        
        CCSprite *upSpriteSel = [CCSprite spriteWithFile:@"mainmenu_up.png"];
        upSpriteSel.color = ccc3(127, 127, 127);
        
        CCSprite *leftSprite = [CCSprite spriteWithFile:@"mainmenu_left.png"];
        
        CCSprite *leftSpriteSel = [CCSprite spriteWithFile:@"mainmenu_left.png"];
        leftSpriteSel.color = ccc3(127, 127, 127);
        
        CCSprite *rightSprite = [CCSprite spriteWithFile:@"mainmenu_left.png"];
        rightSprite.flipX = YES;
        
        CCSprite *rightSpriteSel = [CCSprite spriteWithFile:@"mainmenu_left.png"];
        rightSpriteSel.flipX = YES;
        rightSpriteSel.color = ccc3(127, 127, 127);
        
        _upButton = [CCMenuItemSprite itemWithNormalSprite:upSprite selectedSprite:upSpriteSel target:self selector:@selector(tappedUp:)];
        _upButton.position = ccp(0, director.winSize.height/2-21);
        _upButton.opacity = 204;
        
        _leftButton = [CCMenuItemSprite itemWithNormalSprite:leftSprite selectedSprite:leftSpriteSel target:self selector:@selector(tappedLeft:)];
        _leftButton.position = ccp(-director.winSize.width/2 + leftSprite.contentSize.width/2, director.winSize.height/2-67);
        
        _rightButton = [CCMenuItemSprite itemWithNormalSprite:rightSprite selectedSprite:rightSpriteSel target:self selector:@selector(tappedRight:)];
        _rightButton.position = ccp(director.winSize.width/2 - rightSprite.contentSize.width/2, director.winSize.height/2-67);
        
        _menu = [CCMenu menuWithItems:_upButton, _leftButton, _rightButton, nil];
        [self addChild:_menu];        
    }
    return self;
}


- (void)transDetailOutAndRunAction:(CCFiniteTimeAction *)action
{
    [_detailTitle stopAllActions];
    [_detailTitleStroke.sprite stopAllActions];
    [_detailDescription stopAllActions];
    [_detailDescriptionStroke.sprite stopAllActions];
    [_tweetMenu stopAllActions];
    [_detailSprite stopAllActions];
    
    [_detailTitle runAction:[CCFadeOut actionWithDuration:0.25]];
    [_detailTitleStroke.sprite runAction:[CCFadeOut actionWithDuration:0.25]];
    [_detailDescription runAction:[CCFadeOut actionWithDuration:0.25]];
    [_detailDescriptionStroke.sprite runAction:[CCFadeOut actionWithDuration:0.25]];
    [_tweetMenu runAction:[CCFadeOut actionWithDuration:0.25]];
    
    CCMoveTo *moveSprite = [CCMoveTo actionWithDuration:0.25 position:ccp(_detailSprite.position.x, -_detailContainer.contentSize.height/2)];
    [_detailSprite runAction:[CCEaseIn actionWithAction:[CCFadeOut actionWithDuration:0.25] rate:4]];
    [_detailSprite runAction:[CCSequence actionOne:[CCEaseIn actionWithAction:moveSprite rate:2]
                                               two:action]];
    
    _showingDetail = NO;
}

- (void)transDetailInWithJunkType:(JunkType *)type
{
    if ( _detailSprite )
        [_detailSprite removeFromParentAndCleanup:YES];
    
    _detailSprite = type.spriteLarge;
    _detailSprite.position = ccp(_detailContainer.contentSize.width/2, -_detailContainer.contentSize.height/2);
    _detailSprite.scale = _detailContainer.contentSize.height / MAX(_detailSprite.contentSize.width, _detailSprite.contentSize.height);
    [_detailSprite runAction:[CCRotateBy actionWithDuration:10000 angle:100000]];
    [_detailContainer addChild:_detailSprite z:0];
    
    
    _detailTitle.string = type.name;
    _detailTitle.opacity = 0;
    
    _detailDescription.string = type.desc;
    _detailDescription.opacity = 0;

    if ( _detailTitleStroke )
        [_detailTitleStroke removeFromParentAndCleanup:YES];
    _detailTitleStroke = [CCLabelStroker createStroke:_detailTitle size:2 color:ccBLACK];
    _detailTitleStroke.sprite.opacity = 0;
    [_detailContainer addChild:_detailTitleStroke z:_detailTitle.zOrder-1];
    
    if ( _detailDescriptionStroke )
        [_detailDescriptionStroke removeFromParentAndCleanup:YES];
    _detailDescriptionStroke = [CCLabelStroker createStroke:_detailDescription size:1 color:ccBLACK];
    _detailDescriptionStroke.sprite.opacity = 0;
    [_detailContainer addChild:_detailDescriptionStroke z:_detailDescription.zOrder-1];
    
    _tweetMenu.opacity = 0;
    
    // animation
    [_detailSprite runAction:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:ccp(_detailSprite.position.x, _detailContainer.contentSize.height/2)] rate:2]];
    [_detailTitle runAction:[CCFadeIn actionWithDuration:0.25]];
    [_detailTitleStroke.sprite runAction:[CCFadeIn actionWithDuration:0.25]];
    [_detailDescription runAction:[CCFadeIn actionWithDuration:0.25]];
    [_detailDescriptionStroke.sprite runAction:[CCFadeIn actionWithDuration:0.25]];
    [_tweetMenu runAction:[CCFadeIn actionWithDuration:0.25]];
    
    _showingDetail = YES;
}

- (void)willBeOnscreen
{
    _scrollLayer.visible = YES;
}

- (void)noLongerOnscreen
{
    _scrollLayer.visible = NO;
}

- (void)showStats
{
    [_percentageLabel runAction:[CCFadeIn actionWithDuration:0.25]];
    [_objectiveLabel runAction:[CCFadeIn actionWithDuration:0.25]];
    _showingStats = YES;
}

- (void)hideStatsAndRunAction:(CCFiniteTimeAction *)action
{
    [_percentageLabel runAction:[CCFadeOut actionWithDuration:0.25]];
    [_objectiveLabel runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:0.25]
                                                 two:action]];
    _showingStats = NO;
}

- (void)onEnter
{
    [super onEnter];
}

- (void)tappedUp:(id)sender
{
    [_delegate collectionDidSelectBack];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
    
    _cheatTapCount = 0;
}

- (void)tappedLeft:(id)sender
{
    [_scrollLayer moveToPage:_scrollLayer.currentScreen-1];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
    
    _cheatTapCount++;
    if ( _cheatTapCount == 20 )
    {
        // CHEAT
        for ( int i=1; i<=4; i++ )
        {
            JunkCategory *cat = [JunkCategory categoryForIndex:i];
            for ( JunkType *type in cat.types )
            {
                [[UserData sharedData] addToJunkCountForType:type];
            }
        }
        [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];
    }
}

- (void)tappedRight:(id)sender
{
    [_scrollLayer moveToPage:_scrollLayer.currentScreen+1];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
    
    _cheatTapCount = 0;
}

- (void)tappedTweet:(id)sender
{
    NSString *text = _detailJunkType.tweetText;
    
    BOOL isSocialAvailable = NSClassFromString(@"SLComposeViewController") != nil;
    if ( isSocialAvailable )
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:text];
            [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
        }
    }
    else
    {
        if ([TWTweetComposeViewController canSendTweet])
        {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:text];
            [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
        }
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
}

- (void)collectionPageDidSelectJunkType:(JunkType *)type
{
    if ( [[UserData sharedData] junkCountForType:type] )
    {
        if ( !_showingStats )
        {
            if ( _showingDetail )
                [self transDetailOutAndRunAction:[CCCallFuncO actionWithTarget:self selector:@selector(transDetailInWithJunkType:) object:type]];
            else
                [self transDetailInWithJunkType:type];
            
            _detailJunkType = type;
            [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
        }
        else
        {
            [self hideStatsAndRunAction:[CCCallFuncO actionWithTarget:self selector:@selector(collectionPageDidSelectJunkType:) object:type]];
        }
    }
}

- (void)scrollLayer:(CCScrollLayer *)sender scrolledToPageNumber:(int)page
{
    UserData *data = [UserData sharedData];
    _percentageLabel.string = [NSString stringWithFormat:@"%d%%", [data junkPercentageForCategory:[JunkCategory categoryForIndex:page+1]]];
    
    for ( CollectionPage *page in _scrollLayer.pages )
    {
        [page resetSelection];
    }
    
    if ( !_showingStats )
    {
        [self transDetailOutAndRunAction:[CCCallFunc actionWithTarget:self selector:@selector(showStats)]];
    }
}

@end
