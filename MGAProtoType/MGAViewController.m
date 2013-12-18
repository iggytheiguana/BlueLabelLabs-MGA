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
    
    NSMutableArray *_placeholderArray;
    
    
    // NEW
    NSDictionary *_stageDataDictionary;
    NSDictionary *_stageMapDataDictionary;
    NSMutableArray *_gamePieceArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // We need to extract the properties of the stage from the plist file.
    NSString* plistsource = [[NSBundle mainBundle] pathForResource:@"MGAPropertyList" ofType:@"plist"];
    NSArray *temp = [NSArray arrayWithContentsOfFile:plistsource];
    
    // Now that we have a temporary array of all the stages and data,
    // we grab the stage dictionary we are interested in and setup the properties.
    int stageIndex = 0;
    _stageDataDictionary = [temp objectAtIndex:stageIndex];
    
    // First setup the map for this stage.
    _stageMapDataDictionary = [_stageDataDictionary objectForKey:@"map"];
    self.iv_map = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_stageMapDataDictionary objectForKey:@"map_image_filename"]]];
    
    // Next, setup the game pieces and placeholders for each country.
    NSArray *countries = [_stageDataDictionary objectForKey:@"countries"];
    _gamePieceArray = [[NSMutableArray alloc] initWithCapacity:[countries count]];
    
    for (NSDictionary *countryDictionary in countries) {
        UIImage *activeImage = [UIImage imageNamed:[countryDictionary objectForKey:@"active_image_filename"]];
        UIImage *inactiveImage = [UIImage imageNamed:[countryDictionary objectForKey:@"inactive_image_filename"]];
        UIImage *placeholderImage = [UIImage imageNamed:[countryDictionary objectForKey:@"placeholder_image_filename"]];
        
        MGAGamePiece *gamePiece = [[MGAGamePiece alloc] initWithImage:inactiveImage];
        gamePiece.delegate = self;
        
        UIImageView *placeholderImageView = [[UIImageView alloc] initWithImage:placeholderImage];
        gamePiece.placeholder = placeholderImageView;
        
        gamePiece.image_active = activeImage;
        gamePiece.image_inactive = inactiveImage;
        gamePiece.image_placeholder = placeholderImage;
        
        gamePiece.name = [countryDictionary objectForKey:@"name"];
        gamePiece.scaleStep2 = [[countryDictionary objectForKey:@"scaleStep2"] floatValue];
        gamePiece.maxDistanceFromCenterStep3 = [[countryDictionary objectForKey:@"maxDistanceFromCenterStep3"] floatValue];
        
        // Get the various frames for this game piece
        NSDictionary *frames = [countryDictionary objectForKey:@"frames"];
        
        NSDictionary *frameStep1 = [frames objectForKey:@"frameStep1"];
        gamePiece.frameStep1 = CGRectMake([[frameStep1 objectForKey:@"x"] floatValue],
                                       [[frameStep1 objectForKey:@"y"] floatValue],
                                       [[frameStep1 objectForKey:@"width"] floatValue],
                                       [[frameStep1 objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep2 = [frames objectForKey:@"frameStep2"];
        gamePiece.frameStep2 = CGRectMake([[frameStep2 objectForKey:@"x"] floatValue],
                                          [[frameStep2 objectForKey:@"y"] floatValue],
                                          [[frameStep2 objectForKey:@"width"] floatValue],
                                          [[frameStep2 objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep3Placeholder = [frames objectForKey:@"frameStep3Placeholder"];
        gamePiece.frameStep3Placeholder = CGRectMake([[frameStep3Placeholder objectForKey:@"x"] floatValue],
                                          [[frameStep3Placeholder objectForKey:@"y"] floatValue],
                                          [[frameStep3Placeholder objectForKey:@"width"] floatValue],
                                          [[frameStep3Placeholder objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep3GamePiece = [frames objectForKey:@"frameStep3GamePiece"];
        gamePiece.frameStep3GamePiece = CGRectMake([[frameStep3GamePiece objectForKey:@"x"] floatValue],
                                          [[frameStep3GamePiece objectForKey:@"y"] floatValue],
                                          [[frameStep3GamePiece objectForKey:@"width"] floatValue],
                                          [[frameStep3GamePiece objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep4 = [frames objectForKey:@"frameStep4"];
        gamePiece.frameStep4 = CGRectMake([[frameStep4 objectForKey:@"x"] floatValue],
                                          [[frameStep4 objectForKey:@"y"] floatValue],
                                          [[frameStep4 objectForKey:@"width"] floatValue],
                                          [[frameStep4 objectForKey:@"height"] floatValue]);
        
        [_gamePieceArray addObject:gamePiece];
    }
    
    
//    // Add the image to the image view properties
//    self.iv_map = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_map.png"]];
//    
//    self.iv_southKoreaPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_SouthKorea.png"]];
//    self.iv_northKoreaPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_NorthKorea.png"]];
//    self.iv_japanPlaceholder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stage1_placeholder_Japan.png"]];
//    
//    self.iv_southKoreaGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_SouthKorea.png"] withPlaceholder:self.iv_southKoreaPlaceholder];
//    self.iv_southKoreaGamePiece.delegate = self;
//    self.iv_northKoreaGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_NorthKorea.png"] withPlaceholder:self.iv_northKoreaPlaceholder];
//    self.iv_northKoreaGamePiece.delegate = self;
//    self.iv_japanGamePiece = [[MGAGamePiece alloc] initWithImage:[UIImage imageNamed:@"stage1_gamepiece_Japan.png"] withPlaceholder:self.iv_japanPlaceholder];
//    self.iv_japanGamePiece.delegate = self;
//    
//    
//    // Setup the various frames required for the map pieces for use throughout the stage
//    _mapFrame = CGRectMake(0.0, 0.0, 754.0, 682.0);
//    
//    _southKoreaPlaceholderFrameOnMap = CGRectMake(162.0, 326.0, 117.0, 123.0);
//    _northKoreaPlaceholderFrameOnMap = CGRectMake(156.0, 219.0, 118.0, 130.0);
//    _japanPlaceholderFrameOnMap = CGRectMake(129.0, 152.0, 422.0, 484.0);
//    
//    _southKoreaGamePieceFrameDraggingStep = CGRectMake(826.0, 151.0, 159.0, 168.0);
//    _northKoreaGamePieceFrameDraggingStep = CGRectMake(591.0, 469.0, 139.0, 152.0);
//    _japanGamePieceFrameDraggingStep = CGRectMake(748.0, 397.0, 240.0, 276.0);
    
    
//    // Apply the inital frame for each map piece
//    self.iv_map.frame = _mapFrame;
//    
//    self.iv_southKoreaPlaceholder.frame = _southKoreaPlaceholderFrameOnMap;
//    self.iv_northKoreaPlaceholder.frame = _northKoreaPlaceholderFrameOnMap;
//    self.iv_japanPlaceholder.frame = _japanPlaceholderFrameOnMap;
//    
//    self.iv_southKoreaGamePiece.frame = _southKoreaGamePieceFrameDraggingStep;
//    self.iv_northKoreaGamePiece.frame = _northKoreaGamePieceFrameDraggingStep;
//    self.iv_japanGamePiece.frame = _japanGamePieceFrameDraggingStep;
//    
//    _gamePieceArray = [[NSArray alloc] initWithObjects:self.iv_northKoreaGamePiece, self.iv_southKoreaGamePiece, self.iv_japanGamePiece, nil];
//    _placeholderArray = [[NSArray alloc] initWithObjects:self.iv_northKoreaPlaceholder, self.iv_southKoreaPlaceholder, self.iv_japanPlaceholder, nil];
//    
//    // Add the map piece to the view. Order is important because the game pieces need to be on top of other pieces while dragging.
//    [self.view addSubview:self.iv_map];
//    
//    [self.view addSubview:self.iv_southKoreaPlaceholder];
//    [self.view addSubview:self.iv_northKoreaPlaceholder];
//    [self.view addSubview:self.iv_japanPlaceholder];
//    
//    [self.view addSubview:self.iv_southKoreaGamePiece];
//    [self.view addSubview:self.iv_northKoreaGamePiece];
//    [self.view addSubview:self.iv_japanGamePiece];
    
    // TODO: TEMP For now i have only programmed the dragging step. The Stage starts with the animated Intro step.
//    [self setupGamePiecesForDragging];
    [self setupStep1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Setup the UILabel for the instruction text.
    float labelHeight = 80.0f;
    CGRect labelFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);    // Put the view off the screen to the bottom
    self.lbl_instruction = [[UILabel alloc] initWithFrame:labelFrame];
    [self.lbl_instruction setBackgroundColor:[UIColor colorWithRed:175.0f/255.0f green:235.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [self.lbl_instruction setTextAlignment:NSTextAlignmentCenter];
    [self.lbl_instruction setTextColor:[UIColor whiteColor]];
    [self.lbl_instruction setFont:[UIFont boldSystemFontOfSize:36.0f]];
    [self.view addSubview:self.lbl_instruction];
    
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
    NSDictionary *mapFrame = [[[_stageDataDictionary objectForKey:@"map"] objectForKey:@"frames"] objectForKey:@"frameStep1"];
    self.iv_map.frame = CGRectMake([[mapFrame objectForKey:@"x"] floatValue],
                                   [[mapFrame objectForKey:@"y"] floatValue],
                                   [[mapFrame objectForKey:@"width"] floatValue],
                                   [[mapFrame objectForKey:@"height"] floatValue]);
    [self.view addSubview:self.iv_map];
    
    // Apply the frame for step 1 for each game piece
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        gamePiece.image = gamePiece.image_inactive;
        gamePiece.frame = gamePiece.frameStep1;
        gamePiece.placeholder.frame = gamePiece.frameStep1;
        gamePiece.placeholder.alpha = 0.0;
        
        [self.view addSubview:gamePiece];
        [self.view addSubview:gamePiece.placeholder];
    }
}

- (void)introduceGamePiece:(MGAGamePiece *)gamePiece
                 withScale:(float)scale
                  withText:(NSString *)text
                completion:(void (^)(void))completion
{
    CGPoint originalCenterGamePiece = gamePiece.center;
    
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
                                 otherGamePiece.placeholder.alpha = 0.0f;
                             }
                         }
                         
                         gamePiece.center = self.view.center;
                         gamePiece.transform = CGAffineTransformScale(gamePiece.transform, scale, scale);
                         
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
                                              
                                              gamePiece.center = originalCenterGamePiece;
                                              gamePiece.transform = CGAffineTransformIdentity;
                                              
                                              _lbl_instruction.frame = newLabelFrame;
                                          }
                                          completion:^(BOOL finished){
                                              if (completion)
                                                  completion();
                                          }];
                     }];
}

- (void)startStep1 {
    // For every game piece we create a completion block that will instruct
    // the viewController to introduce the next game piece.
    // The last game piece has no completion handler.
    
    int gamePieceCount = [_gamePieceArray count];
    
    NSMutableArray *completionBlocks = [[NSMutableArray alloc] initWithCapacity:gamePieceCount];
    
    void (^lastBlock)(void) = ^(void) {
        [self endStep1];
    };
    [completionBlocks addObject:lastBlock];
    
    int blockIndex = 0;
    for (int i = gamePieceCount - 1; i > 0; i--) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        void (^completionBlock)(void) = ^(void) {
            [self introduceGamePiece:gamePiece
                           withScale:gamePiece.scaleStep2
                            withText:[NSString stringWithFormat:@"This is %@", gamePiece.name]
                          completion:[completionBlocks objectAtIndex:blockIndex]];
        };
        
        [completionBlocks addObject:completionBlock];
        blockIndex++;
    }
    NSArray* reversedCompletionBlocks = [[completionBlocks reverseObjectEnumerator] allObjects];
    
    // We start with the first game piece in the stage. We hide the map at the same time.
    MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:0];
    [self introduceGamePiece:gamePiece
                   withScale:gamePiece.scaleStep2
                    withText:[NSString stringWithFormat:@"This is %@", gamePiece.name]
                  completion:[reversedCompletionBlocks objectAtIndex:0]];
}

- (void)endStep1 {
    // Fade out the current view to prepare fro step 2.
    [UIView animateWithDuration:0.35
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.iv_map.alpha = 0.0f;
                         
                         for (MGAGamePiece *gamePiece in _gamePieceArray) {
                             gamePiece.alpha = 0.0f;
                             gamePiece.placeholder.alpha = 0.0f;
                         }
                     }
                     completion:^(BOOL finished){
                         [self startStep2];
                     }];
}

#pragma mark - Step 2 (Taping - No Map) Instance Methods
- (void)startStep2 {
    // Move the game pieces to the top off the screen, off the screen
    // so they can drop into place to begin the next step.
    
    int gamePieceCount = [_gamePieceArray count];
    
    // TODO: Layout currently only supports 1 row of pieces. Need a more scalable solution for when 3+ pieces are shown.
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        gamePiece.image = gamePiece.image_active;
        gamePiece.frame = gamePiece.frameStep2;
        gamePiece.center = CGPointMake((i+i+1)*(self.view.bounds.size.width / (2*gamePieceCount)), -(self.view.bounds.size.height/2));
        gamePiece.alpha = 1.0f;
        [gamePiece setUserInteractionEnabled:NO];
    }
    
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        CGPoint center = CGPointMake(gamePiece.center.x, self.view.bounds.size.height/2);
        [gamePiece makeGamePieceTappableWithCenter:center];
        
        [gamePiece performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0];
    }
    
    // TODO: Randomize step 2 and shuffle until all countries are identified.
    [self showInstructionWithText:@"Show me South Korea" completion:nil];
}

#pragma mark - Step 3 (Dragging - On Map) Instance Methods
- (void)startStep3 {
    // Setup game pieces for dragging step and move them to their starting location on the screen.
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.iv_map.alpha = 1.0f;
                         
                         for (MGAGamePiece *gamePiece in _gamePieceArray) {
                             gamePiece.image = gamePiece.image_active;
                             gamePiece.alpha = 1.0f;
                             gamePiece.placeholder.alpha = 1.0f;
                             
                             gamePiece.frame = gamePiece.frameStep3GamePiece;
                             gamePiece.placeholder.frame = gamePiece.frameStep3Placeholder;
                             
                             [self.view bringSubviewToFront:gamePiece];
                         }
                     }
                     completion:^(BOOL finished){
                         [self setupGamePiecesForDragging];
                         
                         [self showInstructionWithText:@"Show me where these go" completion:nil];
                     }];
}

- (void)setupGamePiecesForDragging {
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [gamePiece makeGamePieceDraggable];
    }
}


#pragma mark - Step 4 (Taping - On Map) Instance Methods
- (void)startStep4 {
    // Game pieces should now be in their proper postions on the map.
    // Make them tappable for this step.
    
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [gamePiece makeGamePieceTappableWithCenter:gamePiece.center];
        gamePiece.image = gamePiece.image_active;
        
        [gamePiece setUserInteractionEnabled:YES];
    }
    
    [self showInstructionWithText:@"Show me South Korea" completion:nil];
}


#pragma mark - MGAGamePieceDelegate Draggable Game Piece Methods
- (void)draggableGamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point {
    [self.view bringSubviewToFront:gamePiece];
}

- (void)draggableGamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point {
    
}

- (void)draggableGamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point {
    CGPoint p1 = gamePiece.placeholder.center;
    CGPoint p2 = gamePiece.center;
    
    CGFloat targetDistance = gamePiece.maxDistanceFromCenterStep3;
    
    CGFloat distanceCenters = hypotf(p1.x - p2.x, p1.y - p2.y);
    
    if (distanceCenters <= targetDistance) {
        [gamePiece placeGamePieceOnMapTarget:YES];
        
        // Disable further interation with the game piece
        [gamePiece setUserInteractionEnabled:NO];
        
        if ([gamePiece.name isEqualToString:@"South Korea"]) {
            [self startStep4];
        }
    }
    else {
        [gamePiece returnGamePieceToOriginalLocation];
    }
}

- (void)gamePiecePlacedOnTarget:(MGAGamePiece *)gamePiece {
    [self startStep4];
}

- (void)gamePieceReturnedToOriginalLocation:(MGAGamePiece *)gamePiece {
    
}

#pragma mark - MGAGamePieceDelegate Tappable Game Piece Methods
- (void)tappableGamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point {
    
}

- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point {
    
}

- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point {
    if ([gamePiece.name isEqualToString:@"South Korea"]) {
        [gamePiece bounceGamePiece];
    }
    else {
        [gamePiece shakeGamePiece];
    }
}

- (void)gamePieceBounceDidComplete:(MGAGamePiece *)gamePiece {
    [self startStep3];
}

- (void)gamePieceShakeDidComplete:(MGAGamePiece *)gamePiece {
    
}

#pragma mark - Navigation Methods
- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
