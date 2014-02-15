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

@interface PelotoniaWeb()
+ (NSString *)stripWhitespace:(NSString *)input;
@end

@implementation PelotoniaWeb

+ (void)searchForRiderWithLastName:(NSString *)lastName riderId:(NSString *)riderId onComplete:(void(^)(NSArray *searchResults))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.mypelotonia.org/riders_searchresults.jsp?SearchType=&LastName=%@&RiderID=%@&RideDistance=&ZipCode=&", lastName, riderId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                    NSString *relativeUrl = [[[[[[riderAttributeColumn children] objectAtIndex:1] children] objectAtIndex:1] attributes] valueForKey:@"src"];
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
                    NSLog(@"content: %d", [[riderAttributeColumn children] count]);
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


+ (void)profileForRider:(Rider *)rider onComplete:(void(^)(Rider *rider))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    //NSURL *url = [NSURL URLWithString:rider.profileUrl];
    NSLog(@"looking for rider profile %@, %@", rider.name, rider.profileUrl);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:rider.profileUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Found rider %@", rider.name);
        @try
        {
            TFHpple *parser = [TFHpple hppleWithHTMLData:[operation responseData]];
            
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
            NSString *riderPhotoRelativeUrl = [[[[parser searchWithXPathQuery:riderPhotoUrlXPath] objectAtIndex:0] attributes] valueForKey:@"src"];
            NSString *riderPhotoAbsoluteUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", riderPhotoRelativeUrl];
            rider.riderPhotoUrl = riderPhotoAbsoluteUrl;
            
            // get the riders' story
            // this query gets all text from all descendant nodes of the div of class 'story'
            // the query is formatted like this to catch text that's embedded in embedded HTML
            NSArray *div = [parser searchWithXPathQuery:@"//div[@class='story']/descendant-or-self::*/text()"];
            NSString *storyString = @"";
            for (TFHppleElement *story in div)
            {
                NSLog(@"Story = %@", story.content);
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
                                         @"pelotonCaptain": @"//*[@id='dashboard-peloton']/div/div[2]/dl[4]/dd/a"
                                         };
            
            rider.amountRaised = [self getValueAtXPath:[xpathTable objectForKey:@"raised"] parser:parser];
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
                                NSLog(@"Found donor amount %@", tf.text);
                                donor.amount = tf.text;
                            }
                            if ([[tf objectForKey:@"class"] isEqualToString:@"name"]) {
                                NSLog(@"Found donor amount %@", tf.text);
                                donor.name = tf.text;
                            }
                            if ([[tf objectForKey:@"class"] isEqualToString:@"date"]) {
                                NSLog(@"Found donor amount %@", tf.text);
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


@end
