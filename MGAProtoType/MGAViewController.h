//
//  MGAViewController.h
//  MGAProtoType
//
//  Created by Jordan Gurrieri on 11/14/13.
//  Copyright (c) 2013 bluelabellabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGAGamePiece.h"

@interface MGAViewController : UIViewController < MGAGamePieceDelegate >

- (IBAction)onResetButtonPressed:(id)sender;
- (IBAction)onBackButtonPressed:(id)sender;

@end
