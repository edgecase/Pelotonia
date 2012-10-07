//
//  ImageCache.m
//  Pelotonia
//
//  Created by Mark Harris on 7/13/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "ImageCache.h"


@implementation ImageCache
+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (ImageCache *)sharedStore
{
    static ImageCache *sharedStore = nil;
    if (!sharedStore) {
        // Create the singleton
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

- (id)init {
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self 
               selector:@selector(clearCache:) 
                   name:UIApplicationDidReceiveMemoryWarningNotification 
                 object:nil];

    }
    return self;
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
    // Create full path for image
    NSString *imagePath = [self imagePathForKey:s];
    NSLog(@"setImage: writing out image %@", imagePath);
    
    // Turn image into JPEG data,
    NSData *d = UIImageJPEGRepresentation(i, 0.5);
    
    // Write it to full path
    [d writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)s
{
    // If possible, get it from the dictionary
    UIImage *result = [dictionary objectForKey:s];
    
    if (!result) {
        // Create UIImage object from file
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
        
        // If we found an image on the file system, place it into the cache
        if (result)
            [dictionary setObject:result forKey:s];
        else
        {
            NSLog(@"Unable to find %@", [self imagePathForKey:s]);
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)s
{
    if(!s)
        return;
    [dictionary removeObjectForKey:s];
    NSString *path = [self imagePathForKey:s];
    [[NSFileManager defaultManager] removeItemAtPath:path
                                               error:NULL];
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, 
                                        YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *sanitizedKey = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return [documentDirectory stringByAppendingPathComponent:sanitizedKey];
}
@end
