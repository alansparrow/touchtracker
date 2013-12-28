//
//  TouchViewController.m
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "TouchViewController.h"
#import "Line.h"



@interface TouchViewController ()
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}
@end

@implementation TouchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        // Read in TouchTracker.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        // "What are all of my entities and their attribute and relationships?"
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // "Where does the SQLite file go?"
        NSString *path = [Line archivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo,
        // but we don't need it
        [context setUndoManager:nil];

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
    [tdv setCompleteLines:[self loadAllLines]];
    
    [self setView:tdv];
}

- (void)saveCompletedLinesToDB
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
}

- (void)removeLinesInDB:(NSArray *)lines
{
    for (Line *line in lines) {
        [context deleteObject:line];
    }
    
    // Commit changes
    [self saveCompletedLinesToDB];
    
    NSLog(@"%d", [[self loadAllLines] count]);
}

- (NSMutableArray *) loadAllLines
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Line"];
    [request setEntity:e];
    
    NSError *err;
    NSArray *result = [context executeFetchRequest:request
                                             error:&err];
    
    if (!result) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@",
         [err localizedDescription]];
    }
    
    // This will lead to awakeFromFetch. Fuck it!
    //NSLog(@"%@", [[result objectAtIndex:0] primitiveValueForKey:@"beginRawData"]);
    //NSLog(@"%@", [[result objectAtIndex:1] primitiveValueForKey:@"beginRawData"]);
    
    //[result objectAtIndex:1];
    
    return [[NSMutableArray alloc] initWithArray:result];
}

- (Line *)newLine
{
    Line *l = [NSEntityDescription
               insertNewObjectForEntityForName:@"Line"
               inManagedObjectContext:context];
    return l;
}

@end
