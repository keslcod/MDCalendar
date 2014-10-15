//
//  MDDateFormatterSymbolsTests.m
//
//
//  Copyright (c) 2014 Florian Bürger
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDateFormatter+LocalizedSymbols.h"

@interface NSDateFormatterSymbolsTests : XCTestCase
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation NSDateFormatterSymbolsTests

- (void)setUp {
    [super setUp];
	self.dateFormatter = [[NSDateFormatter alloc] init];
}

- (void)tearDown {
	self.dateFormatter = nil;
    [super tearDown];
}

- (void)testSymbolsForUSLocale {
	// given
	NSLocale *usLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
	self.dateFormatter.locale = usLocale;

	// when
	NSArray *localizedWeekdaySymbols = [self.dateFormatter localizedSymbolsForSelector:@selector(weekdaySymbols) firstWeekDay:1];

	// then
	NSArray *expected = @[ @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday" ];
	XCTAssertEqualObjects(localizedWeekdaySymbols, expected);
}

- (void)testSymbolsForDELocale {
	// given
	NSLocale *deLocale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
	self.dateFormatter.locale = deLocale;

	// when
	NSArray *localizedWeekdaySymbols = [self.dateFormatter localizedSymbolsForSelector:@selector(weekdaySymbols) firstWeekDay:2];

	// then
	NSArray *expected = @[ @"Montag", @"Dienstag", @"Mittwoch", @"Donnerstag", @"Freitag", @"Samstag", @"Sonntag", ];
	XCTAssertEqualObjects(localizedWeekdaySymbols, expected);
}

@end
