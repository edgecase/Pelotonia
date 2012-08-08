//
//  PelotoniaSHKConfigurator.m
//  Pelotonia
//
//  Created by Mark Harris on 8/8/12.
//
//

#import "PelotoniaSHKConfigurator.h"

@implementation PelotoniaSHKConfigurator


- (NSString *)facebookAppId
{
    return @"269799726466566";
}

- (NSString*)facebookSecret {
    return @"2650698f3fd9f840b579eec9049e68c4";
}


- (NSString*)twitterConsumerKey {
	return @"5wwPWS7GpGvcygqmfyPIcQ";
}

- (NSString*)twitterSecret {
	return @"95FOLBeQqgv0uYGMWewxf50U0sVAVIbVBlvsmjiB4V8";
}

// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"http://www.pelotonia.org";
}

// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}



@end
