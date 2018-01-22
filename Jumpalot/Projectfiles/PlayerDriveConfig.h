//
//  PlayerDriveConfig.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-11.
//
//

#import <Foundation/Foundation.h>

@interface PlayerDriveConfig : NSObject

@property (readonly, nonatomic) float minSpeed;
@property (readonly, nonatomic) float maxSpeed;
@property (readonly, nonatomic) float boostSpeed;
@property (readonly, nonatomic) float decelFactor;
@property (readonly, nonatomic) float hyperSpeed;
@property (readonly, nonatomic) float hyperLength;
@property (readonly, nonatomic) float megaSpeed;
@property (readonly, nonatomic) float ultraSpeed;
@property (nonatomic) float energyDrainSpeed;
@property (readonly, nonatomic) float energyDrainAccel;
@property (readonly, nonatomic) float minZoom;
@property (readonly, nonatomic) float maxZoom;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) ccColor3B color;
@property (readonly, nonatomic) int level;

- (id)initWithLevel1;
- (id)initWithLevel2;
- (id)initWithLevel3;
- (id)initWithLevel4;

+ (PlayerDriveConfig *)driveConfigWithLevel:(int)level;

+ (void)setSharedLevelSetting:(int)level;
+ (int)sharedLevelSetting;

@end
