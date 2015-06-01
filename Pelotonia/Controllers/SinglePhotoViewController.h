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
@property (assign, nonatomic) NSUInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)trashPhoto:(id)sender;
@end
