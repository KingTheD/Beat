//
//  BeatDocumentViewController.h
//  Beat iOS
//
//  Created by Lauri-Matti Parppei on 18.2.2023.
//  Copyright © 2023 Lauri-Matti Parppei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BeatCore/BeatCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeatDocumentViewController : UIViewController <BeatEditorDelegate, UITextViewDelegate, ContinuousFountainParserDelegate>
@property (nonatomic) BeatDocumentSettings *documentSettings;

@property (nonatomic) bool printSceneNumbers;

// Editor flags
@property (nonatomic) bool revisionMode;
@property (nonatomic, readonly) bool characterInput;
@property (nonatomic) Line* characterInputForLine;
@property (nonatomic) BeatEditorMode mode;
@property (nonatomic, readonly) bool hideFountainMarkup;

@property (nonatomic) ContinuousFountainParser *parser;

@property (nonatomic) BeatPaperSize pageSize;

@property (nonatomic) Line* currentLine;
@property (nonatomic) bool moving;

@property (nonatomic) bool showSceneNumberLabels;
@property (nonatomic) bool showRevisions;
@property (nonatomic) bool showTags;
@property (nonatomic) NSString* revisionColor;

@property (nonatomic) NSDictionary<NSString*,NSString*>* characterGenders;


// Fonts
@property (strong, nonatomic) BXFont* _Nonnull courier;
@property (strong, nonatomic) BXFont* _Nonnull boldCourier;
@property (strong, nonatomic) BXFont* _Nonnull boldItalicCourier;
@property (strong, nonatomic) BXFont* _Nonnull italicCourier;


@property (nonatomic) bool skipSelectionChangeEvent;

@property (nonatomic) NSInteger sceneNumberingStartsFrom;

@end

NS_ASSUME_NONNULL_END
