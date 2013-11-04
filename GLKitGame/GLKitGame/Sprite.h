//
//  Sprite.h
//  GLKitGame
//
//  Created by Yuhua Mai on 11/3/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Sprite : NSObject

@property (assign) GLKVector2 position;
@property (assign) CGSize contentSize;

@property (assign) GLKVector2 moveVelocity;

- (CGRect)boundingBox;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)render;
- (void)update:(float)dt;

@end
