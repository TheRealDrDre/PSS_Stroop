

pss <- read.table("PSS/pss-aggregated.txt", header=T, sep="\t")
#raw_stroop <- read.table("StroopRedux/stroop_redux.csv", header=T, sep=",")
raw_stroop <- read.table("Stroop/stroop.csv", header=T, sep=",")
raw_stroop$X.type <- as.character(raw_stroop$X.type)
raw_stroop$Condition <- raw_stroop$X.type
raw_stroop$Condition[raw_stroop$X.type == "NegativePrime"] <- "Incongruent"
raw_stroop$Condition[raw_stroop$X.type == "Conflict"] <- "Incongruent"

raw_stroop$Condition[raw_stroop$X.type == "CW"] <- "Incongruent"
raw_stroop$Condition[raw_stroop$X.type == "WC"] <- "Incongruent"
raw_stroop$Condition[raw_stroop$X.type == "Double"] <- "Incongruent"

raw_stroop <- subset(raw_stroop, raw_stroop$Condition %in% c("Neutral", "Incongruent") & raw_stroop$Correct == "TRUE")
raw_stroop$RT <- as.numeric(raw_stroop$RT)
raw_stroop <- subset(raw_stroop, raw_stroop$RT > 50)
raw_stroop <- subset(raw_stroop, raw_stroop$RT < 2000)

astroop <- aggregate(raw_stroop[c("RT")], list(Subject=raw_stroop$Subj, Condition=raw_stroop$Condition), mean)

incon <- subset(astroop, astroop$Condition=="Incongruent")
neutral <- subset(astroop, astroop$Condition=="Neutral")
names(incon)[3] <- "IncongruentRT"
names(neutral)[3] <- "NeutralRT"
incon$Condition <- "Stroop"
neutral$Condition <- "Stroop"
stroop <- merge(incon, neutral, all=T)

subj <- intersect(unique(stroop$Subject), unique(pss$Subject))

stroop_sub <- subset(stroop, stroop$Subject %in% subj)
pss_sub <- subset(pss, pss$Subject %in% subj)

final <- merge(stroop_sub, pss_sub, all=T)
final$StroopEffect <- final$IncongruentRT - final$NeutralRT
final <- subset(final, final$StroopEffect > 0 & final$Length < 720)

hist(final$StroopEffect)

cor.test(final$StroopEffect, final$Choose)
cor.test(final$StroopEffect, final$Avoid)
cor.test(final$StroopEffect, final$Avoid-final$Choose)
cor.test(final$StroopEffect, final$Avoid+final$Choose)


cor.test(final$IncongruentRT, final$Choose)
cor.test(final$IncongruentRT, final$Avoid)

cor.test(final$NeutralRT, final$Choose)
cor.test(final$NeutralRT, final$Avoid)
