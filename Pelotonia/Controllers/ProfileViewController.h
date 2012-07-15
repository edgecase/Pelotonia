//
//  ProfileViewController.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rider.h"

@interface ProfileViewController : UIViewController 

@property (strong, nonatomic) Rider *rider;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *riderIdLabel;
@property (strong, nonatomic) IBOutlet UIImageView *riderImageView;

@end

