//
//  NetworkManager.m
//  RockPaperScissors
//
//  Created by Joshua Barrow on 6/12/14.
//  Copyright (c) 2014 Jukaela Enterprises. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkManager alloc] init];
        
    });
    
    return sharedInstance;
}

-(void)commitThrow:(ThrowType)currentThrow
{
    NSURLRequest *request = [self createSessionWithType:currentThrow];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kErrorFromServer object:nil];
        }
        else if (data) {
            NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            ThrowType returnedThrow = [self throwTypeStringToEnum:returnString];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReturnedThrow object:nil userInfo:@{kReturnedThrow: @(returnedThrow)}];
            
            if (currentThrow == returnedThrow) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kTie object:nil];
            }
            else if ((currentThrow == Rock && returnedThrow == Scissors) ||
                (currentThrow == Scissors && returnedThrow == Paper) ||
                (currentThrow == Paper && returnedThrow == Rock)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerWon object:nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kServerWon object:nil];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUnknownError object:nil];
        }
    }] resume];
}

-(NSURLRequest *)createSessionWithType:(ThrowType)type
{
    NSURL *url = nil;
    
    switch (type) {
        case Rock:
            url = [NSURL URLWithString:@"http://roshambo.herokuapp.com/throws/rock.json"];
            
            break;
        case Paper:
            url = [NSURL URLWithString:@"http://roshambo.herokuapp.com/throws/paper"];

            break;
        case Scissors:
            url = [NSURL URLWithString:@"http://roshambo.herokuapp.com/throws/scissors"];

            break;
        default:
            break;
    }
    
    return [NSURLRequest requestWithURL:url];
}

-(NSString *)throwTypeToString:(ThrowType)throwType
{
    switch (throwType) {
        case Rock:
            return @"rock";
            break;
        case Paper:
            return @"paper";
            break;
        case Scissors:
            return @"scissors";
            break;
        default:
            return nil;
            break;
    }
}

-(ThrowType)throwTypeStringToEnum:(NSString *)throwType
{
    if ([self firstString:throwType constainsString:@"rock"]) {
        return Rock;
    }
    else if ([self firstString:throwType constainsString:@"paper"]) {
        return Paper;
    }
    else {
        return Scissors;
    }
}

-(BOOL)firstString:(NSString *)string constainsString:(NSString *)subString
{
    NSRange range = [string rangeOfString:subString];
    
    return (range.location != NSNotFound);
}
@end
