/**
 * Copyright (C) 2013 Qualcomm Retail Solutions, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Qualcomm
 * Retail Solutions, Inc.
 *
 * The following sample code illustrates various aspects of the FYX iOS SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided pursuant to the License Agreement for FYX Software and Developer
 * Portal AS IS, and your use of this sample code, whether as provided or with
 * any modification, is at your own risk. Neither Qualcomm Retail Solutions,
 * Inc. nor any affiliate takes any liability nor responsibility with respect
 * to the sample code, and disclaims all warranties, express and implied,
 * including without limitation warranties on merchantability, fitness for a
 * specified purpose, and against infringement.
 */
#import <Foundation/Foundation.h>

@class FYXTransmitter;

@interface FYXTransmitterManager : NSObject

/// comment for documentation
+ (void) addTransmitter:(FYXTransmitter *)transmitter
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure;

/// comment for documentation
+ (void) retrieveTransmittersSuccess:(void (^)(NSArray *transmitters))success
                             failure:(void (^)(NSError *error))failure;

/// comment for documentation
+ (void) removeTransmitter:(NSString *)transmitterIdentifier
                   success:(void (^)())success
                   failure:(void (^)(NSError *error))failure;

/// comment for documentation
+ (void) editTransmitter:(FYXTransmitter *)transmitter
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;

@end
