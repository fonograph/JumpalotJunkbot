//
//  JunkCategory.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-13.
//
//


// http://www.colourlovers.com/palette/971420/Hippie_van_%E2%98%AE
//#define COLOR_1 ccc3(253,230,189)
//#define COLOR_2 ccc3(161,197,171)
//#define COLOR_3 ccc3(244,221,81)
//#define COLOR_4 ccc3(209,30,72)

// http://www.colourlovers.com/palette/55400/Neon_Virus
#define COLOR_1 ccc3(34,141,255)
#define COLOR_2 ccc3(182,255,100)
#define COLOR_3 ccc3(255,202,27)
#define COLOR_4 ccc3(255,0,146)

#define TITLE_1 @"WORTHLESS"
#define TITLE_2 @"DECENT"
#define TITLE_3 @"SWEET"
#define TITLE_4 @"EXQUISITE"


#import "JunkCategory.h"
#import "JunkType.h"

static JunkCategory *sharedCategories[4] = {nil, nil, nil, nil};

@interface JunkCategory()

- (id)initWithCategoryIndex:(int)i;

@end

@implementation JunkCategory

- (id)initWithCategoryIndex:(int)i
{
    NSAssert(i>=1 && i<=4, @"Invalid junk category index given");
    
    if ( self = [super init] )
    {
        _level = i;

        switch ( i )
        {
            case 1:
                _color = COLOR_1;
                _title = TITLE_1;
                break;
            case 2:
                _color = COLOR_2;
                _title = TITLE_2;
                break;
            case 3:
                _color = COLOR_3;
                _title = TITLE_3;
                break;
            case 4:
                _color = COLOR_4;
                _title = TITLE_4;
                break;
        }
        
        _types = [CCArray array];
//        for ( int i=0; i<_count; i++ )
//        {
//            JunkType *type = [[JunkType alloc] initWithCategory:self typeIndex:i];
//            [_types addObject:type];
//        }
        
        sharedCategories[i-1] = self;
    }
    return self;
}

+ (JunkCategory *)categoryForIndex:(int)index
{
    if ( sharedCategories[index-1] )
        return sharedCategories[index-1];
    else
        return [[JunkCategory alloc] initWithCategoryIndex:index];
}

@end
