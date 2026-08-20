/* ============================================================
   Lending Club Consumer Loan Pricing & Credit Risk Model
   Logistic regression on cleaned loan-level data (SAS)
   Input: loan_cleaned_2.csv (output of loansqlfile.sql extract)
   ============================================================ */

ods pdf file="~/loan_model_done.pdf";

/* import loan data */
proc import datafile="/home/u63537825/loan_cleaned_2.csv"
    out=loan
    dbms=csv
    replace;
    getnames=yes;
run;

/* checking contents */
proc print data=loan (obs=50);
run;

proc contents data=loan;
run;

/* fix dti above 100 */
proc means data=loan median;
    where dti < 100;
    var dti;
run;

proc sql;
    select count(*) as wrong_dti_count
    from loan
    where dti > 100;
quit;

/* replacing dti > 100 with median */
data loan;
    set loan;
    if dti > 100 then dti = 17.6;
run;

proc sql;
    select count(*) as wrong_dti_count
    from loan
    where dti > 100;
run;

/* summary stats */
proc means data=loan n mean median min max stddev;
    var loan_amnt interest_rate dti annual_income
        delinq_2yrs open_accounts total_accounts
        revolving_utilization;
run;

/* defaults by grade */
proc freq data=loan;
    tables grade*default_flag;
run;

/* defaults by purpose */
proc freq data=loan;
    tables purpose*default_flag;
run;

/* risk buckets */
proc means data=loan mean nway;
    class grade;
    var default_flag interest_rate loan_amnt annual_income dti;
    output out=grade_summary mean=;
run;

proc print data=grade_summary;
run;

/* logistic regression to predict default */
proc logistic data=loan descending;
    class grade home_ownership verification_status
          purpose employment_length / param=ref;
    model default_flag = grade home_ownership
          verification_status purpose
          employment_length loan_amnt interest_rate
          dti delinq_2yrs open_accounts
          total_accounts revolving_utilization;
    output out=loan_scored p=pred_prob;
run;

proc print data=loan_scored (obs=10);
run;

/* loans sorted by descending predicted default probability - top 10 */
proc sort data=loan_scored out=loan_scored_sorted;
    by descending pred_prob;
run;

proc print data=loan_scored_sorted (obs=10);
run;

/* loans sorted by ascending predicted default probability - bottom 10 */
proc sort data=loan_scored out=loan_scored_sorted_asc;
    by pred_prob;
run;

proc print data=loan_scored_sorted_asc (obs=10);
run;

/* average predicted probability by grade - feeds Excel pricing framework */
proc means data=loan_scored mean nway;
    class grade;
    var pred_prob interest_rate loan_amnt dti default_flag;
    output out=grade_pricing mean=avg_pred_prob avg_int_rate avg_loan_amnt avg_actual_default;
run;

/* calculating average loss given default (portfolio-level) */
proc means data=loan mean;
    where default_flag = 1;
    var funded_amnt total_rec_prncp recoveries;
run;

/* grade-level LGD inputs - empirically derived from recovery data */
proc means data=loan mean;
    where default_flag = 1;
    class grade;
    var funded_amnt total_rec_prncp recoveries;
run;

ods pdf close;
