//
//  Donor.m
//  Pelotonia
//
//  Created by Mark Harris on 2/14/14.
//
//

#import "Donor.h"

@implementation Donor

@synthesize date = _date;
@synthesize amount = _amount;
@synthesize name = _name;

- (id)initWithName:(NSString *)name amount:(NSString *)amount date:(NSString *)date
{
    if (self = [super init]) {
        self.name = name;
        self.amount = amount;
        self.date = date;
    }
    return self;
}

@end
