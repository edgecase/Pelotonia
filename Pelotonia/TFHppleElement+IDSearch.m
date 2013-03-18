//
//  TFHppleElement+IDSearch.m
//  InnovationAwards
//
//  Created by Mark Harris on 1/3/13.
//  Copyright (c) 2013 TechColumbus. All rights reserved.
//

#import "TFHppleElement+IDSearch.h"

@implementation TFHppleElement (IDSearch)

- (TFHppleElement *)firstChildWithId:(NSString *)idName;
{
    for (TFHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"id"] isEqualToString:idName])
            return child;
    }
    
    return nil;
}

- (TFHppleElement *)firstChildWithClass:(NSString *)className
{
    for (TFHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"class"] isEqualToString:className])
            return child;
    }
    
    return nil;
}

@end
