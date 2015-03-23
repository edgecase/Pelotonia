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

- (BOOL)isRider {
    return [self.riderType isEqualToString:@"Rider"];
}

- (BOOL)isPeloton {
    return [self.riderType containsString:@"Peloton"];
}

- (BOOL)isVirtualRider {
    return [self.riderType containsString:@"Virtual"];
}

- (BOOL)isVolunteer {
    return [self.riderType containsString:@"Volunteer"];
}

- (NSInteger)distance {
    NSInteger value = 25;
    
    if ([self.route isEqualToString:@"Columbus to Gambier and Back"]) {
        value = 180;
    }
    else if ([self.route isEqualToString:@"Pickerington to Gambier and Back"]) {
        value = 150;
    }
    else if ([self.route isEqualToString:@"Columbus to Gambier"]) {
        value = 100;
    }
    else if ([self.route isEqualToString:@"Pickerington to Gambier"]) {
        value = 75;
    }
    else if ([self.route isEqualToString:@"Columbus to New Albany"]) {
        value = 50;
    }
    else if ([self.route isEqualToString:@"Columbus to Pickerington"]) {
        value = 25;
    }
    
    return value;
}

- (NSString *)totalCommit
{
    NSString *value = @"$0.00";

    if (self.isRider) {
        if ((self.route == nil) || ([self.route length] == 0)) {
            NSLog(@"unable to read rider's route, 0 totalCommit");
            value = @"$0.00";
        }
        else if (self.highRoller == YES) {
            value = @"$4,000.00";
        }
        else if (self.distance == 180 || self.distance == 150) {
            // overnight to columbus or pickerington
            value = @"$2,200.00";
        }
        else if (self.distance == 75 || self.distance == 100) {
            // to gambier from columbus or pickerington
            value = @"$1,800.00";
        }
        else if (self.distance == 50) {
            // to new albany
            value = @"$1,250.00";
        }
        else {
            // to pickerington
            value = @"$1,200.00";
        }
    }
    else if (self.isPeloton) {
        // pelotons commit is everyone's total
        value = self.pelotonGrandTotal;
    }
    else if (self.isVirtualRider || self.isVolunteer) {
        // virtual riders have no commit
        value = self.amountRaised;
    }
    return value;
}

- (NSString *)riderDetailText
{
    if (self.isRider) {
        return self.route;
    }
    else {
        return self.riderType;
    }
}

- (NSString *)totalRaised
{
    if (self.isPeloton) {
        return self.pelotonGrandTotal;
    }
    else {
        return self.amountRaised;
    }    
}

- (float)pctRaised
{
    if (self.isVolunteer || self.isVirtualRider) {
        return 1.00;
    }
    else
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLenient:YES];
        
        float raised = [formatter numberFromString:self.totalRaised].floatValue;
        float commit = [formatter numberFromString:self.totalCommit].floatValue;
        
        if (commit == 0.0) {
            commit = raised;
        }
        return raised/commit;
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
