//
//  Workout.m
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import "Workout.h"
#import "NSDate+Helper.h"

@implementation Workout

@synthesize distanceInMiles = _distanceInMiles;
@synthesize description = _description;
@synthesize type = _type;
@synthesize date = _date;
@synthesize timeInMinutes = _timeInMinutes;


+(NSArray *)workoutTypes {
    return @[@"cycling", @"indoor training", @"running"];
}

+(Workout *)defaultWorkout
{
    Workout *w = [[Workout alloc] init];
    w.description = @"";
    w.type = ID_CYCLING;
    w.distanceInMiles = 0;
    w.date = [NSDate date];
    return w;
}

- (NSString *)typeDescription {
    return [[Workout workoutTypes] objectAtIndex:self.type];
}

#pragma mark -- NSCoding

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_description forKey:@"description"];
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeInteger:_distanceInMiles forKey:@"distance"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _description = [aDecoder decodeObjectForKey:@"description"];
        _date = [aDecoder decodeObjectForKey:@"date"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _distanceInMiles = [aDecoder decodeIntegerForKey:@"distance"];
    }
    return self;
}

@end
