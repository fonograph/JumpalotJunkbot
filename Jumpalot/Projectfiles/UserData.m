//
//  UserData.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-14.
//
//

#define JUNK_COUNTS_KEY @"JunkCounts4" //number suffix allows versioning
#define JUNK_VIEWED_KEY @"JunkViewed4"
#define HI_SCORE_KEY @"HiScore4"
#define LONGEST_TIME_KEY @"LongestTime4"
#define HI_JUNKS_KEY @"HiJunks4"
#define GAMES_PLAYED_KEY @"GamesPlayed4"
//#define GAME_CENTER_DISABLED @"GameCenterDisabled"

#import "UserData.h"
#import "JunkType.h"
#import "JunkCategory.h"
#import "KKGameKitHelper.h"

static UserData *sharedData;

@implementation UserData

+ (UserData *)sharedData
{
    if ( !sharedData )
        sharedData = [[UserData alloc] init];
    return sharedData;
}

- (id)init
{
    if ( self = [super init] )
    {
        NSDictionary *junkCounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:JUNK_COUNTS_KEY];
        if ( junkCounts )
            _junkCounts = [NSMutableDictionary dictionaryWithDictionary:junkCounts];
        else
            _junkCounts = [NSMutableDictionary dictionary];
        
        NSDictionary *junkViewed = [[NSUserDefaults standardUserDefaults] dictionaryForKey:JUNK_VIEWED_KEY];
        if ( junkViewed )
            _junkViewed = [NSMutableDictionary dictionaryWithDictionary:junkViewed];
        else
            _junkViewed = [NSMutableDictionary dictionary];
    }
    return self;
}

- (int)junkCountForType:(JunkType *)type
{
    NSNumber *number = [_junkCounts objectForKey:type.identifier];
    return number.intValue;
//    return 1;
}

- (void)addToJunkCountForType:(JunkType *)type
{
    NSNumber *number = [_junkCounts objectForKey:type.identifier];
    [_junkCounts setObject:[NSNumber numberWithInt:number.intValue+1] forKey:type.identifier];
}

- (BOOL)junkViewed:(JunkType *)type
{
    return [_junkViewed objectForKey:type.identifier] != nil;
}

- (void)setJunkViewed:(JunkType *)type
{
    [_junkViewed setObject:[NSNumber numberWithBool:YES] forKey:type.identifier];
    [self save];
}

- (BOOL)addScore:(int)score
{
    [[KKGameKitHelper sharedGameKitHelper] submitScore:(int64_t)score category:@"scores"];
    if ( score > [self highScore] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:HI_SCORE_KEY];
        return YES;
    }
    return NO;
}

- (int)highScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:HI_SCORE_KEY];
}

- (BOOL)addTime:(int)time
{
    [[KKGameKitHelper sharedGameKitHelper] submitScore:(int64_t)time category:@"times"];
    
    if ( time > [self longestTime] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:time forKey:LONGEST_TIME_KEY];
        return YES;
    }
    return NO;
}

- (int)longestTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:LONGEST_TIME_KEY];
}

- (BOOL)addJunks:(int)junks
{
    [[KKGameKitHelper sharedGameKitHelper] submitScore:(int64_t)junks category:@"junks"];
    
    if ( junks > [self highJunks] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:junks forKey:HI_JUNKS_KEY];
        return YES;
    }
    return NO;
}

- (int)highJunks
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:HI_JUNKS_KEY];
}

- (int)junkCountForCategory:(JunkCategory *)category
{
    int count = 0;
    for ( JunkType *type in category.types )
    {
        if ( [self junkCountForType:type] )
            count++;
    }
    return count;
}

- (int)junkPercentageForCategory:(JunkCategory *)category
{
    int count = [self junkCountForCategory:category];
    return count/(float)category.types.count * 100;
}

- (BOOL)unlock1Achieved
{
    return [self junkPercentageForCategory:[JunkCategory categoryForIndex:2]] >= 50;
}

- (BOOL)unlock2Achieved
{
    return [self junkPercentageForCategory:[JunkCategory categoryForIndex:3]] >= 60;
}

- (BOOL)unlock3Achieved
{
    return [self junkPercentageForCategory:[JunkCategory categoryForIndex:4]] >= 70;
}

- (int)remainingForUnlock1
{
    JunkCategory *cat = [JunkCategory categoryForIndex:2];
    return ceilf(cat.types.count * 0.5) - [self junkCountForCategory:cat];
}

- (int)remainingForUnlock2
{
    JunkCategory *cat = [JunkCategory categoryForIndex:3];
    return ceilf(cat.types.count * 0.6) - [self junkCountForCategory:cat];
}

- (int)remainingForUnlock3
{
    JunkCategory *cat = [JunkCategory categoryForIndex:4];
    return ceilf(cat.types.count * 0.7) - [self junkCountForCategory:cat];
}

- (NSString *)nextUnlockDescription
{
    if ( ![self unlock1Achieved] )
    {
        return [NSString stringWithFormat:@"COLLECT 50%% OF %@ JUNK TO UPGRADE JUNKBOT", [JunkCategory categoryForIndex:2].title];
    }
    else if ( ![self unlock2Achieved] )
    {
        return [NSString stringWithFormat:@"COLLECT 60%% OF %@ JUNK TO UPGRADE JUNKBOT", [JunkCategory categoryForIndex:3].title];
    }
    else if ( ![self unlock3Achieved] )
    {
        return [NSString stringWithFormat:@"COLLECT 70%% OF %@ JUNK TO UPGRADE JUNKBOT", [JunkCategory categoryForIndex:4].title];
    }
    return @"";
}

- (int)gamesPlayed
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:GAMES_PLAYED_KEY];
}

- (void)addGamePlayed
{
    [[NSUserDefaults standardUserDefaults] setInteger:[self gamesPlayed]+1 forKey:GAMES_PLAYED_KEY];
}

//- (void)setGameCenterDisabled:(BOOL)disabled
//{
//    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:GAME_CENTER_DISABLED];
//}
//
//- (BOOL)isGameCenterDisabled
//{
//    return [[NSUserDefaults standardUserDefaults] boolForKey:GAME_CENTER_DISABLED];
//}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:_junkCounts forKey:JUNK_COUNTS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:_junkViewed forKey:JUNK_VIEWED_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)reset
{
    _junkCounts = [NSMutableDictionary dictionary];
    _junkViewed = [NSMutableDictionary dictionary];
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];    
}

- (NSString *)collectionSummary
{
    return [NSString stringWithFormat:@"%d/%d/%d/%d",
            [self junkPercentageForCategory:[JunkCategory categoryForIndex:1]],
            [self junkPercentageForCategory:[JunkCategory categoryForIndex:2]],
            [self junkPercentageForCategory:[JunkCategory categoryForIndex:3]],
            [self junkPercentageForCategory:[JunkCategory categoryForIndex:4]]
            ];
}

@end
