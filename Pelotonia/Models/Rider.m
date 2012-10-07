//
//  Rider.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "Rider.h"
#import "ImageCache.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@interface Rider ()

- (void)asynchronousGetImageAtUrl:(NSString *)url onComplete:(void(^)(UIImage *image))complete;

@end

@implementation Rider
@synthesize delegate = _delegate;
@synthesize name = _name;
@synthesize riderId = _riderId;
@synthesize riderPhotoThumbUrl = _riderPhotoThumbUrl;
@synthesize riderPhotoThumb = _riderPhotoThumb;
@synthesize donateUrl = _donateUrl;
@synthesize profileUrl = _profileUrl;
@synthesize riderType = _riderType;
@synthesize route = _route;
@synthesize highRoller = _highRoller;
@synthesize story = _story;
@synthesize totalRaised = _totalRaised;
@synthesize totalCommit = _totalCommit;

@synthesize riderPhotoUrl = _riderPhotoUrl;
@synthesize riderPhoto = _riderPhoto;
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


- (void)asynchronousGetImageAtUrl:(NSString *)url onComplete:(void(^)(UIImage *image))complete
{
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:[request responseData]];
//            if (image != nil) {
//                [[ImageCache sharedStore] setImage:image forKey:url];
//            }
            
            if (complete) {
                complete(image);
            }
        });
    }];
    [request startAsynchronous];
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
    [aCoder encodeBool:highRoller forKey:@"highRoller"];
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
        highRoller = [aDecoder decodeBoolForKey:@"highRoller"];
    }
    return self;
}

- (UIImage *)riderPhoto
{
    if (_riderPhoto == nil) {
        // look in the cache
        _riderPhoto = [[ImageCache sharedStore] imageForKey:self.riderPhotoUrl];
        
        // use default image for now
        if (_riderPhoto == nil) {

            // get the photo from the web
            [self asynchronousGetImageAtUrl:self.riderPhotoUrl onComplete:^(UIImage *image) {
                self.riderPhoto = image;
            }];
            return [UIImage imageNamed:@"profile_default.jpg"];
        }
        
    }
    return _riderPhoto;
}

- (UIImage *)riderPhotoThumb
{
    if (_riderPhotoThumb == nil) {
        // first look in cache
        _riderPhotoThumb = [[ImageCache sharedStore] imageForKey:self.riderPhotoThumbUrl];
        
        if (_riderPhotoThumb == nil) {
            // get the photo from the web
            [self asynchronousGetImageAtUrl:self.riderPhotoThumbUrl onComplete:^(UIImage *image) {
                self.riderPhotoThumb = image;
            }];
            
            // use default thumb
            return [UIImage imageNamed:@"profile_default_thumb.jpg"];
        }
    }
    return _riderPhotoThumb;
}

- (void)setRiderPhoto:(UIImage *)riderPhoto
{
    _riderPhoto = riderPhoto;
    if (self.riderPhotoUrl && riderPhoto) {
        [[ImageCache sharedStore] setImage:riderPhoto forKey:self.riderPhotoUrl];
        [self.delegate riderPhotoDidUpdate:riderPhoto];
    }
}

- (void)setRiderPhotoThumb:(UIImage *)riderPhotoThumb
{
    _riderPhotoThumb = riderPhotoThumb;
    if (self.riderPhotoThumbUrl && riderPhotoThumb) {
        [[ImageCache sharedStore] setImage:riderPhotoThumb forKey:self.riderPhotoThumbUrl];
        [self.delegate riderPhotoThumbDidUpdate:riderPhotoThumb];
    }
}


#pragma mark -- NSCopying
// NSCopying



@end
