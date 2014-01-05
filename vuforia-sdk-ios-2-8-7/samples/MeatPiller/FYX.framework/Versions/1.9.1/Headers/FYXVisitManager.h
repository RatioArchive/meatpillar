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
#import "FYXVisit.h"


@protocol FYXVisitDelegate <NSObject>

@optional
/// Delegate callback to notify when a Visit has begun
- (void)didArrive:(FYXVisit *)visit;

/// Delegate callback to notify when a Visit has been updated
- (void)receivedSighting:(FYXVisit *)visit updateTime:(NSDate *)updateTime RSSI:(NSNumber *)RSSI;

/// Delegate callback to notify when a Visit has ended and the beacon has departed
- (void)didDepart:(FYXVisit *)visit;

@end

@interface FYXVisitManager:NSObject

/// Visit Manager Option Keys
extern NSString * const FYXVisitOptionArrivalRSSIKey;
extern NSString * const FYXVisitOptionDepartureRSSIKey;
extern NSString * const FYXVisitOptionDepartureIntervalInSecondsKey;
extern NSString * const FYXvVisitOptionBackgroundDepartureIntervalInSecondsKey;

/// The manager will notify the delegate of any Visit Events
@property(weak, nonatomic) id<FYXVisitDelegate> delegate;

/// The manager will start listening for sightings and notify delegate of visits
- (void)start;

/// The manager will start listening for sightings and notify delegate of visits for the given options
- (void)startWithOptions:(NSDictionary *)options;

/// The manager will stop listening for sightings and stop notifying delegate of visits
- (void)stop;

@end
