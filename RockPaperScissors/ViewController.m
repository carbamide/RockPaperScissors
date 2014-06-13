//
//  ViewController.m
//  RockPaperScissors
//
//  Created by Joshua Barrow on 6/12/14.
//  Copyright (c) 2014 Jukaela Enterprises. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "Defines.h"
#import "Game.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIButton *rockButton;
@property (strong, nonatomic) IBOutlet UIButton *paperButton;
@property (strong, nonatomic) IBOutlet UIButton *scissorsButton;
@property (strong, nonatomic) IBOutlet UILabel *returnedThrowLabel;
@property (nonatomic) int playerWinCount;
@property (nonatomic) int serverWinCount;

-(IBAction)showScores:(UIButton *)sender;

@end

@implementation ViewController

#pragma mark -
#pragma mark View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorFromServer) name:kErrorFromServer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unknownError) name:kUnknownError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tie) name:kTie object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerWon) name:kPlayerWon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverWon) name:kServerWon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnedThrow:) name:kReturnedThrow object:nil];
    
    UISwipeGestureRecognizer *rockGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(throwRockGestureHandler)];
    UISwipeGestureRecognizer *paperGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(throwRockGestureHandler)];
    UISwipeGestureRecognizer *scissorsGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(throwRockGestureHandler)];

    [rockGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [paperGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [scissorsGesture setDirection:UISwipeGestureRecognizerDirectionRight];

    [[self view] addGestureRecognizer:rockGesture];
    [[self view] addGestureRecognizer:paperGesture];
    [[self view] addGestureRecognizer:scissorsGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Gesture Handlers

-(void)throwRockGestureHandler
{
    
}

-(void)throwPaperGestureHandler
{
    
}

-(void)throwScissorsGestureHandler
{
    
}

#pragma mark -
#pragma mark IBActions

- (IBAction)throwAction:(UIButton *)button
{
    if (button == [self rockButton]) {
        [[NetworkManager sharedInstance] commitThrow:Rock];
    }
    else if (button == [self paperButton]) {
        [[NetworkManager sharedInstance] commitThrow:Paper];
    }
    else {
        [[NetworkManager sharedInstance] commitThrow:Scissors];
    }
}

- (IBAction)showScores:(UIButton *)sender
{
    [self performSegueWithIdentifier:kShowScores sender:nil];
}

#pragma mark -
#pragma mark Notification Handlers

-(void)errorFromServer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *errorAlert = [[UIAlertView alloc ] initWithTitle:@"Error"
                                                              message:@"There has been an error on the server!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
        
        [errorAlert show];
    });
}

-(void)unknownError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"An unknown error has occured!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
        
        [errorAlert show];
    });
}

-(void)tie
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *tieAlert = [[UIAlertView alloc] initWithTitle:@"Tie"
                                                           message:@"Try again!"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        
        [tieAlert show];
    });
}

-(void)playerWon
{
    _playerWinCount++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self scoreLabel] setText:[NSString stringWithFormat:@"PLAYER SCORE: %d\nSERVER SCORE: %d", [self playerWinCount], [self serverWinCount]]];
        
        [self checkWinningConditions];
    });
}

-(void)serverWon
{
    _serverWinCount++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self scoreLabel] setText:[NSString stringWithFormat:@"PLAYER SCORE: %d\nSERVER SCORE: %d", [self playerWinCount], [self serverWinCount]]];
        
        [self checkWinningConditions];
    });
}

-(void)returnedThrow:(NSNotification *)notification
{
    ThrowType returnedThrowType = [(NSNumber *)[notification userInfo][kReturnedThrow] intValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (returnedThrowType) {
            case Rock:
                [[self returnedThrowLabel] setText:@"Computer threw rock"];
                
                break;
            case Paper:
                [[self returnedThrowLabel] setText:@"Computer threw paper"];

                break;
            case Scissors:
                [[self returnedThrowLabel] setText:@"Computer threw scissors"];

                break;
            default:
                break;
        }
    });
}

#pragma mark -
#pragma mark Helper Methods

-(BOOL)checkWinningConditions
{
    UIAlertView *gameOverAlert = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([self playerWinCount] == 3) {
        gameOverAlert = [[UIAlertView alloc] initWithTitle:@"Yay!"
                                                   message:@"You've won!  Nice job!"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
        [gameOverAlert setTag:0];
        [gameOverAlert show];
        
        Game *wonGame = [[Game alloc] initWithEntity:[NSEntityDescription entityForName:@"Game" inManagedObjectContext:[appDelegate managedObjectContext]] insertIntoManagedObjectContext:[appDelegate managedObjectContext]];
        
        [wonGame setWon:@(YES)];
        [wonGame setTimeStamp:[NSDate date]];
        
        NSError *saveError = nil;
        
        [[wonGame managedObjectContext] save:&saveError];
        
        return YES;
    }
    else if ([self serverWinCount] == 3) {
        gameOverAlert = [[UIAlertView alloc] initWithTitle:@"Oh no!"
                                                   message:@"Game over! Better luck next time!"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
        [gameOverAlert setTag:1];
        [gameOverAlert show];
        
        Game *lostGame = [[Game alloc] initWithEntity:[NSEntityDescription entityForName:@"Game" inManagedObjectContext:[appDelegate managedObjectContext]] insertIntoManagedObjectContext:[appDelegate managedObjectContext]];
        
        [lostGame setWon:@(NO)];
        [lostGame setTimeStamp:[NSDate date]];
        
        NSError *saveError = nil;
        
        [[lostGame managedObjectContext] save:&saveError];
        
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self setServerWinCount:0];
    [self setPlayerWinCount:0];
    
    [[self scoreLabel] setText:[NSString stringWithFormat:@"PLAYER SCORE: %d\nSERVER SCORE: %d", [self playerWinCount], [self serverWinCount]]];
    [[self returnedThrowLabel] setText:nil];
}

@end
