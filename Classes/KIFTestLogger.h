//
//  KIFTestLogger.h
//  KIF
//
//  Created by Petunia.pair.dev.sfo on 10/12/12.
//
//

#import <Foundation/Foundation.h>
#import "KIFTestController.h"
#import "KIFTestScenario.h"
#import "KIFTestStep.h"

@interface KIFTestLogger : NSObject {
    KIFTestController* controller;
}

@property (nonatomic,retain) KIFTestController *controller;

- (void) setupController: (KIFTestController*) controller;

- (void)logTestingDidStart;

- (void)logTestingDidFinish;

- (void)logDidStartScenario:(KIFTestScenario *)scenario;

- (void)logDidSkipScenario:(KIFTestScenario *)scenario;

- (void)logDidSkipAddingScenarioGenerator:(NSString *)selectorString;

- (void)logDidFinishScenario:(KIFTestScenario *)scenario duration:(NSTimeInterval)duration;

- (void)logDidFailStep:(KIFTestStep *)step duration:(NSTimeInterval)duration error:(NSError *)error;

- (void)logDidPassStep:(KIFTestStep *)step duration:(NSTimeInterval)duration;

@end