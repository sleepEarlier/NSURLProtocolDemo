//
//  ViewController.m
//  NSURLProtocolDemo
//
//  Created by kimiLin on 2017/9/20.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *path = @"https://www.google.com/search?q=iOS%20Developer";
    
    
}

- (IBAction)go:(id)sender {
    [self loadURLPath:self.textField.text];
}

- (void)loadURLPath:(NSString *)urlPath {
    urlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlPath];
    if (url) {
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:req];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
