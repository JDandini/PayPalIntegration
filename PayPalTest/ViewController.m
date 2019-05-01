//
//  ViewController.m
//  PayPalTest
//
//  Created by Javier on 4/16/19.
//  Copyright © 2019 GAIA Design. All rights reserved.
//

#import "ViewController.h"
#import "PayPalAuthRequest.h"
#import "Network.h"
#import "PayPalAuthToken.h"
#import "CreateOrder.h"
#import "ThreadManager.h"
#import "OrderCreationResponse.h"
#import <WebKit/WebKit.h>
#import <NativeCheckout/PYPLCheckout.h>
#import <SafariServices/SafariServices.h>

@interface ViewController () < SFSafariViewControllerDelegate, WKNavigationDelegate>
@property (nonatomic, weak) IBOutlet WKWebView *webView;
@property (nonatomic) OrderCreationResponse *currentPayPalOrder;

@end

@implementation ViewController
@synthesize webView;
@synthesize currentPayPalOrder;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) paypalAuthentication {
    if (currentPayPalOrder != nil) {
        [self loadWebViewWithURL: currentPayPalOrder.aprovementURL];
        return;
    }
    __weak typeof(self) welf = self;
    PayPalAuthRequest *request = [[PayPalAuthRequest alloc] init];
    [Network execute:request withSuccess:^(id _Nonnull json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDic = (NSDictionary *)json;
            PayPalAuthToken *token = [[PayPalAuthToken alloc] initWithJSON: jsonDic];
            [ThreadManager mainAsyncThreadWith:^{
                [welf createOrderWithToken: token];
            }];
        }
    } orError:^(NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

-(void)createOrderWithToken: (PayPalAuthToken *)token {
    __weak typeof(self) welf = self;
    CreateOrder *request = [[CreateOrder alloc]initWithToken:token.token andAmount:100.0];
    [Network execute: request withSuccess:^(id _Nonnull json) {
        if (![json isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *jsonDict = (NSDictionary *)json;
        OrderCreationResponse *response = [[OrderCreationResponse alloc]initWithJSON: jsonDict];
        welf.currentPayPalOrder = response;
        [ThreadManager mainAsyncThreadWith:^{
            [welf loadWebViewWithURL:response.aprovementURL];
        }];
    } orError:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


-(void) loadWebViewWithURL: (NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) { return; }
    [self.view bringSubviewToFront:webView];
    NSURLRequest *request =  [NSURLRequest requestWithURL:url];
    webView.navigationDelegate = self;
    [webView loadRequest:request];


}

-(IBAction)startCheckoutWithPayPal:(UIButton *)sender {
    [self paypalAuthentication];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = navigationAction.request.URL.absoluteString;
    WKNavigationActionPolicy shouldNavigate = [url containsString:@"gaiadesign.com.mx"] ? WKNavigationActionPolicyCancel: WKNavigationActionPolicyAllow;
    if ([url containsString:@"gaiadesign.com.mx"]) {
        NSURL *url = navigationAction.request.URL;
        NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
        NSArray *queryItems = [components queryItems];
        NSLog(@"%@",queryItems);
    }
    decisionHandler(shouldNavigate);
}


- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}
@end
