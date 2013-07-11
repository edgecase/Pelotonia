//
//  NSDictionary+JSONConversion.h
//  Pelotonia
//
//  Created by Mark Harris on 7/11/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONConversion)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString *)jsonString;
-(NSData*)toJSON;
-(NSString *)toJSONString;

@end
