//
//  PropsManager.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-23.
//
//

#import "CCNode.h"

@class PropArea, PropAreaGlobal;

@interface PropAreasManager : CCNode
{
//    int _minTemplateSet;
//    int _maxTemplateSet;
    ccTime _generateCounter;
}

@property (nonatomic) BOOL isDynamic;
@property (strong, readonly, nonatomic) CCArray *areas;
@property (strong, readonly, nonatomic) PropAreaGlobal *globalArea; // moving shit

//- (void)startDifficultyTimer;
- (id)initWithDynamic:(BOOL)isDynamic;
- (PropArea *)areaWithPoint:(CGPoint)point;
- (void)scroll:(CGPoint)delta;
- (void)resetAndRepopulateAreas;
- (void)generateGlobalProps:(ccTime)delta;
- (void)cleanupGlobalProps;
- (void)updateDynamicProps;


@end
