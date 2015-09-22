//
//  AppDelegate.h
//  BackgroundDownloadTaskDemo
//
//  Created by Alex Shevlyakov on 22.09.15.
//
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^sessionCompletionHandler)();


@end

