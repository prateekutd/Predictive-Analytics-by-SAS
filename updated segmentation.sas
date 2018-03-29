

LIBNAME UTD 'C:\Users\prr170130\Desktop'; run;

libname utd 'C:\Users\prr170130\Desktop'; run;


* collect datasets and merge by customer_id *;

PROC SORT DATA = UTD.SHOE_DATA;  BY CUSTOMER_ID; RUN;

PROC SORT DATA = UTD.SHOE_DEMO;  BY CUSTOMER_ID; RUN;

DATA WORK.MERGE;
MERGE UTD.SHOE_DATA UTD.SHOE_DEMO; 
BY CUSTOMER_ID; RUN;






**** hierarchical clustering  *;
* can add 'noprint' to supress 5000 line sof clusters *;


proc cluster data = work.merge 
method = average std pseudo noeigen outtree = tree;

var 
mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;

id customer_id; run;


proc tree horizontal;
run;


proc tree sort height=n horizontal;
run;


proc tree noprint out=part nclusters=6;
   id customer_id;
   copy   mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;
run;

proc sort;
   by cluster;
run;



** KMEANS **;

* output by cust_id sort*;

proc sort data = merge; by CUSTOMER_ID; run;

proc fastclus data = work.merge 
maxclusters = 6 out = clus ;
var
mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;
run;



* output by response sort*;

proc sort data = merge; by response; run;

proc fastclus data = work.merge 
maxclusters = 6 out = clus ;
var
mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;
run;





** steps: standard -- kmeans -- discrim *;

proc standard data=work.merge mean=0 std=1 out=standard;
var 
mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;
run;


* note rec and resp *;

proc fastclus data = work.standard 
maxclusters = 6 out = clus_final (keep = customer_id cluster);
var
mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids;
run;


proc sort data = clus_final; by customer_id; run;

proc sort data = merge; by customer_id; run;


data final;
merge merge clus_final; by customer_id ; run;



* discrim tests for best solution *;

proc discrim data= work.final out=output scores = x method=normal anova;
   class cluster ;
   priors prop;
   id customer_id;
   var  

mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids ;
run;


* when happy, output the means *;

proc sort data = final; by cluster; run;


proc means data = work.final; by cluster; 
output out = means; run;


data means2;
set means;
where _stat_ = 'MEAN';
run;
























proc discrim data= work.clus out=output scores = x method=normal anova;
   class cluster ;
   priors prop;
   id customer_id;
   var  

mens_dept_spend		womens_dept_spend		kids_dept_spend
accessories_spend	recency					response
tenure				cmpns					hhincome
hhkids ;
run;



proc sort data = work.clus; by customer_id; run;

proc sort data = work.merge; by customer_id; run;


data work.both;
merge work.clus work.merge;
by customer_id; run;


proc sort data = both; by cluster; run;


proc means data = work.both noprint; by cluster; 
output out = means; run;


data means2;
set means;
where _stat_ = 'MEAN';
run;








