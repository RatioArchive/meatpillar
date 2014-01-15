//
//  FlatSurface.h
//  MeatPiller
//
//  Created by Allan on 1/14/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#ifndef MeatPiller_FlatSurface_h
#define MeatPiller_FlatSurface_h

#define NUM_SURFACE_OBJECT_VERTEX 12
#define NUM_SURFACE_OBJECT_INDEX 12

static const float surfaceVertices[] =
{
    -100, 100, 5,
    -100, -100, 5,
    100, -100, 5,
    100, 100, 5
};

static const float surfaceTexCoords[] =
{
    0, 0,
    0, 1,
    1, 1,
    1, 0
};

static const float surfaceNormals[] =
{

};

static const unsigned short surfaceIndices[] =
{
    0, 1, 2,
    2, 3, 0
};



#endif
