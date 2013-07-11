//
//  NSDictionary+JSONConversion.m
//  Pelotonia
//
//  Created by Mark Harris on 7/11/13.
//
//

#import "NSDictionary+JSONConversion.h"

@implementation NSDictionary (JSONConversion)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

+(NSDictionary *)dictionaryWithContentsOfJSONString:(NSString *)jsonString
{
    NSData *data = [NSData dataWithBytes:(__bridge const void *)(jsonString) length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) {
        return nil;
    }
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}

-(NSString *)toJSONString
{
    NSData *jsonData = [self toJSON];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
