rm(list = ls())
gc()
library(ndjson)
library(Hmisc)
library(anytime)
library(lubridate)
library(dplyr)
library(magrittr)
#system.time(df <- ndjson::stream_in("ggevent.json"))
df<-read.csv("Features.csv")
dim(df)
View(df)
df$params<-NULL
colnames(df)<- c('gameid','timestamp','ai5','debug','random','mobile_vesion','eventtype','ts')
df$debug<-NULL
df$random<-NULL
names(df)
str(df)
df$ai5<-as.factor(df$ai5)
df$mobile_vesion<-as.factor(df$mobile_vesion)
df$eventtype<-as.factor(df$eventtype)
df$timestamp<-anytime(df$timestamp)
cnt_val= 0
cnt_inval= 0
cnt_mul_ses = 0
avg_time <- data.frame("time" = integer(), stringsAsFactors=FALSE)
gameid<- data.frame("gameid" = integer(), stringsAsFactors=FALSE)
game_ttl <- data.frame("gameid" = integer(), stringsAsFactors=FALSE)
game_non_cons <- data.frame("gameid" = integer(), stringsAsFactors=FALSE)

for (i in 1:(nrow(df)-1)) { 
  if (((df[i+1,"ai5"]==df[i,"ai5"]) && (df[i+1,"gameid"]==df[i,"gameid"])) && ((df[i,"eventtype"] == "ggstart") && (df[i+1,"eventtype"]== "ggstop"))&&((as.numeric(df[i+1,"timestamp"]-df[i,"timestamp"])) >= 60))
  {
    gameid[nrow(gameid) + 1, ] <- c( df[i+1,"gameid"])
    avg_time[nrow(avg_time) + 1, ] <- c(df[i+1,"timestamp"]-df[i,"timestamp"])
    inc(cnt_val)=1
  }
  else if (((df[i+1,"ai5"]==df[i,"ai5"]) && (df[i+1,"gameid"]==df[i,"gameid"])) && ((df[i,"eventtype"] == "ggstart") && (df[i+1,"eventtype"]== "ggstop")) &&((as.numeric(df[i+1,"timestamp"]-df[i,"timestamp"])) >= 30)) 
  {
    gameid[nrow(gameid) + 1, ] <- c( df[i+1,"gameid"])
    avg_time[nrow(avg_time) + 1, ] <- c(df[i+1,"timestamp"]-df[i,"timestamp"])
    inc(cnt_mul_ses)=1 
  }
  else if (((df[i+1,"ai5"]==df[i,"ai5"]) && (df[i+1,"gameid"]==df[i,"gameid"])) && ((df[i,"eventtype"] == "ggstart") && (df[i+1,"eventtype"]== "ggstop")) && ((as.numeric(df[i+1,"timestamp"]-df[i,"timestamp"])) < 30)) 
  {
    game_ttl[nrow(game_ttl) + 1, ] <- c( df[i+1,"gameid"])
    inc(cnt_inval)= 1 
  }
  else if (((df[i+1,"ai5"]==df[i,"ai5"]) && (df[i+1,"gameid"]==df[i,"gameid"])) && ((df[i,"eventtype"] == "ggstart") && (df[i+1,"eventtype"]== "ggstart")))
  {
    game_ttl[nrow(game_ttl) + 1, ] <- c( df[i+1,"gameid"])
    inc(cnt_inval)= 1 
  }
  else { next }
}

sprintf("Valid Session: %i",cnt_val)
sprintf('invalid session: %i',cnt_inval)
sprintf('multiple session: %i',cnt_mul_ses)
st = data.frame(gameid)
colnames(st)<-c("gameid")
time = data.frame(avg_time)
colnames(time)<-c("time")
inval_game = data.frame(game_ttl)
colnames(inval_game)<-c("gameid")
comb = cbind(st,time)
comb[,"time"] = anytime(comb[,"time"])
grp = comb %>% group_by(gameid)
sprintf('Avg of time for valid games: %i',sum(grp[,"time"])/nrow(grp[,"time"]))
sprintf('Total  Valid session: %i',table(comb[,'gameid']))
game_ttl = cbind(st,inval_game)
sprintf('Total no of sessions: %i',table(game_ttl[,'gameid']))
