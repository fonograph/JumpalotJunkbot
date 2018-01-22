//
//  CollectionPage.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//

#import "CCLayer.h"

@class JunkCategory, JunkType;

@protocol CollectionPageDelegate <NSObject>

- (void)collectionPageDidSelectJunkType:(JunkType *)type;

@end

@interface CollectionPage : CCLayer
{
    JunkCategory *_category;
    CCLabelTTF *_title;
    CCArray *_icons;
    
    CCNode *_selectedIcon;
    
    UITouch *_tapTouch;
    CCNode *_tapIcon;
    
    CGRect _iconsRect;
}

@property (weak, nonatomic) id<CollectionPageDelegate> delegate;

- (id)initWithJunkCategory:(JunkCategory *)category delegate:(id<CollectionPageDelegate>)delegate;
- (void)resetSelection;

@end
