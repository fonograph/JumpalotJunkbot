//
//  PropAreConfig.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import <Foundation/Foundation.h>

@class JunkCategory, JunkType;

// Produces data for random elements of PropAreas not set in templates
@interface PropAreaRandomizer : NSObject

- (JunkType *)typeForJunk;

+ (PropAreaRandomizer *)sharedRandomizer;

@end
