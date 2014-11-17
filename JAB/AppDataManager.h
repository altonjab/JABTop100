//
//  AppDataManager.h
//  JAB
//
//  Created by Joe Bradley on 11/16/14.
//  Copyright (c) 2014 JAB. All rights reserved.
//

// App data manager facilitates the setup and access of app data (top words)

static NSString * const AppDataManagerFetchTopWordsDataURLString = @"http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201007&sort=count+desc&apikey=82a0d8ab0d9e47ddaa26522ae95f77b0";
static NSString * const AppDataManagerLiveDataRefreshedNotification = @"AppDataManagerLiveDataRefreshedNotification";

#import <Foundation/Foundation.h>

@interface AppDataManager : NSObject

@property (nonatomic, retain) NSArray *liveData;

+ (id)sharedManager;

- (void)invokeServiceCall;

@end
