//
//  ModalWebViewController.m
//  emperors
//
//  Created by Daniel A. Weiner on 1/24/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

#import "ModalWebViewController.h"

@interface ModalWebViewController ()

@property (nonatomic) NSString *HTMLPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightConstraint;

@end

@implementation ModalWebViewController

-(instancetype)initWithHTMLFileName:(NSString *)HTMLFileName title:(NSString *)title modalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle {
    self = [super initWithNibName:@"ModalWebView" bundle:[NSBundle mainBundle]];
    
    self.modalPresentationStyle = modalPresentationStyle;
    
    if (self) {
        self.HTMLPath = [[NSBundle mainBundle] pathForResource:HTMLFileName
                                                        ofType:@"html"];
        self.allowLoadingInlineLinks = NO;
        self.allowScrolling = YES;
        self.title = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.items = @[self.navigationItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    self.webView.delegate = self;
    
    self.webView.scrollView.scrollEnabled = self.allowScrolling;
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
    
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:self.HTMLPath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil]
                         baseURL:baseURL];
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.view.traitCollection.userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        // on iPad the contentInset does not need to be adjusted for the statusbar
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
        self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
        
        // on iPad the modal view will not have a status bar so don't extend the
        // navigationBar behind it
        self.navigationBarHeightConstraint.constant = 44.0;
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType==UIWebViewNavigationTypeOther || self.allowLoadingInlineLinks) {
        return YES;
    }
    else {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
}

@end
