//
//  CCLabelStroker.h
//  Jumpalot
//
//  Created by David Fono on 2013-10-07.
//
//

#import <Foundation/Foundation.h>

@interface CCLabelStroker : NSObject

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;

@end
