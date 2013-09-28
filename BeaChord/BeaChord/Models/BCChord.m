//
//  BCChord.m
//  BeaChord
//
//  Created by Francesco Frison on 27/09/2013.
//  Copyright (c) 2013 NSCoderNight. All rights reserved.
//

#import "BCChord.h"
#import "BCTone.h"

@interface BCChord ()

@property(nonatomic, strong) BCTone *currentArpeggioTone;
@property (nonatomic, strong) NSEnumerator *arpeggioEnumerator;
@property(nonatomic, assign) BOOL isAscending;
@property(nonatomic, assign) BOOL isMelody;

@end

@implementation BCChord

+(instancetype)chordWithTones:(NSArray *)tones {
    BCChord *chord = [[BCChord alloc] init];
    chord.tones = tones;
    return chord;
}

+(instancetype)majorChordFromTone:(BCTone *)tone {
    // Major chords are tone + 4 sm and + 7 sm
    BCTone *thirdMajor = [tone toneByAddingSemitones:4];
    BCTone *fifth = [tone toneByAddingSemitones:7];
    
    return [self chordWithTones:@[tone, thirdMajor, fifth]];
}

+(instancetype)minorChordFromTone:(BCTone *)tone {
    // Major chords are tone + 3 sm and + 7 sm
    BCTone *thirdMinor = [tone toneByAddingSemitones:3];
    BCTone *fifth = [tone toneByAddingSemitones:7];
    
    return [self chordWithTones:@[tone, thirdMinor, fifth]];
}

- (BOOL)isEqual:(BCChord *)object {
    BCTone *thisTone = [self.tones firstObject];
    BCTone *objTone = [object.tones firstObject];
    
    BOOL isFirstSame = ((thisTone.note == objTone.note) && (thisTone.duration == objTone.duration));
    
    thisTone = [self.tones objectAtIndex:1];
    objTone = [object.tones objectAtIndex:1];
    
    BOOL isSecondSame = ((thisTone.note == objTone.note) && (thisTone.duration == objTone.duration));
    
    return (isFirstSame && isSecondSame);
}

- (void)play {
    [self.tones enumerateObjectsUsingBlock:^(BCTone *obj, NSUInteger idx, BOOL *stop) {
        [obj playCompleted:NULL];
    }];
    _isPlaying = YES;
}

- (void)stop {
    _isPlaying = NO;
    _arpeggioEnumerator = nil;
    [self.tones enumerateObjectsUsingBlock:^(BCTone *obj, NSUInteger idx, BOOL *stop) {
        [obj stop];
    }];
}

- (NSEnumerator *)arpeggioEnumerator {
    if (!_arpeggioEnumerator) {
        _arpeggioEnumerator = [self.tones objectEnumerator];
        self.isAscending = YES;
    }
    return _arpeggioEnumerator;
}

- (void)nextTone {
    if (self.currentArpeggioTone) [self.currentArpeggioTone stop];
    
    self.currentArpeggioTone = [self.arpeggioEnumerator nextObject];
    if (!self.currentArpeggioTone) {
        self.isAscending = !self.isAscending;
        if (self.isMelody && !self.isAscending) self.isAscending = YES;
        
        self.arpeggioEnumerator = (self.isAscending)? [self.tones objectEnumerator] : [self.tones reverseObjectEnumerator];
        if (!self.isMelody)[self.arpeggioEnumerator nextObject]; // discard first note as already playing
        self.currentArpeggioTone = [self.arpeggioEnumerator nextObject];
    }
    
    [self.currentArpeggioTone playCompleted:^{
        if (!self.isPlaying) return;
        [self nextTone];
    }];
    NSLog(@"tone: %ld", self.currentArpeggioTone.note);
}

- (void)arpeggio {
    _isPlaying = YES;
    self.isAscending = YES;
    [self nextTone];
}

- (void)playMelody {
    _isPlaying = YES;
    self.isMelody = YES;
    [self nextTone];
}


@end
