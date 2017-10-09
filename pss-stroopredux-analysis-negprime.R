

pss <- read.table("PSS2/pss-aggregated2.txt", header=T, sep="\t")
raw_stroop <- read.table("StroopRedux/stroop_redux.csv", header=T, sep=",")
#raw_stroop <- read.table("Stroop/stroop.csv", header=T, sep=",")
raw_stroop$X.type <- as.character(raw_stroop$X.type)
raw_stroop$Condition <- raw_stroop$X.type
#raw_stroop$Condition[raw_stroop$X.type == "Conflict"] <- "Incongruent"

#raw_stroop$Condition[raw_stroop$X.type == "CW"] <- "Incongruent"
#raw_stroop$Condition[raw_stroop$X.type == "WC"] <- "Incongruent"
#raw_stroop$Condition[raw_stroop$X.type == "Double"] <- "Incongruent"

raw_stroop <- subset(raw_stroop, raw_stroop$Condition %in% c("Neutral", "Incongruent", "NegativePrime", "CW", "WC", "Double") & raw_stroop$Correct == "TRUE")
raw_stroop$RT <- as.numeric(raw_stroop$RT)
raw_stroop_trunc <- subset(raw_stroop, raw_stroop$RT > 100)
raw_stroop_trunc <- subset(raw_stroop_trunc, raw_stroop_trunc$RT < 3000)
raw_stroop_trunc <- subset(raw_stroop_trunc, raw_stroop_trunc$Correct == "TRUE")

astroop <- aggregate(raw_stroop_trunc[c("RT")], list(Subject=raw_stroop_trunc$Subj, Condition=raw_stroop_trunc$Condition), mean)

incon <- subset(astroop, astroop$Condition=="Incongruent")
neutral <- subset(astroop, astroop$Condition=="Neutral")
double <- subset(astroop, astroop$Condition=="Double")
cw <- subset(astroop, astroop$Condition=="CW")
wc <- subset(astroop, astroop$Condition=="WC")
names(incon)[3] <- "IncongruentRT"
names(neutral)[3] <- "NeutralRT"
names(double)[3] <- "DoubleRT"
names(cw)[3] <- "CWRT"
names(wc)[3] <- "WCRT"


incon$Condition <- "Stroop"
neutral$Condition <- "Stroop"
double$Condition <- "Stroop"
wc$Condition <- "Stroop"
cw$Condition <- "Stroop"

stroop <- merge(incon, neutral, all=T)
stroop <- merge(stroop, double, all=T)
stroop <- merge(stroop, wc, all=T)
stroop <- merge(stroop, cw, all=T)

subj <- intersect(unique(stroop$Subject), unique(pss$Subject))

stroop_sub <- subset(stroop, stroop$Subject %in% subj)
pss_sub <- subset(pss, pss$Subject %in% subj)

final <- merge(stroop_sub, pss_sub, all=T)
final$StroopEffect <- final$IncongruentRT - final$NeutralRT
final$NegPrimeEffect <- final$WCRT - final$IncongruentRT
final$PosPrimeEffect <- final$CWRT - final$IncongruentRT
final$DoublePrimeEffect <- final$DoubleRT - final$IncongruentRT
#final <- subset(final, final$StroopEffect > 0 & final$Length < 720)

final <- subset(final, !is.na(final$Avoid))

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

plot(final$Avoid, final$PosPrimeEffect, xlab="Avoid Accuracy", ylab="Positive Priming Effect (ms)",
     pch=21, col="grey25", fg="black")
grid()
m <- lm(NegPrimeEffect~Avoid, final)
i <- m$coefficients[1]
s <- m$coefficients[2]
abline(a=i, b=s, lwd=2, lty=3)
abline(h=0, col="grey")
r <- round(cor(final$Avoid, final$NegPrimeEffect), 2)
text(x=0.3, y=80, label=paste("r =", r))

# Test by groups

final$Group <- "High D2"
final$Group[final$Avoid <= 0.5] <- "Low D2"
final$Group <- as.factor(final$Group)
plot(final$Group, final$NegPrimeEffect)
t.test(NegPrimeEffect ~ Group, paired=F, final)

final$Group <- as.factor(final$Group)
plot(final$Group, final$PosPrimeEffect)
t.test(PosPrimeEffect ~ Group, paired=F, final)

final$Group <- as.factor(final$Group)
plot(final$Group, final$DoublePrimeEffect)
t.test(DoublePrimeEffect ~ Group, paired=F, final)

astroop$Condition <- as.factor(astroop$Condition)