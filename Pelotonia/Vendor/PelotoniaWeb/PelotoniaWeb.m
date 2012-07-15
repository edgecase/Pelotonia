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
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
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
                }
            }
            
            if (rider.name) {
                [riders addObject:rider];
            }
        }
        
        if (completeBlock) {
            completeBlock(riders);
        }
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

+ (void)profileForRider:(Rider *)rider onComplete:(void(^)(Rider *rider))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    NSURL *url = [NSURL URLWithString:rider.profileUrl];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        TFHpple *parser = [TFHpple hppleWithHTMLData:[request responseData]];
        NSString *riderPhotoUrlXPath = @"//div[@id='touts']/div[@class='public-profile-photo']/img";
        NSString *riderPhotoRelativeUrl = [[[[parser searchWithXPathQuery:riderPhotoUrlXPath] objectAtIndex:0] attributes] valueForKey:@"src"];
        NSString *riderPhotoAbsoluteUrl = [NSString stringWithFormat:@"https://www.mypelotonia.org/%@", riderPhotoRelativeUrl];
        
        rider.riderPhotoUrl = riderPhotoAbsoluteUrl;
        
        NSString *metaDataXPath = @"//div[@id='article']/div/div/div/dl";
        NSArray *metaDataFields = [parser searchWithXPathQuery:metaDataXPath];
        
        for (TFHppleElement *metaDataElement in metaDataFields) {
            NSString *header = [[[metaDataElement firstChild] firstChild] content];
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
                NSLog(@"route: %@", rider.route);
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

        if (completeBlock) {
            completeBlock(rider);
        }
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
