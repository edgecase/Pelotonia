//
//  IntroContentViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import "IntroContentViewController.h"

@interface IntroContentViewController ()

@end

@implementation IntroContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundImage.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
    self.detailTextLabel.text = self.detailText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
