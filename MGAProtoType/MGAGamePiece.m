//
//  MGAGamePiece.m
//  MGAProtoType
//
//  Created by Jordan Gurrieri on 11/14/13.
//  Copyright (c) 2013 bluelabellabs. All rights reserved.
//

#import "MGAGamePiece.h"
#import <QuartzCore/QuartzCore.h>

@implementation MGAGamePiece

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (void)setupGamePieceToReferenceView:(UIView *)view {
//    self.referenceView = view;
//    
//    _originalFrame = self.frame;
//    _originalCenter = self.center;
//    
//    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
//    
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//    [self addGestureRecognizer:pinchGestureRecognizer];
//    
////    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
////    [self addGestureRecognizer:rotationGestureRecognizer];
//}

- (void)makeGamePieceDraggable {
    self.draggable = YES;
    
    self.referenceView = [self superview];
    
    _originalFrame = self.frame;
    _originalCenter = self.center;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
//    [self addGestureRecognizer:rotationGestureRecognizer];
}

#pragma mark - UITouch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!self.draggable)
        return;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Only accept the touch if it is on a non transparent pixel of the image
    if ([self isTouchOnTransparentPixel:[touch locationInView:self]]) {
        _didTouchTransparentPixel = YES;
        return;
    }
    else {
        _didTouchTransparentPixel = NO;
        
        // Make the piece slightly transparent
        [self makeTransparent:YES];
    }
    
    [_animator removeAllBehaviors];
    
    // We only zoom in on the first touch of the piece when it is first selected
    if (!_isScaled) {
        [self zoomGamePieceIn];
        _isScaled = YES;
    }
    
    // Retrieve the touch point
    CGPoint point = [[touches anyObject] locationInView:self];
    _startLocation = point;
    
    // Tell the view controller that the game piece has been selected
    [self.delegate gamePieceTouchBegan:self didTouchAtPoint:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.draggable)
        return;
    
    if (_didTouchTransparentPixel)
        return;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // We only move the game piece when one finger is touching it.
    // This prevents the game piece from jumping around the screen when
    // a second finger touches down to perform the pinch scalling.
    if ([[event allTouches] count] == 1) {
        // Move relative to the original touch point
        CGPoint point = [[touches anyObject] locationInView:self];
        CGRect frame = [self frame];
        frame.origin.x += point.x - _startLocation.x;
        frame.origin.y += point.y - _startLocation.y;
        [self setFrame:frame];
    }
    
    // Tell the view controller that the game piece has been moved
    [self.delegate gamePiece:self didDragToPoint:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (!self.draggable)
        return;
    
    if (_didTouchTransparentPixel)
        return;
    
    // Remove the transparency
    [self makeTransparent:NO];
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Tell the view controller that the game piece has been released
    [self.delegate gamePiece:self didReleaseAtPoint:touchLocation];
}

#pragma mark - UIGestureRecognizer Methods
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _lastScale = recognizer.scale;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[recognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (_lastScale - recognizer.scale); // new scale is in the range (0-1)
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale(recognizer.view.transform, newScale, newScale);
        recognizer.view.transform = transform;
        
        _lastScale = recognizer.scale;  // Store the previous scale factor for the next pinch gesture call
    }
}

//- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
//    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
//    recognizer.rotation = 0;
//}

#pragma mark - Instance Methods
- (BOOL)isTouchOnTransparentPixel:(CGPoint)point {
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGFloat alpha = pixel[3]/255.0;
    BOOL transparent = alpha < 0.01;
    
    return transparent;
}

- (void)makeTransparent:(BOOL)transparent {
    [UIView animateWithDuration:0.125
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (transparent)
                             self.alpha = 0.7;
                         else
                             self.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)zoomGamePieceIn {
    [UIView animateWithDuration:0.125
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, 1.25, 1.25);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)zoomGamePieceOut {
    [UIView animateWithDuration:0.125
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)returnGamePieceToOriginalLocation {
    if(!self.draggable)
        return;
    
    _isScaled = NO;
    [self zoomGamePieceOut];
    
    _snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:_originalCenter];
    [_animator addBehavior:_snapBehavior];
}

- (void)placeGamePieceOnMapTarget:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.frame = self.targetFrameOnMap;
                             
                             [self.referenceView sendSubviewToBack:self];
                         }
                         completion:^(BOOL finished){
                             [_animator removeAllBehaviors];
                         }];
    }
    else {
        self.frame = self.targetFrameOnMap;
        
        [self.referenceView sendSubviewToBack:self];
        
        [_animator removeAllBehaviors];
    }
}

- (void)reset {
    [_animator removeAllBehaviors];
    _isScaled = NO;
    [self zoomGamePieceOut];
    
    self.frame = _originalFrame;
    
    self.userInteractionEnabled = YES;
}

@end
