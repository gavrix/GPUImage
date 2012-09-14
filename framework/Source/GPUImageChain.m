//
//  FIPGPUImageChain.m
//  FilteredImagePicker
//
//  Created by Sergey Gavrilyuk on 12-09-09.
//
//

#import "GPUImageChain.h"
#import "GPUImage.h"


@implementation GPUImageChain


-(id) initWithName:(NSString*) name chainItems:(NSArray*) items
{
    self = [super init];
    if(self)
    {
        _name = name;
        _chainItems = [[NSMutableArray alloc] initWithArray:items] ;
        
        for(NSInteger i=0; i<[items count]-1;i++)
        {
            [[_chainItems objectAtIndex:i] addTarget:[_chainItems objectAtIndex:i+1]];
        }
    }
    return self;
}


-(id) initWithChainRepresentation:(NSDictionary*) representation
{
    NSString* name = [representation objectForKey:@"name"];
    NSArray* chainItems = [[NSMutableArray alloc] init];
    
    [(NSArray*)[representation objectForKey:@"chain"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString* className = (NSString*)[(NSDictionary*)obj objectForKey:@"class"];
         NSDictionary* params = (NSDictionary*)[(NSDictionary*)obj objectForKey:@"params"];
         
         if(NSClassFromString(className))
         {
             GPUImageFilter* filterInstance = [[NSClassFromString(className) alloc] init];
             [filterInstance setParametersValuesFrom:params];
         }
     }];

    return [self initWithName:name chainItems:chainItems];
}

-(void) insertFilter:(GPUImageFilter*) filter atIndex:(NSInteger) index
{
    NSAssert(index >=0 && index <=[_chainItems count], @"index out of bounds");
    
    
    [_chainItems insertObject:filter atIndex:index];
    
    GPUImageOutput* source = index>0?[_chainItems objectAtIndex:index-1]: [[_chainItems objectAtIndex:0] source] ;
    id<GPUImageInput> target = index<[_chainItems count]?[_chainItems objectAtIndex:index+1]:[[_chainItems lastObject] firstTarget];
    
    [source removeTarget:target];
    [source addTarget:filter];
    [filter addTarget:target];
    
}

-(void) removeFilter:(GPUImageFilter*) filter atIndex:(NSInteger) index
{
    NSAssert(index>=0 && index < [_chainItems count], @"index out of bounds");

    GPUImageOutput<GPUImageInput>* removingFilter = [_chainItems objectAtIndex:index];
    GPUImageOutput* source = [removingFilter source];
    id<GPUImageInput> target = [removingFilter firstTarget];
    
    [source removeTarget:removingFilter];
    [source addTarget:target];
    [_chainItems removeObjectAtIndex:index];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark GPUImageInput protocol implementation
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)newFrameReadyAtTime:(CMTime)frameTime
{
    [[_chainItems objectAtIndex:0] newFrameReadyAtTime:frameTime];
}

- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex
{
    [[_chainItems objectAtIndex:0] setInputTexture:newInputTexture atIndex:textureIndex] ;
}

- (NSInteger)nextAvailableTextureIndex
{
    return [[_chainItems objectAtIndex:0] nextAvailableTextureIndex];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex
{
    [[_chainItems objectAtIndex:0] setInputSize:newSize atIndex:textureIndex];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex
{
    [[_chainItems objectAtIndex:0] setInputRotation:newInputRotation atIndex:textureIndex];
}

- (CGSize)maximumOutputSize
{
    return [[_chainItems objectAtIndex:0] maximumOutputSize];
}

- (void)endProcessing
{
    [[_chainItems objectAtIndex:0] endProcessing];
}

- (BOOL)shouldIgnoreUpdatesToThisTarget
{
    return [[_chainItems objectAtIndex:0] shouldIgnoreUpdatesToThisTarget];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark GPUImageOutput implementation
////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setShouldSmoothlyScaleOutput:(BOOL)shouldSmoothlyScaleOutput
{
    [[_chainItems lastObject] setShouldSmoothlyScaleOutput:shouldSmoothlyScaleOutput];
}

-(BOOL)shouldSmoothlyScaleOutput
{
    return [[_chainItems lastObject] shouldSmoothlyScaleOutput];
}

-(void)setShouldIgnoreUpdatesToThisTarget:(BOOL)shouldIgnoreUpdatesToThisTarget
{
    [[_chainItems objectAtIndex:0] setShouldIgnoreUpdatesToThisTarget:shouldIgnoreUpdatesToThisTarget];
}




/// @name Managing targets
- (void)setInputTextureForTarget:(id<GPUImageInput>)target atIndex:(NSInteger)inputTextureIndex
{
    [[_chainItems lastObject] setInputTextureForTarget:target atIndex:inputTextureIndex];
}

/** Adds a target to receive notifications when new frames are available.
 
 The target will be asked for its next available texture.
 
 See [GPUImageInput newFrameReadyAtTime:]
 
 @param newTarget Target to be added
 */
- (void)addTarget:(id<GPUImageInput>)newTarget
{
    [[_chainItems lastObject] addTarget:newTarget];
}

/** Adds a target to receive notifications when new frames are available.
 
 See [GPUImageInput newFrameReadyAtTime:]
 
 @param newTarget Target to be added
 */
- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation
{
    [[_chainItems lastObject] addTarget:newTarget atTextureLocation:textureLocation];
}

/** Removes a target. The target will no longer receive notifications when new frames are available.
 
 @param targetToRemove Target to be removed
 */
- (void)removeTarget:(id<GPUImageInput>)targetToRemove
{
    [[_chainItems lastObject] removeTarget:targetToRemove];
}

/** Removes all targets.
 */
- (void)removeAllTargets
{
    [[_chainItems lastObject] removeAllTargets];
}

/// @name Manage the output texture

- (void)initializeOutputTexture
{
    [[_chainItems lastObject] initializeOutputTexture];
}
- (void)deleteOutputTexture
{
    [[_chainItems lastObject] deleteOutputTexture];
}

- (void)forceProcessingAtSize:(CGSize)frameSize
{
    [[_chainItems lastObject] forceProcessingAtSize:frameSize];
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize
{
    [[_chainItems lastObject] forceProcessingAtSizeRespectingAspectRatio:frameSize];
}

/// @name Still image processing

/** Retreives the currently processed image as a UIImage.
 */
- (UIImage *)imageFromCurrentlyProcessedOutput
{
    return [[_chainItems lastObject] imageFromCurrentlyProcessedOutput];
}

/** Convenience method to retreive the currently processed image with a different orientation.
 @param imageOrientation Orientation for image
 */
- (UIImage *)imageFromCurrentlyProcessedOutputWithOrientation:(UIImageOrientation)imageOrientation
{
    return [[_chainItems lastObject] imageFromCurrentlyProcessedOutputWithOrientation:imageOrientation];
}


- (void)prepareForImageCapture
{
    [[_chainItems lastObject] prepareForImageCapture];
}


-(UIImage *)imageByFilteringImage:(UIImage *)imageToFilter
{
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:imageToFilter];
    
    [self prepareForImageCapture];
    
    [stillImageSource addTarget:self];
    [stillImageSource processImage];
    
    UIImage *processedImage = [self imageFromCurrentlyProcessedOutput];
    
    [stillImageSource removeTarget:self];
    return processedImage;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying protocol
////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone
{
    NSMutableArray* arr = [NSMutableArray array];
    for(id item in _chainItems)
        [arr addObject:[[[item class] alloc] init]];
    return [[GPUImageChain allocWithZone:zone] initWithName:_name chainItems:arr];
}


-(NSDictionary*) chainRepresentation
{
    NSMutableArray* arr = [NSMutableArray array];
    
    [_chainItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        NSStringFromClass([obj class]) ,@"class",
                        [(GPUImageFilter*)obj parametersRepresentation], @"params",
                        nil]];
    }];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            _name,@"name",
            arr, @"chain",
            nil];
}
@end
