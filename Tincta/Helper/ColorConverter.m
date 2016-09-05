//
//  ColorConverter.m
//  Dragonfly
//
//  Created by Mr. Fridge on 3/5/10.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "ColorConverter.h"



@implementation ColorConverter


- (ColorConverter*) init {
	
	self = [super init];
	if (self) {
		
		
	}
	return self;
}


+ (NSColor*) brightenColor: (NSColor*) aColor byDegree: (CGFloat) degree {
    
    CGFloat red, green, blue, alpha;
	[ColorConverter getRed:&red green:&green blue:&blue alpha:&alpha forRgbColor: aColor];
    
    red = fmin(1, red + degree);
    green = fmin(1, green + degree);
    blue = fmin(1, blue + degree);
    
    return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}
+ (NSColor*) darkenColor: (NSColor*) aColor byDegree: (CGFloat) degree {
    CGFloat red, green, blue, alpha;
	[ColorConverter getRed:&red green:&green blue:&blue alpha:&alpha forRgbColor: aColor];
    
    red = fmax(0, red - degree);
    green = fmax(0, green - degree);
    blue = fmax(0, blue - degree);
    
    return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}

+ (NSColor*) contrastingColorforColor: (NSColor*) aColor withDegree: (CGFloat) degree  {
      
    if ([ColorConverter isColorBright:aColor]) {
        return [ColorConverter darkenColor:aColor byDegree:degree];
        
    } else {
        return [ColorConverter brightenColor:aColor byDegree:degree];
    }
}

+ (NSColor*) grayValueForColor: (NSColor*) aColor {
        
    CGFloat red, green, blue, alpha;
	[ColorConverter getRed:&red green:&green blue:&blue alpha:&alpha forRgbColor: aColor];
    
    CGFloat gray = 0.3 * red + 0.59 * green + 0.11 * blue;
    
    return [NSColor colorWithDeviceRed:gray green:gray blue:gray alpha:alpha];
}



+ (BOOL) isColorBright: (NSColor*) aColor {
	CGFloat red, green, blue, alpha;
	NSColor* myColor = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	[ColorConverter getRed:&red green:&green blue:&blue alpha:&alpha forRgbColor: myColor];
	if ((green > 0.8 && (red > 0.2 || blue > 0.2)) || (red > 0.9 && blue > 0.9)) {
		return YES;
	} else {
		return NO;
	}
}

+ (void) getRed: (CGFloat*)r green: (CGFloat*)g blue: (CGFloat*)b alpha: (CGFloat*)a forRgbColor: (NSColor*) aColor {
	NSColor* myColor = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	
	CGFloat components[4];
	
	[myColor getComponents:components];
	*r = components[0];
	*g = components[1];
	*b = components[2];
	*a = components[3];
}



@end
