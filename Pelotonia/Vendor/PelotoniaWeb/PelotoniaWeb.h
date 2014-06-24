//
//  PelotoniaWeb.h
//  Pelotonia
//
//  Created by Michael Enriquez on 7/14/12.
//  Copyright (c) 2012 Michael Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rider.h"
#import "Event.h"

static NSString *pelotoniaStory = @"Pelotonia is a grassroots bike tour with one goal: to end cancer. Pelotonia raises money for innovative and life saving cancer research at The Ohio State University Comprehensive Cancer Center - James Cancer Hospital and Solove Research Institute. Driven by the passion of its cyclists and volunteers, and their family and friends, Pelotonia's annual cycling experience will be a place of hope, energy and determination. Pelotonia proudly directs 100% of every dollar raised to research. It is a community of people coming together to chase down cancer and defeat it.";

@interface PelotoniaWeb : NSObject

+ (void)searchForRiderWithLastName:(NSString *)lastName riderId:(NSString *)riderId onComplete:(void(^)(NSArray *searchResults))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock;

+ (void)profileForRider:(Rider *)rider onComplete:(void(^)(Rider *rider))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock;

+ (void)getPelotoniaStatsOnComplete:(void(^)(NSString *amtRaised, NSString *numRiders))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock;

+ (void)getPelotoniaEventsOnComplete:(void(^)(void))onComplete onFailure:(void(^)(NSString *errorMessage))failureBlock;

+ (void)getEventDescription:(Event *)event
                 onComplete:(void (^)(Event *e))completeBlock
                  onFailure:(void (^)(NSString *))failureBlock;


@end
