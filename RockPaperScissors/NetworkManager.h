//
//  NetworkManager.h
//  RockPaperScissors
//
//  Created by Joshua Barrow on 6/12/14.
//  Copyright (c) 2014 Jukaela Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface NetworkManager : NSObject

/*
 * The singleton instance of the NetworkManager class
 */
+(NetworkManager *)sharedInstance;

-(void)commitThrow:(ThrowType)currentThrow;

@end
