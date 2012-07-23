//
//  RiderDataController.m
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RiderDataController.h"

@implementation RiderDataController

- (void)initializeDefaultGameList {
    NSMutableArray *defaultList = [[NSMutableArray alloc] initWithCapacity:1];
    _riderList = defaultList;
}


- (id)init 
{
    if (self = [super init]) {
        [self initializeDefaultGameList];
        return self;
    }
    return nil;
}


- (unsigned)count
{
    return [_riderList count];
}

- (Rider *)objectAtIndex:(NSUInteger)index
{
    return [_riderList objectAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_riderList removeObjectAtIndex:index];
}

- (void)removeObject:(Rider *)object
{
    for (NSInteger i = 0; i < [_riderList count]; i++) {
        Rider *r = [_riderList objectAtIndex:i];
        if ([r.riderId isEqualToString:object.riderId]) {
            [_riderList removeObjectAtIndex:i];
        }
    }
}

- (void)addObject:(Rider *)object
{
    [_riderList addObject:object];
}

- (void)insertObject:(Rider *)object atIndex:(NSUInteger)index
{
    [_riderList insertObject:object atIndex:index];
}

// Archive methods
#pragma mark -- Archive methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_riderList forKey:@"rider_list"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // for each archived instance variable, we decode it
    // and pass it to the setters.
    if (self = [super init]) {
        _riderList = [aDecoder decodeObjectForKey:@"rider_list"];
    }
    
    return self;
}


@end
