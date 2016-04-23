//
//  PelotoniaPhotosLibrary.swift
//  Pelotonia
//
//  Created by Mark Harris on 4/9/16.
//
//

import Photos

class PelotoniaPhotosLibrary: NSObject {
    
    let albumName:String = "Pelotonia"
    var collection:PHAssetCollection!
    
    func library() -> PHPhotoLibrary?
    {
        if (PHPhotoLibrary.authorizationStatus() != .NotDetermined) {
            return PHPhotoLibrary.sharedPhotoLibrary();
        }
        else {
            return nil;
        }
    }

    func createAlbum(completion: (PHAssetCollection) -> Void) {
        
        var assetCollectionPlaceholder: PHObjectPlaceholder!
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.albumName)
            assetCollectionPlaceholder = request.placeholderForCreatedAssetCollection
            },
            completionHandler: { (success:Bool, error:NSError?) in
                if (success) {
                    let result:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([assetCollectionPlaceholder.localIdentifier], options: nil)
                    self.collection = result.firstObject as! PHAssetCollection
                    completion(self.collection)
                }
        })
    }

    func album(completion: (PHAssetCollection) -> Void) {
        if (self.collection == nil) {
            let options:PHFetchOptions = PHFetchOptions()
            options.predicate = NSPredicate(format: "estimatedAssetCount >= 0")
            
            let userAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: options)
            
            userAlbums.enumerateObjectsUsingBlock{ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
                if object is PHAssetCollection {
                    let obj:PHAssetCollection = object as! PHAssetCollection
                    if (obj.localizedTitle == self.albumName) {
                        self.collection = obj
                        stop.initialize(true)
                    }
                }
            }
            if (self.collection == nil) {
                self.createAlbum(completion)
            }
            else {
                completion(self.collection)
            }
        }
        else {
            completion(self.collection)
        }
    }
    
    func saveImage(image : UIImage, completion: (NSURL?, NSError!) -> Void) {
        
        library()!.performChanges({ () -> Void in
            let createAssetRequest  = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder  = createAssetRequest.placeholderForCreatedAsset!
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.collection)
    
            albumChangeRequest!.addAssets([assetPlaceholder])
            })
            { (success : Bool, error : NSError?) -> Void in
                if (success) {
                    completion(nil, nil)
                }
                else {
                    completion(nil, error)
                }
            }
    }
    
    func images(completion:(PHFetchResult) -> Void) {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        self.album { (pelotoniaAlbum : PHAssetCollection) -> Void in
            let images: PHFetchResult = PHAsset.fetchAssetsInAssetCollection(pelotoniaAlbum, options: options)
            completion(images)
        }
    }
    
}


