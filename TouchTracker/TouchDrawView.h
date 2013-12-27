//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchDrawView : UIView
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
}

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@end
