//
//  KIFJunitTestLogger.h
//  KIF
//
//  Created by Petunia.pair.dev.sfo on 10/12/12.
//
//

#import "KIFTestLogger.h"
#import "NSFileManager-KIFAdditions.h"

@interface KIFJunitTestLogger : KIFTestLogger {
    NSFileHandle* fileHandle;
}

@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, retain) NSString *logDirectoryPath;

- (void)logTestingDidStart;

- (void)logTestingDidFinish;

- (void)logDidStartScenario:(KIFTestScenario *)scenario;

- (void)logDidSkipScenario:(KIFTestScenario *)scenario;

- (void)logDidSkipAddingScenarioGenerator:(NSString *)selectorString;

- (void)logDidFinishScenario:(KIFTestScenario *)scenario duration:(NSTimeInterval)duration;

- (void)logDidFailStep:(KIFTestStep *)step duration:(NSTimeInterval)duration error:(NSError *)error;

- (void)logDidPassStep:(KIFTestStep *)step duration:(NSTimeInterval)duration;

@end