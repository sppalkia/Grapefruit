//
//  GPResultTableRowView.m
//  Grapefruit
//
//  Created by Shoumik Palkar on 10/31/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "GPResultTableRowView.h"
#import "immintrin.h"

@implementation GPResultTableRowView

inline void normalized_sRGBA(float *components, float *dst) {
#if TARGET_CPU_X86 || TARGET_CPU_X86_64
    float normalizer[4] = {255, 255, 255, 1};
    __m128 norm = _mm_load_ps(normalizer);
    __m128 comps = _mm_load_ps(components);
    comps = _mm_div_ps(comps, norm);
    _mm_storeu_ps(dst, comps);
#else
    dst[0] = components[0] / 255;
    dst[1] = components[1] / 255;
    dst[2] = components[2] / 255;
    dst[3] = components[3];
#endif
    
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
        
        float sRGB[4] = {0, 20, 168, 0.4};
        float* norm_components = (float *)malloc(4 * sizeof(float));
        normalized_sRGBA(sRGB, norm_components);
        
        NSColor *color = [NSColor colorWithSRGBRed:norm_components[0]
                                             green:norm_components[1]
                                              blue:norm_components[2]
                                             alpha:norm_components[3]];
        free(norm_components);
        
        [color setStroke];
        [color setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end
