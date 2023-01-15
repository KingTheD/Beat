//
//  ThemeManager.m
//  Beat
//
//  Copyright © 2019 Lauri-Matti Parppei. All rights reserved.
//  Parts copyright © 2016 Hendrik Noeller. All rights reserved.
//

/*
 
 NOTE:
 This has been rewritten to support macOS dark mode and to NOT support multiple themes.
 
 NOTE IN 2021:
 This has been rewritten to offer limited support for multiple themes.
 
 NOTE LATER IN 2021:
 Themes.plist file contains two keys: "Default" and "Custom". Both are dictionaries
 with theme values, and loadTheme: converts the dictionary to a Theme object.
 
 Basic usage:
 Theme* theme = [self loadTheme:dictionary];
 [self readTheme:theme];
 
 */

#import "ThemeManager.h"

#import <BeatThemes/BeatThemes-Swift.h>
#import <BeatDynamicColor/BeatDynamicColor.h>

#import "BeatTheme.h"

@interface ThemeManager ()
@property (strong, nonatomic) NSMutableDictionary* themes;
@property (nonatomic) NSUInteger selectedTheme;
@property (nonatomic) id<BeatTheme> fallbackTheme;
@end

@implementation ThemeManager

#define VERSION_KEY @"version"
#define SELECTED_THEME_KEY @"selectedTheme"
#define THEMES_KEY @"themes"
#define USER_THEME_FILE @"Custom Colors.plist"

#define DEFAULT_KEY @"Default"
#define CUSTOM_KEY @"Custom"

#pragma mark File Loading

+ (ThemeManager*)sharedManager
{
    static ThemeManager* sharedManager;
    if (!sharedManager) {
        sharedManager = ThemeManager.new;
    }
    return sharedManager;
}

- (ThemeManager*)init
{
    self = [super init];
    if (self) {
		[self loadThemes];
		[self readTheme];
    }
    return self;
}
-(void)loadThemes {
	_themes = NSMutableDictionary.new;
	NSDictionary* themes = [self loadThemeFile];
	
	for (NSDictionary* theme in themes[THEMES_KEY]) {
		NSString* name = theme[@"Name"];
		[_themes setValue:theme forKey:name];
	}
}
- (void)revertToSaved {
	[self loadThemes];
	[self readTheme];
	[self loadThemeForAllDocuments];
}

/// Load both bundled default theme file, as well as the one customized by user.
- (NSDictionary*)loadThemeFile
{
	NSMutableDictionary *contents = [NSMutableDictionary dictionaryWithContentsOfFile:[self bundlePlistFilePath]];
    
#if !TARGET_OS_IOS
	NSDictionary *customPlist = [self loadCustomTheme];
	if (customPlist) {
		NSMutableArray *themes = contents[THEMES_KEY];
		[themes addObject:customPlist];
	}
#endif
	
	return contents;
}

/// Read user-created theme file into a dictionary
- (NSDictionary*)loadCustomTheme {
	// Read user-created theme file
    id<BeatThemeDelegate> delegate = (id<BeatThemeDelegate>)NSApp.delegate;
	NSURL *userUrl = [delegate appDataPath:@""];
	userUrl = [userUrl URLByAppendingPathComponent:USER_THEME_FILE];
	
	NSDictionary *customPlist = [NSDictionary dictionaryWithContentsOfFile:userUrl.path];
	return customPlist;
}

/// Return the **bundled** `plist` file path
- (NSString*)bundlePlistFilePath
{
    NSBundle *bundle = [NSBundle bundleForClass:ThemeManager.class];
    return [bundle pathForResource:@"Themes" ofType:@"plist"];
}

/// Returns the default theme
-(id<BeatTheme>)defaultTheme {
	id<BeatTheme> theme = [self dictionaryToTheme:self.themes[DEFAULT_KEY]];
	return theme;
}

/// Resets current theme to the default one
-(void)resetToDefault {
	_theme = [self dictionaryToTheme:self.themes[DEFAULT_KEY]];
}

-(id<BeatTheme>)dictionaryToTheme:(NSDictionary*)values {
	// Work for the new theme model
#if TARGET_OS_IOS
	id<BeatTheme> theme = iOSTheme.new;
#else
	id<BeatTheme> theme = macOSTheme.new;
#endif
    
    
	NSDictionary *lightTheme = values[@"Light"];
	NSDictionary *darkTheme = values[@"Dark"];
	
	// Fall back to light theme if no dark settings are available
	if (!darkTheme.count) darkTheme = lightTheme;
	
#if !TARGET_OS_IOS
	// If it's the default color scheme, we'll use native accent colors for certain items
	if (@available(macOS 10.14, *)) {
		theme.selectionColor = [self dynamicColorFromColor:NSColor.controlAccentColor];
	} else {
		// Fallback on earlier versions
		theme.selectionColor = [self dynamicColorFromArray:lightTheme[@"Selection"] darkArray:darkTheme[@"Selection"]];
	}
#endif
	
	theme.backgroundColor = [self dynamicColorFromArray:lightTheme[@"Background"] darkArray:darkTheme[@"Background"]];
	theme.textColor = [self dynamicColorFromArray:lightTheme[@"Text"] darkArray:darkTheme[@"Text"]];
	theme.marginColor = [self dynamicColorFromArray:lightTheme[@"Margin"] darkArray:darkTheme[@"Margin"]];
	
	theme.commentColor  = [self dynamicColorFromArray:lightTheme[@"Comment"] darkArray:darkTheme[@"Comment"]];
	theme.invisibleTextColor  = [self dynamicColorFromArray:lightTheme[@"InvisibleText"] darkArray:darkTheme[@"InvisibleText"]];
	theme.caretColor = [self dynamicColorFromArray:lightTheme[@"Caret"] darkArray:darkTheme[@"Caret"]];
	theme.pageNumberColor = [self dynamicColorFromArray:lightTheme[@"PageNumber"] darkArray:darkTheme[@"PageNumber"]];

	theme.synopsisTextColor = [self dynamicColorFromArray:lightTheme[@"SynopsisText"] darkArray:darkTheme[@"SynopsisText"]];
	theme.sectionTextColor = [self dynamicColorFromArray:lightTheme[@"SectionText"] darkArray:darkTheme[@"SectionText"]];

	theme.outlineBackground = [self dynamicColorFromArray:darkTheme[@"OutlineBackground"] darkArray:darkTheme[@"OutlineBackground"]];
	theme.outlineHighlight = [self dynamicColorFromArray:darkTheme[@"OutlineHighlight"] darkArray:darkTheme[@"OutlineHighlight"]];
	
	theme.highlightColor = [self dynamicColorFromArray:darkTheme[@"Highlight"] darkArray:darkTheme[@"Highlight"]];
	
	theme.genderWomanColor = [self dynamicColorFromArray:darkTheme[@"Woman"] darkArray:darkTheme[@"Woman"]];
	theme.genderManColor = [self dynamicColorFromArray:darkTheme[@"Man"] darkArray:darkTheme[@"Man"]];
	theme.genderOtherColor = [self dynamicColorFromArray:darkTheme[@"Other"] darkArray:darkTheme[@"Other"]];
	theme.genderUnspecifiedColor = [self dynamicColorFromArray:darkTheme[@"Unspecified"] darkArray:darkTheme[@"Unspecified"]];
	
	return theme;
}

-(void)readTheme:(id<BeatTheme>)theme {
	/**
	 Adding new customizable values could result in null value problems.
	 We'll cross-check existing values against the default theme, and will only use the changed values for our customized theme.
	 */
	
	// First load DEFAULT theme into memory
	_theme = [self dictionaryToTheme:_themes[DEFAULT_KEY]];
	
	// Load custom theme
	id<BeatTheme> customTheme = theme;
	
	// If custom theme exists, we'll get the property names from that and overwrite those in default theme.
	if (customTheme) {
		for (NSString *property in customTheme.propertyToValue) {
			if ([customTheme valueForKey:property]) {
				[_theme setValue:[customTheme valueForKey:property] forKey:property];
			}
		}
	}
}

-(void)readTheme {
	id<BeatTheme> customTheme = [self dictionaryToTheme:_themes[CUSTOM_KEY]];
	[self readTheme:customTheme];
}

-(void)saveTheme {
#if !TARGET_OS_IOS
	id<BeatTheme> defaultTheme = [self defaultTheme];
	id<BeatTheme> customTheme = macOSTheme.new;
    id<BeatThemeDelegate> delegate = (id<BeatThemeDelegate>)NSApp.delegate;
	
	for (NSString *property in customTheme.propertyToValue) {
		DynamicColor *currentColor = [self valueForKey:property];
		DynamicColor *defaultColor = [defaultTheme valueForKey:property];
		
		// We won't save colors that are the same as default colors
		if (![currentColor isEqualToColor:defaultColor]) [customTheme setValue:currentColor forKey:property];
	}
	
	// Convert theme values into a dictionary
	NSDictionary *themeDict = [customTheme themeAsDictionaryWithName:CUSTOM_KEY];
	
	NSURL *userUrl = [delegate appDataPath:@""];
	userUrl = [userUrl URLByAppendingPathComponent:USER_THEME_FILE];
	
	[themeDict writeToFile:userUrl.path atomically:NO];
#endif
}

/// Returns a color from an array of doubles: `[r, g, b]`
- (BXColor*)colorFromArray:(NSArray*)array
{
    if (!array || array.count != 3)  return nil;
    
    NSNumber* redValue = array[0];
    NSNumber* greenValue = array[1];
    NSNumber* blueValue = array[2];
    
    double red = redValue.doubleValue / 255.0;
    double green = greenValue.doubleValue / 255.0;
    double blue = blueValue.doubleValue / 255.0;
	
#if TARGET_OS_IOS
	// iOS
	return [BXColor.clearColor initWithRed:red green:green blue:blue alpha:1.0];
#else
	// macOS
	return [BXColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
#endif
}

- (DynamicColor*)dynamicColorFromColor:(BXColor*)color {
	return [[DynamicColor new] initWithAquaColor:color darkAquaColor:color];
}

- (DynamicColor*)dynamicColorFromArray:(NSArray*)lightArray darkArray:(NSArray*)darkArray {
	if (!lightArray || !darkArray) return nil;
	
	NSNumber* redValueLight = lightArray[0];
	NSNumber* greenValueLight = lightArray[1];
	NSNumber* blueValueLight = lightArray[2];

	NSNumber* redValueDark = darkArray[0];
	NSNumber* greenValueDark = darkArray[1];
	NSNumber* blueValueDark = darkArray[2];
	
	double redLight = redValueLight.doubleValue / 255.0;
	double greenLight = greenValueLight.doubleValue / 255.0;
	double blueLight = blueValueLight.doubleValue / 255.0;
	
	double redDark = redValueDark.doubleValue / 255.0;
	double greenDark = greenValueDark.doubleValue / 255.0;
	double blueDark = blueValueDark.doubleValue / 255.0;

#if TARGET_OS_IOS
	return [[DynamicColor new]
			initWithAquaColor:[UIColor.clearColor initWithRed:redLight green:greenLight blue:blueLight alpha:1.0]
			darkAquaColor:[UIColor.clearColor initWithRed:redDark green:greenDark blue:blueDark alpha:1.0]];
#else
	return [[DynamicColor new]
			initWithAquaColor:[NSColor colorWithCalibratedRed:redLight green:greenLight blue:blueLight alpha:1.0]
			darkAquaColor:[NSColor colorWithCalibratedRed:redDark green:greenDark blue:blueDark alpha:1.0]];
#endif
}


#pragma mark - Accessing theme values

- (id<BeatTheme>)theme { return _theme; }

- (DynamicColor*)backgroundColor { return _theme.backgroundColor; }
- (DynamicColor*)marginColor { return _theme.marginColor; }
- (DynamicColor*)selectionColor { return _theme.selectionColor; }
- (DynamicColor*)textColor { return _theme.textColor; }
- (DynamicColor*)invisibleTextColor { return _theme.invisibleTextColor; }
- (DynamicColor*)caretColor { return _theme.caretColor; }
- (DynamicColor*)commentColor { return _theme.commentColor; }
- (DynamicColor*)outlineHighlight { return _theme.outlineHighlight; }
- (DynamicColor*)outlineBackground { return _theme.outlineBackground; }
- (DynamicColor*)pageNumberColor { return _theme.pageNumberColor; }
- (DynamicColor*)sectionTextColor { return _theme.sectionTextColor; }
- (DynamicColor*)synopsisTextColor { return _theme.synopsisTextColor; }
- (DynamicColor*)highlightColor { return _theme.highlightColor; }

- (DynamicColor*)genderWomanColor { return _theme.genderWomanColor; }
- (DynamicColor*)genderManColor { return _theme.genderManColor; }
- (DynamicColor*)genderOtherColor { return _theme.genderOtherColor; }
- (DynamicColor*)genderUnspecifiedColor { return _theme.genderUnspecifiedColor; }


#pragma mark - Load selected theme for ALL documents

- (void)loadThemeForAllDocuments
{
#if !TARGET_OS_IOS
	NSArray* openDocuments = NSApplication.sharedApplication.orderedDocuments;
	
	for (id<BeatThemeManagedDocument>doc in openDocuments) {
		[doc updateTheme];
	}
#endif
}

@end
