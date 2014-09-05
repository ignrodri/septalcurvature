//
//  CnicUiaSeptumCurvatureFilter.m
//  CnicUiaSeptumCurvature
//
//  Copyright (c) 2013 CNIC. All rights reserved.
//

#import "CnicUiaSeptumCurvatureFilter.h"

@implementation CnicUiaSeptumCurvatureFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
    NSMutableArray  *roiSeriesList;
    NSMutableArray  *roiImageList;
    NSMutableArray  *xpoints;
    
    float xa, xb, xc, xm, ya, yb, yc, ym, ma, mb, mc, md, me, mf, r;
    
    ROI*            roi = 0L;
    
    NSArray         *pixList = [viewerController pixList: 0];
    int             curSlice = [[viewerController imageView] curImage];
    DCMPix          *curPix = [pixList objectAtIndex: curSlice];
    
    roiSeriesList = [viewerController roiList];
    
    // search through all ROIs in current slice
    roiImageList = [roiSeriesList objectAtIndex: curSlice];
    
    
    if ([roiImageList count] == 1)
    {
        roi = [roiImageList objectAtIndex:0];
        xpoints = [roi points];
        if ([xpoints count] == 3)
        {
            xa = [curPix pixelSpacingX] * [[xpoints objectAtIndex:0] x] / 10;
            xb = [curPix pixelSpacingX] * [[xpoints objectAtIndex:1] x] / 10;
            xc = [curPix pixelSpacingX] * [[xpoints objectAtIndex:2] x] / 10;
            ya = [curPix pixelSpacingY] * [[xpoints objectAtIndex:0] y] / 10;
            yb = [curPix pixelSpacingY] * [[xpoints objectAtIndex:1] y] / 10;
            yc = [curPix pixelSpacingY] * [[xpoints objectAtIndex:2] y] / 10;
            
            ma = 2 * (xb - xa);
            mb = 2 * (yb - ya);
            mc = 2 * (xc - xb);
            md = 2 * (yc - yb);
            me = xb * xb + yb * yb - xa * xa - ya * ya;
            mf = xc * xc + yc * yc - xb * xb - yc * yc;
            
            xm = (me * md - mb * mf) / (ma * md - mb * mc);
            ym = (ma * mf - me * mc) / (ma * md - mb * mc);
            
            r = sqrt((xa - xm) * (xa - xm) + (ya - ym) * (ya - ym));
            NSRunInformationalAlertPanel(@"Curvature",
                                             [NSString stringWithFormat:
                                              @"Curvature is %f cm ^ -1.",
                                              1 / r],
                                             @"OK", 0L, 0L);
    
        }
        else
        {
            NSRunInformationalAlertPanel(@"Incorrect number of points",
                                         [NSString stringWithFormat:
                                          @"Three points need to be drawn, %ld points found.\nPlease draw three points at the septum.",
                                          [xpoints count]],
                                         @"OK", 0L, 0L);
        }
    }
    else {
        NSRunInformationalAlertPanel(@"Incorrect number of ROIs",
                                     [NSString stringWithFormat:
                                      @"One ROI needs to be drawn, %ld ROIs found.\nPlease draw one ROI corresponding to the septum.",
                                      [roiImageList count]],
                                     @"OK", 0L, 0L);
        
    }
    
    // We modified the view: OsiriX please update the display!
    [viewerController needsDisplayUpdate];
    
    return 0;
}

@end
