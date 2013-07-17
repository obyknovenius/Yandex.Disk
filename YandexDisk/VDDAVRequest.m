//
//  VDDAVListingRequest.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/11/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDDAVRequest.h"
#import "VDDAVResponseParser.h"
#import "VDDAVSession.h"

#define DEFAULT_TIMEOUT 60

NSString * const HTTPErrorDomain = @"HTTPErrorDomain";
NSString * const AuthErrorDomain = @"AuthErrorDomain";

@interface VDDAVRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation VDDAVRequest

- (NSMutableData *)data
{
    if (!_data) {
		_data = [[NSMutableData alloc] init];
	}
    
    return _data;
}

- (void)setPath:(NSString *)path
{
    if (!path || [path isEqualToString:@""]) {
        _path = @"/";
    } else {
        _path = [path copy];
    }
}

- (id)init
{
    return [self initWithPath:nil];
}

- (id)initWithPath:(NSString *)path
{
	if (!path || [path isEqualToString:@""]) {
        _path = @"/";
    } else {
        _path = [path copy];
    }
    
	return self;
}

- (void)send
{
    VDDAVSession *session = [VDDAVSession sharedSession];
    NSURL *url = self.path ? [session.baseURL URLByAppendingPathComponent:self.path] : session.baseURL;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:@"PROPFIND"];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT];
	
    [request setValue:@"1" forHTTPHeaderField:@"Depth"];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
	NSString *xml = @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"
    @"<D:propfind xmlns:D=\"DAV:\"><D:allprop/></D:propfind>";
	
	[request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        VDDAVSession *session = [VDDAVSession sharedSession];
        NSURLCredential *credential = [NSURLCredential credentialWithUser:session.username
                                                                 password:session.password
                                                              persistence:NSURLCredentialPersistenceNone];
        
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [connection cancel];
        
        if (self.failure) {
            NSError *error = [[NSError alloc] initWithDomain:AuthErrorDomain
                                                        code:911
                                                    userInfo:nil];
            self.failure(self, error);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.failure) {
        self.failure(self, error);
    }
    
    self.data = nil;
}

#pragma mark - URL connection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSInteger code = [(NSHTTPURLResponse *)response statusCode];
		
		if (code >= 400) {
            [connection cancel];
            
            if (self.failure) {
                NSError *error = [[NSError alloc] initWithDomain:HTTPErrorDomain
                                                            code:code
                                                        userInfo:nil];
                self.failure(self, error);
            }
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    VDDAVResponseParser *parser = [[VDDAVResponseParser alloc] initWithData:self.data];
	
	NSError *error = nil;
	NSArray *files = [parser parse:&error];
	
	if (files) {
        if (self.success) {
            self.success(self, files);
        }
    } else {
        if (self.failure) {
            self.failure(self, error);
        }
	}
    
    self.data = nil;
}

@end
