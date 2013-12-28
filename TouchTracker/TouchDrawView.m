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
@synthesize selectedLine;

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
        
        UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapRecognizer];
        
        UITapGestureRecognizer *doubleTapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearAll)];
        [doubleTapRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [pressRecognizer setMinimumPressDuration:1];
        [self addGestureRecognizer:pressRecognizer];
        
        moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(moveLine:)];
        [moveRecognizer setDelegate:self];
        [moveRecognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:moveRecognizer];
        
        UISwipeGestureRecognizer *swipeGestureRecognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showColorMenu:)];
        //[swipeGestureRecognizer setCancelsTouchesInView:NO];
        [swipeGestureRecognizer setNumberOfTouchesRequired:3];
        [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [self addGestureRecognizer:swipeGestureRecognizer];
    }
    
    return self;
}

- (void)showColorMenu:(UISwipeGestureRecognizer *)gr
{
    //[gr ]
    NSLog(@"go into swipe");
    if ([gr numberOfTouches] == 3) {
        [linesInProcess removeAllObjects];
        
        NSLog(@"Swiped with 3 fingers");
        
        // We will talk about this shortly
        [self becomeFirstResponder];
        
        // Grab the menu controller
        UIMenuController *colorMenu = [UIMenuController sharedMenuController];
        
        
        NSArray *colors = [NSArray arrayWithObjects:[[UIMenuItem alloc] initWithTitle:@"Black"
                                                                               action:@selector(setLineColorBlack:)],
                           [[UIMenuItem alloc] initWithTitle:@"Purple"
                                                      action:@selector(setLineColorPurple:)],
                           [[UIMenuItem alloc] initWithTitle:@"Orange"
                                                      action:@selector(setLineColorOrange:)],
                           nil];
        
        
        [colorMenu setMenuItems:colors];
        
        // Tell the menu where it should come from
        // and show it
        CGPoint point = [gr locationInView:self];
        [colorMenu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [colorMenu setMenuVisible:YES animated:YES];
    }
}

- (void)setLineColorBlack:(id)sender
{
    lineColor = [UIColor blackColor];
    [self setNeedsDisplay];
}


- (void)setLineColorPurple:(id)sender
{
    lineColor = [UIColor purpleColor];
    [self setNeedsDisplay];
}


- (void)setLineColorOrange:(id)sender
{
    lineColor = [UIColor orangeColor];
    [self setNeedsDisplay];
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    
    // Where the pan recognizer changes its position...
    if ([gr state] == UIGestureRecognizerStateChanged) {
        if ([self selectedLine]) {
            
            // How far as the pan moved?
            CGPoint translation = [gr translationInView:self];
            
            // Add the translation to the current begin and
            // end point of the line
            CGPoint begin = [[self selectedLine] begin];
            CGPoint end = [[self selectedLine] end];
            begin.x += translation.x;
            begin.y += translation.y;
            end.x += translation.x;
            end.y += translation.y;
            
            // Set the new begining and end points of the line
            [[self selectedLine] setBegin:begin];
            [[self selectedLine] setEnd:end];
            
            // Redraw the screen
            [self setNeedsDisplay];
            
            // This makes sense
            [gr setTranslation:CGPointZero inView:self];
        } else {
            //NSLog(@"%f %f", [gr velocityInView:self].x, [gr velocityInView:self].y);
            velocity = hypot([gr velocityInView:self].x, [gr velocityInView:self].y);
            //NSLog(@"%f", velocity);
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == moveRecognizer)
        return YES;
    return NO;
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    [linesInProcess removeAllObjects];
    
    if ([gr state] == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        [self setSelectedLine:[self lineAtPoint:point]];
        
        if ([self selectedLine]) {
            [linesInProcess removeAllObjects];
        }
    } else if ([gr state] == UIGestureRecognizerStateEnded) {
        [self setSelectedLine:nil];
    }
    
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr
{
    
    NSLog(@"Recognized tap");
    
    CGPoint point = [gr locationInView:self];
    [self setSelectedLine:[self lineAtPoint:point]];
    
    // If we just tapped, remove all lines in process
    // so that a tap doesn't result in a new line
    [linesInProcess removeAllObjects];
    
    if ([self selectedLine]) {
        // We will talk about this shortly
        [self becomeFirstResponder];
        
        // Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        [menu setMenuItems:[NSArray arrayWithObject:deleteItem]];
        
        // Tell the menu where it should come from
        // and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO
                                                       animated:YES];
    }
    
    [self setNeedsDisplay];
}

- (void)deleteLine:(id)sender
{
    // Remove the selected line from the list of completeLines
    [completeLines removeObject:[self selectedLine]];
    
    // Redraw everything
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (Line *)lineAtPoint:(CGPoint)p
{
    // Find a line close to p
    for (Line *l in completeLines) {
        CGPoint start = [l begin];
        CGPoint end = [l end];
        
        // Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t*(end.x-start.x);
            float y = start.y + t*(end.y-start.y);
            
            // If the tapped point is within 20 points,
            // let's return this line
            if (hypot(x-p.x, y-p.y) < 20)
                return l;
        }
    }
    
    // If nothing is close enough to the tapped point,
    // then we didn't select a line
    return nil;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // Draw complete lines in black
    [lineColor set];
    for (Line *line in completeLines) {
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    
    // Draw lines in process in red (Don't copy and paste
    // the previous loop; this one is way different)
    [[UIColor redColor] set];
    for (NSValue *v in linesInProcess) {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        double lineThickness = 30 * velocity/3300 + 10;
        CGContextSetLineWidth(context, lineThickness);
        CGContextStrokePath(context);
    }
    
    // If there is a selected line, draw it
    if ([self selectedLine]) {
        [[UIColor greenColor] set];
        CGContextMoveToPoint(context, [[self selectedLine] begin].x,
                             [[self selectedLine] begin].y);
        CGContextAddLineToPoint(context, [[self selectedLine] end].x,
                                [[self selectedLine] end].y);
        CGContextStrokePath(context);
    }
}

- (void)clearAll
{
    // Clear the collections
    [linesInProcess removeAllObjects];
    [completeLines removeAllObjects];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    // Redraw
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        /*
         // Is this a double tap?
         if ([t tapCount] > 1) {
         [self clearAll];
         return;
         }
         */
        
        if (selectedLine) {
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
            selectedLine = nil;
            return;
        }
        
        // Use the touch object (packed in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        NSLog(@"%@", key);
        // Create a line for the value
        CGPoint loc = [t locationInView:self];
        Line *newLine = [[Line alloc] init];
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
