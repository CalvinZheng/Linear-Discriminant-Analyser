Only compatible to Mac OS.

To use the app, simply double click “Linear Discriminant Analyser.app” to open, input the degree of polynomial, then drag the appropriate csv file on to the app icon on the DOCK. Only compatible to csv files found in our project. The app will lose response when calculating, after at most 1 min for 10 degree case, it will output the average training error and test error for 10-folder validation. To see more detailed results including weights vector for each fold, simply open console and check the logs. You can do another calculation by just dropping another csv file.

To check the source code, simply double click “Linear Discriminant Analyser.xcodeproj”, you need Xcode of course, core calculation is done in “LDACaculator.cpp”, some input processing is done in “LDAAppDelegate.mm”. Used a matrix inverse library in “matrix.h”, otherwise all self written codes.

Haomin (Calvin) Zheng
zheng.haomin@mail.mcgill.ca