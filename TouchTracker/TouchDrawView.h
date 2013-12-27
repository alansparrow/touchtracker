//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchDrawViewDelegate
//@optional try later
- (void) saveLines:(NSArray *)completeLines;
@end

@interface TouchDrawView : UIView

{
    NSMutableDictionary *linesInProcess;
}

@property (nonatomic, strong) NSMutableArray *completeLines;
@property (nonatomic, assign) id delegate;

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@end
