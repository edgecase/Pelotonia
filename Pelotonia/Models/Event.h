//
//  Event.h
//  Pelotonia
//
//  Created by Mark Harris on 6/22/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventCategory;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * startDateTime;
@property (nonatomic, retain) NSDate * endDateTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * detailsLink;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSString * eventDesc;
@property (nonatomic, retain) EventCategory *category;

@end
