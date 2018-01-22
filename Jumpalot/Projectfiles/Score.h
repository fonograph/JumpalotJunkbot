//
//  Score.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

@property (readonly, nonatomic) int points;
@property (readonly, nonatomic) int level;
@property (readonly, nonatomic) int junksToLevelUp;
@property (readonly, nonatomic) int junksRemainingToLevelUp;
@property (nonatomic) ccTime time;
@property (nonatomic) int junks;
@property (nonatomic) int hypers;
@property (nonatomic) int combos;

- (void)addPoints:(int)points;
- (void)levelUp;

@end
