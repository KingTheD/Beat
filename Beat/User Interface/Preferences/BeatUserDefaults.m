//
//  BeatUserDefaults.m
//  Beat
//
//  Created by Lauri-Matti Parppei on 2.10.2021.
//  Copyright © 2021 Lauri-Matti Parppei. All rights reserved.
//
/*
 
 This class aims to make life easier working with user defaults.
 userDefaults dictionary contains both the property name in DOCUMENT and in
 system user defaults, which, unfortunately, are not unified. I was young and silly.
 
 */

#import "BeatUserDefaults.h"

@implementation BeatUserDefaults

// Magnifying stuff
#define MAGNIFYLEVEL_KEY @"Magnifylevel"
#define DEFAULT_MAGNIFY 0.98
#define MAGNIFY YES

// User preferences key names
#define MATCH_PARENTHESES_KEY @"Match Parentheses"
#define SHOW_PAGENUMBERS_KEY @"Show Page Numbers"
#define SHOW_SCENE_LABELS_KEY @"Show Scene Number Labels"
#define PRINT_SCENE_NUMBERS_KEY @"Print scene numbers"
#define DARKMODE_KEY @"Dark Mode"
#define AUTOMATIC_LINEBREAKS_KEY @"Automatic Line Breaks"
#define TYPEWRITER_KEY @"Typewriter Mode"
#define FONT_STYLE_KEY @"Sans Serif"
#define HIDE_FOUNTAIN_MARKUP_KEY @"Hide Fountain Markup"
#define AUTOSAVE_KEY @"Autosave"
#define AUTOCOMPLETE_KEY @"Autocomplete"


+ (BeatUserDefaults*)sharedDefaults
{
	static BeatUserDefaults* sharedDefaults;
	if (!sharedDefaults) {
		sharedDefaults = [[BeatUserDefaults alloc] init];
	}
	return sharedDefaults;
}

+ (NSDictionary*)userDefaults {
	// For the barbaric countries still using imperial units and non-standard paper sizes,
	// we'll set default-default paper size to US Letter (1)
	NSInteger pageSize = 0;
	NSString *language = NSLocale.currentLocale.localeIdentifier;
	if ([language isEqualToString:@"en_US"]) pageSize = 1;
	
	return @{
		// Structure: Document class property name, key, default
		@"matchParentheses": @[MATCH_PARENTHESES_KEY, @YES],
		@"showPageNumbers": @[SHOW_PAGENUMBERS_KEY, @YES],
		@"autoLineBreaks": @[AUTOMATIC_LINEBREAKS_KEY, @YES],
		@"showSceneNumberLabels": @[SHOW_SCENE_LABELS_KEY, @YES],
		@"hideFountainMarkup": @[HIDE_FOUNTAIN_MARKUP_KEY, @NO],
		@"typewriterMode": @[TYPEWRITER_KEY, @NO],
		@"autosave": @[AUTOSAVE_KEY, @NO],
		@"autocomplete": @[AUTOCOMPLETE_KEY, @YES],
		@"useSansSerif": @[FONT_STYLE_KEY, @NO],
		@"printSceneNumbers": @[PRINT_SCENE_NUMBERS_KEY, @YES],
		@"headingStyleBold": @[@"headingStyleBold", @YES],
		@"headingStyleUnderline": @[@"headingStyleUnderline", @NO],
		@"defaultPageSize": @[@"defaultPageSize", @(pageSize)],
		@"disableFormatting": @[@"disableFormatting", @NO],
		@"showMarkersInScrollbar": @[@"showMarkersInScrollbar", @NO],
		@"sceneHeadingSpacing": @[@"sceneHeadingSpacing", @2],
		@"screenplayItemMore": @[@"screenplayItemMore", @"MORE"],
		@"screenplayItemContd": @[@"screenplayItemContd", @"CONT'D"],
		@"showRevisions": @[@"showRevisions", @YES],
		@"showTags": @[@"showTags", @YES],
		@"automaticContd": @[@"automaticContd", @YES],
		@"zoomLevel": @[@"zoomLevel", @0.97]
	};
}

- (instancetype)init {
	self = [super init];
	
	
	return self;
}

- (void)readUserDefaultsFor:(id)target
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	for (NSString *docKey in userDefaults.allKeys) {
		NSArray *values = userDefaults[docKey];
		
		NSString *settingKey = values[0];
		id defaultValue = values[1];
		id value;
		
		if (![NSUserDefaults.standardUserDefaults objectForKey:settingKey]) {
			// Use default
			value = defaultValue;
		} else {
			value = [NSUserDefaults.standardUserDefaults objectForKey:settingKey];
			
			if ([value isKindOfClass:NSString.class]) {
				// We need to jump through some weird backwards compatibility hoops here.
				// Let's convert "YES" and "NO" string values to bool and save them.
				NSString *str = value;
				
				if ([str isEqualToString:@"YES"] || [str isEqualToString:@"NO"]) {
					if ([str isEqualToString:@"YES"]) value = @YES;
					else value = @NO;
				}
				
				// Use default when the string is empty
				if (str.length == 0) value = defaultValue;
			}
		}
		
		[target setValue:value forKey:docKey];
	}
}

- (id)defaultValueFor:(NSString*)key {
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	if (!userDefaults[key]) {
		NSLog(@"WARNING: User default key does not exist: %@", key);
		return nil;
	}

	NSArray *values = userDefaults[key];
	return values[1];
}

- (NSInteger)getInteger:(NSString*)docKey
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[docKey];
	
	NSString *settingKey = values[0];
	if (![NSUserDefaults.standardUserDefaults objectForKey:settingKey]) {
		return [(NSNumber*)values[1] integerValue];
	} else {
		return [NSUserDefaults.standardUserDefaults integerForKey:settingKey];
	}
}
- (CGFloat)getFloat:(NSString*)docKey
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[docKey];
	
	NSString *settingKey = values[0];
	if (![NSUserDefaults.standardUserDefaults objectForKey:settingKey]) {
		return [(NSNumber*)values[1] floatValue];
	} else {
		return [NSUserDefaults.standardUserDefaults floatForKey:settingKey];
	}
}
- (BOOL)getBool:(NSString*)docKey
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[docKey];
	
	NSString *settingKey = values[0];
	if (![NSUserDefaults.standardUserDefaults objectForKey:settingKey]) {
		return [(NSNumber*)values[1] boolValue];
	} else {
		return [NSUserDefaults.standardUserDefaults boolForKey:settingKey];
	}
}
- (id)get:(NSString*)docKey {
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[docKey];
	
	NSString *settingKey = values[0];
	if (![NSUserDefaults.standardUserDefaults objectForKey:settingKey]) {
		return values[1];
	} else {
		id setting = [NSUserDefaults.standardUserDefaults objectForKey:settingKey];
		
		// Return default value for empty strings
		if ([setting isKindOfClass:NSString.class]) {
			NSString *settingStr = setting;
			if (settingStr.length == 0) return values[1];
			else return settingStr;
		}
		// Otherwise just return the saved value
		return [NSUserDefaults.standardUserDefaults valueForKey:settingKey];
	}
}

- (BOOL)isSuppressed:(NSString*)key {
	NSDictionary *suppressions = [NSUserDefaults.standardUserDefaults objectForKey:@"suppressedAlerts"];
	if (![suppressions objectForKey:key]) {
		return NO;
	} else {
		return [(NSNumber*)[suppressions objectForKey:key] boolValue];
	}
}

- (void)setSuppressed:(NSString *)key value:(bool)value {
	NSMutableDictionary *suppressions = [[NSUserDefaults.standardUserDefaults objectForKey:@"suppressedAlerts"] mutableCopy];
	if (!suppressions) suppressions = NSMutableDictionary.new;
		

	[suppressions setObject:@(value) forKey:key];
	[NSUserDefaults.standardUserDefaults setValue:suppressions forKey:@"suppressedAlerts"];
}

- (void)saveBool:(bool)value forKey:(NSString*)key
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[key];
	
	if (values) {
		NSString *settingKey = values[0];
		[NSUserDefaults.standardUserDefaults setBool:value forKey:settingKey];
	}
}
- (void)saveInteger:(NSInteger)value forKey:(NSString*)key
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[key];
	
	if (values) {
		NSString *settingKey = values[0];
		[NSUserDefaults.standardUserDefaults setInteger:value forKey:settingKey];
	}
}
- (void)saveFloat:(CGFloat)value forKey:(NSString*)key
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[key];
	
	if (values) {
		NSString *settingKey = values[0];
		[NSUserDefaults.standardUserDefaults setFloat:value forKey:settingKey];
	}
}
- (void)save:(id)value forKey:(NSString *)key {
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	NSArray *values = userDefaults[key];
	
	if (values) {
		NSString *settingKey = values[0];
		[NSUserDefaults.standardUserDefaults setValue:value forKey:settingKey];
	}
}

- (void)saveSettingsFrom:(id)target
{
	NSDictionary* userDefaults = BeatUserDefaults.userDefaults;
	
	for (NSString *docKey in userDefaults.allKeys) {
		id value = [target valueForKey:docKey];
		NSArray *keyValues = userDefaults[docKey];
		
		if (keyValues) [NSUserDefaults.standardUserDefaults setValue:value forKey:keyValues[0]];
	}
}

@end
/*
 
 never loved  this hard this fast before
 but then again
 I've never loved a boy like you before
 never had somebody sweep me off the floor
 the way you do
 
 never came this hard, this long before
 but then again
 I've never fucked a boy like you before
 never had somebody I could fuck hardcore
 until I met you
 
 */
