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
        
        self.referenceView = [self superview];
        
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

- (void)makeGamePieceDraggable {
    self.draggable = YES;
    self.tappable = NO;
    
    _originalCenter = self.center;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    _animator.delegate = self;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
}

- (void)makeGamePieceTappableWithCenter:(CGPoint)center {
    self.tappable = YES;
    self.draggable = NO;
    
    _originalCenter = center;
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    _snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:_originalCenter];
    _snapBehavior.damping = 1.25;
    [_animator addBehavior:_snapBehavior];
}

#pragma mark - UITouch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event allTouches] anyObject];
    
    // Only accept the touch if it is on a non transparent pixel of the image
    if ([self isTouchOnTransparentPixel:[touch locationInView:self]]) {
        _didTouchTransparentPixel = YES;
        
        // We need to pass the touch through to the next responder incase
        // there is another game piece within this transparent area.
        [self.delegate gamePieceDidTouchTransparentPixel:self touchesBegan:touches withEvent:event];
        return;
    }
    else {
        _didTouchTransparentPixel = NO;
    }
    
    if (self.draggable)
        [self draggableGamePieceTouchesBegan:touches withEvent:event];
    else if (self.tappable)
        [self tappableGamePieceTouchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (_didTouchTransparentPixel) {
        [self.delegate gamePieceDidTouchTransparentPixel:self touchesMoved:touches withEvent:event];
         return;
    }
    
    if (self.draggable)
        [self draggableGamePieceTouchesMoved:touches withEvent:event];
    else if (self.tappable)
        [self tappableGamePieceTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_didTouchTransparentPixel) {
        [self.delegate gamePieceDidTouchTransparentPixel:self touchesEnded:touches withEvent:event];
        return;
    }
    
    if (self.draggable)
        [self draggableGamePieceTouchesEnded:touches withEvent:event];
    else if (self.tappable)
        [self tappableGamePieceTouchesEnded:touches withEvent:event];
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

#pragma mark - Common Instance Methods
- (void)hideLabel {
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.lbl_name.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)showLabel {
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.lbl_name.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

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

- (void)shakeGamePiece {
    self.image = self.image_placeholder;
    
    [UIView animateWithDuration:0.125
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformTranslate(self.transform, -20.0f, 0.0f);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.125
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.transform = CGAffineTransformTranslate(self.transform, 40.0f, 0.0f);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.125
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   self.transform = CGAffineTransformTranslate(self.transform, -40.0f, 0.0f);
                                                               }
                                                               completion:^(BOOL finished){
                                                                   [UIView animateWithDuration:0.125
                                                                                         delay:0.0
                                                                                       options:UIViewAnimationOptionCurveEaseInOut
                                                                                    animations:^{
                                                                                        self.transform = CGAffineTransformIdentity;
                                                                                    }
                                                                                    completion:^(BOOL finished){
                                                                                        self.image = self.image_active;
                                                                                        
                                                                                        [self.delegate gamePieceShakeDidComplete:self];
                                                                                    }];
                                                               }];
                                          }];
                     }];
}

- (void)bounceGamePiece {
    self.image = self.image_inactive;
    
    [UIView animateWithDuration:0.125
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformTranslate(self.transform, 0.0f, -20.0f);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.125
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.transform = CGAffineTransformTranslate(self.transform, 0.0f, 40.0f);
                                          }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:0.125
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                               animations:^{
                                                                   self.transform = CGAffineTransformTranslate(self.transform, 0.0f, -40.0f);
                                                               }
                                                               completion:^(BOOL finished){
                                                                   [UIView animateWithDuration:0.125
                                                                                         delay:0.0
                                                                                       options:UIViewAnimationOptionCurveEaseInOut
                                                                                    animations:^{
                                                                                        self.transform = CGAffineTransformIdentity;
                                                                                    }
                                                                                    completion:^(BOOL finished){
                                                                                        self.image = self.image_active;
                                                                                        
                                                                                        [self.delegate gamePieceBounceDidComplete:self];
                                                                                    }];
                                                               }];
                                          }];
                     }];
}

#pragma mark - Draggable Instance Methods
- (void)draggableGamePieceTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
        
    // Make the piece slightly transparent
    [self makeTransparent:YES];
    
    // Hide the label
    [self hideLabel];
    
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
    [self.delegate draggableGamePieceTouchBegan:self didTouchAtPoint:touchLocation];
}

- (void)draggableGamePieceTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    [self.delegate draggableGamePiece:self didDragToPoint:touchLocation];
}

- (void)draggableGamePieceTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Remove the transparency
    [self makeTransparent:NO];
    
    // Tell the view controller that the game piece has been released
    [self.delegate draggableGamePiece:self didReleaseAtPoint:touchLocation];
}

- (void)returnGamePieceToOriginalLocation {
    if(!self.draggable)
        return;
    
    _isScaled = NO;
    [self zoomGamePieceOut];
    
    _snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:_originalCenter];
    [_animator addBehavior:_snapBehavior];
    
    // Show the label
    [self showLabel];
    
    [self.delegate gamePieceReturnedToOriginalLocation:self];
}

- (void)placeGamePieceOnMapTarget:(BOOL)animated {
    _isScaled = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                             self.frame = self.placeholder.frame;
                             
                             self.image = self.image_inactive;
                         }
                         completion:^(BOOL finished){
                             self.placeholder.alpha = 0.0;
                             
                             [_animator removeAllBehaviors];
                             
                             [self.delegate gamePiecePlacedOnTarget:self];
                         }];
    }
    else {
        self.transform = CGAffineTransformIdentity;
        self.frame = self.placeholder.frame;
        
        self.image = self.image_inactive;
        
        self.placeholder.alpha = 0.0;
        
        [_animator removeAllBehaviors];
        
        [self.delegate gamePiecePlacedOnTarget:self];
    }
}

#pragma mark - Draggable Instance Methods
- (void)tappableGamePieceTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Tell the view controller that the game piece has been selected
    [self.delegate tappableGamePieceTouchBegan:self didTouchAtPoint:touchLocation];
}

- (void)tappableGamePieceTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Tell the view controller that the game piece has been moved
    [self.delegate tappableGamePiece:self didDragToPoint:touchLocation];
}

- (void)tappableGamePieceTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.referenceView];
    
    // Tell the view controller that the game piece has been released
    [self.delegate tappableGamePiece:self didReleaseAtPoint:touchLocation];
}

@end
