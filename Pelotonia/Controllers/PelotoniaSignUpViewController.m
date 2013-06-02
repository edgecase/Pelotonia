//
//  PelotoniaSignUpViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 5/21/13.
//
//

#import "PelotoniaSignUpViewController.h"

@interface PelotoniaSignUpViewController ()

@end

@implementation PelotoniaSignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = PRIMARY_DARK_GRAY;
    UIImageView *pelotoniaLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pelotonia_logo_22x216.png"]];
    self.signUpView.logo = pelotoniaLogo;
    [self.signUpView.logo sizeToFit];
}


@end
