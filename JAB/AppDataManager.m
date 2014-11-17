//
//  AppDataManager.m
//  JAB
//
//  Created by Joe Bradley on 11/16/14.
//  Copyright (c) 2014 JAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
#import "AFJSONRequestOperation.h"

@implementation AppDataManager

+ (id)sharedManager {
    static AppDataManager *sharedDataManager = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    
    return sharedDataManager;
}

- (id)init {
    if (self = [super init]) {
        // Live data is setup from json after a successful web service call
        _liveData = [[NSArray alloc] init];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////

- (void)invokeServiceCall {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:AppDataManagerFetchTopWordsDataURLString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *requestSuccess, NSHTTPURLResponse *responseSuccess, id JSON) {
        // Success...
        if (JSON && [JSON isKindOfClass:[NSArray class]]) {
            // Pass json array object to use as live data
            [self fetchedData:JSON];
        }
        
    } failure:^(NSURLRequest *requestFailure, NSHTTPURLResponse *responseFailure, NSError *error, id JSON) {
        // Failure...
        if (error) {
            // Log to console any service call relevant info
            NSLog(@"error : %@", error);
            NSLog(@"requestFailure : %@", requestFailure);
            NSLog(@"responseFailure : %@", responseFailure);
            NSLog(@"JSON : %@", JSON);

            // Call method on main thread to display UI alert view with generic error message
            [self performSelectorOnMainThread:@selector(showErrorMessage)
                                   withObject:nil
                                waitUntilDone:NO];
        }
    }];
    
    [operation start];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////

// Sets live data and posts custom notification
- (void)fetchedData:(NSArray *)responseArray {
    if (responseArray) {
        
        // Setup live data from response array, arranging from most-to-least count value
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count"
                                                                       ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.liveData = [responseArray sortedArrayUsingDescriptors:sortDescriptors];;
        
        // Send notification so table data is refreshed
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:AppDataManagerLiveDataRefreshedNotification
                                                                                             object:self]];
    }
    
    else {
        // Display error and return if there's no valid response data
        [self performSelectorOnMainThread:@selector(showErrorMessage)
                               withObject:nil
                            waitUntilDone:NO];
        
        return;
    }
}

// TODO: Setup to take parameters for various error types/messages
- (void)showErrorMessage {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                message:NSLocalizedString(@"Sorry and error occurred", nil)
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

@end
