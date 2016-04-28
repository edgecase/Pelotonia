//
//  RiderPhotoCell.m
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import "RiderPhotoCell.h"

@implementation RiderPhotoCell 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImageAsset:(PHAsset *)imageAsset
{
    
    [self.imageManager requestImageForAsset:imageAsset
                                 targetSize: CGSizeMake(165, 165)
                                contentMode: PHImageContentModeAspectFit
                                    options: nil
                              resultHandler: ^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  NSLog(@"******** Setting photo!!!!");                                  
                                  self.imageView.image = result;
                              }];
}


@end
