//
//  TitlesHelpViewController.h
//  emperors
//
//  Created by Daniel A. Weiner on 1/24/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalWebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic) BOOL allowScrolling;
@property (nonatomic) BOOL allowLoadingInlineLinks;

-(instancetype)initWithHTMLFileName:(NSString *)HTMLFileName title:(NSString *)title modalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle;

@end