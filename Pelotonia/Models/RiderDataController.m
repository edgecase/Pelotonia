//
//  RiderDataController.m
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "RiderDataController.h"
#import "PelotoniaWeb.h"
#import "Workout.h"
#import "AppDelegate.h"

@implementation RiderDataController

@synthesize favoriteRider = _favoriteRider;
@synthesize workouts = _workouts;
@synthesize photoKeys = _photoKeys;

- (void)initializeDefaultList {
    NSMutableArray *defaultList = [[NSMutableArray alloc] initWithCapacity:1];
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

- (PHPhotoLibrary *)sharedAssetsLibrary
{
    self.library = [PHPhotoLibrary sharedPhotoLibrary];
    return self.library;
}

- (NSMutableArray *)photoKeys {
    // have to do this to make sure that the stashed keys in our
    // file still are valid on this particular device
    NSMutableArray *tempKeys = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (_photoKeys != nil) {
        // trim out the photo keys that have gone missing since last open
        for (int i = 0; i < [_photoKeys count]; i++) {
//            NSString *key = [[_photoKeys objectAtIndex:i] objectForKey:@"key"];
//            BOOL assetExists = [AssetURLChecker assetExists:[NSURL URLWithString:key]];
//            if (assetExists) {
                [tempKeys addObject:[_photoKeys objectAtIndex:i]];
//            }
        }
    }

    _photoKeys = tempKeys;
    return _photoKeys;
}

- (NSMutableArray *)workouts {
    if (_workouts == nil) {
        _workouts = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [_workouts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Workout *w1 = (Workout *)obj1;
        Workout *w2 = (Workout *)obj2;
        return [w2.date compare:w1.date];
    }];
    return _workouts;
}

- (NSInteger)count
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

- (void)save
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    [app archiveData];
}

// Archive methods
#pragma mark -- Archive methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_riderList forKey:@"rider_list"];
    [aCoder encodeObject:_favoriteRider forKey:@"favorite_rider"];
    [aCoder encodeObject:_workouts forKey:@"workouts"];
    [aCoder encodeObject:_photoKeys forKey:@"photos"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // for each archived instance variable, we decode it
    // and pass it to the setters.
    if (self = [super init]) {
        _riderList = [aDecoder decodeObjectForKey:@"rider_list"];
        _favoriteRider = [aDecoder decodeObjectForKey:@"favorite_rider"];
        _workouts = [aDecoder decodeObjectForKey:@"workouts"];
        _photoKeys = [aDecoder decodeObjectForKey:@"photos"];
    }
    
    return self;
}


@end
