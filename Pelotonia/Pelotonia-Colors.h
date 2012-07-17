//
//  Pelotonia-Colors.h
//  Pelotonia
//
//  Created by Mark Harris on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Pelotonia_Pelotonia_Colors_h
#define Pelotonia_Pelotonia_Colors_h

#import <UIKit/UIKit.h>

#define RGB_COLOR(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define PRIMARY_GREEN RGB_COLOR(154,202,60)
#define PRIMARY_DARK_GRAY RGB_COLOR(84,94,101)
#define SECONDARY_DARK_GREEN RGB_COLOR(0,84,58)
#define SECONDARY_LIGHT_GRAY RGB_COLOR(194,209,212)
#define SECONDARY_GREEN RGB_COLOR(193,216,47)

#define PELOTONIA_FONT(s) [UIFont fontWithName:@"Baksheesh" size:s]


#endif
