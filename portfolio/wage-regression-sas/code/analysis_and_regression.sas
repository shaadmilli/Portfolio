/* ============================================================
   Education & Earned Income — Descriptive Statistics & Regression
   Input: e625proj.analysis_data (output of data_preparation.sas)
   ============================================================ */

proc means data=e625proj.analysis_data n std min max maxdec=3;
    title "Descriptive Statistics of Analysis Data";
run;

proc contents data=e625proj.analysis_data;
    title "Contents";
run;

/* earned income histogram */
proc sgplot data=e625proj.analysis_data;
    histogram earned_income;
    title "Distribution of Earned Income";
run;

/* years of education bar chart */
proc sgplot data=e625proj.analysis_data;
    vbar educyrs;
    title "Distribution of Years of Education";
run;

/* education format */
proc format;
    value edufmt
        1 = "less than high school degree"
        2 = "high school graduate"
        3 = "some college"
        4 = "bachelors degree"
        5 = "masters degree"
        6 = "phd or professional degree"
    ;
run;

/* education categories bar chart */
proc sgplot data=e625proj.analysis_data;
    vbar educ_cat;
    format educ_cat edufmt.;
    title "Distribution of Education Categories";
run;

/* scatterplot of earned income by years of education */
proc sgplot data=e625proj.analysis_data;
    scatter y=earned_income x=educyrs;
    title "Relationship Between Years of Education and Earned Income";
run;

/* mean earned income by education category */
proc means data=e625proj.analysis_data;
    title "Descriptive Information on Income Variables By Education Level";
    var earned_income;
    class educ_cat;
run;

/* income distribution by education category */
proc sgpanel data=e625proj.analysis_data;
    panelby educ_cat / novarname;
    histogram earned_income;
    format educ_cat edufmt.;
    title "Distribution of Earned Income By Education Category";
run;

/* imputation frequency table */
proc freq data=e625proj.analysis_data;
    title "Frequencies of Imputed Data";
    table miss_earn * miss_demo / nocum;
run;

/* Model 1: simple regression, earned income on years of education (centered at 12) */
proc reg data=e625proj.analysis_data plots=none;
    model earned_income = educyrs12;
    title "Regression of Earned Income on Years of Education - 12";
run;

/* Model 2: multiple regression, excluding observations with allocated demographic data */
proc reg data=e625proj.analysis_data plots=none;
    title "Multiple Regression with Earned Income WITHOUT Allocated Data";
    model earned_income = educ_eq_hs educ_some_college educ_college educ_ma
          educ_prof_phd age18 female citizen poor_health
          northeast midwest west married widowed divorced separated
          black asian other hispanic;
    where miss_demo = 0;
    test educ_eq_hs, educ_some_college, educ_college, educ_ma, educ_prof_phd;
run;

/* Model 3: multiple regression, observations with allocated demographic data */
proc reg data=e625proj.analysis_data plots=none;
    title "Regression of Earned Income on Years of Education WITH Imputed Data";
    model earned_income = educ_eq_hs educ_some_college educ_college educ_ma
          educ_prof_phd age18 female citizen poor_health
          northeast midwest west married widowed divorced separated
          black asian other hispanic;
    where miss_demo = 1;
run;
