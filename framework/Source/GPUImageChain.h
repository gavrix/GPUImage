//
//  FIPGPUImageChain.h
//  FilteredImagePicker
//
//  Created by Sergey Gavrilyuk on 12-09-09.
//
//

#import "GPUImageOutput.h"
@class GPUImageFilter;

@interface GPUImageChain : GPUImageOutput<GPUImageInput, NSCopying>
{
    NSString* _name;
    NSMutableArray* _chainItems;
}

-(id) initWithName:(NSString*) name chainItems:(NSArray*) items;
-(id) initWithChainRepresentation:(NSDictionary*) representation;

-(void) insertFilter:(GPUImageFilter*) filter atIndex:(NSInteger) index;
-(void) removeFilter:(GPUImageFilter*) filter atIndex:(NSInteger) index;

-(NSDictionary*) chainRepresentation;

@end
