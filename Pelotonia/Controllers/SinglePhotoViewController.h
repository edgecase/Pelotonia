//
//  SinglePhotoViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SinglePhotoViewController : UIViewController
@property (strong, nonatomic) NSDictionary *imageData;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) ALAssetsLibrary *library;
@end
