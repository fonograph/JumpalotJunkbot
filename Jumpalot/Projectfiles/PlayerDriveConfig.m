//
//  PlayerDriveConfig.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-11.
//
//

#import "PlayerDriveConfig.h"

static int sharedLevelSetting = 1;

@interface PlayerDriveConfig()

- (id)initWithDefaults;

@end

@implementation PlayerDriveConfig

+ (int)sharedLevelSetting
{
    return sharedLevelSetting;
}

+ (void)setSharedLevelSetting:(int)level
{
    sharedLevelSetting = level;
}

- (float)hyperSpeed
{
    return self.maxSpeed + 5;
}

- (id)initWithDefaults
{
    if ( self = [super init] )
    {
        _decelFactor = 1.25;
        _hyperLength = 3;
        _energyDrainAccel = 0.015;
        _minZoom = 1.5;
        _maxZoom = 2.6;
    }
    return self;
}

- (id)initWithLevel1
{
    if ( self = [self initWithDefaults] )
    {
        _decelFactor = 1.15;
        _hyperLength = 2;
        _minSpeed = 200;
        _maxSpeed = _minSpeed * 3;
        _boostSpeed = _minSpeed / 2;
        _megaSpeed = _maxSpeed * 0.75;
        _ultraSpeed = _maxSpeed * 0.9;
        _energyDrainSpeed = 3;
        _minZoom = 1;
        _maxZoom = 2;
        
        _name = @"WORTHLESS";
        _color = ccc3(34,141,255);
        _level = 1;
    }
    return self;
}


- (id)initWithLevel2
{
    if ( self = [self initWithDefaults] )
    {
        _decelFactor = 1.25;
        _hyperLength = 3;
        _minSpeed = 250;
        _maxSpeed = _minSpeed * 3.2;
        _boostSpeed = _minSpeed / 2;
        _megaSpeed = _maxSpeed * 0.75;
        _ultraSpeed = _maxSpeed * 0.9;
        _energyDrainSpeed = 2.5;
        
        _name = @"DECENT";
        _color = ccc3(182,255,100);
        _level = 2;
    }
    return self;
}

- (id)initWithLevel3
{
    if ( self = [self initWithDefaults] )
    {
        _decelFactor = 1.275;
        _hyperLength = 3.5;
        _minSpeed = 300;
        _maxSpeed = _minSpeed * 3.35;
        _boostSpeed = _minSpeed / 2;
        _megaSpeed = _maxSpeed * 0.75;
        _ultraSpeed = _maxSpeed * 0.9;
        _energyDrainSpeed = 2.25;

        
        _name = @"SWEET";
        _color = ccc3(255,202,27);
        _level = 3;
    }
    return self;
}

- (id)initWithLevel4
{
    if ( self = [self initWithDefaults] )
    {
        _decelFactor = 1.3;
        _hyperLength = 4;
        _minSpeed = 350;
        _maxSpeed = _minSpeed * 3.5;
        _boostSpeed = _minSpeed / 2;
        _megaSpeed = _maxSpeed * 0.75;
        _ultraSpeed = _maxSpeed * 0.9;
        _energyDrainSpeed = 2;

        
        _name = @"EXQUISITE";
        _color = ccc3(255,0,146);
        _level = 4;
    }
    return self;
}


+ (PlayerDriveConfig *)driveConfigWithLevel:(int)level
{
    if ( level == 1 )
        return [[PlayerDriveConfig alloc] initWithLevel1];
    else if ( level == 2 )
        return [[PlayerDriveConfig alloc] initWithLevel2];
    else if ( level == 3 )
        return [[PlayerDriveConfig alloc] initWithLevel3];
    else if ( level == 4 )
        return [[PlayerDriveConfig alloc] initWithLevel4];
    else
        return nil;
}

@end
