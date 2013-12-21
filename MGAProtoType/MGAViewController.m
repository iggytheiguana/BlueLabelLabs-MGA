//
//  MGAViewController.m
//  MGAProtoType
//
//  Created by Jordan Gurrieri on 11/14/13.
//  Copyright (c) 2013 bluelabellabs. All rights reserved.
//

#import "MGAViewController.h"
#import "MGAStages.h"
#import "MGAStageSteps.h"
#import "MGAGamePiece.h"
#import "NSMutableArray+Shuffling.h"

@interface MGAViewController ()

@property (strong, nonatomic) UILabel *lbl_instruction;
@property (strong, nonatomic) UIImageView *iv_map;

@end

@implementation MGAViewController {
    NSDictionary *_stageDataDictionary;
    NSDictionary *_stageMapDataDictionary;
    NSMutableArray *_gamePieceArray;
    
    int _currentStage;
    int _currentStep;
    int _currentGamePieceIndex;
    
    NSMutableArray *_gamePiecesCompletedInCurrentStep;
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
    _currentStage = kSTAGE0;
    _stageDataDictionary = [temp objectAtIndex:_currentStage];
    
    // First setup the map for this stage.
    _stageMapDataDictionary = [_stageDataDictionary objectForKey:@"map"];
    self.iv_map = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_stageMapDataDictionary objectForKey:@"map_image_filename"]]];
    
    // Next, setup the game pieces and placeholders for each country.
    NSArray *countries = [_stageDataDictionary objectForKey:@"countries"];
    _gamePieceArray = [[NSMutableArray alloc] initWithCapacity:[countries count]];
    _gamePiecesCompletedInCurrentStep = [[NSMutableArray alloc] initWithCapacity:[countries count]];
    
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
        gamePiece.scaleStep0 = [[countryDictionary objectForKey:@"scaleStep0"] floatValue];
        gamePiece.maxDistanceFromCenterStep2 = [[countryDictionary objectForKey:@"maxDistanceFromCenterStep2"] floatValue];
        
        // Setup the game piece label. We will position it on the screen later.
        UILabel *gamePieceLabel = [[UILabel alloc] init];
        [gamePieceLabel setTextAlignment:NSTextAlignmentCenter];
        [gamePieceLabel setTextColor:[UIColor blackColor]];
        [gamePieceLabel setFont:[UIFont systemFontOfSize:24.0f]];
        [gamePieceLabel setText:gamePiece.name];
        [gamePieceLabel sizeToFit];
        gamePiece.lbl_name = gamePieceLabel;
        
        // Get the various frames for this game piece
        NSDictionary *frames = [countryDictionary objectForKey:@"frames"];
        
        NSDictionary *frameStep0 = [frames objectForKey:@"frameStep0"];
        gamePiece.frameStep0 = CGRectMake([[frameStep0 objectForKey:@"x"] floatValue],
                                       [[frameStep0 objectForKey:@"y"] floatValue],
                                       [[frameStep0 objectForKey:@"width"] floatValue],
                                       [[frameStep0 objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep1 = [frames objectForKey:@"frameStep1"];
        gamePiece.frameStep1 = CGRectMake([[frameStep1 objectForKey:@"x"] floatValue],
                                          [[frameStep1 objectForKey:@"y"] floatValue],
                                          [[frameStep1 objectForKey:@"width"] floatValue],
                                          [[frameStep1 objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep2Placeholder = [frames objectForKey:@"frameStep2Placeholder"];
        gamePiece.frameStep2Placeholder = CGRectMake([[frameStep2Placeholder objectForKey:@"x"] floatValue],
                                          [[frameStep2Placeholder objectForKey:@"y"] floatValue],
                                          [[frameStep2Placeholder objectForKey:@"width"] floatValue],
                                          [[frameStep2Placeholder objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep2GamePiece = [frames objectForKey:@"frameStep2GamePiece"];
        gamePiece.frameStep2GamePiece = CGRectMake([[frameStep2GamePiece objectForKey:@"x"] floatValue],
                                          [[frameStep2GamePiece objectForKey:@"y"] floatValue],
                                          [[frameStep2GamePiece objectForKey:@"width"] floatValue],
                                          [[frameStep2GamePiece objectForKey:@"height"] floatValue]);
        
        NSDictionary *frameStep3 = [frames objectForKey:@"frameStep3"];
        gamePiece.frameStep3 = CGRectMake([[frameStep3 objectForKey:@"x"] floatValue],
                                          [[frameStep3 objectForKey:@"y"] floatValue],
                                          [[frameStep3 objectForKey:@"width"] floatValue],
                                          [[frameStep3 objectForKey:@"height"] floatValue]);
        
        [_gamePieceArray addObject:gamePiece];
    }
    
    // Start with game piece introduction step for this stage.
    [self setupStep0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Setup the UILabel for the instruction text.
    float labelHeight = 60.0f;
    CGRect labelFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);    // Put the view off the screen to the bottom
    self.lbl_instruction = [[UILabel alloc] initWithFrame:labelFrame];
    [self.lbl_instruction setBackgroundColor:[UIColor colorWithRed:175.0f/255.0f green:235.0f/255.0f blue:254.0f/255.0f alpha:1.0f]];
    [self.lbl_instruction setTextAlignment:NSTextAlignmentCenter];
    [self.lbl_instruction setTextColor:[UIColor whiteColor]];
    [self.lbl_instruction setFont:[UIFont boldSystemFontOfSize:36.0f]];
    [self.view addSubview:self.lbl_instruction];
    
    [self startStep0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instruction Label Instance Methods
- (void)showInstructionWithText1:(NSString *)text1 withText2:(NSString *)text2 completion:(void (^)(void))completion {
    // Animate the view into the screen coming up from the bottom.
    [self.lbl_instruction setText:text1];
    
    float labelHeight = self.lbl_instruction.frame.size.height;
    CGRect labelFrame = CGRectMake(0.0, self.view.bounds.size.height - labelHeight, self.view.bounds.size.width, labelHeight);
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.lbl_instruction.frame = labelFrame;
                     }
                     completion:^(BOOL finished){
                         if (text2) {
                             // Animate the transition of the label text changing from text1 to text2.
                             CATransition *animation = [CATransition animation];
                             animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                             animation.type = kCATransitionFade;
                             animation.duration = 1.5;
                             [self.lbl_instruction.layer addAnimation:animation forKey:@"kCATransitionFade"];
                             [self.lbl_instruction setText:text2];
                         }
                         
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)hideInstructionWithTextWithCompletion:(void (^)(void))completion {
    // Animate the view off the screen going down to the bottom.
    float labelHeight = self.lbl_instruction.frame.size.height;
    CGRect newFrame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, labelHeight);
    [UIView animateWithDuration:0.7
                          delay:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.lbl_instruction.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion();
                         }
                     }];
}

#pragma mark - Step 0 (Intro) Instance Methods
- (void)setupStep0 {
    _currentStep = kSTEP0;
    _currentGamePieceIndex = 0;
    
    // Apply the inital frame for each map piece
    NSDictionary *mapFrame = [[[_stageDataDictionary objectForKey:@"map"] objectForKey:@"frames"] objectForKey:@"frameStep0"];
    self.iv_map.frame = CGRectMake([[mapFrame objectForKey:@"x"] floatValue],
                                   [[mapFrame objectForKey:@"y"] floatValue],
                                   [[mapFrame objectForKey:@"width"] floatValue],
                                   [[mapFrame objectForKey:@"height"] floatValue]);
    [self.view addSubview:self.iv_map];
    
    // Apply the frame for step 1 for each game piece
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        gamePiece.image = gamePiece.image_inactive;
        gamePiece.frame = gamePiece.frameStep0;
        gamePiece.placeholder.frame = gamePiece.frameStep0;
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
    [self.view bringSubviewToFront:gamePiece];
    
    CGPoint originalCenterGamePiece = gamePiece.center;
    
    [self.lbl_instruction setText:[NSString stringWithFormat:@"This is %@", gamePiece.name]];
    
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
                         
                         self.lbl_instruction.frame = newLabelFrame;
                     }
                     completion:^(BOOL finished){
                         // Animate the transition of the label text changing.
                         CATransition *animation = [CATransition animation];
                         animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                         animation.type = kCATransitionFade;
                         animation.duration = 1.5;
                         [self.lbl_instruction.layer addAnimation:animation forKey:@"kCATransitionFade"];
                         [self.lbl_instruction setText:[NSString stringWithFormat:@"%@", gamePiece.name]];
                         
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
                                              
                                              self.lbl_instruction.frame = newLabelFrame;
                                          }
                                          completion:^(BOOL finished){
                                              [_gamePiecesCompletedInCurrentStep addObject:gamePiece];
                                              
                                              if (completion)
                                                  completion();
                                          }];
                     }];
}

- (void)startStep0 {
    // For every game piece we create a completion block that will instruct
    // the viewController to introduce the next game piece.
    // The last game piece has no completion handler.
    
    int gamePieceCount = (int)[_gamePieceArray count];
    
    NSMutableArray *completionBlocks = [[NSMutableArray alloc] initWithCapacity:gamePieceCount];
    
    void (^lastBlock)(void) = ^(void) {
        void (^completion)(void) = ^(void) {
            [self endStep0];
        };
        [self hideInstructionWithTextWithCompletion:completion];
    };
    [completionBlocks addObject:lastBlock];
    
    int blockIndex = 0;
    for (int i = gamePieceCount - 1; i > 0; i--) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        void (^completionBlock)(void) = ^(void) {
            void (^completion)(void) = ^(void) {
                _currentGamePieceIndex++;
                [self introduceGamePiece:gamePiece
                               withScale:gamePiece.scaleStep0
                                withText:[NSString stringWithFormat:@"This is %@", gamePiece.name]
                              completion:[completionBlocks objectAtIndex:blockIndex]];
            };
            [self hideInstructionWithTextWithCompletion:completion];
        };
        
        [completionBlocks addObject:completionBlock];
        blockIndex++;
    }
    NSArray* reversedCompletionBlocks = [[completionBlocks reverseObjectEnumerator] allObjects];
    
    // We start with the first game piece in the stage. We hide the map at the same time.
    _currentGamePieceIndex = 0;
    MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:_currentGamePieceIndex];
    [self introduceGamePiece:gamePiece
                   withScale:gamePiece.scaleStep0
                    withText:[NSString stringWithFormat:@"This is %@", gamePiece.name]
                  completion:[reversedCompletionBlocks objectAtIndex:0]];
}

- (void)endStep0 {
    // Fade out the current view to prepare for step 1.
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
                         [self startStep1];
                     }];
}

#pragma mark - Step 1 (Taping - No Map) Instance Methods
- (void)startStep1 {
    _currentStep = kSTEP1;
    _currentGamePieceIndex = 0;
    
    // First empty the array that tracks which game pieces have been completed for this step.
    [_gamePiecesCompletedInCurrentStep removeAllObjects];
    
    // Move the game pieces to the top off the screen, off the screen
    // so they can drop into place to begin the next step.
    
    int gamePieceCount = (int)[_gamePieceArray count];
    
    // TODO: Layout currently only supports 1 row of pieces. Need a more scalable solution for when 3+ pieces are shown.
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        gamePiece.image = gamePiece.image_active;
        gamePiece.frame = gamePiece.frameStep1;
        gamePiece.center = CGPointMake((i+i+1)*(self.view.bounds.size.width / (2*gamePieceCount)), -(self.view.bounds.size.height/2));
        gamePiece.alpha = 1.0f;
        [gamePiece setUserInteractionEnabled:NO];
    }
    
    // Get all the centers of the game pieces.
    NSMutableArray *tempGamePieceCentersArray = [[NSMutableArray alloc] initWithCapacity:gamePieceCount];
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [tempGamePieceCentersArray addObject:[NSValue valueWithCGPoint:gamePiece.center]];
    }
    
    // Next, shuffle the centers array randomly.
    [tempGamePieceCentersArray shuffle];
    
    // Now apply the shuffled centers to each game piece.
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        
        CGPoint newCenter = [[tempGamePieceCentersArray objectAtIndex:i] CGPointValue];
        
        gamePiece.center = newCenter;
    }
    
    // Now we let the game pieces drop down into the screen form the top.
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        CGPoint center = CGPointMake(gamePiece.center.x, self.view.bounds.size.height/2);
        [gamePiece makeGamePieceTappableWithCenter:center];
        
        [gamePiece performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0];
    }
    
    // Start with the first game piece in this stage.
    _currentGamePieceIndex = 0;
    MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:_currentGamePieceIndex];
    void (^completion)(void) = ^(void) {
        [self.lbl_instruction setText:gamePiece.name];
    };
    [self showInstructionWithText1:[NSString stringWithFormat:@"Show me %@", gamePiece.name] withText2:[NSString stringWithFormat:@"%@", gamePiece.name] completion:completion];
}

- (void)shuffleStep1 {
    int gamePieceCount = (int)[_gamePieceArray count];
    
    // Get all the centers of the game pieces.
    NSMutableArray *tempGamePieceCentersArray = [[NSMutableArray alloc] initWithCapacity:gamePieceCount];
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [tempGamePieceCentersArray addObject:[NSValue valueWithCGPoint:gamePiece.center]];
    }
    
    // Next, shuffle the centers array randomly.
    [tempGamePieceCentersArray shuffle];
    
    // Now apply the shuffled centers to each game piece.
    for (int i = 0; i < gamePieceCount; i++) {
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:i];
        
        CGPoint newCenter = [[tempGamePieceCentersArray objectAtIndex:i] CGPointValue];
        
        [gamePiece makeGamePieceTappableWithCenter:newCenter];
    }
    
//    // Now randomly select one of the centers and apply it to a differnt game piece.
//    for (MGAGamePiece *gamePiece in _gamePieceArray) {
//        int gamePieceCenterIndex = arc4random_uniform([tempGamePieceCentersArray count]);
//        
//        CGPoint newCenter = [[tempGamePieceCentersArray objectAtIndex:gamePieceCenterIndex] CGPointValue];
//        
//        [gamePiece makeGamePieceTappableWithCenter:newCenter];
//        
//        // Remove this center point form the array of available centers.
//        [tempGamePieceCentersArray removeObjectAtIndex:gamePieceCenterIndex];
//    }
}

#pragma mark - Step 2 (Dragging - On Map) Instance Methods
- (void)startStep2 {
    _currentStep = kSTEP2;
    _currentGamePieceIndex = 0;
    
    // First empty the array that tracks which game pieces have been completed for this step.
    [_gamePiecesCompletedInCurrentStep removeAllObjects];
    
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
                             
                             gamePiece.frame = gamePiece.frameStep2GamePiece;
                             gamePiece.placeholder.frame = gamePiece.frameStep2Placeholder;
                             
                             [self.view bringSubviewToFront:gamePiece];
                         }
                     }
                     completion:^(BOOL finished){
                         [self setupGamePiecesForDragging];
                         
                         // Show the game piece labels under each game piece.
                         // Position the gamepiece label and show it.
                         for (MGAGamePiece *gamePiece in _gamePieceArray) {
                             CGPoint labeCenter = CGPointMake(gamePiece.center.x, gamePiece.center.y + gamePiece.frame.size.height/2 + 15.0);
                             gamePiece.lbl_name.center = labeCenter;
                             gamePiece.lbl_name.alpha = 0.0;
                             
                             [self.view addSubview:gamePiece.lbl_name];
                         }
                         
                         [UIView animateWithDuration:0.35
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              for (MGAGamePiece *gamePiece in _gamePieceArray) {
                                                  gamePiece.lbl_name.alpha = 1.0;
                                              }
                                          }
                                          completion:^(BOOL finished){
                                              void (^completion)(void) = ^(void) {
                                                  [self hideInstructionWithTextWithCompletion:nil];
                                              };
                                              [self showInstructionWithText1:@"Show me where these go" withText2:nil completion:completion];
                                          }];
                     }];
}

- (void)setupGamePiecesForDragging {
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [gamePiece makeGamePieceDraggable];
    }
}

#pragma mark - Step 3 (Taping - On Map) Instance Methods
- (void)startStep3 {
    _currentStep = kSTEP3;
    _currentGamePieceIndex = 0;
    
    // First empty the array that tracks which game pieces have been completed for this step.
    [_gamePiecesCompletedInCurrentStep removeAllObjects];
    
    // Game pieces should now be in their proper postions on the map.
    // Make them tappable for this step.
    
    for (MGAGamePiece *gamePiece in _gamePieceArray) {
        [gamePiece makeGamePieceTappableWithCenter:gamePiece.center];
        gamePiece.image = gamePiece.image_active;
        
        [gamePiece setUserInteractionEnabled:YES];
    }
    
    // Start with the first game piece in this stage.
    MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:_currentGamePieceIndex];
    void (^completion)(void) = ^(void) {
        [self.lbl_instruction setText:gamePiece.name];
    };
    [self showInstructionWithText1:[NSString stringWithFormat:@"Show me %@", gamePiece.name] withText2:[NSString stringWithFormat:@"%@", gamePiece.name] completion:completion];
}

#pragma mark - MGAGamePieceDelegate Game Piece Methods
- (void)gamePieceDidTouchTransparentPixel:(MGAGamePiece *)gamePiece touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // We need to test to see if the touch if within another game pieces frame below this one.
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (MGAGamePiece *otherGamePiece in _gamePieceArray) {
        if (otherGamePiece != gamePiece &&
            CGRectContainsPoint(otherGamePiece.frame, touchLocation))
        {
            [otherGamePiece touchesBegan:touches withEvent:event];
        }
    }
}

- (void)gamePieceDidTouchTransparentPixel:(MGAGamePiece *)gamePiece touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // We need to test to see if the touch if within another game pieces frame below this one.
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (MGAGamePiece *otherGamePiece in _gamePieceArray) {
        if (otherGamePiece != gamePiece &&
            CGRectContainsPoint(otherGamePiece.frame, touchLocation))
        {
            [otherGamePiece touchesMoved:touches withEvent:event];
        }
    }
}

- (void)gamePieceDidTouchTransparentPixel:(MGAGamePiece *)gamePiece touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // We need to test to see if the touch if within another game pieces frame below this one.
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (MGAGamePiece *otherGamePiece in _gamePieceArray) {
        if (otherGamePiece != gamePiece &&
            CGRectContainsPoint(otherGamePiece.frame, touchLocation))
        {
            [otherGamePiece touchesEnded:touches withEvent:event];
        }
    }
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
    
    CGFloat targetDistance = gamePiece.maxDistanceFromCenterStep2;
    
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

- (void)gamePiecePlacedOnTarget:(MGAGamePiece *)gamePiece {
    if (_currentStep == kSTEP2) {
        [_gamePiecesCompletedInCurrentStep addObject:gamePiece];
        
        // Check to see if all game pieces have been correctly placed on the map.
        if ([_gamePiecesCompletedInCurrentStep count] == [_gamePieceArray count]) {
            [self startStep3];
        }
    }
}

- (void)gamePieceReturnedToOriginalLocation:(MGAGamePiece *)gamePiece {
    
}

#pragma mark - MGAGamePieceDelegate Tappable Game Piece Methods
- (void)tappableGamePieceTouchBegan:(MGAGamePiece *)gamePiece didTouchAtPoint:(CGPoint)point {
    [self.view bringSubviewToFront:gamePiece];
}

- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didDragToPoint:(CGPoint)point {
    
}

- (void)tappableGamePiece:(MGAGamePiece *)gamePiece didReleaseAtPoint:(CGPoint)point {
    if ([_gamePieceArray objectAtIndex:_currentGamePieceIndex] == gamePiece) {
        [gamePiece bounceGamePiece];
        
        [self hideInstructionWithTextWithCompletion:nil];
    }
    else {
        [gamePiece shakeGamePiece];
    }
}

- (void)gamePieceBounceDidComplete:(MGAGamePiece *)gamePiece {
    [_gamePiecesCompletedInCurrentStep addObject:gamePiece];
    
    // Check to see if all game pieces have been correctly identified.
    if ([_gamePiecesCompletedInCurrentStep count] == [_gamePieceArray count]) {
        if (_currentStep == kSTEP1) {
            [self startStep2];
        }
        else if (_currentStep == kSTEP3) {
            // Stage complete.
            void (^completion)(void) = ^(void) {
                void (^completion)(void) = ^(void) {
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self hideInstructionWithTextWithCompletion:completion];
            };
            [self showInstructionWithText1:@"Stage complete!" withText2:nil completion:completion];
        }
    }
    else {
        if (_currentStep == kSTEP1) {
            [self shuffleStep1];
        }
        
        // Get the next game piece for the user to identify.
        _currentGamePieceIndex++;
        MGAGamePiece *gamePiece = [_gamePieceArray objectAtIndex:_currentGamePieceIndex];
        void (^completion)(void) = ^(void) {
            [self.lbl_instruction setText:gamePiece.name];
        };
        [self showInstructionWithText1:[NSString stringWithFormat:@"Show me %@", gamePiece.name] withText2:[NSString stringWithFormat:@"%@", gamePiece.name] completion:completion];
    }
}

- (void)gamePieceShakeDidComplete:(MGAGamePiece *)gamePiece {
    if (_currentStep == kSTEP1) {
        [self shuffleStep1];
    }
}

#pragma mark - Navigation Methods
- (IBAction)onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
