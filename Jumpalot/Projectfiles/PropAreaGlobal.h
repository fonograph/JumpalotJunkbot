//
//  PropAreaGlobal.h
//  Jumpalot
//
//  Created by David Fono on 2013-06-21.
//
//

#import "CCNode.h"
#import "PropArea.h"

@interface PropAreaGlobal : PropArea

@property (nonatomic) BOOL isDynamic;
@property (readonly, nonatomic) CCArray *asteroids;

- (id)initWithSize:(CGSize)size;
- (void)scroll:(CGPoint)delta;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (void)generateAsteroids:(int)count;
- (void)cleanupProps;
- (void)updateDynamicProps;



@end
