//
//  LDAAppDelegate.mm
//  Linear Discriminant Analyser
//
//  Created by Calvin Zheng on 2014-09-13.
//  Copyright (c) 2014 Zheng. All rights reserved.
//

#import "LDAAppDelegate.h"
#import "LDACaculator.h"

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
    for (int i = 0; i < lines.count; i++)
    {
        if (rand()%100 < 10)
        {
            [testLines addObject:[lines objectAtIndex:i]];
        }
        else
        {
            [trainingLines addObject:[lines objectAtIndex:i]];
        }
    }
    
    NSUInteger numberOfFeatures = [[trainingLines objectAtIndex:0] componentsSeparatedByString:@","].count - 1;   ///< last column is label
    numberOfFeatures -= 2;     ///< leave out some features
    
    double** trainingDataMatrix = new double*[trainingLines.count];
    for (int i = 0; i < trainingLines.count; i++)
    {
        trainingDataMatrix[i] = new double[numberOfFeatures];
    }
    int* trainingDataLabel = new int[trainingLines.count];
    
    for (int i = 0; i < trainingLines.count; i++)
    {
        NSArray* numbers = [[trainingLines objectAtIndex:i] componentsSeparatedByString:@","];
        for (int j = 0; j < numbers.count - 1; j++)
        {
            int jIndex = j;
            if (j == 3)
            {
                continue;
            }
            if (j > 3)
            {
                jIndex--;
            }
//            if (j >= 5)
//            {
//                jIndex--;
//            }
            if (j >= 12)
            {
                continue;
            }
            trainingDataMatrix[i][jIndex] = (j == -1 ? [[numbers objectAtIndex:j] doubleValue] / 10.0 : [[numbers objectAtIndex:j] doubleValue]);
        }
        trainingDataLabel[i] = [numbers.lastObject intValue] - 1;
        assert(trainingDataLabel[i] == 0||trainingDataLabel[i] == 1);
    }
    
    LDACaculator aCalculator;
    aCalculator.numberOfFeatures = (int)numberOfFeatures;
    aCalculator.numberOfTrainingData = (int)trainingLines.count;
    aCalculator.trainingData = trainingDataMatrix;
    aCalculator.trainingDataLabel = trainingDataLabel;
    
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\nU0        U1\n"];
    for (int i = 0; i < aCalculator.numberOfFeatures; i++)
    {
        self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:
                                     @"%.3f    %.3f\n",
                                     aCalculator.caculateMu(0)[i],
                                     aCalculator.caculateMu(1)[i]];
    }
    
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\nSigma Matrix\n"];
    for (int i = 0; i < aCalculator.numberOfFeatures; i++)
    {
        for (int j = 0; j < aCalculator.numberOfFeatures; j++)
        {
            self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"%.3f    ", aCalculator.caculateSigma()[i][j]];
        }
        self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\n"];
    }
    
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\nOmiga Vector\n"];
    for (int i = 0; i < aCalculator.numberOfFeatures + 1; i++)
    {
        self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"%.4f,", aCalculator.caculateOmigaVector()[i]];
    }
    
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\n Training Error Rate\n"];
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"%.5f", aCalculator.trainingDataErrorRate()];
    
    double** testDataMatrix = new double*[testLines.count];
    for (int i = 0; i < testLines.count; i++)
    {
        testDataMatrix[i] = new double[numberOfFeatures];
    }
    int* testDataLabel = new int[testLines.count];
    
    for (int i = 0; i < testLines.count; i++)
    {
        NSArray* numbers = [[testLines objectAtIndex:i] componentsSeparatedByString:@","];
        for (int j = 0; j < numbers.count - 1; j++)
        {
            int jIndex = j;
            if (j == 3)
            {
                continue;
            }
            if (j > 3)
            {
                jIndex--;
            }
            if (j >= 12)
            {
                continue;
            }
            testDataMatrix[i][jIndex] = (j == -1 ? [[numbers objectAtIndex:j] doubleValue] / 10.0 : [[numbers objectAtIndex:j] doubleValue]);
        }
        testDataLabel[i] = [numbers.lastObject intValue] - 1;
        assert(testDataLabel[i] == 0||testDataLabel[i] == 1);
    }
    
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:@"\n Test Data Error Rate\n"];
    self.textView.stringValue = [self.textView.stringValue stringByAppendingFormat:
                                 @"%.5f", aCalculator.testDataErrorRate(testDataMatrix, testDataLabel, (int)testLines.count)];

    NSLog(@"%@", self.textView.stringValue);

    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

@end
