//
//  MGAViewController.m
//  MGAProtoType
//
//  Created by Jordan Gurrieri on 11/14/13.
//  Copyright (c) 2013 bluelabellabs. All rights reserved.
//

#import "MGAViewController.h"
#import "MGAGamePiece.h"

@interface MGAViewController ()

@property (strong, nonatomic) UILabel *lbl_instruction;

@property (strong, nonatomic) UIImageView *iv_map;

@property (strong, nonatomic) UIImageView *iv_japanPlaceholder;
@property (strong, nonatomic) UIImageView *iv_southKoreaPlaceholder;
@property (strong, nonatomic) UIImageView *iv_northKoreaPlaceholder;

@property (strong, nonatomic) MGAGamePiece *iv_japanGamePiece;
@property (strong, nonatomic) MGAGamePiece *iv_southKoreaGamePiece;
@property (strong, nonatomic) MGAGamePiece *iv_northKoreaGamePiece;

@end

@implementation MGAViewController {
    // Game Piece Meta Data
    float _maxDistanceFromCenter;
    CGPoint _targetPointOnMap;
    CGPoint _targetPointOfGamePiece;
    
    UILabel *_lbl_instruction;
    
    // Various frames for map images
    CGRect _mapFrame;
    
    CGRect _southKoreaPlaceholderFrameOnMap;
    CGRect _northKoreaPlaceholderFrameOnMap;
    CGRect _japanPlaceholderFrameOnMap;
    
    CGRect _southKoreaGamePieceFrameDraggingStep;
    CGRect _northKoreaGamePieceFrameDraggingStep;
    CGRect _japanGamePieceFrameDraggingStep;
    
    NSArray *_gamePieceArray;
    NSArray *_placeholderArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Add the image to the image view properties
    self.iv_map = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_map.png"]];
    
    self.iv_southKoreaPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_SouthKorea.png"]];
    self.iv_northKoreaPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_NorthKorea.png"]];
    self.iv_japanPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_Japan.png"]];
    
    self.iv_southKoreaGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_SouthKorea.png"]];
    self.iv_northKoreaGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_NorthKorea.png"]];
    self.iv_japanGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_Japan.png"]];
    
    
    // Setup the various frames required for the map pieces for use throughout the stage
    _mapFrame = CGRectMake(0.0, 0.0, 754.0, 682.0);
    
    _southKoreaPlaceholderFrameOnMap = CGRectMake(162.0, 326.0, 117.0, 123.0);
    _northKoreaPlaceholderFrameOnMap = CGRectMake(156.0, 219.0, 118.0, 130.0);
    _japanPlaceholderFrameOnMap = CGRectMake(129.0, 152.0, 422.0, 484.0);
    
    _southKoreaGamePieceFrameDraggingStep = CGRectMake(826.0, 151.0, 159.0, 168.0);
    _northKoreaGamePieceFrameDraggingStep = CGRectMake(591.0, 469.0, 139.0, 152.0);
    _japanGamePieceFrameDraggingStep = CGRectMake(748.0, 397.0, 240.0, 276.0);
    
    
    // Apply the inital frame for each map piece
    self.iv_map.frame = _mapFrame;
    
    self.iv_southKoreaPlaceholder.frame = _southKoreaPlaceholderFrameOnMap;
    self.iv_northKoreaPlaceholder.frame = _northKoreaPlaceholderFrameOnMap;
    self.iv_japanPlaceholder.frame = _japanPlaceholderFrameOnMap;
    
    self.iv_southKoreaGamePiece.frame = _southKoreaGamePieceFrameDraggingStep;
    self.iv_northKoreaGamePiece.frame = _northKoreaGamePieceFrameDraggingStep;
    self.iv_japanGamePiece.frame = _japanGamePieceFrameDraggingStep;
    
    _gamePieceArray = [[NSArray alloc] initWithObjects:self.iv_northKoreaGamePiece, self.iv_southKoreaGamePiece, self.iv_japanGamePiece, nil];
    _placeholderArray = [[NSArray alloc] initWithObjects:self.iv_northKoreaPlaceholder, self.iv_southKoreaPlaceholder, self.iv_japanPlaceholder, nil];
    
    // Add the map piece to the view. Order is important because the game pieces need to be on top of other pieces while dragging.
    [self.view addSubview:self.iv_map];
    
    [self.view addSubview:self.iv_southKoreaPlaceholder];
    [self.view addSubview:self.iv_northKoreaPlaceholder];
    [self.view addSubview:self.iv_japanPlaceholder];
    
    [self.view addSubview:self.iv_southKoreaGamePiece];
    [self.view addSubview:self.iv_northKoreaGamePiece];
    [self.view addSubview:self.iv_japanGamePiece];
    
    // TODO: TEMP For now i have only programmed the dragging step. The Stage starts with the animated Intro step.
//    [self setupGamePiecesForDragging];
    [self setupStep1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    float labelHeight = 80.0f;
    CGRect labelFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);    // Put the view off the screen to the bottom
    self.lbl_instruction = [[UILabel alloc] initWithFrame:labelFrame];
    [self.lbl_instruction setBackgroundColor:[UIColor colorWithRed:175.0f/255.0f green:235.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [self.lbl_instruction setTextAlignment:NSTextAlignmentCenter];
    [self.lbl_instruction setTextColor:[UIColor whiteColor]];
    [self.lbl_instruction setFont:[UIFont boldSystemFontOfSize:36.0f]];
    [self.view addSubview:self.lbl_instruction];
    
//    // Animate the view into the screen coming up from the bottom, then disappearing again.
//    void (^nextStep)(void) = ^(void) {
//        [self setupStep1];
//    };
//    
//    [self showInstructionWithText:_instruction completion:nextStep];
    [self startStep1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instruction Label Instance Methods
- (void)showInstructionWithText:(NSString *)text completion:(void (^)(void))completion {
    // Animate the view into the screen coming up from the bottom, then disappearing again.
    [self.lbl_instruction setText:text];
    
    float labelHeight = self.lbl_instruction.frame.size.height;
    CGRect labelFrame = CGRectMake(0.0, self.view.bounds.size.height - labelHeight, self.view.bounds.size.width, labelHeight);
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _lbl_instruction.frame = labelFrame;
                     }
                     completion:^(BOOL finished){
                         CGRect newFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);
                         [UIView animateWithDuration:0.7
                                               delay:5.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _lbl_instruction.frame = newFrame;
                                          }
                                          completion:^(BOOL finished){
                                              if (completion)
                                                  completion();
                                          }];
                     }];
}

#pragma mark - Step 1 (Intro) Instance Methods
- (void)setupStep1 {
    // Apply the inital frame for each map piece
    self.iv_map.frame = _mapFrame;
    
    self.iv_southKoreaPlaceholder.frame = _southKoreaPlaceholderFrameOnMap;
    self.iv_northKoreaPlaceholder.frame = _northKoreaPlaceholderFrameOnMap;
    self.iv_japanPlaceholder.frame = _japanPlaceholderFrameOnMap;
    
    self.iv_southKoreaGamePiece.frame = _southKoreaPlaceholderFrameOnMap;
    self.iv_northKoreaGamePiece.frame = _northKoreaPlaceholderFrameOnMap;
    self.iv_japanGamePiece.frame = _japanPlaceholderFrameOnMap;
    
    [self.view sendSubviewToBack:self.iv_southKoreaGamePiece];
    [self.view sendSubviewToBack:self.iv_northKoreaGamePiece];
    [self.view sendSubviewToBack:self.iv_japanGamePiece];
}

- (void)introduceGamePiece:(MGAGamePiece *)gamePiece
           withPlaceholder:(UIImageView *)placeholder
                 withScale:(float)scale
                  withText:(NSString *)text
                completion:(void (^)(void))completion
{
    CGPoint originalCenterGamePiece = gamePiece.center;
    CGPoint originalCenterPlaceholder = placeholder.center;
    
    [self.lbl_instruction setText:text];
    
    float labelHeight = self.lbl_instruction.frame.size.height;
    CGRect newLabelFrame = CGRectMake(0.0, self.view.bounds.size.height - labelHeight, self.view.bounds.size.width, labelHeight);
    
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.iv_map.alpha = 0.0f;
                         
                         for (MGAGamePiece *otherGamePiece in _gamePieceArray) {
                             if (otherGamePiece != gamePiece) {
                                 otherGamePiece.alpha = 0.0f;
                             }
                         }
                         
                         for (UIImageView *otherPlaceholder in _placeholderArray) {
                             if (otherPlaceholder != placeholder) {
                                 otherPlaceholder.alpha = 0.0f;
                             }
                         }
                         
                         gamePiece.center = self.view.center;
                         gamePiece.transform = CGAffineTransformScale(gamePiece.transform, scale, scale);
                         
                         placeholder.center = self.view.center;
                         placeholder.transform = CGAffineTransformScale(placeholder.transform, scale, scale);
                         
                         _lbl_instruction.frame = newLabelFrame;
                     }
                     completion:^(BOOL finished){
                         CGRect newLabelFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);
                         
                         [UIView animateWithDuration:0.7
                                               delay:5.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.iv_map.alpha = 1.0f;
                                              
                                              for (MGAGamePiece *otherGamePiece in _gamePieceArray) {
                                                  if (otherGamePiece != gamePiece) {
                                                      otherGamePiece.alpha = 1.0f;
                                                  }
                                              }
                                              
                                              for (UIImageView *otherPlaceholder in _placeholderArray) {
                                                  if (otherPlaceholder != placeholder) {
                                                      otherPlaceholder.alpha = 1.0f;
                                                  }
                                              }
                                              
                                              gamePiece.center = originalCenterGamePiece;
                                              gamePiece.transform = CGAffineTransformIdentity;
                                              
                                              placeholder.center = originalCenterPlaceholder;
                                              placeholder.transform = CGAffineTransformIdentity;
                                              
                                              _lbl_instruction.frame = newLabelFrame;
                                          }
                                          completion:^(BOOL finished){
                                              if (completion)
                                                  completion();
                                          }];
                     }];
}

- (void)startStep1 {
    // Of every game piece we create a completion block that will instruct
    // the view control to introduce the next game piece. The last game piece
    // has no completion handler.
    
    void (^nextStep)(void) = ^(void) {
        [self startStep3];
    };
    
    void (^showJapan)(void) = ^(void) {
        [self introduceGamePiece:self.iv_japanGamePiece
                 withPlaceholder:self.iv_japanPlaceholder
                       withScale:1.25
                        withText:@"This is Japan"
                      completion:nextStep];
    };
    
    void (^showSouthKorea)(void) = ^(void) {
        [self introduceGamePiece:self.iv_southKoreaGamePiece
                 withPlaceholder:self.iv_southKoreaPlaceholder
                       withScale:2.0
                        withText:@"This is South Korea"
                      completion:showJapan];
    };
    
    // We start with the first game piece in the stage. We hide the map at the same time.
    [self introduceGamePiece:self.iv_northKoreaGamePiece
             withPlaceholder:self.iv_northKoreaPlaceholder
                   withScale:2.0
                    withText:@"This is North Korea"
                  completion:showSouthKorea];
}


#pragma mark - Step 2 (Taping - No Map) Instance Methods


#pragma mark - Step 3 (Dragging - On Map) Instance Methods
- (void)startStep3 {
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.iv_southKoreaGamePiece.frame = _southKoreaGamePieceFrameDraggingStep;
                         self.iv_northKoreaGamePiece.frame = _northKoreaGamePieceFrameDraggingStep;
                         self.iv_japanGamePiece.frame = _japanGamePieceFrameDraggingStep;
                     }
                     completion:^(BOOL finished){
                         [self setupGamePiecesForDragging];
                         
                         [self showInstructionWithText:@"Show me where these go" completion:nil];
                     }];
}

- (void)setupGamePiecesForDragging {
    [self.iv_southKoreaGamePiece makeGamePieceDraggable];
    self.iv_southKoreaGamePiece.delegate = self;
    self.iv_southKoreaGamePiece.targetCenterOnMap = self.iv_southKoreaPlaceholder.center;
    self.iv_southKoreaGamePiece.targetFrameOnMap = _southKoreaPlaceholderFrameOnMap;
    _maxDistanceFromCenter = 50.0f;
    
    [self.iv_northKoreaGamePiece makeGamePieceDraggable];
    self.iv_northKoreaGamePiece.delegate = self;
    self.iv_northKoreaGamePiece.targetCenterOnMap = self.iv_northKoreaPlaceholder.center;
    self.iv_northKoreaGamePiece.targetFrameOnMap = _northKoreaPlaceholderFrameOnMap;
    _maxDistanceFromCenter = 50.0f;
    
    [self.iv_japanGamePiece makeGamePieceDraggable];
    self.iv_japanGamePiece.delegate = self;
    self.iv_japanGamePiece.targetCenterOnMap = self.iv_japanPlaceholder.center;
    self.iv_japanGamePiece.targetFrameOnMap = _japanPlaceholderFrameOnMap;
    _maxDistanceFromCenter = 50.0f;
}


#pragma mark - Step 4 (Taping - On Map) Instance Methods



#pragma mark - MGAGamePieceDelegate Methods
- (void)gamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point {
    
}

- (void)gamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point {
    
}

- (void)gamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point {
    CGPoint p1 = gamePiece.targetCenterOnMap;
    CGPoint p2 = gamePiece.center;
    
    CGFloat targetDistance = _maxDistanceFromCenter;
    
    CGFloat distanceCenters = hypotf(p1.x - p2.x, p1.y - p2.y);
    
    if (distanceCenters <= targetDistance) {
        [gamePiece placeGamePieceOnMapTarget:YES];
        
        // Disable further interation with the game piece
        [gamePiece setUserInteractionEnabled:NO];
    }
    else {
        [gamePiece returnGamePieceToOriginalLocation];
    }
}

- (IBAction)onResetButtonPressed:(id)sender {
    [self.iv_japanGamePiece reset];
    [self.iv_northKoreaGamePiece reset];
    [self.iv_southKoreaGamePiece reset];
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
