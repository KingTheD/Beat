//
//  BeatLayoutManager.h
//  Beat
//
//  Created by Lauri-Matti Parppei on 11.2.2022.
//  Copyright © 2022 Lauri-Matti Parppei. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BeatTextView.h"
#import "BeatEditorDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BeatLayoutManagerDelegate<NSLayoutManagerDelegate>
@property (nonatomic, weak) id<BeatEditorDelegate> editorDelegate;
@end

@interface BeatLayoutManager : NSLayoutManager
@property(atomic, weak) id<BeatLayoutManagerDelegate> delegate;
@property (nonatomic, weak) BeatTextView * textView;
@end

NS_ASSUME_NONNULL_END
