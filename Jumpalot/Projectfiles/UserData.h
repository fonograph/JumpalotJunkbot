//
//  UserData.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-14.
//
//

#import <Foundation/Foundation.h>

@class JunkCategory, JunkType;

@interface UserData : NSObject
{
    NSMutableDictionary *_junkCounts;
    NSMutableDictionary *_junkViewed;
}

+ (UserData *)sharedData;

- (int)junkCountForType:(JunkType *)type;
- (void)addToJunkCountForType:(JunkType *)type;

- (BOOL)junkViewed:(JunkType *)type;
- (void)setJunkViewed:(JunkType *)type;

- (int)junkPercentageForCategory:(JunkCategory *)category;

- (BOOL)addScore:(int)score;
- (int)highScore;

- (BOOL)addTime:(int)time;
- (int)longestTime;

- (BOOL)addJunks:(int)junks;
- (int)highJunks;

- (BOOL)unlock1Achieved;
- (BOOL)unlock2Achieved;
- (BOOL)unlock3Achieved;

- (int)remainingForUnlock1;
- (int)remainingForUnlock2;
- (int)remainingForUnlock3;
- (NSString *)nextUnlockDescription;

- (int)gamesPlayed;
- (void)addGamePlayed;

//- (void)setGameCenterDisabled:(BOOL)disabled;
//- (BOOL)isGameCenterDisabled;

- (void)save;
- (void)reset;

- (NSString *)collectionSummary;

@end
