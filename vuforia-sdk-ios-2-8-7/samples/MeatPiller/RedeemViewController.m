//
//  RedeemViewController.m
//  MeatPiller
//
//  Created by Nathan on 1/4/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#import "RedeemViewController.h"
#import "GothButton.h"

NSString *const kPurchaseAppKey = @"55isgrqdfwo7vqve9zf7hnga4mbgpoyt";
NSString *const kPurchaseAppSecret = @"zrcfufpyl82hbxvj1ffqjwhm98tf8w3m";

@interface RedeemViewController () <UITextFieldDelegate, NSURLSessionDelegate>

- (IBAction)purchaseTapped:(UIButton *)sender;

@end

@implementation RedeemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disableView
{
    for (id view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]])
        {
            [view setEnabled:NO];
        }
    }
}

- (void)enableView
{
    for (id view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]])
        {
            [view setEnabled:YES];
        }
    }
}

- (IBAction)purchaseTapped:(GothButton *)sender
{
    [self disableView];
    
    [sender showActivity];
    
    
    BOOL isOldAPI = YES;
    
    if (isOldAPI) {
        [self requestAccessTokenCompletion:^(NSString *accessToken) {
            NSLog(@"access Token %@", accessToken);
            [self requestNotaryWithAccessToken:accessToken completion:^(NSString *signature, NSString *signedDocument) {
                NSLog(@"signature %@", signature);
                NSLog(@"signedDocument %@", signedDocument);
                [self openSafariWithSigniture:signature signedDocument:signedDocument];
            }];
        }];
        
    } else {
        [self requestNotaryDaleCompletion:^(NSString *signature, NSString *signedDocument) {
            NSLog(@"-------------did requestNotaryDaleCompletion--------------------------");
            NSLog(@"signature %@", signature);
            NSLog(@"signedDocument %@", signedDocument);
            [self openSafariWithSigniture:signature signedDocument:signedDocument];
            
        }];
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (NSString *)transactionString {
    //    NSString *dateTemplate = @"YYYY'-'MM'-'dd'T'HH':'mm''ss'Z'";
    //    dateTemplate = @"SS";
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                                   fromDate:[NSDate date]];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger randomNum = arc4random_uniform(1000);
    NSString *transactionString = [NSString stringWithFormat:@"%d%d%d%d%d%d", year, month, day, hour, minute, randomNum];
    NSLog(@"transaction string %@", transactionString);
    
    return transactionString;
}


- (void)requestAccessTokenCompletion:(void (^)(NSString *accessToken))block {
    NSString *postString = [NSString stringWithFormat: @"client_id=%@&client_secret=%@&scope=PAYMENT&grant_type=client_credentials", kPurchaseAppKey, kPurchaseAppSecret];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    
	NSURL *remoteURL = [NSURL URLWithString:@"https://api.att.com/oauth/token"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
	[urlRequest setURL:remoteURL];
	[urlRequest setHTTPMethod:@"POST" ];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setHTTPBody:postData];
    
	NSLog(@"request %@", remoteURL);
	NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"error");
                                                        return;
                                                    }
                                                    NSLog(@"access token reponse %@", response);
                                                    NSDictionary *jsonSerialization = [NSJSONSerialization
                                                                                       JSONObjectWithData:data
                                                                                       options:kNilOptions
                                                                                       error:&error];
                                                    
                                                    NSLog(@"data %@", jsonSerialization);
                                                    block(jsonSerialization[@"access_token"]);
                                                    
                                                }];
    [dataTask resume];
    
}



- (void)requestNotaryWithAccessToken:(NSString *)accessToken completion:(void (^)(NSString *signature, NSString *signedDocument))block {
    
    NSString *transactionString = [self transactionString];
    
    NSString *redirectURL = [self callbackURL];
    
    NSString *merchantProductID = [NSString stringWithFormat:@"P%@", transactionString];
    NSString *merchantTransactionID = [NSString stringWithFormat:@"T%@", transactionString];
    
    NSDictionary *postDictionary = @{@"Description" : @"Crossword 6",
                                     @"Category" : @3,
                                     @"Amount" : @(1.01),
                                     @"Channel" : @"MOBILE_WEB",
                                     @"MerchantPaymentRedirectUrl" : redirectURL,
                                     @"MerchantProductId" : merchantProductID,
                                     @"MerchantTransactionId" : merchantTransactionID};
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary
                                                       options:0 error:&error];
    
	NSURL *remoteURL = [NSURL URLWithString:@"https://api.att.com/Security/Notary/Rest/1/SignedPayload"];
    
    NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
	[urlRequest setURL:remoteURL];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:kPurchaseAppKey forHTTPHeaderField:@"client_id"];
	[urlRequest setValue:kPurchaseAppSecret forHTTPHeaderField:@"client_secret"];
	[urlRequest setHTTPBody:postData];
	[urlRequest setHTTPMethod:@"POST" ];
    
	NSLog(@"notary request %@", remoteURL);
	NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"error");
                                                        return;
                                                    }
                                                    NSLog(@"notary reponse %@", response);
                                                    NSDictionary *jsonSerialization = [NSJSONSerialization
                                                                                       JSONObjectWithData:data
                                                                                       options:kNilOptions
                                                                                       error:&error];
                                                    
                                                    NSLog(@"json %@", jsonSerialization);
                                                    
                                                    block(jsonSerialization[@"Signature"], jsonSerialization[@"SignedDocument"]);
                                                    
                                                }];
    [dataTask resume];
}



//POST https://api.att.com/Security/Notary/Rest/1/SignedPayload HTTP/1.1
//Content-Type: application/json
//Accept: application/json
//Client_id: 88b311961bc67da439e605534cc6c6b8
//Client_secret: 866f2e1144103d79
//User-Agent: Ruby
//      Host: api.att.com
//Content-Length: 239
//{"Amount":1.01,
//    "Category":3,
//    "Channel":"MOBILE_WEB",
//    "Description":"Crossword 6",
//    "MerchantTransactionId":"T20120320211053406",
//    "MerchantProductId":"LEVEL20120320211053406",
//    "MerchantPaymentRedirectUrl":"http://somewhere.com/20120320211053406"
//}
- (void)requestNotaryDaleCompletion:(void (^)(NSString *signature, NSString *signedDocument))block {
    NSString *transactionString = [self transactionString];
    NSString *redirectURL = [self callbackURL];
    
    NSString *merchantProductID = [NSString stringWithFormat:@"LEVEL%@", transactionString];
    NSString *merchantTransactionID = [NSString stringWithFormat:@"T%@", transactionString];
    
    NSDictionary *postDictionary = @{@"Amount" : @(1.01),
                                     @"Category" : @3,
                                     @"Channel" : @"MOBILE_WEB",
                                     @"Description" : @"Crossword 6",
                                     @"MerchantTransactionId" : merchantTransactionID,
                                     @"MerchantProductId" : merchantProductID,
                                     @"MerchantPaymentRedirectUrl" : redirectURL
                                     };
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary
                                                       options:0 error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
	NSURLSession *session = [NSURLSession sharedSession];
	NSURL *remoteURL = [NSURL URLWithString:@"https://api.att.com/Security/Notary/Rest/1/SignedPayload"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
	[urlRequest setURL:remoteURL];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:kPurchaseAppKey forHTTPHeaderField:@"Client_id"];
	[urlRequest setValue:kPurchaseAppSecret forHTTPHeaderField:@"Client_secret"];
    [urlRequest setValue:@"Ruby" forHTTPHeaderField:@"User-Agent"];
	[urlRequest setValue:@"api.att.com" forHTTPHeaderField:@"Host"];
	[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[urlRequest setHTTPBody:postData];
	[urlRequest setHTTPMethod:@"POST"];
    
	NSLog(@"request %@", remoteURL);
    //	RTOViewController __weak *weakSelf = self;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"error - %@", [error localizedDescription]);
                                                        return;
                                                    }
                                                    NSLog(@"redirect reponse %@", response);
                                                    NSDictionary *jsonSerialization = [NSJSONSerialization
                                                                                       JSONObjectWithData:data
                                                                                       options:kNilOptions
                                                                                       error:&error];
                                                    
                                                    block(jsonSerialization[@"Signature"], jsonSerialization[@"SignedDocument"]);
                                                }];
    [dataTask resume];
}


- (void)openSafariWithSigniture:(NSString *)signiture signedDocument:(NSString *)signedDocument {
    
    NSString *confirmURLPath = [NSString stringWithFormat:@"https://api.att.com/rest/3/Commerce/Payment/Transactions?Signature=%@&SignedPaymentDetail=%@&clientid=%@", signiture, signedDocument, kPurchaseAppKey];
    
    //    NSString *confirmURLPath = [NSString stringWithFormat:@"https://api.att.com/Commerce/Payment/Rest/2/Transactions?Signature=%@&SignedPaymentDetail=%@&clientid=%@", signiture, signedDocument, kPurchaseAppKey];
    
    NSURL *confirmURL = [NSURL URLWithString:confirmURLPath];
    
    NSLog(@"\n\n---------------------------------------------------------------------------------");
	NSLog(@"request %@", confirmURL);
    NSLog(@"\n");
    
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:confirmURL
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSLog(@"redirect reponse %@", response);
                                                if (error) {
                                                    NSLog(@"!!!error %@- %@", [error localizedDescription], error);
                                                    return;
                                                }
                                                
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    //[[UIApplication sharedApplication] openURL:response.URL];
                                                    [self createWebviewWithURL:response.URL];
                                                }];
                                                
                                            }];
    
    
    [dataTask resume];
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    //    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    //
    //            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    
}

- (NSString *)callbackURL {
    return @"https://chinesedeliveryapp.com/attredirect";
}

- (void)createWebviewWithURL:(NSURL *)url {
    CGRect windowFrame = self.view.window.frame;
    windowFrame.origin.y -= 124;
    windowFrame.origin.x += 124;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:windowFrame];
    webView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    [self.parentViewController.view addSubview:webView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    //    [[UIApplication sharedApplication] openURL:url];
}
@end
