//
//  Sprite.m
//  GLKitGame
//
//  Created by Yuhua Mai on 11/3/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "Sprite.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface Sprite()

@property (strong) GLKBaseEffect * effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;

@end

@implementation Sprite

@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;

@synthesize position = _position;
@synthesize contentSize = _contentSize;

@synthesize moveVelocity = _moveVelocity;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if ((self = [super init])) {
        // Stores the GLKBaseEffect that will be used to render the sprite
        self.effect = effect;
        
        // Sets up the options so that when we load the texture, the origin of the texture will be considered the bottom left. If you don’t do this, the origin will be the top left (which we don’t want, because it won’t match OpenGL’s coordinate system)
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        
        // Gets the path to the file we’re going to load. The filename is passed in. Note that if you pass nil as the type, it will allow you to enter the full filename in the first parameter. Believe it or not, I just learned this after 2 years of iOS dev :P
        NSError * error;
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        
        // Finally loads the texture with the handy GLKTextureLoader class. You should appreciate this – it used to take tons of code to accomplish this
        self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
        
        // Set up Textured Quad
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(self.textureInfo.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
        newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = newQuad;
    }
    return self;
}

- (GLKMatrix4) modelMatrix {
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentSize.width/2, -self.contentSize.height/2, 0);
    return modelMatrix;
    
}

- (void)render {
    
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;

    [self.effect prepareToDraw];
    
    //set this matrix as the modelViewMatrix – and now our geometry will be translated based on what the position is set to
    self.effect.transform.modelviewMatrix = self.modelMatrix;

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)update:(float)dt {
    GLKVector2 curMove = GLKVector2MultiplyScalar(self.moveVelocity, dt);
    self.position = GLKVector2Add(self.position, curMove);
}

- (CGRect)boundingBox {
    CGRect rect = CGRectMake(self.position.x, self.position.y, self.contentSize.width, self.contentSize.height);
    return rect;
}

@end
