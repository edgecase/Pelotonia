//
//  RiderDataController.h
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rider.h"

@interface RiderDataController : NSObject <NSCoding> {
    NSMutableArray *_riderList;
}

- (unsigned)count;
- (Rider *)objectAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(Rider *)object;
- (void)insertObject:(Rider *)object atIndex:(NSUInteger)index;

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;


@end
