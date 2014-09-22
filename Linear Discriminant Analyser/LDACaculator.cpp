//
//  LDACaculator.cpp
//  Linear Discriminant Analyser
//
//  Created by Calvin Zheng on 2014-09-13.
//  Copyright (c) 2014 Zheng. All rights reserved.
//

#include "LDACaculator.h"
#include <iostream>
#include <assert.h>
#include <math.h>
#include "matrix.h"

/// TODO: memory leaks!

LDACaculator::LDACaculator()
{
    m_n0 = 0;
    m_n1 = 0;
    m_mu0 = NULL;
    m_mu1 = NULL;
    m_sigma = NULL;
    m_omigaVector = NULL;
    
    numberOfFeatures = 0;
    numberOfTrainingData = 0;
    trainingData = NULL;
    trainingDataLabel = NULL;
}

bool LDACaculator::verifyInputs()
{
    return numberOfFeatures > 0 && numberOfTrainingData > 0 && trainingData != NULL && trainingDataLabel != NULL;
}

double* LDACaculator::caculateMu(int label)
{
    assert(label == 0 || label == 1);
    
    if (m_mu0 == NULL)
    {
        assert(m_mu1 == NULL);
        m_mu0 = new double[numberOfFeatures];
        memset(m_mu0, 0, numberOfFeatures*sizeof(double));
        m_n0 = 0;
        m_mu1 = new double[numberOfFeatures];
        memset(m_mu1, 0, numberOfFeatures*sizeof(double));
        m_n1 = 0;
        
        for (int i = 0; i < numberOfTrainingData; i++)
        {
            if (trainingDataLabel[i] == 0)
            {
                m_n0++;
                for (int j = 0; j < numberOfFeatures; j++)
                {
                    m_mu0[j] += trainingData[i][j];
                }
            }
            else if (trainingDataLabel[i] == 1)
            {
                m_n1++;
                for (int j = 0; j < numberOfFeatures; j++)
                {
                    m_mu1[j] += trainingData[i][j];
                }
            }
            else
            {
                /// we can only do binary classification right now
                assert(0);
            }
        }
        
        for (int i = 0; i < numberOfFeatures; i++)
        {
            m_mu0[i] /= m_n0;
            m_mu1[i] /= m_n1;
        }
    }
    
    return label == 0 ? m_mu0 : m_mu1;
}

double** LDACaculator::caculateSigma()
{
    if (m_sigma == NULL)
    {
        caculateMu(0);
        caculateMu(1);
        m_sigma = new double*[numberOfFeatures];
        for (int i = 0; i < numberOfFeatures; i++)
        {
            m_sigma[i] = new double[numberOfFeatures];
            memset(m_sigma[i], 0, sizeof(double)*numberOfFeatures);
        }
        
        for (int i = 0; i < numberOfTrainingData; i++)
        {
            if (trainingDataLabel[i] == 0)
            {
                for (int j = 0; j < numberOfFeatures; j++)
                {
                    for (int k = 0; k < numberOfFeatures; k++)
                    {
                        m_sigma[j][k] += ((trainingData[i][j] - m_mu0[j]) * (trainingData[i][k] - m_mu0[k])) / m_n1;
                    }
                }
            }
            else if (trainingDataLabel[i] == 1)
            {
                for (int j = 0; j < numberOfFeatures; j++)
                {
                    for (int k = 0; k < numberOfFeatures; k++)
                    {
                        m_sigma[j][k] += ((trainingData[i][j] - m_mu1[j]) * (trainingData[i][k] - m_mu1[k])) / m_n0;
                    }
                }
            }
            else
            {
                assert(0);
            }
        }
    }
    return m_sigma;
}

double* LDACaculator::caculateOmigaVector()
{
    if (m_omigaVector == NULL)
    {
        caculateSigma();
        
        m_omigaVector = new double[numberOfFeatures+1];
        
        matrix <double> M1(numberOfFeatures, numberOfFeatures);
        int k = 0;
        for (int i=0; i < M1.getactualsize(); i++)
            for (int j=0; j<M1.getactualsize(); j++)
            {
                M1.setvalue(i,j,m_sigma[i][j]);
                k++;
            }
        M1.invert();  // invert the matrix
        
        double** inversedSigma = new double*[numberOfFeatures];
        for (int i = 0; i < numberOfFeatures; i++)
        {
            inversedSigma[i] = new double[numberOfFeatures];
        }
        for (int i = 0; i < numberOfFeatures; i++)
        {
            for (int j = 0; j < numberOfFeatures; j++)
            {
                double result;
                bool success;
                M1.getvalue(i, j, result, success);
                assert(success);
                inversedSigma[i][j] = result;
            }
        }
        
        assert(inversedSigma);
        double* inversedSigmaByMuDiff = new double[numberOfFeatures];
        memset(inversedSigmaByMuDiff, 0, sizeof(double)*numberOfFeatures);
        for (int i = 0; i < numberOfFeatures; i++)
        {
            for (int j = 0; j < numberOfFeatures; j++)
            {
                inversedSigmaByMuDiff[i] += inversedSigma[i][j] * (m_mu0[j] - m_mu1[j]);
            }
        }
        
        double omiga0 = log((double)m_n1/m_n0);
        for (int i = 0; i < numberOfFeatures; i++)
        {
            omiga0 -= (m_mu0[i] + m_mu1[i]) * inversedSigmaByMuDiff[i] / 2;
        }
        
        m_omigaVector[0] = -omiga0;
        for (int i = 1; i < numberOfFeatures+1; i++)
        {
            m_omigaVector[i] = -inversedSigmaByMuDiff[i-1];
        }
    }
    return m_omigaVector;
}

int LDACaculator::testWithInput(double *testData)
{
    double logOddsRatio = m_omigaVector[0];
    for (int i = 1; i < numberOfFeatures+1; i++)
    {
        logOddsRatio += testData[i-1] * m_omigaVector[i];
    }
    
    return logOddsRatio > 0 ? 1 : 0;
}

double LDACaculator::trainingDataErrorRate()
{
    int errors = 0;
    for (int i = 0; i < numberOfTrainingData; i++)
    {
        if (testWithInput(trainingData[i]) != trainingDataLabel[i])
        {
            errors++;
        }
    }
    return (double)errors / numberOfTrainingData;
}

double LDACaculator::testDataErrorRate(double **testDataSet, int* testDataLabel, int numberOfTestData)
{
    int errors = 0;
    for (int i = 0; i < numberOfTestData; i++)
    {
        if (testWithInput(testDataSet[i]) != testDataLabel[i])
        {
            errors++;
        }
    }
    return (double)errors / numberOfTestData;
    return 0;
}