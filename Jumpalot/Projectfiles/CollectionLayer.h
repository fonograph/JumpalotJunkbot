//
//  CollectionLayer.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import "CCLayer.h"
#import "CCScrollLayer.h"
#import "CollectionPage.h"

@protocol CollectionDelegate <NSObject>

- (void)collectionDidSelectBack;

@end

@class JunkType;

@interface CollectionLayer : CCLayer <CCScrollLayerDelegate, CollectionPageDelegate>
{
    CCMenu *_menu;
    CCMenuItemSprite *_upButton;
    CCMenuItemSprite *_leftButton;
    CCMenuItemSprite *_rightButton;
    
    CCLayerColor *_bgLayer;
    CCScrollLayer *_scrollLayer;
    
    CCNode *_statsContainer;
    CCLabelTTF *_percentageLabel;
    CCLabelTTF *_objectiveLabel;

    JunkType *_detailJunkType;
    CCNode *_detailContainer;
    CCSprite *_detailSprite;
    CCLabelTTF *_detailTitle;
    CCRenderTexture *_detailTitleStroke;
    CCLabelTTF *_detailDescription;
    CCRenderTexture *_detailDescriptionStroke;
    
    CCMenu *_tweetMenu;
    CCMenuItemSprite *_tweetButton;
    
    BOOL _showingStats;
    BOOL _showingDetail;
    
    int _cheatTapCount;
}

@property (weak, nonatomic) id<CollectionDelegate> delegate;

- (void)willBeOnscreen;
- (void)noLongerOnscreen;

@end
