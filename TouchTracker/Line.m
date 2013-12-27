//
//  Line.m
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import "Line.h"

@implementation Line

@synthesize begin, end;

+ (NSString *)archivePath
{
    // Careful! Easy to write NSDocumentationDirectory!!! It's super wrong
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"lines.archive"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:begin forKey:@"begin"];
    [aCoder encodeCGPoint:end forKey:@"end"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setBegin:[aDecoder decodeCGPointForKey:@"begin"]];
        [self setEnd:[aDecoder decodeCGPointForKey:@"end"]];
    }
    
    return  self;
}

@end
