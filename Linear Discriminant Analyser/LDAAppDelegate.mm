//
//  LDAAppDelegate.mm
//  Linear Discriminant Analyser
//
//  Created by Calvin Zheng on 2014-09-13.
//  Copyright (c) 2014 Zheng. All rights reserved.
//

#import "LDAAppDelegate.h"
#import "LDACaculator.h"
#import <math.h>

const int kFold = 10;
NSArray *excludeFeatures = @[];//@[@(3)];

@implementation LDAAppDelegate

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    self.textView.stringValue = @"";
    
    NSString* dataString = [NSString stringWithContentsOfFile:filename
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    assert(dataString);
    NSArray* lines = [dataString componentsSeparatedByString:@"\n"];
    NSMutableArray* trainingLines = [NSMutableArray array];
    NSMutableArray* testLines = [NSMutableArray array];
    srand([[NSDate date] timeIntervalSinceReferenceDate]);
    
    long degree = self.degree.stringValue.integerValue;
    
    double trainingErrorRate = 0, testErrorRate = 0;
    for (int crossValidate = 0; crossValidate < kFold; crossValidate++)
    {
        [testLines removeAllObjects];
        [trainingLines removeAllObjects];
        for (int i = 0; i < lines.count; i++)
        {
            if ([[lines objectAtIndex:i] isEqualToString:@""])
            {
                continue;
            }
            if ([[lines objectAtIndex:i] hasSuffix:@"2"] || [[lines objectAtIndex:i] hasSuffix:@"4"])
            {
                continue;
            }
            if (i >= lines.count/kFold*crossValidate && i < lines.count/kFold*(crossValidate+1))
//            if (i >= lines.count / 10)
            {
                [testLines addObject:[lines objectAtIndex:i]];
            }
            else
            {
                [trainingLines addObject:[lines objectAtIndex:i]];
            }
        }
        
        NSUInteger numberOfFeatures = [[trainingLines objectAtIndex:0] componentsSeparatedByString:@","].count - 1;   ///< last column is label
        numberOfFeatures -= excludeFeatures.count;
        numberOfFeatures *= degree;    ///< making polynomial
        
        double** trainingDataMatrix = new double*[trainingLines.count];
        for (int i = 0; i < trainingLines.count; i++)
        {
            trainingDataMatrix[i] = new double[numberOfFeatures];
        }
        int* trainingDataLabel = new int[trainingLines.count];
        
        for (int i = 0; i < trainingLines.count; i++)
        {
            @autoreleasepool
            {
                NSArray* numbers = [[trainingLines objectAtIndex:i] componentsSeparatedByString:@","];
                for (int j = 0, matrxJ = 0; j < numbers.count - 1; j++, matrxJ++)
                {
                    if ([excludeFeatures containsObject:@(j)])
                    {
                        matrxJ--;
                        continue;
                    }
                    for (int k = 1; k <= degree; k++)
                    {
                        trainingDataMatrix[i][degree*matrxJ+k-1] = pow([[numbers objectAtIndex:j] doubleValue], k);
                    }
                }
                trainingDataLabel[i] = [numbers.lastObject intValue] >= 3 ? 1 : 0;
                assert(trainingDataLabel[i] == 0||trainingDataLabel[i] == 1);
            }
        }
        
        LDACaculator aCalculator;
        aCalculator.numberOfFeatures = (int)numberOfFeatures;
        aCalculator.numberOfTrainingData = (int)trainingLines.count;
        aCalculator.trainingData = trainingDataMatrix;
        aCalculator.trainingDataLabel = trainingDataLabel;
        
        NSMutableString* omigaString = [NSMutableString stringWithString:@"Omiga Vector\n"];
        for (int i = 0; i < aCalculator.numberOfFeatures + 1; i++)
        {
            [omigaString appendFormat:@"%.4f,", aCalculator.caculateOmigaVector()[i]];
        }
        NSLog(@"\n%@\nTraining Error Rate\n%.5f", omigaString, aCalculator.trainingDataErrorRate());
        
        trainingErrorRate += aCalculator.trainingDataErrorRate();
        
        double** testDataMatrix = new double*[testLines.count];
        for (int i = 0; i < testLines.count; i++)
        {
            testDataMatrix[i] = new double[numberOfFeatures];
        }
        int* testDataLabel = new int[testLines.count];
        
        for (int i = 0; i < testLines.count; i++)
        {
            @autoreleasepool
            {
                NSArray* numbers = [[testLines objectAtIndex:i] componentsSeparatedByString:@","];
                for (int j = 0, matrxJ = 0; j < numbers.count - 1; j++, matrxJ++)
                {
                    if ([excludeFeatures containsObject:@(j)])
                    {
                        matrxJ--;
                        continue;
                    }
                    for (int k = 1; k <= degree; k++)
                    {
                        testDataMatrix[i][degree*matrxJ+k-1] = pow([[numbers objectAtIndex:j] doubleValue], k);
                    }
                }
                testDataLabel[i] = [numbers.lastObject intValue] >= 3 ? 1 : 0;
                assert(testDataLabel[i] == 0||testDataLabel[i] == 1);
            }
        }
        
        NSLog(@"\nTest Data Error Rate\n%.5f", aCalculator.testDataErrorRate(testDataMatrix, testDataLabel, (int)testLines.count));
        
        testErrorRate += aCalculator.testDataErrorRate(testDataMatrix, testDataLabel, (int)testLines.count);
        
        for (int i = 0; i < trainingLines.count; i++)
        {
            delete [] trainingDataMatrix[i];
        }
        delete [] trainingDataMatrix;
        delete [] trainingDataLabel;
        
        for (int i = 0; i < testLines.count; i++)
        {
            delete [] testDataMatrix[i];
        }
        delete [] testDataMatrix;
        delete [] testDataLabel;
    }
    
    testErrorRate /= kFold;
    trainingErrorRate /= kFold;
    
    self.textView.stringValue = [NSString stringWithFormat:
                                 @"Calculation Complete!\nAverage Training Error: %.5f\n%d-Fold Validation Result: %.5f\nPlease see console for detailed results!",
                                 trainingErrorRate, kFold, testErrorRate];
    
    NSLog(@"\nAverage Training Error: %.5f\n%d-Fold Validation Result: %.5f", trainingErrorRate, kFold, testErrorRate);

    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)stepped:(NSStepper *)sender
{
    self.degree.stringValue = [NSString stringWithFormat:@"%ld", [sender integerValue]];
}
@end
