//
//  KIFJunitTestLogger.m
//  KIF
//
//  Created by Petunia.pair.dev.sfo on 10/12/12.
//
//

#import "KIFJunitTestLogger.h"

@implementation KIFJunitTestLogger

@synthesize fileHandle;
@synthesize logDirectoryPath;

static NSMutableDictionary* durations = nil;
static NSMutableDictionary* errors = nil;
static KIFTestScenario* currentScenario = nil;

- (NSString *)encodeSafeXml:(NSString*)unsafe {
    return [[[[[unsafe stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"]
               stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
              stringByReplacingOccurrencesOfString: @"'" withString: @"&#39;"]
             stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
            stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
}

- (void)initFileHandle;
{
    if (!fileHandle) {
        NSString *logsDirectory;
        if (!self.logDirectoryPath) {
            logsDirectory = [[NSFileManager defaultManager] createUserDirectory:NSLibraryDirectory];
            if (logsDirectory) {
                logsDirectory = [logsDirectory stringByAppendingPathComponent:@"Logs"];
            }
        }
        else{
            logsDirectory = self.logDirectoryPath;
        }
        
        
        if (![[NSFileManager defaultManager] recursivelyCreateDirectory:logsDirectory]) {
            logsDirectory = nil;
        }
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterLongStyle];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"."];
        dateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"."];
        NSString *fileName = [NSString stringWithFormat:@"KIF Tests %@.junit.xml", dateString];
        
        NSString *logFilePath = [logsDirectory stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[NSData data] attributes:nil];
        }
        
        fileHandle = [[NSFileHandle fileHandleForWritingAtPath:logFilePath] retain];
        
        if (fileHandle) {
            NSLog(@"JUNIT XML RESULTS AT %@", logFilePath);
        }
    }
}

- (void)appendToLog:(NSString*) data;
{
    [self initFileHandle];
    [self.fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)dealloc;
{
    [fileHandle closeFile];
    [fileHandle release];
    self.logDirectoryPath = nil;
    [errors release];
    [durations release];
    [super dealloc];
}


- (void)_init;
{
    if (durations == nil) {
        durations = [[NSMutableDictionary alloc] init];
    }
    
    if (errors == nil) {
        errors = [[NSMutableDictionary alloc] init];
    }
}

- (void)logTestingDidStart;
{
    [self _init];
}

- (void)logTestingDidFinish;
{
    NSTimeInterval totalDuration = -[self.controller.testSuiteStartDate timeIntervalSinceNow];
    
    NSString* testSuiteName = [NSString stringWithFormat:@"KIF %@", (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"iPhone" : @"iPad"];
    
    NSString* data = [NSString stringWithFormat: @"<testsuite name=\"%@\" tests=\"%d\" failures=\"%d\" time=\"%0.4f\">\n",
                      testSuiteName, [self.controller.scenarios count], self.controller.failureCount, totalDuration];
    
    [self appendToLog:data];
    
    for (KIFTestScenario* scenario in self.controller.scenarios) {
        NSNumber* duration = [durations objectForKey: [scenario description]];
        NSError* error = [errors objectForKey: [scenario description]];
        
        NSString *scenarioSteps = [[scenario.steps valueForKeyPath:@"description"] componentsJoinedByString:@"\n"];
        NSString *screenshots = @"";
        for (KIFTestStep *step in scenario.steps) {
            if (step.failingScreenshotPath != nil) {
                screenshots = [screenshots stringByAppendingFormat:@"Screenshot of failing step: %@\n",
                        [self encodeSafeXml:step.failingScreenshotPath]];
            }
        }
        NSString* errorMsg =  (error ? [NSString stringWithFormat:@"<failure message=\"%@\">%@\n%@</failure>",
                                        [self encodeSafeXml:[error localizedDescription]], [self encodeSafeXml:scenarioSteps], screenshots] : @"");
        
        NSString* description = [scenario description];
        NSString* classString = NSStringFromClass([scenario class]);
        
        data = [NSString stringWithFormat:@"<testcase name=\"%@\" class=\"%@\" time=\"%0.4f\">%@</testcase>\n",
                [self encodeSafeXml:description], [self encodeSafeXml:classString], [duration doubleValue], errorMsg];
        [self appendToLog:data];
    }
    
    [self appendToLog:@"</testsuite>\n"];
}

- (void)logDidStartScenario:(KIFTestScenario *)scenario;
{
    currentScenario = scenario;
}

- (void)logDidSkipScenario:(KIFTestScenario *)scenario;
{
    
}

- (void)logDidSkipAddingScenarioGenerator:(NSString *)selectorString;
{
    
}

- (void)logDidFinishScenario:(KIFTestScenario *)scenario duration:(NSTimeInterval)duration;
{
    NSNumber* number = [[NSNumber alloc] initWithDouble: duration];
    [durations setValue: number forKey: [scenario description]];
}

- (void)logDidFailStep:(KIFTestStep *)step duration:(NSTimeInterval)duration error:(NSError *)error;
{
    [errors setValue:error forKey:[currentScenario description]];
}

- (void)logDidPassStep:(KIFTestStep *)step duration:(NSTimeInterval)duration;
{
    
}

@end