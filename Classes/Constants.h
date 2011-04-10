/*
 *  Constants.h
 *
 *  Created by P. Mark Anderson on 11/30/10.
 *  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
 *
 */

#define RELEASE(object) \
{ \
if(object)\
{ \
[object release];\
object=nil; \
} \
}

#define CONFIG_PERMANENT_ACCESS_TOKEN @"CONFIG_PERMANENT_ACCESS_TOKEN"
