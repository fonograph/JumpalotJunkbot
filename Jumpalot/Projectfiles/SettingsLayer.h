//
//  SettingsLayer.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-15.
//
//

#import "CCLayer.h"

@protocol SettingsDelegate <NSObject>

- (void)settingsDidSelectBack;

@end

@interface SettingsLayer : CCLayer <UIAlertViewDelegate>
{
    CCMenu *_menu;
    CCMenuItem *_clearButton;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_junksLabel;
}

@property (weak, nonatomic) id<SettingsDelegate> delegate;

@end
