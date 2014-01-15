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

//Chair
static const float chairVertices[] =
{
    -63, 80, 5,
    -63, -80, 5,
    63, -80, 5,
    63, 80, 5
};

static const float chairTexCoords[] =
{
    0, 0,
    0, 1,
    1, 1,
    1, 0
};

static const float chairNormals[] =
{

};

static const unsigned short chairIndices[] =
{
    0, 1, 2,
    2, 3, 0
};


//Giraffe
static const float giraffeVertices[] =
{
    -77, 93, 5,
    -77, -93, 5,
    77, -93, 5,
    77, 93, 5
};

static const float giraffeTexCoords[] =
{
    0, 0,
    0, 1,
    1, 1,
    1, 0
};

static const float giraffeNormals[] =
{
    
};

static const unsigned short giraffeIndices[] =
{
    0, 1, 2,
    2, 3, 0
};


//Bin
static const float binVertices[] =
{
    -65, 65, 5,
    -65, -65, 5,
    65, -65, 5,
    65, 65, 5
};

static const float binTexCoords[] =
{
    0, 0,
    0, 1,
    1, 1,
    1, 0
};

static const float binNormals[] =
{
    
};

static const unsigned short binIndices[] =
{
    0, 1, 2,
    2, 3, 0
};

#endif
