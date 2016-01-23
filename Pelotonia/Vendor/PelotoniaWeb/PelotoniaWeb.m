//
//  PelotoniaWeb.m
//  Pelotonia
//
//  Created by Michael Enriquez on 7/14/12.
//  Copyright (c) 2012 Michael Enriquez. All rights reserved.
//

#import "PelotoniaWeb.h"
#import "TFHpple.h"
#import "Donor.h"
#import "TFHppleElement+IDSearch.h"
#import <AFNetworking/AFNetworking.h>
#import "Event.h"
#import "EventCategory.h"
#import "NewsItem.h"
#import "NSDate+Helper.h"


@interface PelotoniaWeb()
+ (NSString *)stripWhitespace:(NSString *)input;
@end

@implementation PelotoniaWeb

+ (void)searchForRiderWithLastName:(NSString *)lastName
                           riderId:(NSString *)riderId
                        onComplete:(void(^)(NSArray *searchResults))completeBlock
                         onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.mypelotonia.org/riders_searchresults.jsp?SearchType=&LastName=%@&RiderID=%@&RideDistance=&ZipCode=&", lastName, riderId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // success
        NSLog(@"completing network call");
        TFHpple *parser = [TFHpple hppleWithHTMLData:[operation responseData]];
        NSString *xPath = @"//table[@id='search-results']/tr";
        NSArray *riderTableRows = [parser searchWithXPathQuery:xPath];
        
        NSMutableArray *riders = [NSMutableArray array];
        for (TFHppleElement *riderTableRow in riderTableRows) {
            Rider *rider = [[Rider alloc] init];
            for (TFHppleElement *riderAttributeColumn in [riderTableRow children]) {
                NSString *classAttribute = [[riderAttributeColumn attributes] valueForKey:@"class"];
                
                if ([classAttribute isEqualToString:@"rider"]) {
                    rider.name = [self stripWhitespace:[[[[riderAttributeColumn children] objectAtIndex:1] firstChild] content]];
                } else if ([classAttribute isEqualToString:@"id"]) {
                    rider.riderId = [[riderAttributeColumn firstChild] content];
                } else if ([classAttribute isEqualToString:@"photo"]) {
                    TFHppleElement *elem = [[riderAttributeColumn children] objectAtIndex:1];
                    NSString *relativeUrl = [[[[elem children] objectAtIndex:1] attributes] valueForKey:@"src"];
                    rider.riderPhotoThumbUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
                } else if ([classAttribute isEqualToString:@"donate"]) {
                    NSString *relativeUrl = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"href"];
                    rider.donateUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
                } else if ([classAttribute isEqualToString:@"profile"]) {
                    NSString *relativeUrl = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"href"];
                    rider.profileUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", relativeUrl];
                } else if ([classAttribute isEqualToString:@"type"]) {
                    rider.riderType = [[[[riderAttributeColumn children] objectAtIndex:1] attributes] valueForKey:@"alt"];
                } else if ([classAttribute isEqualToString:@"route"]) {
                    rider.route = [self stripWhitespace:[[riderAttributeColumn firstChild] content]];
                } else if ([classAttribute isEqualToString:@"high-roller"]) {
                    // if the high-roller class is non-empty, we have a high roller
                    NSLog(@"content: %lu", (unsigned long)[[riderAttributeColumn children] count]);
                    if ([[riderAttributeColumn children] count] > 1) {
                        rider.highRoller = YES;
                    }
                    else {
                        rider.highRoller = NO;
                    }
                }
            }
            
            if (rider.name) {
                NSLog(@"Adding rider %@", rider.name);
                [riders addObject:rider];
            }
        }
        
        NSLog(@"calling completeblock");
        if (completeBlock) {
            completeBlock(riders);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"unable to get search URL");
    }];
    
}


+ (void)profileForRider:(Rider *)rider
             onComplete:(void(^)(Rider *rider))completeBlock
              onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSLog(@"looking for rider profile %@, %@", rider.name, rider.profileUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    [manager GET:rider.profileUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Found rider %@", rider.name);
        @try
        {
            TFHpple *parser = [TFHpple hppleWithHTMLData:(NSData *)responseObject];
            
            // figure out what type of rider we are first
            NSString *riderTypeUrlXPath = @"//*[@id='sectionheader']/img";
            NSString *riderType = [[[[parser searchWithXPathQuery:riderTypeUrlXPath] objectAtIndex:0] attributes] valueForKey:@"alt"];
            
            NSRange superPelotonRange = [riderType rangeOfString:@"Profile > Super Peloton" options:NSCaseInsensitiveSearch];
            NSRange pelotonRange = [riderType rangeOfString:@"Profile > Peloton" options:NSCaseInsensitiveSearch];
            NSRange riderRange = [riderType rangeOfString:@"Profile > Rider" options:NSCaseInsensitiveSearch];
            NSRange virtualRiderRange = [riderType rangeOfString:@"Profile > Virtual" options:NSCaseInsensitiveSearch];
            NSRange volunteerRiderRange = [riderType rangeOfString:@"Profile > Volunteer" options:NSCaseInsensitiveSearch];
            
            if (superPelotonRange.location != NSNotFound) {
                rider.riderType = @"Super Peloton";
            } else if (pelotonRange.location != NSNotFound) {
                rider.riderType = @"Peloton";
            } else if (riderRange.location != NSNotFound) {
                rider.riderType = @"Rider";
            } else if (virtualRiderRange.location != NSNotFound) {
                rider.riderType = @"Virtual Rider";
            } else if (volunteerRiderRange.location != NSNotFound) {
                rider.riderType = @"Volunteer";
            } else {
                NSLog(@"rider type not recognized");
                rider.riderType = nil;
            }
            
            // get the photos' URLs
            NSString *riderPhotoUrlXPath = @"//div[@id='touts']/div[1]/img";
            NSString *altRiderPhotoUrlXPath = @"//div[@id='touts']/div[1]/a/img";
            NSArray *photoNodes = [parser searchWithXPathQuery:riderPhotoUrlXPath];
            if ([photoNodes count] == 0) {
                photoNodes = [parser searchWithXPathQuery:altRiderPhotoUrlXPath];
            }
            NSString *riderPhotoRelativeUrl = [[[photoNodes objectAtIndex:0] attributes] valueForKey:@"src"];
            NSString *riderPhotoAbsoluteUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", riderPhotoRelativeUrl];
            rider.riderPhotoUrl = riderPhotoAbsoluteUrl;
            
            // get the riders' story
            // this query gets all text from all descendant nodes of the div of class 'story'
            // the query is formatted like this to catch text that's embedded in embedded HTML
            NSArray *div = [parser searchWithXPathQuery:@"//div[@class='story']/descendant-or-self::*/text()"];
            
            NSString *storyString = @"";
            for (TFHppleElement *story in div)
            {
                if (story.content) {
                    storyString = [storyString stringByAppendingString:story.content];
                }
            }
            rider.story = storyString;
            
            // get the rider's properties like how much they've raised, etc.
            NSDictionary *xpathTable = @{
                                         @"raised": @"//*[@id='dashboard-rider']/div/div[2]/dl[2]/dd",
                                         @"myPeloton": @"//*[@id='dashboard-rider']/div/div[2]/dl[3]/dd/a",
                                         @"route": @"//*[@id='dashboard-rider']/div/div[2]/dl[1]/dd",
                                         @"pelotonFundsRaised": @"//*[@id='dashboard-peloton']/div/div[2]/dl[1]/dd",
                                         @"pelotonTotalOfAllMembers": @"//*[@id='dashboard-peloton']/div/div[2]/dl[2]/dd",
                                         @"pelotonGrandTotal": @"//*[@id='dashboard-peloton']/div/div[2]/dl[3]/dd",
                                         @"pelotonCaptain": @"//*[@id='dashboard-peloton']/div/div[2]/dl[4]/dd/a",
                                         @"virtualRiderRaised": @"//*[@id='dashboard-virtual-rider']/div/div[2]/dl[1]/dd",
                                         @"volunteerRaised": @"//*[@id='dashboard-volunteer']/div/div[2]/dl[1]/dd"
                                         };
            
            // rider
            rider.amountRaised = [self getValueAtXPath:[xpathTable objectForKey:@"raised"] parser:parser];
            if ([rider.amountRaised length] == 0 ) {
                // virtual rider
                rider.amountRaised = [self getValueAtXPath:[xpathTable objectForKey:@"virtualRiderRaised"] parser:parser];
                if ([rider.amountRaised length] == 0) {
                    // volunteer
                    rider.amountRaised = [self getValueAtXPath:[xpathTable objectForKey:@"volunteerRaised"] parser:parser];
                }
            }
            rider.myPeloton = [self getValueAtXPath:[xpathTable objectForKey:@"myPeloton"] parser:parser];
            rider.route = [self getValueAtXPath:[xpathTable objectForKey:@"route"] parser:parser];
            rider.pelotonFundsRaised = [self getValueAtXPath:[xpathTable objectForKey:@"pelotonFundsRaised"] parser:parser];
            rider.pelotonTotalOfAllMembers = [self getValueAtXPath:[xpathTable objectForKey:@"pelotonTotalOfAllMembers"] parser:parser];
            rider.pelotonGrandTotal = [self getValueAtXPath:[xpathTable objectForKey:@"pelotonGrandTotal"] parser:parser];
            rider.pelotonCaptain = [self stripWhitespace:[self getValueAtXPath:[xpathTable objectForKey:@"pelotonCaptain"] parser:parser]];
            
            // get the list of donors
            NSArray *donors = [parser searchWithXPathQuery:@"//*[@class='donor-list']/tr"];
            if (donors) {
                NSMutableArray *donorArray = [[NSMutableArray alloc] initWithCapacity:0];
                // loop through the donors (represented as a TR each) & add objects with name/etc.
                for (TFHppleElement *e in donors) {
                    NSArray *data = [e childrenWithTagName:@"td"];
                    if ([data count] > 0) {
                        Donor *donor = [[Donor alloc] init];
                        for (TFHppleElement *tf in data) {
                            if ([[tf objectForKey:@"class"] isEqualToString:@"amount"]) {
                                donor.amount = tf.text;
                            }
                            if ([[tf objectForKey:@"class"] isEqualToString:@"name"]) {
                                donor.name = tf.text;
                            }
                            if ([[tf objectForKey:@"class"] isEqualToString:@"date"]) {
                                donor.date = tf.text;
                            }
                        }
                        [donorArray addObject:donor];
                    }
                }
                rider.donors = donorArray;
            }
            
            
            NSLog(@"Returning profile for rider %@", rider.name);
            
        }
        @catch (NSException *exception) {
            NSLog(@"trouble parsing %@'s profile story", rider.name);
            rider.story = @"(no story on file)";
            NSLog(@"%@", [exception description]);
        }
        
        if (completeBlock) {
            completeBlock(rider);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error description]);
        NSLog(@"Response : %@", [operation responseString]);
        NSLog(@"Debug Response : %@", [operation debugDescription]);
        if (failureBlock) {
            failureBlock([error description]);
        }
    }];
}

+ (NSString *)stripWhitespace:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)getValueAtXPath:(NSString *)xpath parser:(TFHpple *)parser
{
    NSArray *results = [parser searchWithXPathQuery:xpath];
    NSString *value = @"";
    if (results && [results count] > 0) {
        value = [[[results objectAtIndex:0] firstChild] content];
    }
    return value;
}

+ (void)getPelotoniaStatsOnComplete:(void (^)(NSString *, NSString *))completeBlock
                          onFailure:(void (^)(NSString *))failureBlock
{
    NSLog(@"looking for pelotonia stats on www.pelotonia.org");
    
    // Parse pelotonia.org's home page for the financial information
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://www.mypelotonia.org/counter_homepage.jsp" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // parse the page for the amount of money being raised
        TFHpple *parser = [TFHpple hppleWithHTMLData:[operation responseData]];
        NSString *raisedAmount = @"Coming Soon";
        NSString *riders = @"Coming Soon";
        
        // figure out what type of rider we are first
        NSString *raisedAmountXPath = @"//*[@id='amount-to-date']/text()";
        
        NSArray *nodes = [parser searchWithXPathQuery:raisedAmountXPath];
        if ([nodes count] > 0) {
            TFHppleElement *raisedAmountNode = [nodes objectAtIndex:0];
            raisedAmount = [raisedAmountNode content];
        }

        NSString *ridersXPath = @"//*[@id='riders']/text()";
        
        nodes = [parser searchWithXPathQuery:ridersXPath];
        if ([nodes count] > 0) {
            TFHppleElement *ridersNode = [nodes objectAtIndex:0];
            riders = [ridersNode content];
        }

        completeBlock(raisedAmount, riders);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Couldn't find the information on pelotonia");
        // must be offline for a bit
        failureBlock([error localizedDescription]);
    }];
}

+ (NSString *)getEventImageFromRow:(TFHppleElement *)tr
{
    /*
     <td class='event-image'>
     <img src=''>
     </td>
     */
    TFHppleElement *td = [[tr childrenWithClassName:@"event-image"] objectAtIndex:0];
    TFHppleElement *imgNode = [[td childrenWithTagName:@"img"] objectAtIndex:0];
    NSString *imgSrc = [[imgNode attributes] objectForKey:@"src"];
    return imgSrc;
}

+ (NSString *)getEventAddressFromRow:(TFHppleElement *)tr
{
    /*
     <td class='events-namevenue'>
     <div class='event-name'>
     <a href='http to details'>event name</a>
     </div>
     "name and address of venue"
     </td>
     */
    TFHppleElement *td = [[tr childrenWithClassName:@"events-namevenue"] objectAtIndex:0];
    NSString *text = (td.text ? td.text : @"See Description for Address");
    return text;
}

+ (NSString *)getEventNameFromRow:(TFHppleElement *)tr
{
    /*
     <td class='events-namevenue'>
     <div class='event-name'>
     <a href='http to details'>event name</a>
     </div>
     "name and address of venue"
     </td>
     */
    TFHppleElement *anchor = [[[[tr childrenWithClassName:@"events-namevenue"] objectAtIndex:0] firstChild] firstChild];
    return anchor.text;
}

+ (NSString *)getDetailsLinkFromRow:(TFHppleElement *)tr
{
    /*
     <td class='events-namevenue'>
     <div class='event-name'>
     <a href='http to details'>event name</a>
     </div>
     "name and address of venue"
     </td>
     */
    TFHppleElement *anchor = [[[[tr childrenWithClassName:@"events-namevenue"] objectAtIndex:0] firstChild] firstChild];
    return [NSString stringWithFormat:@"http://www.pelotonia.org%@", [[anchor attributes] objectForKey:@"href"]];
}

+ (NSDate *)getStartTimeFromRow:(TFHppleElement *)tr
{
    // td class='events-datetime', in format:
    /*
     <td class='events-datetime'>
     <strong>Mon dd, yyyy- Mon dd, yyyy</strong>
     <br>
     "hh:mm p to hh:mm p"
     </td>
     */
    TFHppleElement *tdEventsDateTime = [[tr childrenWithClassName:@"events-datetime"] objectAtIndex:0];
    NSString *datetime = [[tdEventsDateTime firstChild] text];
    NSArray *dates = [datetime componentsSeparatedByString:@"- "];
    NSString *startDate = [dates objectAtIndex:0];
    
    NSString *time = [[[tdEventsDateTime children] objectAtIndex:3] content];
    NSArray *times = [time componentsSeparatedByString:@" to "];
    NSString *startTime = [times objectAtIndex:0];
    
    NSString *eventStartDateTime = [NSString stringWithFormat:@"%@ %@", startDate, startTime];
    NSDate *eventStart = [NSDate dateFromString:eventStartDateTime withFormat:@"MMM d, yyyy h:mm a"];
    
    return eventStart;
}

+ (NSDate *)getEndTimeFromRow:(TFHppleElement *)tr
{
    // td class='events-datetime', in format:
    /*
     <td class='events-datetime'>
     <strong>Mon dd, yyyy- Mon dd, yyyy</strong>
     <br>
     "hh:mm p to hh:mm p"
     </td>
     */
    TFHppleElement *tdEventsDateTime = [[tr childrenWithClassName:@"events-datetime"] objectAtIndex:0];
    NSString *datetime = [[tdEventsDateTime firstChild] text];
    NSArray *dates = [datetime componentsSeparatedByString:@"- "];
    NSString *endDate = [dates objectAtIndex:1];
    
    NSString *time = [[[tdEventsDateTime children] objectAtIndex:3] content];
    NSArray *times = [time componentsSeparatedByString:@" to "];
    NSString *endTime = [times objectAtIndex:1];
    
    
    NSString *eventEndDateTime = [NSString stringWithFormat:@"%@ %@", endDate, endTime];
    NSDate *eventEnd = [NSDate dateFromString:eventEndDateTime withFormat:@"MMM d, yyyy h:mm a"];
    
    return eventEnd;
}


+ (void)getEventDescription:(Event *)event
                 onComplete:(void (^)(Event *e))completeBlock
                  onFailure:(void (^)(NSString *))failureBlock
{
    // given an event, fill it out with details & call back
    if (event.detailsLink) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:event.detailsLink parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:(NSData *)responseObject];
            NSString *eventDescriptionpath =  @"//*[@id='article']/div/p/text()";

            // parse out the paragraphs
            NSArray *nodes = [parser searchWithXPathQuery:eventDescriptionpath];
            NSString *description = @"";
            for (int i = 0; ([nodes count] > 0) && (i < [nodes count]-1); i++) {
                TFHppleElement *paragraph = [nodes objectAtIndex:i];
                description = [description stringByAppendingString:[[paragraph content] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
                description = [description stringByAppendingString:@"\n\n"];
            }
            event.eventDesc = description;
            // save the database
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"You successfully saved your context.");
                    if (completeBlock) {
                        completeBlock(event);
                    }
                } else if (error) {
                    NSLog(@"Error saving context: %@", error.description);
                    if (failureBlock) {
                        failureBlock([error localizedDescription]);
                    }
                }
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error parsing event description %@", [error localizedDescription]);
            if (failureBlock) {
                failureBlock([error localizedDescription]);
            }
        }];
    }

}

+ (void)parseEventRow:(TFHppleElement *)row forCategory:(EventCategory *)category
{
    NSString *title = [self getEventNameFromRow:row];
    Event *event = [Event MR_findFirstByAttribute:@"title" withValue:title];
    
    if (event == nil) {
        // not already in database, so create it
        event = [Event MR_createEntity];

        // category
        [category addEventsObject:event];
        event.category = category;
    }

    // td.events-namevenue div.event-name is the anchor to the event name
    event.title = title;

    // td[0] is the image
    event.imageLink = [self getEventImageFromRow:row];
    
    // td class='events-namevenue' has the name & address
    event.address = [self getEventAddressFromRow:row];

    // link to details
    event.detailsLink = [self getDetailsLinkFromRow:row];
    
    // start date & time
    event.startDateTime = [self getStartTimeFromRow:row];
    event.endDateTime = [self getEndTimeFromRow:row];

}

+ (void)getPelotoniaEventsOnComplete:(void (^)(void))completeBlock onFailure:(void (^)(NSString *))failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://pelotonia.org/events/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *parser = [TFHpple hppleWithHTMLData:(NSData *)responseObject];
        NSString *pelotoniaEventsPath =  @"//*[@id='article']/div/table/tr";
        
        // first parse out the pelotonia events
        NSArray *nodes = [parser searchWithXPathQuery:pelotoniaEventsPath];
        EventCategory *category = [EventCategory MR_findFirstByAttribute:@"name" withValue:@"Pelotonia"];
        if (category == nil) {
            category = [EventCategory MR_createEntity];
            category.name = @"Pelotonia";
        }
        for (TFHppleElement *node in nodes) {
            
            // each TR is an event.  There are 3 columns in each row, for events
            NSArray *columns = [node childrenWithTagName:@"td"];
            
            if ([columns count] == 3) {
                [self parseEventRow:node forCategory:category];
            }
        }
        
        // now get the rider events
        NSString *riderEventsPath = @"//*[@id='events-rider-events']/table/tr";
        NSArray *riderEvents = [parser searchWithXPathQuery:riderEventsPath];
        category = [EventCategory MR_findFirstByAttribute:@"name" withValue:@"Rider Events"];
        if (category == nil) {
            category = [EventCategory MR_createEntity];
            category.name = @"Rider Events";
        }
        for (TFHppleElement *node in riderEvents) {
            
            // each TR is an event.  There are 3 columns in each row, for events
            NSArray *columns = [node childrenWithTagName:@"td"];
            
            if ([columns count] == 3) {
                [self parseEventRow:node forCategory:category];
            }
        }

        // now get the training rides
        NSString *trainingRidesPath = @"//*[@id='events-training-rides']/table/tr";
        NSArray *trainingRides = [parser searchWithXPathQuery:trainingRidesPath];
        category = [EventCategory MR_findFirstByAttribute:@"name" withValue:@"Training Rides"];
        if (category == nil) {
            category = [EventCategory MR_createEntity];
            category.name = @"Training Rides";
        }
        for (TFHppleElement *node in trainingRides) {
            
            // each TR is an event.  There are 3 columns in each row, for events
            NSArray *columns = [node childrenWithTagName:@"td"];
            
            if ([columns count] == 3) {
                [self parseEventRow:node forCategory:category];
            }
        }
        
        // save the database
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Error saving context: %@", error.description);
                if (failureBlock) {
                    failureBlock([error localizedDescription]);
                }
            } else {
                // success
                NSLog(@"You successfully saved your context.");
                if (completeBlock) {
                    completeBlock();
                }
            }
        }];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"couldn't find events");
        if (failureBlock) {
            failureBlock([error localizedDescription]);
        }
    }];
}

+ (void)parseNewsDiv:(TFHppleElement *)newsItemNode {
    // title is in the H3
    TFHppleElement *titleNode = [[newsItemNode firstChildWithTagName:@"h3"] firstChildWithTagName:@"a"];
    NSString *title = [[[newsItemNode firstChildWithTagName:@"h3"] firstChildWithTagName:@"a"] text];
    NewsItem *newsItem = [NewsItem MR_findFirstByAttribute:@"title" withValue:title];
    
    if (newsItem == nil) {
        // not in database, so delete it & replace
//        [newsItem deleteEntity];
        newsItem = [NewsItem MR_createEntity];
    }
    newsItem.title = title;
    
    // detail link is also in the H3
    NSString *link = [[titleNode attributes] valueForKey:@"href"];
    newsItem.detailLink = link;
    
    // date is in div[@id='news-entity-meta'] in format "MMMM dd, yyyy"
    NSString *dateTimeString = [[newsItemNode firstChildWithClass:@"news-entry-meta"] text];
    NSDate *dateTime = [NSDate dateFromString:dateTimeString withFormat:@"MMM dd, yyyy"];
    newsItem.dateTime = dateTime;
    
    // leader is in the <P> tag
    TFHppleElement *pNode = [newsItemNode firstChildWithTagName:@"p"];
    NSString *leader = [[NSString alloc] initWithData:[pNode.text dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES]  encoding:NSUTF8StringEncoding];

    newsItem.leader = leader;
    
    
}


+ (void)getPelotoniaNewsOnComplete:(void(^)(void))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    [manager GET:@"http://www.pelotonia.org/news" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *parser = [TFHpple hppleWithHTMLData:(NSData *)responseObject];
        NSString *pelotoniaNewsPath =  @"//*[@id='news-posts']/div";
        // first parse out the pelotonia events
        NSArray *nodes = [parser searchWithXPathQuery:pelotoniaNewsPath];
        for (TFHppleElement *node in nodes) {
            
            // each DIV is a news element.
            [self parseNewsDiv:node];
        }

        // save the database
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"You successfully saved your context.");
                if (completeBlock) {
                    completeBlock();
                }
            } else if (error) {
                NSLog(@"Error saving context: %@", error.description);
                if (failureBlock) {
                    failureBlock([error localizedDescription]);
                }
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get news: %@", [error localizedDescription]);
        if (failureBlock) {
            failureBlock([error localizedDescription]);
        }
    }];

}

+ (void)getPelotoniaNewsDetailOnComplete:(NewsItem *)item
                              onComplete:(void (^)(NewsItem *i))completeBlock
                               onFailure:(void (^)(NSString *))failureBlock
{
    // get detail from page
    //  //*[@id="article"]/div/p[1]
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    [manager GET:item.detailLink parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *parser = [TFHpple hppleWithHTMLData:(NSData *)responseObject];
        NSString *detailPath = @"//*[@id='article']/div/p";
        NSArray *nodes = [parser searchWithXPathQuery:detailPath];
        NSString *detailString = [NSString stringWithFormat:@""];
        for (TFHppleElement *paragraph in nodes) {
            // ### marks the beginning of the boilerplate text
            if ([paragraph.text isEqualToString:@"###"]) {
                break;
            }
            
            // pull out the text content of each P element
            NSString *elemText = [[NSString alloc] initWithFormat:@""];
            for (TFHppleElement *elem in paragraph.children) {
                
                // text content of a P node is stored in "content"
                NSString *text = elem.content;
                
                // get text representation of Anchor tags
                if ([elem.tagName isEqualToString:@"a"]) {
                    text = elem.text;
                }
                if (text) {
                    elemText = [elemText stringByAppendingString:text];
                }
            }
            
            // have to do this weirdness b/c of smart quotes and special dashes in the Pelotonia CMS db
            elemText = [elemText stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
            elemText = [elemText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // sometimes we have null nodes
            if (elemText && ([elemText length] > 0)) {
                detailString = [detailString stringByAppendingString:[NSString stringWithFormat:@"%@\n\n", elemText]];
            }
        }
        item.detail = detailString;
        // save the database
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"You successfully saved your context.");
                if (completeBlock) {
                    completeBlock(item);
                }
            } else if (error) {
                NSLog(@"Error saving context: %@", error.description);
                if (failureBlock) {
                    failureBlock([error localizedDescription]);
                }
            }
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"unable to get detail for event: %@", [error localizedDescription]);
        item.detail = @"Unable to retrieve detail for this item";
    }];

}


@end
