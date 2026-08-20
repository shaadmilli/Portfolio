# ============================================================
# Retail Sales Forecasting - Furniture/Antique Retailer (Atlanta, GA)
# Full model-selection script: 6 model families, 60+ specifications
# Selected model: STL decomposition + ETS(M,N,N), t.window=1, s.window=7,
#                 lambda=0, biasadj=TRUE (see final fitted model, Part 5)
# Data: 48 months of POS sales data, Jan 2020-Dec 2023
# Train: Jan 2020-Dec 2022 | Test: Jan 2023-Dec 2023 | Forecast: 12 months
# ============================================================

library(fpp2)
library(forecast)
library(readxl)
library(vars)
library(readxl)  
library(dplyr)
library(zoo)
#####Monthly data

### Load Data ###
sales.data.monthly <- readxl::read_excel("monthlysales3.xlsx") 
sales.data.monthly
sales.data.monthly.ts <- ts(sales.data.monthly[,"Sales"], freq=12, start=c(2020,1))

autoplot(sales.data.monthly.ts)+
  ylab("Sales") +
  ggtitle("Monthly Sales Before fixing Data") 

mean(sales.data.monthly.ts)



###impute data for 0's###

# Replace zeros with NA on data frame 

sales.data.monthly[sales.data.monthly == 0] <- NA

sdm.imputed <- na.approx(sales.data.monthly$Sales)
sdm.imputed <- readxl::read_excel("monthlysales5.xlsx") 






#### Create & plot Time Series ####
sdm.imputed.timeseries <- ts(sdm.imputed[,"Sales"],freq=12, start=c(2020,1))

sdm.imputed.ts <- (sdm.imputed.timeseries)



#auto plot#
autoplot(sdm.imputed.ts) +
  ylab ("value") +
  ggtitle ("EDM Monthly Sales")

#seasonal plot#
ggseasonplot(sdm.imputed.ts, year.labels = TRUE, year.labels.left = TRUE) +
  ylab ("value") +
  ggtitle ("Seasonal plot: EDM Monthly Sales ")

#seasonal subplots#
ggsubseriesplot(sdm.imputed.ts)+
  ggtitle("Seasonal Subplot: EDM Monthly Sales")

#acf plot
ggAcf(sdm.imputed.ts, lag = 50)+
  ggtitle("ACF plot:EDM Monthly Sales ")


####Partition Series####
train.sdm <- window(sdm.imputed.ts, start=c(2020,1), end=c(2022,12))
test.sdm <- window(sdm.imputed.ts, start=c(2023,1), end=c(2023,12))
test.sdm
train.sdm

autoplot(train.sdm) +
  ylab ("Sales") +
  ggtitle ("Training Series")

autoplot(test.sdm) +
  ylab ("Sales") +
  ggtitle ("Test Series")

#Plot data#

autoplot(sdm.imputed.ts) +
  autolayer(train.sdm, series="Training") +
  autolayer(test.sdm, series="Test")

###############FPART 4 model selection###############
h <- length(test.sdm)
#average
meanfc <- meanf(train.sdm, h=h)
#naive
naivefc <-naive(train.sdm, h=h)
#Seasonal naive
snaivefc <-snaive(train.sdm, h=h)
#drift
driftfc <-rwf(train.sdm, drift=TRUE, h=h)

checkresiduals(meanfc)
checkresiduals(naivefc)
checkresiduals(snaivefc)
checkresiduals(driftfc)


autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with mean forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(meanfc$mean , col=2, series ="mean method")

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with naive forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(naivefc$mean , col=3, series ="naive method")


autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with seasonal naive forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(snaivefc$mean , col=4, series ="seasonal naive method")


autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with drift forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(driftfc$mean , col=5, series ="drift method") 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("Sales with Benchmark Forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(driftfc$mean,  series ="drift method") + 
  autolayer(meanfc$mean , series ="mean method") +
  autolayer(naivefc$mean ,  series ="naive method") +
  autolayer(snaivefc$mean ,  series ="seasonal naive method")



#Forecast accuracy
accuracy(meanfc, test.sdm)
accuracy(naivefc, test.sdm)
accuracy(snaivefc, test.sdm)
accuracy(driftfc, test.sdm)



#######ETS Forecast#######

sdm.ets.auto <- ets(train.sdm)
sdm.ets.autofcast <- forecast(sdm.ets.auto,h=h)
sdm.ets.autofcast
sdm.ets.auto

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with AUTO ETS forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(sdm.ets.autofcast, series ="AUTO ETS", PI=FALSE)

summary(sdm.ets.autofcast)
accuracy(sdm.ets.autofcast, test.sdm)


##simple exponential smoothing (SES)
sdm.ses <- ses(train.sdm)
sdm.ses.forecast <-forecast(sdm.ses)



summary(sdm.ses)
accuracy (sdm.ses.forecast, test.sdm)

#SES plot
autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with Simple Exponential Smoothing forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(sdm.ses,  series ="Simple Exponential Smoothing", PI=FALSE)

##holt winter models

sdm.holt.additive <- hw(train.sdm, seasonal = "additive")
sdm.holt.multiplicative <- hw(train.sdm, seasonal = "multiplicative")
sdm.holt.linear <- holt(train.sdm, h=3)

summary(sdm.holt.additive)
summary(sdm.holt.multiplicative)
summary(sdm.holt.linear)

accuracy(sdm.holt.linear, test.sdm)
accuracy(sdm.holt.additive, test.sdm)
accuracy(sdm.holt.multiplicative, test.sdm)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with Holt winter forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test") +
  autolayer(sdm.holt.multiplicative, series ="Holt Multiplicative", PI=FALSE)+
  autolayer(sdm.holt.additive, series ="Holt Additive", PI=FALSE) +
  autolayer(sdm.holt.linear, series ="Holt Linear", PI=FALSE) 


##holt damped fcast
sdm.holt <- holt(train.sdm, h=h)
sdm.holt.damped <- holt(train.sdm, h=h, damped = TRUE)
accuracy(sdm.holt.damped, test.sdm)


#####ARIMA Forecast####

#auto arima
sdm.autoarima <- auto.arima(train.sdm)
sdm.autoarima.fcast <-forecast(sdm.autoarima, h=12)
sdm.autoarima

#manual arima models

#box cox transform
lambda <- BoxCox.lambda(sdm.imputed.ts)
autoplot(BoxCox(sdm.imputed.ts,lambda))

#differencing
autoplot(diff(sdm.imputed.ts,lag=12))

library(urca)
summary(ur.kpss(diff(sdm.imputed.ts,lag=12)))

ggtsdisplay(diff(sdm.imputed.ts,lag=12))

model1 <- Arima(train.sdm,order=c(1,1,0),seasonal=c(0,1,0))
model2 <- Arima(train.sdm,order=c(2,1,0),seasonal=c(0,1,0))
model3 <- Arima(train.sdm,order=c(0,1,1),seasonal=c(0,1,0))
model4 <-Arima(train.sdm,order=c(0,1,2),seasonal=c(0,1,0))
model5 <- Arima(train.sdm,order=c(1,1,1),seasonal=c(0,1,0))

model1.fcast <- forecast(model1)
model2.fcast <- forecast(model2)
model3.fcast <- forecast(model3)
model4.fcast <- forecast(model4)
model5.fcast <- forecast(model5)

model6 <- Arima(train.sdm,order=c(1,1,0))
model7 <- Arima(train.sdm,order=c(2,1,0))
model8 <- Arima(train.sdm,order=c(0,1,1))
model9 <-Arima(train.sdm,order=c(0,1,2))
model10 <- Arima(train.sdm,order=c(1,1,1))

model6.fcast <- forecast(model6)
model7.fcast <- forecast(model7)
model8.fcast <- forecast(model8)
model9.fcast <- forecast(model9)
model10.fcast <- forecast(model10)

model11 <- Arima(train.sdm,order=c(3,1,0))
model12 <- Arima(train.sdm,order=c(3,1,0))
model13 <- Arima(train.sdm,order=c(3,1,1))
model14 <-Arima(train.sdm,order=c(3,1,2))
model15 <- Arima(train.sdm,order=c(3,1,1))

model11.fcast <- forecast(model11)
model12.fcast <- forecast(model12)
model13.fcast <- forecast(model13)
model14.fcast <- forecast(model14)
model15.fcast <- forecast(model15)

accuracy(model1.fcast, test.sdm)
accuracy(model2.fcast, test.sdm)
accuracy(model3.fcast, test.sdm)
accuracy(model4.fcast, test.sdm)
accuracy(model5.fcast, test.sdm)
accuracy(model6.fcast, test.sdm)
accuracy(model7.fcast, test.sdm)
accuracy(model8.fcast, test.sdm)
accuracy(model9.fcast, test.sdm)
accuracy(model10.fcast, test.sdm)
accuracy(model11.fcast, test.sdm)
accuracy(model12.fcast, test.sdm)
accuracy(model13.fcast, test.sdm)
accuracy(model14.fcast, test.sdm)
accuracy(model15.fcast, test.sdm)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with top 3 arima forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(model10.fcast , series ="model 10", PI=FALSE) +
  autolayer(model8.fcast , series ="model 8", PI=FALSE) +
  autolayer(model3.fcast, series ="model 3", PI=FALSE) 

accuracy(sdm.autoarima.fcast, test.sdm)

####Standard Regression####

sdm.tslm <- tslm(train.sdm ~trend + season)
sdm.tslm.fcast <- forecast(sdm.tslm)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with standard regression forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.tslm.fcast , series ="TSLM", PI=FALSE) 

accuracy(sdm.tslm.fcast, test.sdm)

sdm.tslm.trend <- tslm(train.sdm ~ trend)
sdm.tslm.trend.fcast <- forecast(sdm.tslm)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with non linear regression forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.tslm.trend.fcast , series ="TSLM", PI=FALSE) 

accuracy(sdm.tslm.trend.fcast, test.sdm)

#####Decompositons#####
library(seasonal)

#model
sdm.stlf.rwdrift <- stlf(train.sdm, method = "rwdrift")
sdm.stlf.naive <- stlf(train.sdm, method = "naive")
sdm.stlf.ets <- stlf(train.sdm, method = "ets")
sdm.stlf.arima <- stlf(train.sdm, method = "arima")

#forecast 
sdm.stlf.rwdrift.fcast <- forecast(sdm.stlf.rwdrift)
sdm.stlf.naive.fcast <- forecast(sdm.stlf.naive)
sdm.stlf.ets.fcast <- forecast(sdm.stlf.ets)
sdm.stlf.arima.fcast <- forecast(sdm.stlf.arima)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with decompositon forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.stlf.rwdrift.fcast , series ="STLF RWDRIFT", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with decompositon forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.stlf.naive.fcast , series ="STLF naive", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with decompositon forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.stlf.ets.fcast , series ="STLF ets", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with decompositon forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.stlf.arima.fcast , series ="STLF arima", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with decompositon forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.stlf.arima.fcast , series ="STLF arima", PI=FALSE) +
  autolayer(sdm.stlf.ets.fcast , series ="STLF ets", PI=FALSE) +
  autolayer(sdm.stlf.naive.fcast , series ="STLF naive", PI=FALSE) + 
  autolayer(sdm.stlf.rwdrift.fcast , series ="STLF RWDRIFT", PI=FALSE) 
  


accuracy(sdm.stlf.rwdrift.fcast, test.sdm)
accuracy(sdm.stlf.naive.fcast, test.sdm)
accuracy(sdm.stlf.ets.fcast, test.sdm)
accuracy(sdm.stlf.arima.fcast, test.sdm)

#######nural networks#####
sdm.nn1 <- nnetar(train.sdm)
sdm.nn1
sdm.nn2 <- nnetar(train.sdm, p=2, P=1, size=2)
sdm.nn3 <- nnetar(train.sdm, p=1, P=0, size=2)
sdm.nn4 <- nnetar(train.sdm, p=1, P=1, size=3)
sdm.nn5 <- nnetar(train.sdm, p=2, P=1, size=3)

sdm.nn1.forecast <- forecast(sdm.nn1, h=h)
sdm.nn2.forecast <- forecast(sdm.nn2, h=h)
sdm.nn3.forecast <- forecast(sdm.nn3, h=h)
sdm.nn4.forecast <- forecast(sdm.nn4, h=h)
sdm.nn5.forecast <- forecast(sdm.nn5, h=h)

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with neural net forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.nn1.forecast , series ="auto nn", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with neural net forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.nn2.forecast , series =" nn 212", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with neural net forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.nn3.forecast , series ="auto nn 102", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with neural net forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.nn4.forecast , series ="auto nn 113", PI=FALSE) 

autoplot(sdm.imputed.ts) +
  xlab("Month")+
  ylab("Sales")+
  ggtitle("EDM sales with neural net forecast")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")+
  autolayer(sdm.nn5.forecast , series ="auto nn 213", PI=FALSE) 

accuracy(sdm.nn1.forecast, test.sdm)
accuracy(sdm.nn2.forecast, test.sdm)
accuracy(sdm.nn3.forecast, test.sdm)
accuracy(sdm.nn4.forecast, test.sdm)
accuracy(sdm.nn5.forecast, test.sdm)

######combination#####

ETS <- forecast(ets(train.sdm), h=h)
ARIMA <-forecast(auto.arima(train.sdm, lambda = 0), h=h)
STL <- stlf( train.sdm, lambda = 0, h=h) 
NNAR <- forecast(nnetar(train.sdm), h=h)

Combination <- (ETS[["mean"]] + ARIMA[["mean"]] +
                  STL[["mean"]] + NNAR[["mean"]])/4

autoplot(sdm.imputed.ts) +
  autolayer(ETS, series="ETS", PI=FALSE) +
  autolayer(ARIMA, series="ARIMA", PI=FALSE) +
  autolayer(STL, series="STL", PI=FALSE) +
  autolayer(NNAR, series="NNAR", PI=FALSE) +
  autolayer(Combination, series="Combination")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")

accuracy(Combination, test.sdm)


##ALL ACCURCACIES
#Forecast accuracy
accuracy(meanfc, test.sdm)
accuracy(naivefc, test.sdm)
accuracy(snaivefc, test.sdm)
accuracy(driftfc, test.sdm)
accuracy(sdm.ets.autofcast, test.sdm)
accuracy (sdm.ses.forecast, test.sdm)
accuracy(sdm.holt.linear, test.sdm)
accuracy(sdm.holt.additive, test.sdm)
accuracy(sdm.holt.multiplicative, test.sdm)
accuracy(sdm.autoarima.fcast, test.sdm)
accuracy(sdm.tslm.fcast, test.sdm)
accuracy(sdm.tslm.trend.fcast, test.sdm)
accuracy(sdm.stlf.rwdrift.fcast, test.sdm)
accuracy(sdm.stlf.naive.fcast, test.sdm)
accuracy(sdm.stlf.ets.fcast, test.sdm)
accuracy(sdm.stlf.arima.fcast, test.sdm)
accuracy(sdm.nn1.forecast, test.sdm)
accuracy(sdm.nn2.forecast, test.sdm)
accuracy(sdm.nn3.forecast, test.sdm)
accuracy(sdm.nn4.forecast, test.sdm)
accuracy(sdm.nn5.forecast, test.sdm)
accuracy(Combination, test.sdm)



###MOST PROMISSING 3
accuracy(sdm.stlf.ets.fcast, test.sdm)
accuracy(sdm.nn2.forecast, test.sdm)
accuracy(sdm.nn3.forecast, test.sdm)

Combination2 <- (sdm.stlf.ets.fcast[["mean"]] + sdm.nn2.forecast[["mean"]] + sdm.nn3.forecast[["mean"]])/3

autoplot(sdm.imputed.ts) +
  autolayer(sdm.stlf.ets.fcast, series= "decomp ets fcast", PI=FALSE) +
  autolayer(sdm.nn2.forecast, series="nn2 forecast", PI=FALSE) +
  autolayer(sdm.nn3.forecast, series="nn3 forecast", PI=FALSE) +
  autolayer(Combination2, series="Combination")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")

accuracy(Combination2, test.sdm)

Combination3 <- (sdm.nn2.forecast[["mean"]] + sdm.nn3.forecast[["mean"]])/2

autoplot(sdm.imputed.ts) +
  autolayer(sdm.nn2.forecast, series="nn2 forecast", PI=FALSE) +
  autolayer(sdm.nn3.forecast, series="nn3 forecast", PI=FALSE) +
  autolayer(Combination3, series="Combination")+
  autolayer(train.sdm , series = "training")+
  autolayer(test.sdm , series = "test")

accuracy(Combination3, test.sdm)

########MORE DECOMPOSITION MODELS######
sdm.stlf.fit1 <- stlf( train.sdm, lambda = 0, method = "ets", h=h) 
sdm.stlf.fit2 <- stlf( train.sdm, lambda, method = "ets", h=h)
sdm.stlf.fit3 <- stlf( train.sdm, s.window = 3, method = "ets")
sdm.stlf.fit4 <- stlf( train.sdm, s.window = 1, method = "ets")
sdm.stlf.fit5 <- stlf( train.sdm, t.window = 1, s.window = 3, method = "ets")
sdm.stlf.fit6 <- stlf( train.sdm, t.window = 1, s.window = 5, method = "ets")
sdm.stlf.fit7 <- stlf( train.sdm, t.window = 1, s.window = 7, method = "ets")
sdm.stlf.fit8 <- stlf( train.sdm, t.window = 1, s.window = 9, method = "ets")
sdm.stlf.fit9 <- stlf( train.sdm, t.window = 1, s.window = 11, method = "ets")
sdm.stlf.fit10 <- stlf( train.sdm, t.window = 1, s.window = 13, method = "ets")
sdm.stlf.fit11 <- stlf( train.sdm, t.window = 1, s.window = 15, method = "ets")
sdm.stlf.fit12 <- stlf( train.sdm, t.window = 3, s.window = 3, method = "ets")
sdm.stlf.fit13 <- stlf( train.sdm, t.window = 3, s.window = 5, method = "ets")
sdm.stlf.fit14 <- stlf( train.sdm, t.window = 3, s.window = 7, method = "ets")
sdm.stlf.fit15 <- stlf( train.sdm, t.window = 3, s.window = 9, method = "ets")
sdm.stlf.fit16 <- stlf( train.sdm, t.window = 3, s.window = 11, method = "ets")
sdm.stlf.fit17 <- stlf( train.sdm, t.window = 3, s.window = 13, method = "ets")
sdm.stlf.fit18 <- stlf( train.sdm, t.window = 3, s.window = 15, method = "ets")
sdm.stlf.fit19 <- stlf( train.sdm, t.window = 1, s.window = 7, method = "ets")
sdm.stlf.fit20 <- stlf( train.sdm, t.window = 3, s.window = 7, method = "ets")
sdm.stlf.fit21 <- stlf( train.sdm, t.window = 5, s.window = 7, method = "ets")
sdm.stlf.fit22 <- stlf( train.sdm, t.window = 7, s.window = 7, method = "ets")
sdm.stlf.fit23 <- stlf( train.sdm, t.window = 9, s.window = 7, method = "ets")
sdm.stlf.fit24 <- stlf( train.sdm, t.window = 11, s.window = 7, method = "ets")
sdm.stlf.fit25 <- stlf( train.sdm, t.window = 13, s.window = 7, method = "ets")
sdm.stlf.fit26 <- stlf( train.sdm, t.window = 15, s.window = 7, method = "ets")
sdm.stlf.fit27 <- stlf( train.sdm, s.window = 1, method = "ets")
sdm.stlf.fit28 <- stlf( train.sdm, s.window = 3, method = "ets")
sdm.stlf.fit29 <- stlf( train.sdm,  s.window = 5, method = "ets")
sdm.stlf.fit30 <- stlf( train.sdm, s.window = 7, method = "ets")
sdm.stlf.fit31 <- stlf( train.sdm, s.window = 9, method = "ets")
sdm.stlf.fit32 <- stlf( train.sdm, s.window = 11, method = "ets")
sdm.stlf.fit33 <- stlf( train.sdm, s.window = 13, method = "ets")
sdm.stlf.fit34 <- stlf( train.sdm, s.window = 15, method = "ets")



sdm.stlf.fcast1 <- forecast(sdm.stlf.fit1)
sdm.stlf.fcast2 <- forecast(sdm.stlf.fit2)
sdm.stlf.fcast3 <- forecast(sdm.stlf.fit3)
sdm.stlf.fcast4 <- forecast(sdm.stlf.fit4)
sdm.stlf.fcast5 <- forecast(sdm.stlf.fit5)
sdm.stlf.fcast6 <- forecast(sdm.stlf.fit6)
sdm.stlf.fcast7 <- forecast(sdm.stlf.fit7)
sdm.stlf.fcast8 <- forecast(sdm.stlf.fit8)
sdm.stlf.fcast9 <- forecast(sdm.stlf.fit9)
sdm.stlf.fcast10 <- forecast(sdm.stlf.fit10)
sdm.stlf.fcast11 <- forecast(sdm.stlf.fit11)
sdm.stlf.fcast12 <- forecast(sdm.stlf.fit12)
sdm.stlf.fcast13 <- forecast(sdm.stlf.fit13)
sdm.stlf.fcast14 <- forecast(sdm.stlf.fit14)
sdm.stlf.fcast15 <- forecast(sdm.stlf.fit15)
sdm.stlf.fcast16 <- forecast(sdm.stlf.fit16)
sdm.stlf.fcast17 <- forecast(sdm.stlf.fit17)
sdm.stlf.fcast18 <- forecast(sdm.stlf.fit18)
sdm.stlf.fcast19 <- forecast(sdm.stlf.fit19)
sdm.stlf.fcast20 <- forecast(sdm.stlf.fit20)
sdm.stlf.fcast21 <- forecast(sdm.stlf.fit21)
sdm.stlf.fcast22 <- forecast(sdm.stlf.fit22)
sdm.stlf.fcast23 <- forecast(sdm.stlf.fit23)
sdm.stlf.fcast24 <- forecast(sdm.stlf.fit24)
sdm.stlf.fcast25 <- forecast(sdm.stlf.fit25)
sdm.stlf.fcast26 <- forecast(sdm.stlf.fit26)
sdm.stlf.fcast27 <- forecast(sdm.stlf.fit27)
sdm.stlf.fcast28 <- forecast(sdm.stlf.fit28)
sdm.stlf.fcast29 <- forecast(sdm.stlf.fit29)
sdm.stlf.fcast30 <- forecast(sdm.stlf.fit30)
sdm.stlf.fcast31 <- forecast(sdm.stlf.fit31)
sdm.stlf.fcast32 <- forecast(sdm.stlf.fit32)
sdm.stlf.fcast33 <- forecast(sdm.stlf.fit33)
sdm.stlf.fcast34 <- forecast(sdm.stlf.fit34)



autoplot(sdm.stlf.fcast1)
autoplot(sdm.stlf.fcast2)
autoplot(sdm.stlf.fcast3)
autoplot(sdm.stlf.fcast4)
autoplot(sdm.stlf.fcast5)
autoplot(sdm.stlf.fcast6)
autoplot(sdm.stlf.fcast7)
autoplot(sdm.stlf.fcast8)
autoplot(sdm.stlf.fcast9)
autoplot(sdm.stlf.fcast10)
autoplot(sdm.stlf.fcast11)
autoplot(sdm.stlf.fcast12)
autoplot(sdm.stlf.fcast13)
autoplot(sdm.stlf.fcast14)
autoplot(sdm.stlf.fcast15)
autoplot(sdm.stlf.fcast16)
autoplot(sdm.stlf.fcast17)
autoplot(sdm.stlf.fcast18)
autoplot(sdm.stlf.fcast19)
autoplot(sdm.stlf.fcast20)
autoplot(sdm.stlf.fcast21)
autoplot(sdm.stlf.fcast22)
autoplot(sdm.stlf.fcast23)
autoplot(sdm.stlf.fcast24)
autoplot(sdm.stlf.fcast25)
autoplot(sdm.stlf.fcast26)
autoplot(sdm.stlf.fcast27)
autoplot(sdm.stlf.fcast28)
autoplot(sdm.stlf.fcast29)
autoplot(sdm.stlf.fcast30)
autoplot(sdm.stlf.fcast31)
autoplot(sdm.stlf.fcast32)
autoplot(sdm.stlf.fcast33)
autoplot(sdm.stlf.fcast34)


accuracy(sdm.stlf.fcast1, test.sdm)
accuracy(sdm.stlf.fcast2, test.sdm)
accuracy(sdm.stlf.fcast3, test.sdm)
accuracy(sdm.stlf.fcast4, test.sdm)
accuracy(sdm.stlf.fcast5, test.sdm)
accuracy(sdm.stlf.fcast6, test.sdm)
accuracy(sdm.stlf.fcast7, test.sdm)
accuracy(sdm.stlf.fcast8, test.sdm)
accuracy(sdm.stlf.fcast9, test.sdm)
accuracy(sdm.stlf.fcast10, test.sdm)
accuracy(sdm.stlf.fcast11, test.sdm)
accuracy(sdm.stlf.fcast12, test.sdm)
accuracy(sdm.stlf.fcast13, test.sdm)
accuracy(sdm.stlf.fcast14, test.sdm)
accuracy(sdm.stlf.fcast15, test.sdm)
accuracy(sdm.stlf.fcast16, test.sdm)
accuracy(sdm.stlf.fcast17, test.sdm)
accuracy(sdm.stlf.fcast18, test.sdm)
accuracy(sdm.stlf.fcast19, test.sdm)
accuracy(sdm.stlf.fcast20, test.sdm)
accuracy(sdm.stlf.fcast21, test.sdm)
accuracy(sdm.stlf.fcast22, test.sdm)
accuracy(sdm.stlf.fcast23, test.sdm)
accuracy(sdm.stlf.fcast24, test.sdm)
accuracy(sdm.stlf.fcast25, test.sdm)
accuracy(sdm.stlf.fcast26, test.sdm)
accuracy(sdm.stlf.fcast27, test.sdm)
accuracy(sdm.stlf.fcast28, test.sdm)
accuracy(sdm.stlf.fcast29, test.sdm)
accuracy(sdm.stlf.fcast30, test.sdm)
accuracy(sdm.stlf.fcast31, test.sdm)
accuracy(sdm.stlf.fcast32, test.sdm)
accuracy(sdm.stlf.fcast33, test.sdm)
accuracy(sdm.stlf.fcast34, test.sdm)


lambda


########PART 5 Implementing forecast########
sdm.fitted <- stlf( sdm.imputed.ts, t.window = 1, s.window = 7, method = "ets", lambda=0, biasadj = TRUE, h=12)
sdm.fitted.forecast <-forecast(sdm.fitted)


autoplot(sdm.imputed.ts) +
  autolayer(fitted(sdm.fitted), series="fitted") +
  xlab("TIME")+
  ylab("Sales")+
  ggtitle("EDM Sales Forecast with ETS Decomposition Model")+
  autolayer(sdm.fitted.forecast , series = "forecast")

sdm.fitted
sdm.fitted.forecast
sdm.imputed.ts





