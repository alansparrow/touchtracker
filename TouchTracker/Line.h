//
//  Line.h
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Line : NSManagedObject
{
    
}

@property (nonatomic, strong) NSData * beginRawData;
@property (nonatomic, strong) NSData * endRawData;

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;

+ (NSString *)archivePath;

@end
