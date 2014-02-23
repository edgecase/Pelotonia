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

#pragma mark -- NSCoding

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeObject:_amount forKey:@"amount"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:@"date"];
        _amount = [aDecoder decodeObjectForKey:@"amount"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
