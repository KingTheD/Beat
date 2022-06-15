//
//  OutlineItem.m
//  Beat
//
//  Created by Lauri-Matti Parppei on 20.11.2020.
//  Copyright © 2020 Lauri-Matti Parppei. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import <TargetConditionals.h>
#import "OutlineViewItem.h"
#import "OutlineScene.h"
#import "BeatColors.h"
#import "ThemeManager.h"

#define SECTION_FONTSIZE 13.0
#define SYNOPSE_FONTSIZE 12.0
#define SCENE_FONTSIZE 11.5

#if TARGET_OS_IOS
	#import <UIKit/UIKit.h>
	#define BXFont UIFont
	#define BXColor UIColor
#else
	#import <Cocoa/Cocoa.h>
	#define BXFont NSFont
	#define BXColor NSColor
#endif


@interface OutlineViewItem ()
@property (nonatomic) OutlineScene *scene;
@end

@implementation OutlineViewItem

+ (NSMutableAttributedString*) withScene:(OutlineScene *)scene currentScene:(OutlineScene *)current {
	Line *line = scene.line;
	
	NSUInteger sceneNumberLength = 0;
	//bool currentScene = false;
	
	// Check that this scene is not omited from the screenplay
	bool omited = line.omitted;
	
	// Create padding for entry
	NSString *padding = @"";
	NSString *paddingSpace = @"";
	
	padding = [@"" stringByPaddingToLength:(scene.sectionDepth * paddingSpace.length) withString: paddingSpace startingAtIndex:0];
	
	// Section padding is slightly smaller
	if (scene.type == section) {
		if (scene.sectionDepth > 1) padding = [@"" stringByPaddingToLength:((scene.sectionDepth - 1) * paddingSpace.length) withString: paddingSpace startingAtIndex:0];
		else padding = @"";
	}
	
	// Get the string and strip any formatting
	NSMutableString *rawString = [NSMutableString stringWithString:scene.stringForDisplay];
	[rawString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [rawString length])];
	
	NSMutableAttributedString * resultString = [[NSMutableAttributedString alloc] initWithString:(rawString) ? rawString : @""];
	if (resultString.length == 0) return resultString;
	
	// Check if this scene item is the currently edited scene
	/*
	if (current.string) {
		if (current == scene) currentScene = true;
		if ([line.string isEqualToString:current.string] && line.sceneNumber == current.sceneNumber) currentScene = true;
	}
	*/
	
	
	NSString *string = rawString;
	string = [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	
	// Style the item
	if (line.type == heading) {
		//Replace "INT/EXT" with "I/E" to make the lines match nicely
		string = string.uppercaseString;
		string = [string stringByReplacingOccurrencesOfString:@"INT/EXT" withString:@"I/E"];
		string = [string stringByReplacingOccurrencesOfString:@"INT./EXT" withString:@"I/E"];
		string = [string stringByReplacingOccurrencesOfString:@"EXT/INT" withString:@"I/E"];
		string = [string stringByReplacingOccurrencesOfString:@"EXT./INT" withString:@"I/E"];

		// Create a HEADER part for the scene
		NSString *sceneHeader;
		if (!omited) {
			sceneHeader = [NSString stringWithFormat:@"%@%@.", padding, line.sceneNumber];
			string = [NSString stringWithFormat:@"%@ %@", sceneHeader, string];
		} else {
			// If scene is omited, put it in brackets
			sceneHeader = [NSString stringWithFormat:@"%@", padding];
			string = [NSString stringWithFormat:@"%@(%@)", sceneHeader, string];
		}
		
		// Put it together with the scene name
		BXFont *font = [BXFont systemFontOfSize:BXFont.smallSystemFontSize weight:NSFontWeightRegular];
		
		NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
		
		resultString = [[NSMutableAttributedString alloc] initWithString:(string) ? string : @"" attributes:fontAttributes];
		sceneNumberLength = [sceneHeader length];
		
		// Scene number will be displayed in a slightly darker shade
		if (!omited) {
			[resultString addAttribute:NSForegroundColorAttributeName value:[BeatColors color:@"gray"] range:NSMakeRange(0,[sceneHeader length])];
			[resultString addAttribute:NSForegroundColorAttributeName value:[BeatColors color:@"darkGray"] range:NSMakeRange(sceneHeader.length, resultString.length - sceneHeader.length)];
		}
		
		// If the scene is omited, make it totally gray
		else {
			[resultString addAttribute:NSForegroundColorAttributeName value:[BeatColors color:@"veryDarkGray"] range:NSMakeRange(0, resultString.length)];
		}
		
		// If this is the currently edited scene, make the whole string white. For color-coded scenes, the color will be set later.
		// if (currentScene) [resultString addAttribute:NSForegroundColorAttributeName value:BXColor.whiteColor range:NSMakeRange(0, resultString.length)];
		
	    
		// Lines without RTF formatting have uneven leading, so let's fix that.
		//[resultString applyFontTraits:NSUnitalicFontMask range:NSMakeRange(0, resultString.length)];
		//[resultString applyFontTraits:NSBoldFontMask range:NSMakeRange(0, resultString.length)];
	}
	else if (line.type == synopse) {
		if (string.length > 0) {
			string = [NSString stringWithFormat:@"%@%@", padding, string];
			
			#if !TARGET_OS_IOS
			BXFont *font = [BXFont systemFontOfSize:BXFont.smallSystemFontSize];
			#else
			BXFont *font = [BXFont italicSystemFontOfSize:SYNOPSE_FONTSIZE];
			#endif

			NSDictionary * fontAttributes = [NSDictionary.alloc initWithObjectsAndKeys:font, NSFontAttributeName, nil];
			resultString = [NSMutableAttributedString.alloc initWithString:(string) ? string : @"" attributes:fontAttributes];
			
			// Italic + gray color
			#if !TARGET_OS_IOS
			[resultString applyFontTraits:NSItalicFontMask range:NSMakeRange(0, resultString.length)];
			#endif
			
			BXColor *color = [BeatColors color:@"lightGray"];
			// if (currentScene) color = BXColor.whiteColor;
			
			[resultString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, resultString.length)];
			
		} else {
			resultString = [[NSMutableAttributedString alloc] initWithString:@""];
		}
	}
	if (line.type == section) {
		NSString* string = rawString;
		if (string.length > 0) {
			// Add padding
			string = [NSString stringWithFormat:@"%@%@", padding, string];
			
			BXFont *font = [BXFont systemFontOfSize:BXFont.smallSystemFontSize * 1.2 weight:NSFontWeightBold];
			NSDictionary * fontAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];

			resultString = [[NSMutableAttributedString alloc] initWithString:(string) ? string : @"" attributes:fontAttributes];
			
			BXColor *color = BXColor.whiteColor;
			if (line.color) {
				if (!(color = [BeatColors color:line.color])) {
					color = BXColor.whiteColor;
				}
			}
			//if (currentScene) color = BXColor.whiteColor;
			
			// Bold + highlight color
			[resultString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, resultString.length)];
						
		} else {
			resultString = [[NSMutableAttributedString alloc] initWithString:@""];
		}
	}

	// Don't color omited scenes
	if (line.color && !omited) {
		NSString *colorString = line.color.lowercaseString;
		BXColor *colorName = [BeatColors color:colorString];
		
		// If we found a suitable color, let's add it
		if (colorName != nil) {
			[resultString addAttribute:NSForegroundColorAttributeName value:colorName range:NSMakeRange(sceneNumberLength, resultString.length - sceneNumberLength)];
		}
	}
	
	if (resultString.length == 0) NSLog(@"problem %@", scene.string);
	return resultString;
}

@end
