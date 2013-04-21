//
//  RiderDataController.m
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "RiderDataController.h"
#import "PelotoniaWeb.h"

@implementation RiderDataController

- (void)initializeDefaultList {
    NSMutableArray *defaultList = [[NSMutableArray alloc] initWithCapacity:1];
    Rider *firstRider = [[Rider alloc] initWithName:@"Mark Harris" andId:@"4111"];
    [defaultList addObject:firstRider];
    _riderList = defaultList;
}


- (id)init 
{
    if (self = [super init]) {
        [self initializeDefaultList];
        return self;
    }
    return nil;
}


- (NSArray *)allRiders
{
    return _riderList;
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
    if ([object.riderId length] > 0) {
        [_riderList filterUsingPredicate:[NSPredicate predicateWithFormat:@"not riderId like %@", object.riderId]];
    }
    else {
        // it's a peloton, and they don't have riderId's, so we have to use the name
        [_riderList filterUsingPredicate:[NSPredicate predicateWithFormat:@"not name like %@", object.name]];
    }
}

- (BOOL)containsRider:(Rider *)object
{
    NSArray *filtered = nil;
    if ([object.riderId length] > 0) {
        filtered = [_riderList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"riderId like %@", object.riderId]];
    }
    else {
        // it's a peloton, and they don't have riderId's, so we have to use the name
        filtered = [_riderList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name like %@", object.name]];
    }
    return [filtered count] > 0;
}

- (void)addObject:(Rider *)object
{
    [_riderList addObject:object];

}

- (void)insertObject:(Rider *)object atIndex:(NSUInteger)index
{
    [_riderList insertObject:object atIndex:index];
}

- (void)sortRidersUsingDescriptors:(NSArray *)descriptors
{
    [_riderList sortUsingDescriptors:descriptors];
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
