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
- (void)gamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point;
- (void)gamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point;
- (void)gamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point;
@end

@interface MGAGamePiece : UIImageView < UIGestureRecognizerDelegate > {
    UIDynamicAnimator *_animator;
    UISnapBehavior *_snapBehavior;
    UIAttachmentBehavior *_touchAttachmentBehavior;
    
    CGRect _originalFrame;
    CGPoint _originalCenter;
    
    CGPoint _startLocation;
    
    BOOL _didTouchTransparentPixel;
    BOOL _isScaled;
    float _lastScale;
}

@property (weak, nonatomic) id <MGAGamePieceDelegate> delegate;

@property (nonatomic, strong) UIView *referenceView;
@property (nonatomic) CGPoint targetCenterOnMap;
@property (nonatomic) CGRect targetFrameOnMap;
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) BOOL tappable;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithImage:(UIImage *)image;
- (void)makeGamePieceDraggable;
//- (void)setupGamePieceToReferenceView:(UIView *)view;
- (void)returnGamePieceToOriginalLocation;
- (void)placeGamePieceOnMapTarget:(BOOL)animated;
- (void)reset;

@end
