//
//  Rider.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Rider.h"

@implementation Rider
@synthesize name = _name;
@synthesize riderId = _riderId;
@synthesize riderPhotoThumbUrl = _riderPhotoThumbUrl;
@synthesize donateUrl = _donateUrl;
@synthesize profileUrl = _profileUrl;
@synthesize riderType = _riderType;
@synthesize route = _route;

@synthesize riderPhotoUrl = _riderPhotoUrl;
@synthesize amountRaised = _amountRaised;
@synthesize myPeloton = _myPeloton;
@synthesize pelotonFundsRaised = _pelotonFundsRaised;
@synthesize pelotonTotalOfAllMembers = _pelotonTotalOfAllMembers;
@synthesize pelotonGrandTotal = _pelotonGrandTotal;
@synthesize pelotonCaptain = _pelotonCaptain;

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
    }
    return self;
}


@end
