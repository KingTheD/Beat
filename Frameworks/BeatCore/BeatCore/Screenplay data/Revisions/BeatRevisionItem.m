//
//  BeatReviewItem.m
//  Beat
//
//  Created by Lauri-Matti Parppei on 15.3.2021.
//  Copyright © 2021 Lauri-Matti Parppei. All rights reserved.
//

#import "BeatColors.h"
#import "BeatRevisionItem.h"
#import "BeatRevisions.h"

@implementation BeatRevisionItem

- (instancetype)initWithType:(RevisionType)type generation:(NSInteger)level
{
    self = [super init];
    if (self) {
        _type = type;
        _generationLevel = level;
    }
    
    return self;
}

+ (BeatRevisionItem*)type:(RevisionType)type generation:(NSInteger)level
{
    return [BeatRevisionItem.alloc initWithType:type generation:level];
}

/// Returns the key for saving
- (NSString*)key {
	if (self.type == RevisionRemovalSuggestion) return @"RemovalSuggestion";
	else if (self.type == RevisionAddition) return @"Addition";
	return @"";
}


#pragma mark - Encoding and Copying

-(void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.type forKey:@"type"];
	[coder encodeInteger:self.generationLevel forKey:@"generationLevel"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
	self = [super init];

	if (self) {
		_type = [coder decodeIntForKey:@"type"];
        _generationLevel = [coder decodeIntForKey:@"generationLevel"];
	}
	
	return self;

}

-(id)copyWithZone:(NSZone *)zone
{
    return [BeatRevisionItem.alloc initWithType:self.type generation:self.generationLevel];
}

#pragma mark - Debug

- (NSString*)description { return [NSString stringWithFormat:@"Revision: %@ (%lu)", self.key, self.generationLevel]; }

@end
/*
 
 16.3.
 16. maaliskuuta
 istun paperipinkan päällä ja katson kadulle:
 paljon kevättä
 istun paperipinkan päällä ja silloin
 aivan kuin filmiltä nään hänen silmillään...
 
 16.3
 täytyy mennä ulos postiin
 hän on sileänaama, poikanen vielä
 lunastaa tulleen paketin
 jonka sisältö muuttaa
 K A I K E N
 hän viettää
 15 seuraava vuottansa matkalla...
 
 alas
 postin
 portaita
 auringossa
 
 */
