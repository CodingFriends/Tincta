//
//  TCEncodings.m
//  Tincta
//
//  Created by Mr. Fridge on 4/27/11.
//  Copyright 2010-2016 Gabriel Reimers, Julius Peinelt
//      & Anna Neovesky Software GbR.
//

#import "TCEncodings.h"


@implementation TCEncodings

@synthesize target;

- (id)init
{
    self = [super init];
    if (self) {
        [self createEncodingsArrays];
        // Initialization code here.
        self.target = nil;
    }
    
    return self;
}




- (NSMenu*) encodingsMenuWithAction: (SEL)theAction {
    
    NSMenu* encodingsMenu = [[NSMenu alloc] initWithTitle:@"Encoding"];
    
    for (NSNumber* encNo in standardEncodings) {
        [encodingsMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    
    
    NSMenuItem* separator = [NSMenuItem separatorItem];
    [encodingsMenu addItem:separator];

    NSMenuItem* unicodeMenuItem = [[NSMenuItem alloc] initWithTitle:@"Unicode" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:unicodeMenuItem];
    
    NSMenuItem* westernMenuItem = [[NSMenuItem alloc] initWithTitle:@"Western" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:westernMenuItem];
    
    NSMenuItem* eastEuropeMenuItem = [[NSMenuItem alloc] initWithTitle:@"East European" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:eastEuropeMenuItem];
    
    NSMenuItem* nearEastMenuItem = [[NSMenuItem alloc] initWithTitle:@"Near East" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:nearEastMenuItem];
    
    NSMenuItem* indianMenuItem = [[NSMenuItem alloc] initWithTitle:@"Middle East" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:indianMenuItem];
    
    NSMenuItem* eastAsianMenuItem = [[NSMenuItem alloc] initWithTitle:@"East Asian" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:eastAsianMenuItem];
    
    NSMenuItem* weiredMenuItem = [[NSMenuItem alloc] initWithTitle:@"Weird" action:NULL keyEquivalent:@""];
    [encodingsMenu addItem:weiredMenuItem];
    
    NSMenu* unicodeMenu = [[NSMenu alloc] initWithTitle:@"Unicode"];
    for (NSNumber* encNo in unicodeEncodings) {
        [unicodeMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:unicodeMenu forItem:unicodeMenuItem];
    
    
    
    NSMenu* westernMenu = [[NSMenu alloc] initWithTitle:@"Western"];
    for (NSNumber* encNo in westernEncodings) {
        [westernMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:westernMenu forItem:westernMenuItem];
    
    
    NSMenu* eastEuropeMenu = [[NSMenu alloc] initWithTitle:@"East European"];
    for (NSNumber* encNo in eastEuropeanEncodings) {
        [eastEuropeMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:eastEuropeMenu forItem:eastEuropeMenuItem];
    
    NSMenu* nearEastMenu = [[NSMenu alloc] initWithTitle:@"Near East"];
    for (NSNumber* encNo in nearEastEncodings) {
        [nearEastMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:nearEastMenu forItem:nearEastMenuItem];
    
    
    NSMenu* indianMenu = [[NSMenu alloc] initWithTitle:@"Middle East"];
    for (NSNumber* encNo in indianEncodings) {
        [indianMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:indianMenu forItem:indianMenuItem];
    
    
    NSMenu* eastAsianMenu = [[NSMenu alloc] initWithTitle:@"East Asian"];
    for (NSNumber* encNo in eastAsianEncodings) {
        [eastAsianMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:eastAsianMenu forItem:eastAsianMenuItem];
    
    NSMenu* weiredMenu = [[NSMenu alloc] initWithTitle:@"Weird"];
    for (NSNumber* encNo in weiredEncodings) {
        [weiredMenu addItem:[self menuItemForCFStringEncoding:encNo withAction:theAction]];
    }
    [encodingsMenu setSubmenu:weiredMenu forItem:weiredMenuItem];
    
    
    return encodingsMenu;
}


- (NSMenuItem*) menuItemForCFStringEncoding: (NSNumber*) encNo withAction: (SEL) theAction {
    NSUInteger enc = [encNo unsignedIntValue];
    NSString* encName = [NSString localizedNameOfStringEncoding: CFStringConvertEncodingToNSStringEncoding((CFStringEncoding)enc)];
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:encName action:theAction keyEquivalent:@""];
    if (self.target != nil) {
        [menuItem setTarget:self.target];
    }
    [menuItem setTag:enc];
    return menuItem;
}

- (void) createEncodingsArrays {
    
    standardEncodings = @[@(kCFStringEncodingUTF8),
                         @(kCFStringEncodingUTF16),
                         @(kCFStringEncodingMacRoman),
                         @(kCFStringEncodingWindowsLatin1),
                         @(kCFStringEncodingISOLatin1),
                         @(kCFStringEncodingASCII)];
    
    westernEncodings = @[@(kCFStringEncodingASCII),
                        @(kCFStringEncodingMacRoman),
                        @(kCFStringEncodingMacRomanLatin1),
                        @(kCFStringEncodingMacCentralEurRoman),
                        @(kCFStringEncodingMacGreek),
                        @(kCFStringEncodingMacIcelandic),
                        @(kCFStringEncodingMacCeltic),
                        @(kCFStringEncodingMacGaelic),
                        
                        @(kCFStringEncodingISOLatin1),
                        @(kCFStringEncodingISOLatin2),
                        @(kCFStringEncodingISOLatin3),
                        @(kCFStringEncodingISOLatin4),
                        @(kCFStringEncodingISOLatin8),
                        @(kCFStringEncodingISOLatin9),
                        @(kCFStringEncodingISOLatinGreek),
                        
                        @(kCFStringEncodingDOSLatinUS),
                        @(kCFStringEncodingDOSGreek),
                        @(kCFStringEncodingDOSLatin1),
                        @(kCFStringEncodingDOSGreek1),
                        @(kCFStringEncodingDOSLatin2),
                        @(kCFStringEncodingDOSPortuguese),
                        @(kCFStringEncodingDOSIcelandic),
                        @(kCFStringEncodingDOSNordic),
                        @(kCFStringEncodingDOSCanadianFrench),
                        @(kCFStringEncodingDOSGreek2),
                        @(kCFStringEncodingWindowsLatin1),
                        @(kCFStringEncodingWindowsLatin2),
                        @(kCFStringEncodingWindowsGreek),
                        @(kCFStringEncodingNextStepLatin),
                        @(kCFStringEncodingMacInuit)];
    
    eastEuropeanEncodings = @[@(kCFStringEncodingMacCyrillic),
                             @(kCFStringEncodingMacGeorgian),
                             @(kCFStringEncodingMacArmenian),
                             @(kCFStringEncodingMacCroatian),
                             @(kCFStringEncodingMacRomanian),
                             @(kCFStringEncodingISOLatin7), //baltic
                             @(kCFStringEncodingISOLatin10), //south east european
                             
                             @(kCFStringEncodingMacUkrainian),
                             @(kCFStringEncodingDOSBalticRim),
                             @(kCFStringEncodingWindowsCyrillic),
                             @(kCFStringEncodingWindowsBalticRim),
                             @(kCFStringEncodingDOSRussian),
                             @(kCFStringEncodingKOI8_U),
                             @(kCFStringEncodingDOSCyrillic),
                             @(kCFStringEncodingISOLatinCyrillic)];
    
    eastAsianEncodings = @[@(kCFStringEncodingMacJapanese),
                          @(kCFStringEncodingISO_2022_JP_3),
                          @(kCFStringEncodingJIS_X0208_90),
                          @(kCFStringEncodingShiftJIS),
                          @(kCFStringEncodingShiftJIS_X0213),
                          @(kCFStringEncodingEUC_JP),
                          @(kCFStringEncodingNextStepJapanese),
                          @(kCFStringEncodingDOSJapanese),
                          
                          @(kCFStringEncodingMacKorean),
                          @(kCFStringEncodingISO_2022_KR),
                          @(kCFStringEncodingEUC_KR),
                          @(kCFStringEncodingKSC_5601_87),    
                          @(kCFStringEncodingWindowsKoreanJohab),
                          @(kCFStringEncodingDOSKorean),
                          
                          @(kCFStringEncodingMacVietnamese),
                          @(kCFStringEncodingWindowsVietnamese),
                          @(kCFStringEncodingMacThai),
                          @(kCFStringEncodingDOSThai),
                          @(kCFStringEncodingISOLatinThai),
                          @(kCFStringEncodingMacLaotian),
                          @(kCFStringEncodingMacMongolian),
                          
                          @(kCFStringEncodingBig5),//taiwan
                          @(kCFStringEncodingBig5_HKSCS_1999),
                          @(kCFStringEncodingBig5_E),
                          @(kCFStringEncodingEUC_TW),
                          @(kCFStringEncodingISO_2022_CN_EXT),
                          @(kCFStringEncodingMacChineseTrad),
                          @(kCFStringEncodingMacChineseSimp),
                          @(kCFStringEncodingEUC_CN),
                          @(kCFStringEncodingGB_2312_80),
                          @(kCFStringEncodingGBK_95),
                          @(kCFStringEncodingGB_18030_2000),
                          @(kCFStringEncodingHZ_GB_2312),
                          @(kCFStringEncodingKOI8_R),
                          @(kCFStringEncodingDOSChineseSimplif),
                          @(kCFStringEncodingDOSChineseTrad)];
    
    indianEncodings = @[@(kCFStringEncodingMacDevanagari),
                       @(kCFStringEncodingMacGurmukhi),
                       @(kCFStringEncodingMacGujarati),
                       @(kCFStringEncodingMacOriya),
                       @(kCFStringEncodingMacBengali),
                       @(kCFStringEncodingMacTamil),
                       @(kCFStringEncodingMacTelugu),
                       @(kCFStringEncodingMacKannada),
                       @(kCFStringEncodingMacSinhalese),
                       @(kCFStringEncodingMacMalayalam),
                       @(kCFStringEncodingMacBurmese),
                       @(kCFStringEncodingMacTibetan),
                       @(kCFStringEncodingMacKhmer),
                       @(kCFStringEncodingMacBurmese)];
    
    unicodeEncodings = @[@(kCFStringEncodingUTF8),
                        @(kCFStringEncodingUTF7),
                        //no localized name @(kCFStringEncodingUTF7_IMAP),
                        @(kCFStringEncodingUTF16),
                        @(kCFStringEncodingUTF16BE),
                        @(kCFStringEncodingUTF16LE),
                        @(kCFStringEncodingUTF32),
                        @(kCFStringEncodingUTF32BE),
                        @(kCFStringEncodingUTF32LE)];
    
    nearEastEncodings = @[@(kCFStringEncodingMacArabic),
                         //no localized name @(kCFStringEncodingMacExtArabic),
                         @(kCFStringEncodingMacHebrew),
                         @(kCFStringEncodingMacTurkish),
                         @(kCFStringEncodingMacFarsi),
                         @(kCFStringEncodingISOLatinArabic),
                         @(kCFStringEncodingISOLatinHebrew),
                         @(kCFStringEncodingDOSArabic),
                         @(kCFStringEncodingDOSHebrew),
                         @(kCFStringEncodingWindowsArabic),
                         @(kCFStringEncodingWindowsHebrew),
                         @(kCFStringEncodingDOSTurkish),
                         @(kCFStringEncodingWindowsLatin5),
                         @(kCFStringEncodingISOLatin5),//turkish
                         @(kCFStringEncodingMacEthiopic)];
    
    weiredEncodings = @[@(kCFStringEncodingMacSymbol),
                       @(kCFStringEncodingMacDingbats),
                       @(kCFStringEncodingMacVT100),
                       @(kCFStringEncodingMacHFS),
                       @(kCFStringEncodingANSEL),
                       @(kCFStringEncodingEBCDIC_US),
                       @(kCFStringEncodingEBCDIC_CP037),
                       @(kCFStringEncodingUTF16BE)];
    
}



@end
