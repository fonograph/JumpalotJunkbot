//
//  PropAreaTemplatesManager.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-16.
//
//

#import <Foundation/Foundation.h>

@class PropAreaTemplate;

@interface PropAreaTemplatesManager : NSObject

@property (strong, nonatomic, readonly) CCArray *templatesA;
@property (strong, nonatomic, readonly) CCArray *templatesB;
@property (strong, nonatomic, readonly) CCArray *templatesC;
@property (strong, nonatomic, readonly) CCArray *templatesD;
@property (strong, nonatomic, readonly) CCArray *templatesE;
@property (strong, nonatomic, readonly) CCArray *templatesF;
@property (strong, nonatomic, readonly) CCArray *templatesZ;
@property (strong, nonatomic, readonly) PropAreaTemplate *startingTemplate;


+ (PropAreaTemplatesManager *)sharedManager;

- (void)loadTemplates;
- (PropAreaTemplate *)randomTemplateFromSet:(int)set;
- (PropAreaTemplate *)randomTemplateFromSet:(int)set limit:(int)limit;

@end
