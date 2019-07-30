//
//  KRCAppController.m
//  InsomniChat
//
//  Created by Christopher Aronson on 7/30/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

#import "KRCAppController.h"

@import Firebase;

@implementation KRCAppController

+ (KRCAppController *)sharedInstance {
    
    static KRCAppController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KRCAppController alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStateChange) name:@"AuthStateDidChange" object:nil];
    }
    
    return self;
}

- (void)handleStateChange {
    NSLog(@"User changed state");
}

- (void)showWindow:(UIWindow *)window {
    
    [FIRApp configure];
    
    [self setWindow:window];
    
    [[self window] makeKeyAndVisible];
}

@end
