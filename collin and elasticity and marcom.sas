


* Influential Observations;


libname collin 'C:\Users\prr170130\Desktop'; run;


proc reg data = collin.DEMAND;
model UNITS = ADVERT DIRMAIL SMS STAFF EMAIL DISC PRICE ;
output out = resid p = PUNITS r = RUNITS student = student;
run;quit;


proc plot data = resid hpercent=50;
plot RUNITS*PUNITS student*PUNITS /vpos = 20 vref = 0; 
run;quit;


data collin.DEMAND2;
set resid;
if student > 3.00 then delete;
if student < -3.00 then delete;
run;


proc reg data = collin.DEMAND2;
model UNITS = ADVERT DIRMAIL SMS STAFF EMAIL DISC PRICE ;
output out = resid2 p = PUNITS r = RUNITS student = student;
run;quit;


data collin.DEMAND3;
set resid;
pos =0; neg = 0;
if student > 3.0 then pos = 1;
if student < -3.0 then neg = 1;
run;


proc reg data = collin.DEMAND3;
model UNITS = ADVERT DIRMAIL SMS STAFF EMAIL DISC PRICE neg;
output out = resid3 p = PUNITS r = RUNITS student = student;
run;quit;


* Collinearity Diagnostics /Correction(s);

proc corr data = collin.demand2; 
var UNITS ADVERT DIRMAIL SMS STAFF EMAIL DISC PRICE; run;


proc reg data = collin.DEMAND2;
model UNITS = ADVERT DIRMAIL SMS STAFF EMAIL DISC PRICE /VIF COLLIN;
run;quit;



proc reg data = collin.DEMAND2;
model UNITS = ADVERT DIRMAIL SMS STAFF EMAIL PRICE /VIF COLLIN;
run;quit;



proc factor data = collin.DEMAND2 out = factors nfactors = 6;
var ADVERT DIRMAIL SMS STAFF EMAIL DISC; run;


proc corr data = factors; 
var factor1 factor2 factor3 ; run;


proc reg data = factors;
model UNITS = factor1 factor2 factor3 price/VIF COLLIN;
run;quit;


*******************************************;
* elasticity modeling *;


proc means data = collin.demand2;
var price units; run;



*******************************************;
* marcom value *;


proc reg data = collin.marcom;
model revenue = em1 em2 sms dm/vif collin;
output out = marcom_resid p = Prev r = Rrev student = student;
run;quit;


proc means data = collin.marcom; run;



