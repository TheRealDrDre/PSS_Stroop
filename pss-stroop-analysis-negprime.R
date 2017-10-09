

#pss <- read.table("PSS/pss-aggregated.txt", header=T, sep="\t")
pss <- read.table("pss-all.txt", header=T, sep="\t")
#raw_stroop <- read.table("StroopRedux/stroop_redux.csv", header=T, sep=",")
raw_stroop <- read.table("Stroop/stroop.csv", header=T, sep=",")
raw_stroop$X.type <- as.character(raw_stroop$X.type)
raw_stroop$Condition <- raw_stroop$X.type
raw_stroop$Condition[raw_stroop$X.type == "Conflict"] <- "Incongruent"

raw_stroop$Condition[raw_stroop$X.type == "CW"] <- "Incongruent"
raw_stroop$Condition[raw_stroop$X.type == "WC"] <- "Incongruent"
raw_stroop$Condition[raw_stroop$X.type == "Double"] <- "Incongruent"

raw_stroop <- subset(raw_stroop, raw_stroop$Condition %in% c("Neutral", "Incongruent", "NegativePrime") & raw_stroop$Correct == "TRUE")

# Brief analysis of accuracy
raw_stroop$Accuracy <- 1
raw_stroop$Accuracy[raw_stroop$Correct == FALSE] <- 0
astroop <- aggregate(raw_stroop[c("RT")], list(Subject=raw_stroop$Subj, Condition=raw_stroop$Condition), mean)


raw_stroop$RT <- as.numeric(raw_stroop$RT)
raw_stroop_trunc <- subset(raw_stroop, raw_stroop$RT > 100)
raw_stroop_trunc <- subset(raw_stroop_trunc, raw_stroop_trunc$RT < 2000)
raw_stroop_trunc <- subset(raw_stroop_trunc, raw_stroop_trunc$Correct == "TRUE")

astroop <- aggregate(raw_stroop_trunc[c("RT")], list(Subject=raw_stroop_trunc$Subj, Condition=raw_stroop_trunc$Condition), mean)

incon <- subset(astroop, astroop$Condition=="Incongruent")
neutral <- subset(astroop, astroop$Condition=="Neutral")
negprime <- subset(astroop, astroop$Condition=="NegativePrime")
names(incon)[3] <- "IncongruentRT"
names(neutral)[3] <- "NeutralRT"
names(negprime)[3] <- "NegativePrimeRT"

incon$Condition <- "Stroop"
neutral$Condition <- "Stroop"
negprime$Condition <- "Stroop"

stroop <- merge(incon, neutral, all=T)
stroop <- merge(stroop, negprime, all=T)

subj <- intersect(unique(stroop$Subject), unique(pss$Subject))

stroop_sub <- subset(stroop, stroop$Subject %in% subj)
pss_sub <- subset(pss, pss$Subject %in% subj)

final <- merge(stroop_sub, pss_sub, all=T)
final <-subset(final, !is.na(final$Avoid))
final$StroopEffect <- final$IncongruentRT - final$NeutralRT
final$NegPrimeEffect <- final$NegativePrimeRT - final$IncongruentRT
#final <- subset(final, final$StroopEffect > 0 & final$Length < 720)

hist(final$StroopEffect)
hist(final$NegPrimeEffect)


cor.test(final$StroopEffect, final$Choose)
cor.test(final$StroopEffect, final$Avoid)
cor.test(final$StroopEffect, final$Avoid-final$Choose)
cor.test(final$StroopEffect, final$Avoid+final$Choose)

cor.test(final$NegPrimeEffect, final$Choose)
cor.test(final$NegPrimeEffect, final$Avoid)

cor.test(final$NegPrimeEffect, final$Avoid-final$Choose)
cor.test(final$NegPrimeEffect, final$Avoid+final$Choose)


cor.test(final$IncongruentRT, final$Choose)
cor.test(final$IncongruentRT, final$Avoid)

cor.test(final$NeutralRT, final$Choose)
cor.test(final$NeutralRT, final$Avoid)

plot(final$Avoid, final$NegPrimeEffect, xlab="Avoid Accuracy", ylab="Negative Priming Effect (ms)",
     pch=21, col="grey25", fg="black")
grid()
m <- lm(NegPrimeEffect~Avoid, final)
i <- m$coefficients[1]
s <- m$coefficients[2]
abline(a=i, b=s, lwd=2, lty=3)
abline(h=0, col="grey")
r <- round(cor(final$Avoid, final$NegPrimeEffect), 2)
text(x=0.3, y=80, label=paste("r =", r))
title("Correlation between Negative Priming and Avoid Accuracy")

# Test by groups

final$Group <- "High Avoid"
final$Group[final$Avoid <= 0.5] <- "Low Avoid"
final$Group <- as.factor(final$Group)
plot(final$Group, final$NegPrimeEffect, ylab="Negative Priming (ms)")
grid()
means <- round(tapply(final$NegPrimeEffect, final$Group, mean), 2)
text(x=1:2, y=means+1, labels = paste(means, "ms"), adj = c(1/2,0))
title("Negative Priming in Low-Avoid and High-Avoid participants")
m <- t.test(NegPrimeEffect ~ Group, paired=F, final)
text(x=1.5, y=100, labels = paste("p =", round(m$p.value, 3)))


# Median split

final$Group <- "High Avoid"
final$Group[final$Avoid <= median(final$Avoid)] <- "Low Avoid"
final$Group <- as.factor(final$Group)
plot(final$Group, final$NegPrimeEffect, ylab="Negative Priming (ms)")
grid()
means <- round(tapply(final$NegPrimeEffect, final$Group, mean), 2)
text(x=1:2, y=means+1, labels = paste(means, "ms"), adj = c(1/2,0))
title("Negative Priming in Low-Avoid and High-Avoid participants")
m <- t.test(NegPrimeEffect ~ Group, paired=F, final)
text(x=1.5, y=100, labels = paste("p =", round(m$p.value, 3)))
