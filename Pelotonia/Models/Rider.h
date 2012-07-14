//
//  Rider.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rider : NSObject <NSCoding> {
    NSString *_name;
    NSString *_riderId;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *riderId;

// NSObject & initialization
- (id)initWithName:(NSString *)name andId:(NSString *)riderId;

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end


