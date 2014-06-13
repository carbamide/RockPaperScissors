//
//  Defines.h
//  RockPaperScissors
//
//  Created by Joshua Barrow on 6/12/14.
//  Copyright (c) 2014 Jukaela Enterprises. All rights reserved.
//

typedef enum : NSUInteger {
    Rock,
    Paper,
    Scissors,
} ThrowType;

#define kErrorFromServer @"error_from_server"
#define kUnknownError @"unknown_error"
#define kTie @"tie"
#define kPlayerWon @"player_won"
#define kServerWon @"server_won"
#define kReturnedThrow @"returned_throw"
#define kShowScores @"ShowScores"