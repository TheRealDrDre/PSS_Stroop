data1 <- read.table("alldata_fixed.txt", header=T, sep="\t")
data2 <- read.table("alldata_fixed2.txt", header=T, sep="\t")
unique(data1$Subject)
unique(data2$Subject)

pss <- merge(data1, data2, all=T)
train <- subset(pss, pss$Procedure == "Trainb")
lengths <- aggregate(train$Subject, list(Trials = train$Subject), length)
names(lengths) <- c("Subject", "Length")

test <- subset(pss, !is.na(pss$StimulusPresentation2.ACC))

choose_trials <- c("AC", "AD", "AE", "AF", "CA", "DA", "EA", "FA")
avoid_trials <- c("BC", "BD", "BE", "BF", "CB", "DB", "EB", "FB")

test_choose <- subset(test, test$TrialType %in% choose_trials)
test_avoid <- subset(test, test$TrialType %in% avoid_trials)

choose <- aggregate(test_choose$StimulusPresentation2.ACC, list(Subject=test_choose$Subject), mean)
names(choose)[2] <- "Choose"
avoid <- aggregate(test_avoid$StimulusPresentation2.ACC, list(Subject=test_avoid$Subject), mean)
names(avoid)[2] <- "Avoid"

rt <- aggregate(test$StimulusPresentation2.RT, list(Subject=test$Subject), mean)
names(rt)[2] <- "RT"
#choose$RT <- rt$RT
#avoid$RT <- rt$RT
final <- merge(choose, avoid, all=T)
final <- merge(final, lengths, all=T)

write.table(final, "pss-aggregated.txt", quote=F, col.names=T, row.names=F, sep="\t")