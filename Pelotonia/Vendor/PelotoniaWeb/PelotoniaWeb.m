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
                    rider.name = [[[[riderAttributeColumn children] objectAtIndex:1] firstChild] content];
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
                    rider.route = [[riderAttributeColumn firstChild] content];
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
        NSLog(@"url: %@", rider.riderPhotoUrl);
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

@end
