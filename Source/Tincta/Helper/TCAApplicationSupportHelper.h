//
//  TCApplicationSupportHelper.h
//  Tincta Pro
//
//  Created by Julius Peinelt on 6/20/13.
//
//

@interface TCAApplicationSupportHelper : NSObject

+ (NSString* )applicationSupportSyntaxDefinitionsDirectory;
+ (NSString*)applicationSupportColorSchemesDirectory;

+ (NSString* )applicationSupportDirectory;
+ (NSString* )findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString* )appendComponent
                              error:(NSError**)errorOut;
@end
