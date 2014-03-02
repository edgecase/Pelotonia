//
//  Rider.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "Rider.h"
#import "PelotoniaWeb.h"

@interface Rider ()


@end

@implementation Rider
@synthesize name = _name;
@synthesize riderId = _riderId;
@synthesize riderPhotoThumbUrl = _riderPhotoThumbUrl;
@synthesize donateUrl = _donateUrl;
@synthesize profileUrl = _profileUrl;
@synthesize riderType = _riderType;
@synthesize route = _route;
@synthesize highRoller = _highRoller;
@synthesize story = _story;
@synthesize totalRaised = _totalRaised;
@synthesize totalCommit = _totalCommit;

@synthesize riderPhotoUrl = _riderPhotoUrl;
@synthesize amountRaised = _amountRaised;
@synthesize myPeloton = _myPeloton;
@synthesize pelotonFundsRaised = _pelotonFundsRaised;
@synthesize pelotonTotalOfAllMembers = _pelotonTotalOfAllMembers;
@synthesize pelotonGrandTotal = _pelotonGrandTotal;
@synthesize pelotonCaptain = _pelotonCaptain;
@synthesize donors = _donors;

// NSObject methods

- (id)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (id)initWithName:(NSString *)name andId:(NSString *)riderId {
    if (self = [super init]) {
        _name = name;
        _riderId = riderId;
    }
    return self;
}



#pragma mark -- Properties

- (NSString *)totalCommit 
{
    NSString *value = @"0";

    if (self.highRoller == YES) {
        value = @"4000";
    }
    else
    {
        if ([self.riderType isEqualToString:@"Rider"]) {
            if ([self.route length] == 0) {
                value = @"0";
            }
            if ([self.route isEqualToString:@"Columbus to Gambier and Back"]) {
                value = @"2,200";
            }
            if ([self.route isEqualToString:@"Pickerington to Gambier and Back"]) {
                value = @"2,200";
            }
            if ([self.route isEqualToString:@"Columbus to Gambier"]) {
                value = @"1,800";
            }
            if ([self.route isEqualToString:@"Pickerington to Gambier"]) {
                value = @"1,800";
            }
            if ([self.route isEqualToString:@"Columbus to New Albany"]) {
                value = @"1,250";
            }
            if ([self.route isEqualToString:@"Columbus to Pickerington"]) {
                value = @"1,200";
            }
        }
        else
        {
            value = @"0";
        }
    }
    return [NSString stringWithFormat:@"$%@.00", value];
}


- (NSString *)totalRaised
{
    if ([self.pelotonGrandTotal length] > 0) {
        return self.pelotonGrandTotal;
    }
    else {
        return self.amountRaised;
    }    
}

- (NSNumber *)pctRaised
{
    if (self.totalCommit == 0) {
        return [NSNumber numberWithFloat:100.0];
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLenient:YES];
        
        NSNumber *totalRaised = [formatter numberFromString:self.totalRaised];
        NSNumber *totalCommit = [formatter numberFromString:self.totalCommit];
        
        float raised = totalRaised.floatValue;
        float commit = totalCommit.floatValue;
        if (commit == 0.0) {
            commit = 1;
        }
        return [NSNumber numberWithFloat:(raised/commit)*100];
    }
}

- (NSString *)route
{
    NSString *routeString = _route;
    
    if (![self.riderType isEqualToString:@"Rider"]) {
        routeString = self.riderType;
    }
    
    return routeString;
}

#pragma mark -- NSCoding

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_riderId forKey:@"riderId"];
    [aCoder encodeObject:_riderPhotoThumbUrl forKey:@"riderPhotoThumbUrl"];
    [aCoder encodeObject:_donateUrl forKey:@"donateUrl"];
    [aCoder encodeObject:_profileUrl forKey:@"profileUrl"];
    [aCoder encodeObject:_riderType forKey:@"riderType"];
    [aCoder encodeObject:_route forKey:@"route"];
    
    [aCoder encodeObject:_riderPhotoUrl forKey:@"riderPhotoUrl"];
    [aCoder encodeObject:_amountRaised forKey:@"amountRaised"];
    [aCoder encodeObject:_myPeloton forKey:@"myPeloton"];
    [aCoder encodeObject:_pelotonFundsRaised forKey:@"pelotonFundsRaised"];
    [aCoder encodeObject:_pelotonTotalOfAllMembers forKey:@"pelotonTotalOfAllMembers"];
    [aCoder encodeObject:_pelotonGrandTotal forKey:@"pelotonGrandTotal"];
    [aCoder encodeObject:_pelotonCaptain forKey:@"pelotonCaptain"];
    [aCoder encodeObject:_story forKey:@"story"];
    [aCoder encodeBool:_highRoller forKey:@"highRoller"];
    [aCoder encodeObject:_donors forKey:@"donors"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _riderId = [aDecoder decodeObjectForKey:@"riderId"];
        _riderPhotoThumbUrl = [aDecoder decodeObjectForKey:@"riderPhotoThumbUrl"];
        _donateUrl = [aDecoder decodeObjectForKey:@"donateUrl"];
        _profileUrl = [aDecoder decodeObjectForKey:@"profileUrl"];
        _riderType = [aDecoder decodeObjectForKey:@"riderType"];
        _route = [aDecoder decodeObjectForKey:@"route"];
        
        _riderPhotoUrl = [aDecoder decodeObjectForKey:@"riderPhotoUrl"];
        _amountRaised = [aDecoder decodeObjectForKey:@"amountRaised"];
        _myPeloton = [aDecoder decodeObjectForKey:@"myPeloton"];
        _pelotonFundsRaised = [aDecoder decodeObjectForKey:@"pelotonFundsRaised"];
        _pelotonTotalOfAllMembers = [aDecoder decodeObjectForKey:@"pelotonTotalOfAllMembers"];
        _pelotonGrandTotal = [aDecoder decodeObjectForKey:@"pelotonGrandTotal"];
        _pelotonCaptain = [aDecoder decodeObjectForKey:@"pelotonCaptain"];
        _story = [aDecoder decodeObjectForKey:@"story"];
        _highRoller = [aDecoder decodeBoolForKey:@"highRoller"];
        _donors = [aDecoder decodeObjectForKey:@"donors"];
    }
    return self;
}

#pragma mark -- property overrides



#pragma mark -- implementation
- (void)refreshFromWebOnComplete:(void(^)(Rider *rider))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock
{
    [PelotoniaWeb profileForRider:self onComplete:^(Rider *updatedRider) {
        self.name = updatedRider.name;
        self.riderId = updatedRider.riderId;
        self.riderPhotoThumbUrl = updatedRider.riderPhotoThumbUrl;
        self.donateUrl = updatedRider.donateUrl;
        self.profileUrl = updatedRider.profileUrl;
        self.riderType = updatedRider.riderType;
        self.route = updatedRider.route;
        self.story = updatedRider.story;
        self.highRoller = updatedRider.highRoller;
        self.riderPhotoUrl = updatedRider.riderPhotoUrl;
        self.amountRaised = updatedRider.amountRaised;
        self.myPeloton = updatedRider.myPeloton;
        self.pelotonFundsRaised = updatedRider.pelotonFundsRaised;
        self.pelotonTotalOfAllMembers = updatedRider.pelotonTotalOfAllMembers;
        self.pelotonGrandTotal = updatedRider.pelotonGrandTotal;
        self.pelotonCaptain = updatedRider.pelotonCaptain;
        self.donors = updatedRider.donors;
        if (completeBlock) {
            completeBlock(self);
        }
        
    } onFailure:^(NSString *error) {
        NSLog(@"refreshFromWeb: Unable to get profile for rider. Error: %@", error);
        if (failureBlock) {
            failureBlock(@"unable to get profile for rider");
        }
    }];
}

+ (Rider *)pelotoniaRider
{
    Rider *pelotonia = [[Rider alloc] initWithName:@"Pelotonia" andId:nil];
    pelotonia.profileUrl = @"http://www.pelotonia.org";
    return pelotonia;
}

@end
