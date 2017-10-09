# Parse all the PSS file scripts

library(rprime)

files <- dir()
logs <- grep("Implicit Decision", files)

pss <- NULL

for (file in files[logs]) {
  lines <- read_eprime(file)
  print(file)
  df <- to_data_frame(FrameList(lines))
  df$Subject <- df$Subject[1]
  if (is.null(pss)) {
    pss <- df
  } else {
    pss <- merge(pss, df, all=T)
  }
}

train <- subset(pss, pss$Procedure == "Trainb")
lengths <- aggregate(train$Subject, list(Trials = train$Subject), length)
names(lengths) <- c("Subject", "Length")

test <- subset(pss, !is.na(pss$StimulusPresentation2.ACC))
test$StimulusPresentation2.ACC <- as.numeric(test$StimulusPresentation2.ACC)

choose_trials <- c("AC", "AD", "AE", "AF", "CA", "DA", "EA", "FA")
avoid_trials <- c("BC", "BD", "BE", "BF", "CB", "DB", "EB", "FB")

test_choose <- subset(test, test$TrialType %in% choose_trials)
test_avoid <- subset(test, test$TrialType %in% avoid_trials)

choose <- aggregate(test_choose$StimulusPresentation2.ACC, list(Subject=test_choose$Subject), mean)
names(choose)[2] <- "Choose"
avoid <- aggregate(test_avoid$StimulusPresentation2.ACC, list(Subject=test_avoid$Subject), mean)
names(avoid)[2] <- "Avoid"

final <- merge(choose, avoid, all=T)
final <- merge(final, lengths, all=T)

write.table(final, "pss-aggregated-3.txt", quote=F, col.names=T, row.names=F, sep="\t")