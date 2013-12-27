//
//  TouchViewController.m
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import "TouchViewController.h"

NSString *const TouchTrackerCompleteLinesPrefKey = @"TouchTrackerCompleteLinesPrefKey";

@interface TouchViewController ()

@end

@implementation TouchViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    /*
     "If a view controller is owned by a window object, 
     it acts as the window’s root view controller. 
     The view controller’s root view is added as 
     a subview of the window and resized to fill the window."
     */
    
    TouchDrawView *tdv = [[TouchDrawView alloc] initWithFrame:CGRectZero];
    [tdv setDelegate:self];
    
    NSString *path = [Line archivePath];
    NSArray *completeLines = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (completeLines)
        [tdv setCompleteLines:[completeLines mutableCopy]];
    
    [self setView:tdv];
}

- (void)saveLines:(NSArray *)completeLines
{
    NSString *path = [Line archivePath];
    NSLog([NSString stringWithFormat:@"%@", path]);
    if ([NSKeyedArchiver archiveRootObject:completeLines toFile:path])
        NSLog(@"Completed Lines are saved");
    else
        NSLog(@"Cannot save lines");
}

@end
