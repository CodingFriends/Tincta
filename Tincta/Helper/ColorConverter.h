//
//  ColorConverter.h
//  Dragonfly
//
//  Created by Mr. Fridge on 3/5/10.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt 
//      & Anna Neovesky Software GbR.
//

#import <Cocoa/Cocoa.h>

#define DFNeutralColorSpace 0
#define DFCalibratedSpace 1

@interface ColorConverter : NSObject {
	
	
}

+ (NSColor*) contrastingColorforColor: (NSColor*) aColor withDegree: (CGFloat) degree;
+ (NSColor*) brightenColor: (NSColor*) aColor byDegree: (CGFloat) degree;
+ (NSColor*) darkenColor: (NSColor*) aColor byDegree: (CGFloat) degree;

+ (NSColor*) grayValueForColor: (NSColor*) aColor;


+ (BOOL) isColorBright: (NSColor*) aColor;

+ (void) getRed: (CGFloat*)r green: (CGFloat*)g blue: (CGFloat*)b alpha: (CGFloat*)a forRgbColor: (NSColor*) aColor;

@end
