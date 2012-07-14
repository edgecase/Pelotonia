//
//  PelotoniaWeb.h
//  Pelotonia
//
//  Created by Michael Enriquez on 7/14/12.
//  Copyright (c) 2012 Michael Enriquez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PelotoniaWeb : NSObject
+ (void)searchForRiderWithLastName:(NSString *)lastName riderId:(NSString *)riderId onComplete:(void(^)(NSArray *searchResults))completeBlock onFailure:(void(^)(NSString *errorMessage))failureBlock;
@end
