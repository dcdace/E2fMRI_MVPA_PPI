# import BehaviouralResults.csv
# behData <- read.csv(file.choose(), header = T) 
behData <- read.csv(file = "T:/_CogNeurPhD/02-Experiment/Report/BehaviouralResults.csv", header = T) 

# Execution time differences pre- and post-training
behData$preDiffET <- (behData$ETPreTR - behData$ETPreUN)
behData$postDiffET <- (behData$ETPostTR - behData$ETPostUN)

# Linear regression between pre-diff (x) and post-diff (y)
ETfit <- lm(behData$postDiffET ~ behData$preDiffET)

sprintf("Post-Trained vs. Post-Untrained execution time: t(%d) = %.3f, p = %.3f, d = %.2f, B0 = %.0f ms, 95%% CI [%.0f, %.0f]", +
        dim(behData)[1]-1, +
        abs(coefficients(summary(ETfit))[1,3]), +
        coefficients(summary(ETfit))[1,4], +
        abs(coefficients(summary(ETfit))[1,3]/sqrt(dim(behData)[1])), +
        coefficients(summary(ETfit))[1,1], +
        (coefficients(summary(ETfit))[1,1] - coefficients(summary(ETfit))[1,2] * 2.13), +
        (coefficients(summary(ETfit))[1,1] + coefficients(summary(ETfit))[1,2] * 2.13))

# Error rate differences pre- and post-training
behData$preDiffErr <- (behData$ErrPreTR - behData$ErrPreUN)
behData$postDiffErr <- (behData$ErrPostTR - behData$ErrPostUN)

# Linear regression between pre-diff (x) and post-diff (y)
Errfit <- lm(behData$postDiffErr ~ behData$preDiffErr)

sprintf("Post-Trained vs. Post-Untrained error rate: t(%d) = %.3f, p = %.3f, d = %.2f, B0 = %.1f%%, 95%% CI [%.0f, %.0f]", +
          dim(behData)[1]-1, +
          abs(coefficients(summary(Errfit))[1,3]), +
          coefficients(summary(Errfit))[1,4], +
          abs(coefficients(summary(Errfit))[1,3]/sqrt(dim(behData)[1])), +
          coefficients(summary(Errfit))[1,1], +
          (coefficients(summary(Errfit))[1,1] - coefficients(summary(Errfit))[1,2] * 2.13), +
          (coefficients(summary(Errfit))[1,1] + coefficients(summary(Errfit))[1,2] * 2.13))

