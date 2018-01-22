//
//  CCFilledRect.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "cocos2d.h"
#import "CCFilledRect.h"

@implementation CCFilledRect

void ccDrawFilledRect( CGPoint v1, CGPoint v2 )
{
	CGPoint poli[]={v1,CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );    
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
	// restore default state
}

@end
