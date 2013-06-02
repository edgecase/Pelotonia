//
//  PelotoniaLogInViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 5/21/13.
//
//

#import "PelotoniaLogInViewController.h"
#import "Pelotonia-Colors.h"

@interface PelotoniaLogInViewController ()

@end

@implementation PelotoniaLogInViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PRIMARY_DARK_GRAY;
    UIImageView *pelotoniaLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pelotonia_logo_22x216.png"]];
    self.logInView.logo = pelotoniaLogo; // logo can be any UIView
    [self.logInView.logo sizeToFit];
}

@end
