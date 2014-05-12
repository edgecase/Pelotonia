//
//  Workout.h
//  Pelotonia
//
//  Created by Mark Harris on 2/15/14.
//
//

#import <Foundation/Foundation.h>

@interface Workout : NSObject <NSCoding>

#define ID_CYCLING_RACE 0
#define ID_CYCLING_TOUR 1
#define ID_INDOOR       2
#define ID_RUNNING      3
#define ID_WALKING      4

@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) NSInteger distanceInMiles;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *typeDescription; // cycling, running, swimming, etc.
@property (nonatomic, strong) NSDate *date; // when did this happen?
@property (nonatomic, assign) NSInteger timeInMinutes; // how long it took

+(NSArray *)workoutTypes;
+(Workout *)defaultWorkout;

@end
