//
//  RiderDataController.h
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rider.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;


@interface RiderDataController : NSObject <NSCoding> {
    NSMutableArray *_riderList;
}

@property (strong, nonatomic) Rider *favoriteRider;
@property (strong, nonatomic) NSMutableArray *workouts;
@property (strong, nonatomic) NSMutableArray *photoKeys;
@property (strong, nonatomic) PHPhotoLibrary *library;

- (NSInteger)count;
- (Rider *)objectAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(Rider *)object;
- (void)insertObject:(Rider *)object atIndex:(NSUInteger)index;
- (void)removeObject:(Rider *)object;
- (BOOL)containsRider:(Rider *)object;
- (void)sortRidersUsingDescriptors:(NSArray *)descriptors;
- (NSArray *)allRiders;
- (PHPhotoLibrary *)sharedAssetsLibrary;
- (void)save;

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;


@end
