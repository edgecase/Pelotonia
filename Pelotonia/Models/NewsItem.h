//
//  NewsItem.h
//  Pelotonia
//
//  Created by Mark Harris on 6/29/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * dateTime;
@property (nonatomic, retain) NSString * leader;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSString * detailLink;

@end
