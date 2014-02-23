//
//  NSNumber+Currency.h
//  Pelotonia
//
//  Created by Mark Harris on 2/22/14.
//
//

#import <Foundation/Foundation.h>

@interface NSNumber (Currency)

+ (NSString *)asCurrency:(NSNumber *)number;
+ (NSNumber *)asString:(NSString *)string;
@end
