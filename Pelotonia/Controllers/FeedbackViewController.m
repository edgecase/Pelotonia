//
//  FeedbackViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

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
    // configure the UI appearance of the window
    self.navBar.tintColor = PRIMARY_DARK_GRAY;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        self.navBar.tintColor = PRIMARY_GREEN;
        self.navBar.barTintColor = PRIMARY_DARK_GRAY;
        [self.navigationController.navigationBar setTranslucent:NO];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
//    NSString *feedback = self.feedbackText.text;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
