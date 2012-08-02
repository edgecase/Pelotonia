//
//  AboutViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize versionLabel;

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
	// Do any additional setup after loading the view.
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@.%@",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)viewDidUnload
{
    [self setVersionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sandlotPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.isandlot.com"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
    NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)newContextPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.newcontext.com"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
    NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
@end
