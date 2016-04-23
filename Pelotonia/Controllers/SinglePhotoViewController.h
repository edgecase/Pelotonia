//
//  SinglePhotoViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

@import UIKit;
@import Photos;


@interface SinglePhotoViewController : UIViewController

@property (strong, nonatomic) PHAsset *asset;
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)trashPhoto:(id)sender;

@end
