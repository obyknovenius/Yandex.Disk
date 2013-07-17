//
//  VDDAVListingResponseParser.m
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/13/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import "VDDAVResponseParser.h"
#import "VDDAVFile.h"

@interface VDDAVResponseParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) VDDAVFile *currentItem;
@property (nonatomic, assign) BOOL inResponseType;

@end

@implementation VDDAVResponseParser

- (id)initWithData:(NSData *)data
{
	NSParameterAssert(data != nil);
	
	if (self = [super init]) {
		_items = [[NSMutableArray alloc] init];
		
		_parser = [[NSXMLParser alloc] initWithData:data];
		[self.parser setDelegate:self];
		[self.parser setShouldProcessNamespaces:YES];
	}
	return self;
}

- (NSArray *)parse:(NSError **)error
{
	if (![self.parser parse]) {
		if (error) {
			*error = [self.parser parserError];
		}
		
		return nil;
	}
	
	return [self.items copy];
}

#pragma mark - XML parser delegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
	self.currentString = [[NSMutableString alloc] init];
	
	if ([elementName isEqualToString:@"response"]) {
		self.currentItem = [[VDDAVFile alloc] init];
	}
	else if ([elementName isEqualToString:@"resourcetype"]) {
		self.inResponseType = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"href"]) {
		self.currentItem.href = [self.currentString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
    else if ([elementName isEqualToString:@"displayname"]) {
		self.currentItem.displayName = [self.currentString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
    else if ([elementName isEqualToString:@"creationdate"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		self.currentItem.creationDate = [dateFormatter dateFromString:self.currentString];
	}
	else if ([elementName isEqualToString:@"getcontentlength"]) {
		self.currentItem.contentLength = [self.currentString longLongValue];
	}
	else if ([elementName isEqualToString:@"getlastmodified"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss z";
		self.currentItem.modificationDate = [dateFormatter dateFromString:self.currentString];
	}
	else if ([elementName isEqualToString:@"resourcetype"]) {
		self.inResponseType = NO;
	}
	else if ([elementName isEqualToString:@"collection"] && self.inResponseType) {
		self.currentItem.collection = YES;
	}
	else if ([elementName isEqualToString:@"response"]) {
		[self.items addObject:self.currentItem];
		
		self.currentItem = nil;
	}
	
	self.currentString = nil;
}

@end
