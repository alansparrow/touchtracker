//
//  Line.m
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import "Line.h"


@implementation Line

@dynamic beginRawData;
@dynamic endRawData;

@synthesize begin, end;

+ (NSString *)archivePath
{
    NSArray *documentDirectories =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

// Only fetched when outsider (!@#@!##$%#$)
// ask for primitiveValueForKey:@"beginRawData" first. Fuck it!
- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // Take out as an object, then open wrap to get struct (primitive type)
    NSValue *rawData = [NSKeyedUnarchiver
     unarchiveObjectWithData:[self primitiveValueForKey:@"beginRawData"]];
    [self setBegin:[rawData CGPointValue]];
    
    rawData = [NSKeyedUnarchiver
               unarchiveObjectWithData:[self primitiveValueForKey:@"endRawData"]];
    [self setEnd:[rawData CGPointValue]];
    
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
}


@end
