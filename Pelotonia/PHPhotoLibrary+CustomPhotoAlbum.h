//
//  PHPhotoLibrary category to handle a custom photo album
//

@import Foundation;
@import Photos;

typedef void(^SaveImageCompletion)(NSURL* assetURL, NSError* error);

@interface PHPhotoLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

@end