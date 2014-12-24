//
//  Donor.h
//  Pelotonia
//
//  Created by Mark Harris on 2/14/14.
//
//

#import <Foundation/Foundation.h>

@interface Donor : NSObject<NSCoding>

@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *date;

- (id)initWithName:(NSString *)name amount:(NSString *)amount date:(NSString *)date;

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
