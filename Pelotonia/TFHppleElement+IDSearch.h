//
//  TFHppleElement+IDSearch.h
//  InnovationAwards
//
//  Created by Mark Harris on 1/3/13.
//  Copyright (c) 2013 TechColumbus. All rights reserved.
//

#import "TFHppleElement.h"

@interface TFHppleElement (IDSearch)

- (TFHppleElement *)firstChildWithId:(NSString *)idName;
- (TFHppleElement *)firstChildWithClass:(NSString *)className;

@end
