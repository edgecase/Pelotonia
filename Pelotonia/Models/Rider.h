//
//  Rider.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PhotoUpdateDelegate;

@interface Rider : NSObject <NSCoding> {
    NSString *_name;
    NSString *_riderId;
    NSString *_riderPhotoThumbUrl;
    UIImage *_riderPhotoThumb;
    NSString *_donateUrl;
    NSString *_profileUrl;
    NSString *_riderType;
    NSString *_route;
    NSString *_story;
    BOOL highRoller;
    
    NSString *_riderPhotoUrl;
    UIImage *_riderPhoto;
    NSString *_amountRaised;
    NSString *_myPeloton;
    NSString *_pelotonFundsRaised;
    NSString *_pelotonTotalOfAllMembers;
    NSString *_pelotonGrandTotal;
    NSString *_pelotonCaptain;
}

@property (retain, nonatomic) id <PhotoUpdateDelegate> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *riderId;
@property (nonatomic, strong) NSString *riderPhotoThumbUrl;
@property (nonatomic, strong, readonly) UIImage  *riderPhotoThumb;
@property (nonatomic, strong) NSString *donateUrl;
@property (nonatomic, strong) NSString *profileUrl;
@property (nonatomic, strong) NSString *riderType;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *story;
@property (nonatomic, assign) BOOL highRoller;
@property (nonatomic, readonly) NSString *totalCommit;
@property (nonatomic, readonly) NSString *totalRaised;
@property (nonatomic, readonly) NSNumber *pctRaised;

@property (nonatomic, strong) NSString *riderPhotoUrl;
@property (nonatomic, strong, readonly) UIImage  *riderPhoto;
@property (nonatomic, strong) NSString *amountRaised;
@property (nonatomic, strong) NSString *myPeloton;
@property (nonatomic, strong) NSString *pelotonFundsRaised;
@property (nonatomic, strong) NSString *pelotonTotalOfAllMembers;
@property (nonatomic, strong) NSString *pelotonGrandTotal;
@property (nonatomic, strong) NSString *pelotonCaptain;

// NSObject & initialization
- (id)initWithName:(NSString *)name andId:(NSString *)riderId;

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@protocol PhotoUpdateDelegate <NSObject>
- (void)riderPhotoDidUpdate:(UIImage *)image;
- (void)riderPhotoThumbDidUpdate:(UIImage *)image;
@end



