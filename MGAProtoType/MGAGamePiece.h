//
//  MGAGamePiece.h
//  MGAProtoType
//
//  Created by Jordan Gurrieri on 11/14/13.
//  Copyright (c) 2013 bluelabellabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGAGamePiece;

@protocol MGAGamePieceDelegate <NSObject>
@required
- (void)draggableGamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point;
- (void)draggableGamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point;
- (void)draggableGamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point;
- (void)gamePiecePlacedOnTarget:(MGAGamePiece *)gamePiece;
- (void)gamePieceReturnedToOriginalLocation:(MGAGamePiece *)gamePiece;

- (void)tappableGamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point;
- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point;
- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point;
- (void)gamePieceBounceDidComplete:(MGAGamePiece *)gamePiece;
- (void)gamePieceShakeDidComplete:(MGAGamePiece *)gamePiece;

@end

@interface MGAGamePiece : UIImageView < UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate > {
    UIDynamicAnimator *_animator;
    UISnapBehavior *_snapBehavior;
    UIAttachmentBehavior *_touchAttachmentBehavior;
    
//    CGRect _originalFrame;
    CGPoint _originalCenter;
    
    CGPoint _startLocation;
    
    BOOL _didTouchTransparentPixel;
    BOOL _isScaled;
    float _lastScale;
}

@property (weak, nonatomic) id <MGAGamePieceDelegate> delegate;

@property (nonatomic, strong) UIView *referenceView;
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) BOOL tappable;

// Game Piece Properties From Dictionary
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float scaleStep2;
@property (nonatomic, assign) float maxDistanceFromCenterStep3;
@property (nonatomic, strong) UIImage *image_placeholder;
@property (nonatomic, strong) UIImage *image_active;
@property (nonatomic, strong) UIImage *image_inactive;
@property (nonatomic, strong) UIImageView *placeholder;
@property (nonatomic) CGRect frameStep1;
@property (nonatomic) CGRect frameStep2;
@property (nonatomic) CGRect frameStep3Placeholder;
@property (nonatomic) CGRect frameStep3GamePiece;
@property (nonatomic) CGRect frameStep4;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithImage:(UIImage *)image;
- (void)makeGamePieceDraggable;
- (void)makeGamePieceTappableWithCenter:(CGPoint)center;
- (void)returnGamePieceToOriginalLocation;
- (void)placeGamePieceOnMapTarget:(BOOL)animated;
- (void)shakeGamePiece;
- (void)bounceGamePiece;
- (void)reset;

@end
