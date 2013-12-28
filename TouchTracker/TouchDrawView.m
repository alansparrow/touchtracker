//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by Alan Sparrow on 12/28/13.
//  Copyright (c) 2013 Alan Sparrow. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

@implementation TouchDrawView

@synthesize delegate;
@synthesize completeLines;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc] init];
        
        // Don't let the autocomplete fool you on the
        // next line, make sure you are instantiating
        // an NSMutableArray and not NSMutableDictionary
        completeLines = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMultipleTouchEnabled:YES];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (int i = 0; i < [completeLines count]; i += 2) {
        
        // Use this to wake this object up so it will
        // fetch lazy data into begin, end variables
        // If you don't do this, begin and end will be empty
        // because awakeFromFetch didn't run
        // May be this is for
        //NSLog(@"%@", [line primitiveValueForKey:@"beginRawData"]);
        Line *l1 = [completeLines objectAtIndex:i];
        Line *l2 = l1;
        if (i+1 < [completeLines count]) {
            l2 = [completeLines objectAtIndex:i+1];
        }
        
        NSLog(@"%@", [l1 beginRawData]);
        NSLog(@"%@", [l2 beginRawData]);
        
        
        double radius = sqrt(pow([l1 end].x - [l2 end].x, 2) +
                             pow([l1 end].y - [l2 end].y, 2)) / 2;
        CGPoint center = CGPointMake(([l1 end].x + [l2 end].x) / 2,
                                     ([l1 end].y + [l2 end].y) / 2);
        CGContextAddArc(context, center.x, center.y,
                        radius, 0, M_PI*2.0, YES);
        
        NSArray *colors = [NSArray arrayWithObjects:[UIColor greenColor],
                           [UIColor greenColor],
                           [UIColor magentaColor],
                           [UIColor brownColor],
                           [UIColor orangeColor],
                           [UIColor purpleColor],
                           nil];
        
        UIColor *color = [colors objectAtIndex:(rand() % 6)];
        [color set];
        
        CGContextStrokePath(context);
    }
    
    // Draw lines in process in red (Don't copy and paste
    // the previous loop; this one is way different)
    [[UIColor redColor] set];
    
    if ([linesInProcess count] == 2) {
        NSArray *lines = [[linesInProcess objectEnumerator] allObjects];
        Line *l1 = [lines objectAtIndex:0];
        Line *l2 = [lines objectAtIndex:1];
        
        CGContextMoveToPoint(context, [l1 begin].x, [l1 begin].y);
        CGContextAddLineToPoint(context, [l1 end].x, [l1 end].y);
        CGContextStrokePath(context);
        
        
        CGContextMoveToPoint(context, [l2 begin].x, [l2 begin].y);
        CGContextAddLineToPoint(context, [l2 end].x, [l2 end].y);
        CGContextStrokePath(context);
        
        double radius = sqrt(pow([l1 end].x - [l2 end].x, 2) +
                             pow([l1 end].y - [l2 end].y, 2)) / 2;
        CGPoint center = CGPointMake(([l1 end].x + [l2 end].x) / 2,
                                     ([l1 end].y + [l2 end].y) / 2);
        CGContextAddArc(context, center.x, center.y,
                        radius, 0, M_PI*2.0, YES);
        CGContextStrokePath(context);
    }
}

- (void)clearAll
{
    // Clear the collections
    [linesInProcess removeAllObjects];
    
    if ([delegate respondsToSelector:@selector(removeLinesInDB:)]) {
        // Remove in DB too
        [delegate removeLinesInDB:completeLines];
    }
    
    
    [completeLines removeAllObjects];
    
    
    
    // Redraw
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        // Is this a double tap?
        if ([t tapCount] > 1) {
            [self clearAll];
            return;
        }
        
        // Use the touch object (packed in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        NSLog(@"%@", key);
        // Create a line for the value
        CGPoint loc = [t locationInView:self];
        
        Line *newLine = nil;
        if ([delegate respondsToSelector:@selector(newLine)]) {
            newLine = [delegate newLine];
        }
        [newLine setBegin:loc];
        [newLine setEnd:loc];
        
        // Put pair in dictionary
        [linesInProcess setObject:newLine forKey:key];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Update linesInProcess with moved touches
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        // Find the line for this touch
        Line *line = [linesInProcess objectForKey:key];
        
        // Update the line
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    
    // Redraw
    [self setNeedsDisplay];
}

- (void)endTouches:(NSSet *)touches
{
    // Remove ending touches from dictionary
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        // If this is a double tap, 'line' will be nil,
        // so make sure not to add it to the array
        if (line) {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
            
            // Save to DB
            if ([delegate respondsToSelector:@selector(saveCompletedLinesToDB)]) {
                [line setBeginRawData:[NSKeyedArchiver
                                       archivedDataWithRootObject:[NSValue valueWithCGPoint:[line begin]]]];
                [line setEndRawData:[NSKeyedArchiver
                                     archivedDataWithRootObject:[NSValue valueWithCGPoint:[line end]]]];
                [delegate saveCompletedLinesToDB];
            }
        }
    }
    
    // Redraw
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}


@end
