//
//  LDACaculator.h
//  Linear Discriminant Analyser
//
//  Created by Calvin Zheng on 2014-09-13.
//  Copyright (c) 2014 Zheng. All rights reserved.
//

#ifndef __Linear_Discriminant_Analyser__LDACaculator__
#define __Linear_Discriminant_Analyser__LDACaculator__

class LDACaculator
{
    int m_n0;
    int m_n1;
    double* m_mu0;
    double* m_mu1;
    double** m_sigma;
    double* m_omigaVector;
    
public:
    LDACaculator();
    
    // inputs
    int         numberOfFeatures;
    int         numberOfTrainingData;
    double**    trainingData;           ///< The matrix of training set, a row is an entry of data
    int*        trainingDataLabel;      ///< Should be 0 or 1 for binary classification
    
    // outputs
    bool        verifyInputs();
    double*     caculateMu(int label);  ///< numberOfFeatures based vector
    double**    caculateSigma();        ///< numberOfFeatures based square matrix
    double*     caculateOmigaVector();  ///< numberOfFeatures+1 based vector
    int         testWithInput(double* testData);    ///< testData should match numberOfFeatures, return a label
    double      trainingDataErrorRate();
    double      testDataErrorRate(double **testDataSet, int* testDataLabel, int numberOfTestData);
};

#endif /* defined(__Linear_Discriminant_Analyser__LDACaculator__) */
