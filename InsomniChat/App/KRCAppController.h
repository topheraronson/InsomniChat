//
//  KRCAppController.h
//  InsomniChat
//
//  Created by Christopher Aronson on 7/30/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;


@interface KRCAppController : NSObject

@property (nonatomic, nullable)UIWindow* window;

+ (KRCAppController * _Nonnull)sharedInstance;

- (void)handleStateChange;

- (void)showWindow:(UIWindow * _Nonnull)window;

@end

