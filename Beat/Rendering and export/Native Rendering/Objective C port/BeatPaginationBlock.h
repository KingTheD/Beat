//
//  BeatPaginationBlock.h
//  Beat
//
//  Created by Lauri-Matti Parppei on 12.12.2022.
//  Copyright © 2022 Lauri-Matti Parppei. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class Line;
@interface BeatPaginationBlock : NSObject

@property (nonatomic) NSArray<Line*>* lines;

- (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
