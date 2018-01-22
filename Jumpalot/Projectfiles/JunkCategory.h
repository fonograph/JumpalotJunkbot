//
//  JunkCategory.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//

#import <Foundation/Foundation.h>

@class JunkType;

@interface JunkCategory : NSObject

@property (readonly, nonatomic) int level;
@property (readonly, nonatomic) ccColor3B color;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) CCArray *types;

+ (JunkCategory *)categoryForIndex:(int)index;

@end
