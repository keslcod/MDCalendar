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

#import "NSDateFormatter+LocalizedSymbols.h"

@implementation NSDateFormatter (LocalizedSymbols)

- (NSArray *)localizedWeekdaySymbols {
	return [self localizedSymbolsForSelector:@selector(weekdaySymbols) firstWeekDay:[[NSCalendar currentCalendar] firstWeekday]];
}

- (NSArray *)localizedShortWeekdaySymbols {
	return [self localizedSymbolsForSelector:@selector(shortWeekdaySymbols) firstWeekDay:[[NSCalendar currentCalendar] firstWeekday]];
}

- (NSArray *)localizedStandaloneWeekdaySymbols {
	return [self localizedSymbolsForSelector:@selector(standaloneWeekdaySymbols) firstWeekDay:[[NSCalendar currentCalendar] firstWeekday]];
}

- (NSArray *)localizedShortStandaloneWeekdaySymbols {
	return [self localizedSymbolsForSelector:@selector(shortStandaloneWeekdaySymbols) firstWeekDay:[[NSCalendar currentCalendar] firstWeekday]];
}

- (NSArray *)localizedVeryShortStandaloneWeekdaySymbols {
	return [self localizedSymbolsForSelector:@selector(veryShortStandaloneWeekdaySymbols) firstWeekDay:[[NSCalendar currentCalendar] firstWeekday]];
}

#pragma mark - (Semi-)Private

- (NSArray *)localizedSymbolsForSelector:(SEL)symbolsSelector firstWeekDay:(NSInteger)firstWeekDay {
	NSArray *weekdays = [self valueForKey:NSStringFromSelector(symbolsSelector)];
	if (firstWeekDay < 1) {
		firstWeekDay = 1;
	}
	NSInteger weekdayIndex = firstWeekDay;
	weekdayIndex -= 1; // symbols are zero-based, firstWeekDay is not

	NSMutableArray *symbols = [NSMutableArray new];
	for (int i = 0; i < [weekdays count]; i++, weekdayIndex = weekdayIndex % 7) {
		NSString *daySymbol = [weekdays objectAtIndex:weekdayIndex];
		[symbols addObject:daySymbol];
		weekdayIndex++;
	}

	return symbols;
}

@end
