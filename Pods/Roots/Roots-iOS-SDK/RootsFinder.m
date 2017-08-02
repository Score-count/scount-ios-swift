//
//  RootsFinder.m
//  Roots-SDK
//
//  Created by Sojan P.R. on 5/4/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RootsFinder.h"
#import "RootsURLContent.h"
#import "RootsAppLaunchConfig.h"
#import "RootsAppRouter.h"

@interface RootsFinder ()

/**
 * Callback for Root finder events
 */
@property (nonatomic, assign) id<RootsEventsDelegate> rootsEventCallback;
@property (nonatomic, assign) id<RootFinderStateDelegate> rootFinderStateCallback;
@property (nonatomic, strong) RootsLinkOptions *options;

/**
 Uri to find roots
 */
@property (strong, nonatomic) NSString *actualUri;

/**
 * Web view to extract the App links
 */
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation RootsFinder

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
    }
    return self;
}

// Injecting Javascript to get the app links as JSONArray
// Source : https://github.com/BoltsFramework/Bolts-ObjC/blob/9067bd0b725f4b17c5204bf214055734cd71080e/Bolts/iOS/BFWebViewAppLinkResolver.m
static NSString *const METADATA_READ_JAVASCRIPT = @""
"(function() {"
"  var metaTags = document.getElementsByTagName('meta');"
"  var results = [];"
"  for (var i = 0; i < metaTags.length; i++) {"
"    var property = metaTags[i].getAttribute('property');"
"    if (property && property.substring(0, 'al:'.length) === 'al:') {"
"      var tag = { \"property\": metaTags[i].getAttribute('property') };"
"      if (metaTags[i].hasAttribute('content')) {"
"        tag['content'] = metaTags[i].getAttribute('content');"
"      }"
"      results.push(tag);""    }"
"  }"
"  return JSON.stringify(results);"
"})()";

- (void)findAndFollowRoots:(NSString *)url withDelegate:(id)callback withStateDelegate:(id)stateCallback andOptions:(RootsLinkOptions *)options {
    _rootsEventCallback = callback;
    _rootFinderStateCallback = stateCallback;
    _options = options;
    
    if ([self isValidURL:url]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Get the final redirected URL content
            RootsURLContent *rootsUrlContent = [self getUrlContent:url];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // Extract the Applink content by JS injection
                [self scrapeAppLinkContent:rootsUrlContent];
            });
        });
    }
    else {
        if (callback) {
           [callback rootsError:invalid_url];
        }
    }
}

- (RootsURLContent *)getUrlContent:(NSString *)url {
    _actualUri = url;
    NSString *redirectedUrl = url;
    RootsURLContent *rootsUrlContent = [[RootsURLContent alloc] init];
    NSURLResponse *response = nil;
    NSData *contentData = nil;
    
    while (redirectedUrl) {
        NSMutableURLRequest  * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [urlRequest setValue:@"al" forHTTPHeaderField:@"Prefer-Html-Meta-Tags"];
        if ([_options getUserAgent]) {
            [urlRequest setValue:[_options getUserAgent] forHTTPHeaderField:@"User-Agent"];
        }
        NSError * error = nil;
        contentData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        if (error == nil) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger responseCode = [(NSHTTPURLResponse *) response statusCode];
                if(responseCode >= 300 && responseCode < 400) {
                    NSDictionary* headers = [(NSHTTPURLResponse *) response allHeaderFields];
                    redirectedUrl = [headers objectForKey:@"Location"];
                    continue;
                }
            }
        }
        redirectedUrl = nil;
    }
    
    rootsUrlContent.htmlSource = contentData;
    if (response) {
        rootsUrlContent.contentType = response.MIMEType;
        rootsUrlContent.contentEncoding = response.textEncodingName;
    }
    return rootsUrlContent;
}


- (void)scrapeAppLinkContent:(RootsURLContent *)rootsUrlContent {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window addSubview:self.webView];
    _webView.delegate = self;
    _webView.hidden = YES;
    [_webView loadData:rootsUrlContent.htmlSource
              MIMEType:rootsUrlContent.contentType
      textEncodingName:rootsUrlContent.contentEncoding
               baseURL:[NSURL URLWithString:@""]];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self extractAppLaunchConfigUsingJavaScript:webView];
}


- (void)extractAppLaunchConfigUsingJavaScript:(UIWebView *)webView {
    RootsAppLaunchConfig *rootsAppLaunchConfig = [[RootsAppLaunchConfig alloc]init];
    rootsAppLaunchConfig.actualUri = _actualUri;
    rootsAppLaunchConfig.targetAppFallbackUrl = _actualUri;
    
    NSString *jsonString = [webView stringByEvaluatingJavaScriptFromString:METADATA_READ_JAVASCRIPT];
    NSError *error = nil;
    NSArray *appLinkMetadataArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:0
                                                                      error:&error];
    rootsAppLaunchConfig = [RootsAppLaunchConfig initialize:appLinkMetadataArray withUrl:_actualUri];
    if ([_options isUserOverridingFallbackRule]) {
        rootsAppLaunchConfig.alwaysOpenAppStore =  [_options getAlwaysFallbackToAppStore];
    }
    [RootsAppRouter handleAppRouting:rootsAppLaunchConfig withDelegate:_rootsEventCallback];
    
    [_webView setDelegate:nil];
    [_webView stopLoading];
    
    if (_rootFinderStateCallback) {
        [_rootFinderStateCallback onRootFinderFinished:self];
    }
}

- (BOOL)isValidURL:(NSString *)url {
    BOOL isValid = NO;
    NSUInteger length = [url length];
    if (length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:url options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                isValid = YES;
            }
        }
    }
    return isValid;
}

            

@end