//
//  PelotoniaWeb.m
//  Pelotonia
//
//  Created by Michael Enriquez on 7/14/12.
//  Copyright (c) 2012 Michael Enriquez. All rights reserved.
//

#import "PelotoniaWeb.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"

@interface PelotoniaWeb()
+ (NSString *)stripWhitespace:(NSString *)input;
@end

@implementation PelotoniaWeb

+ (void)searchForRiderWithLastName:(NSString *)lastName riderId:(NSString *)riderId onComplete:(void(^)(NSArray *searchResults))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.mypelotonia.org/riders_searchresults.jsp?SearchType=&LastName=%@&RiderID=%@&RideDistance=&ZipCode=&", lastName, riderId]];
    __unsafe_unretained __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    NSLog(@"searchForRiderWithLastName: finding %@ (%@)", lastName, riderId);
    
    [request setCompletionBlock:^{
        NSLog(@"completing network call");
        TFHpple *parser = [TFHpple hppleWithHTMLData:[request responseData]];
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
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@: %@", error.localizedDescription, error.localizedFailureReason);
        
        if (failureBlock) {
            NSString *errstr = [NSString stringWithFormat:@"Network error: %@", error.localizedDescription];
            failureBlock(errstr);
        }
    }];
    
    
    [request startAsynchronous];  
}

+ (void)profileForRider:(Rider *)rider onComplete:(void(^)(Rider *rider))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSURL *url = [NSURL URLWithString:rider.profileUrl];
    NSLog(@"looking for rider profile %@, %@", rider.name, rider.profileUrl);
    __unsafe_unretained __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSLog(@"Found rider %@", rider.name);
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:[request responseData]];
        NSString *riderPhotoUrlXPath = @"//div[@id='touts']/div[1]/img";
        NSString *riderPhotoRelativeUrl = [[[[parser searchWithXPathQuery:riderPhotoUrlXPath] objectAtIndex:0] attributes] valueForKey:@"src"];
        NSString *riderPhotoAbsoluteUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", riderPhotoRelativeUrl];
        
        // get the rider's story
        @try {
            NSString *riderStoryXPath = @"//*[@id='article']/div[3]/div[1]/text()";
            NSArray *storyRows = [parser searchWithXPathQuery:riderStoryXPath];
            NSLog(@"story size %d", [storyRows count]);
            rider.story = @"";
            for (TFHppleElement *element in storyRows) {
                NSLog(@"content = %@", [element content]);
                rider.story = [rider.story stringByAppendingString:[element content]];
            }
            NSLog(@"story (pw) = %@", rider.story);
        }
        @catch (NSException *exception) {
            NSLog(@"trouble parsing %@'s profile story", rider.name);
            rider.story = @"No Story on File";
        }        
        
        rider.riderPhotoUrl = riderPhotoAbsoluteUrl;
        
        NSString *metaDataXPath = @"//div[@id='article']/div/div/div/dl";
        NSArray *metaDataFields = [parser searchWithXPathQuery:metaDataXPath];
        
        for (TFHppleElement *metaDataElement in metaDataFields) {
            NSString *header = [[[metaDataElement firstChild] firstChild] content];
            
            if (header) {
                TFHppleElement *content = [[[metaDataElement children] objectAtIndex:2] firstChild];
                
                if ([header isEqualToString:@"I've Raised:"]) { // volunteer/rider/virtual rider
                    NSString *amountRaised = [content content];
                    rider.amountRaised = amountRaised;
                } else if ([header isEqualToString:@"My Peloton:"]) { // rider/virtual rider
                    NSString *myPeloton = [[content firstChild] content];
                    rider.myPeloton = myPeloton;
                } else if ([header isEqualToString:@"Route I'm Riding:"]) { // rider
                    NSString *route = [self stripWhitespace:[content content]];
                    rider.route = route;
                } else if ([header isEqualToString:@"Peloton Funds Raised:"]) { // peloton
                    NSString *pelotonFundsRaised = [content content];
                    rider.pelotonFundsRaised = pelotonFundsRaised;
                } else if ([header isEqualToString:@"Total of All Members:"]) { // peloton
                    NSString *pelotonTotalOfAllMembers = [content content];
                    rider.pelotonTotalOfAllMembers = pelotonTotalOfAllMembers;
                } else if ([header isEqualToString:@"Grand Total Raised:"]) { // peloton
                    NSString *pelotonGrandTotal = [content content];
                    rider.pelotonGrandTotal = pelotonGrandTotal;
                } else if ([header isEqualToString:@"Peloton Captain:"]) { // peloton
                    NSString *pelotonCaptain = [self stripWhitespace:[[[[[[metaDataElement children] objectAtIndex:2] children] objectAtIndex:1] firstChild] content]];
                    rider.pelotonCaptain = pelotonCaptain;
                }
            }
        }

        if (completeBlock) {
            completeBlock(rider);
        }
        NSLog(@"Returning profile for rider %@", rider.name);
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"%@", error);
        if (failureBlock) {
            failureBlock(@"Network error");
        }
    }];
    
    [request startAsynchronous];
}

+ (NSString *)stripWhitespace:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
