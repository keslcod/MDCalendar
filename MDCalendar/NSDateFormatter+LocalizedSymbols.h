//
//  NSDateFormatter+LocalizedSymbols.m
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

#import <Foundation/Foundation.h>

@interface NSDateFormatter (LocalizedSymbols)

/// Return weekday symbols for the current locale in correct order
/// e.g. on en_US "Sunday" is the first object, on de_DE "Monday"
/// is the first object.
- (NSArray *)localizedWeekdaySymbols;
- (NSArray *)localizedShortWeekdaySymbols;
- (NSArray *)localizedStandaloneWeekdaySymbols;
- (NSArray *)localizedShortStandaloneWeekdaySymbols;
- (NSArray *)localizedVeryShortStandaloneWeekdaySymbols;

/// Don't use this in production, only exposed for tests. Use -localizedWeekdaySymbols instead.
- (NSArray *)localizedSymbolsForSelector:(SEL)symbolsSelector firstWeekDay:(NSInteger)firstWeekDay;

@end
