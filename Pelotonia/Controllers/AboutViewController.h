//
//  AboutViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)done:(id)sender;

@end
