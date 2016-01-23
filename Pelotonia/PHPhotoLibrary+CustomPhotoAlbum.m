//
//  PHPhotoLibrary category to handle a custom photo album
//

#import "PHPhotoLibrary+CustomPhotoAlbum.h"

@implementation PHPhotoLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Get or create the album named 'albumName'
        
        // Request creating an asset from the image.
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // Request editing the album.
//        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
//        
//        // Get a placeholder for the new asset and add it to the album editing request.
//        PHObjectPlaceholder *assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
//        [albumChangeRequest addAssets:@[ assetPlaceholder ]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"Finished adding asset. %@", (success ? @"Success" : error));
        if (error != nil) {
          completionBlock(nil, error);
        }
    }];
}

@end
