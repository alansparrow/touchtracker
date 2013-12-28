//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@protocol TouchDrawViewDelegate

@optional
- (void)saveCompletedLinesToDB;
- (void)removeLinesInDB:(NSArray *) lines;
- (Line *)newLine;

@end

@interface TouchDrawView : UIView
{
    NSMutableDictionary *linesInProcess;
}

@property id delegate;

@property NSMutableArray *completeLines;

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@end
