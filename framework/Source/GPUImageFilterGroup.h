#import "GPUImageOutput.h"
#import "GPUImageFilter.h"
@class GPUImageFilter;

@interface GPUImageFilterGroup : GPUImageOutput <GPUImageInput, GPUImageFilterRepresentation>
{
    NSMutableArray *filters;
    NSArray* parametersDescriptions;
}

@property(readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *terminalFilter;
@property(readwrite, nonatomic, strong) NSArray *initialFilters;
@property(readwrite, nonatomic, strong) GPUImageOutput<GPUImageInput> *inputFilterToIgnoreForUpdates; 

// Filter management
- (void)addFilter:(GPUImageOutput<GPUImageInput> *)newFilter;
- (GPUImageOutput<GPUImageInput> *)filterAtIndex:(NSUInteger)filterIndex;

@end
