//
//  FeedbackViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 9/26/13.
//
//

#import "FeedbackViewController.h"
#import <Socialize/Socialize.h>

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
    NSString *feedback = self.feedbackText.text;
    // send the feedback to support@isandlot.com
    [self sendFeedback:feedback];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFeedback:(NSString *)feedback {
    id<SZEntity> entity = [SZEntity entityWithKey:@"some_entity" name:@"Some Entity"];
    SZShareOptions *options = [SZShareUtils userShareOptions];
    
    [SZShareUtils shareViaEmailWithViewController:self options:options entity:entity success:^(id<SocializeShare> share) {
        NSLog(@"succeeded sending feedback");
    } failure:^(NSError *error) {
        NSLog(@"Failed sending feedback");
    }];
}

@end
