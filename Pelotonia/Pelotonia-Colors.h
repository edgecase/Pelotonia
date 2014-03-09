//
//  Pelotonia-Colors.h
//  Pelotonia
//
//  Created by Mark Harris on 7/15/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#ifndef Pelotonia_Pelotonia_Colors_h
#define Pelotonia_Pelotonia_Colors_h

#import <UIKit/UIKit.h>

#define RGB_COLOR(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define PRIMARY_GREEN RGB_COLOR(57,213,45)
#define PRIMARY_DARK_GRAY RGB_COLOR(84,94,101)
#define SECONDARY_DARK_GREEN RGB_COLOR(0,84,58)
#define SECONDARY_LIGHT_GRAY RGB_COLOR(194,209,212)
#define SECONDARY_GREEN PRIMARY_GREEN
#define PRIMARY_GREEN_ALPHA(a) [UIColor colorWithRed:57/255.0 green:213/255.0 blue:45/255.0 alpha:a]

#define PELOTONIA_FONT(s) [UIFont fontWithName:@"Baksheesh-Regular" size:s]
#define PELOTONIA_SECONDARY_FONT(s) [UIFont fontWithName:@"PFDinTextPro-Regular" size:s]
#define PELOTONIA_FONT_NAME [UIFont fontWithFamilyName:@"Baksheesh-Regular"]

#endif
