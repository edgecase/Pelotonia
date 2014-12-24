//
//  NSNumber+Currency.m
//  Pelotonia
//
//  Created by Mark Harris on 2/22/14.
//
//

#import <Foundation/Foundation.h>
#import "NSNumber+Currency.h"

@implementation NSNumber (Currency)

+ (NSString *)asCurrency:(NSNumber *)number {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *numberAsString = [numberFormatter stringFromNumber:number];
    return numberAsString;
}

+ (NSNumber *)asString:(NSString *)currencyString {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber * myNumber = [f numberFromString:currencyString];
    return myNumber;
}
@end
