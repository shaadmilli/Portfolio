/* ============================================================
   Education & Earned Income — Data Preparation
   Constructs analysis variables from raw CPS ASEC person-,
   household-, and supplemental-level files
   ============================================================ */

proc contents data=e625data.cps_raw_sample;
run;

proc means data=e625data.cps_raw_sample n nmiss mean min max maxdec=3;
run;

/* variable creation data step */
data projdata1;
    set e625data.cps_raw_sample;

    /* citizenship variable */
    citizen = 0;
    IF PRCITSHP GE 1 AND PRCITSHP LE 4 THEN citizen = 1;
    LABEL citizen = "= 1 if citizen; = 0 otherwise";

    /* marital status variables */
    married = 0;
    widowed = 0;
    divorced = 0;
    separated = 0;
    never_married = 0;
    IF A_MARITL IN (1, 2, 3) THEN married = 1;
    ELSE IF A_MARITL EQ 4 THEN widowed = 1;
    ELSE IF A_MARITL EQ 5 THEN divorced = 1;
    ELSE IF A_MARITL EQ 6 THEN separated = 1;
    ELSE IF A_MARITL EQ 7 THEN never_married = 1;
    LABEL married = "= 1 if married; = 0 otherwise";
    LABEL widowed = "= 1 if widowed; = 0 otherwise";
    LABEL divorced = "= 1 if divorced; = 0 otherwise";
    LABEL separated = "= 1 if separated; = 0 otherwise";
    LABEL never_married = "= 1 if never_married; = 0 otherwise";

    /* sex variable */
    female = 0;
    IF A_SEX = 2 THEN female = 1;
    LABEL female = "= 1 if female; = 0 if male";

    /* income variables */
    earned_income = PEARNVAL;
    annual_hours = (hrswk * WKSWORK);
    hourly_wage = (earned_income / annual_hours);

    LABEL earned_income = "Earned income";
    LABEL annual_hours = "Annual hours worked";
    LABEL hourly_wage = "Hourly wage";

    /* education variable — six mutually exclusive dummies from A_HGA */
    educ_lt_hs = 0;
    educ_eq_hs = 0;
    educ_some_college = 0;
    educ_college = 0;
    educ_ma = 0;
    educ_prof_phd = 0;

    if A_HGA >= 31 AND A_HGA <= 38 then educ_lt_hs = 1;
    else if A_HGA = 39 then educ_eq_hs = 1;
    else if A_HGA >= 40 and A_HGA <= 42 then educ_some_college = 1;
    else if A_HGA = 43 then educ_college = 1;
    else if A_HGA = 44 then educ_ma = 1;
    else if A_HGA >= 45 and A_HGA <= 46 then educ_prof_phd = 1;

    LABEL educ_lt_hs = "= 1 if less than high school; = 0 otherwise";
    LABEL educ_eq_hs = "= 1 if high school graduate; = 0 otherwise";
    LABEL educ_some_college = "= 1 if some college (associates/trades etc.); = 0 otherwise";
    LABEL educ_college = "= 1 if college graduate; = 0 otherwise";
    LABEL educ_ma = "= 1 if masters degree; = 0 otherwise";
    LABEL educ_prof_phd = "= 1 if phd or professional degree; = 0 otherwise";

    /* ordinal education category, 1-6 */
    educ_cat = 0;
    if educ_lt_hs = 1 then educ_cat = 1;
    if educ_eq_hs = 1 then educ_cat = 2;
    if educ_some_college = 1 then educ_cat = 3;
    if educ_college = 1 then educ_cat = 4;
    if educ_ma = 1 then educ_cat = 5;
    if educ_prof_phd = 1 then educ_cat = 6;

    LABEL educ_cat = "Highest completed education";

    /* poor health indicator */
    poor_health = 0;
    if HEA >= 4 then poor_health = 1;
    LABEL poor_health = "= 1 if fair/poor health; = 0 if healthy";

    /* race/ethnicity — Hispanic identification takes precedence */
    white = 0;
    black = 0;
    asian = 0;
    other = 0;
    hispanic = 0;
    if pehspnon = 1 then hispanic = 1;
    else if pehspnon = 2 then hispanic = 0;
    if hispanic = 0 then do;
        if prdtrace = 1 then white = 1;
        else if prdtrace in (2,6) then black = 1;
        else if prdtrace in (3, 5, 7, 9, 10, 12, 13, 14, 15) then other = 1;
        else if prdtrace in (4, 8, 11) then asian = 1;
    end;
    LABEL black = "= 1 if black but not hispanic";
    LABEL white = "= 1 if white and not hispanic";
    LABEL asian = "= 1 if asian but not hispanic";
    LABEL other = "= 1 if other but not hispanic";
    LABEL hispanic = "= 1 if hispanic";

    /* imputation flags */
    miss_earn = 0;
    miss_demo = 0;
    if i_hrswk not= 0 or i_wkswk not= 0 then miss_earn = 1;
    if axage not= 0 or axhga not= 0 or i_hea not= 0 or pxhspnon not= 0
        or pxrace1 not= 0 or pxmaritl not= 0 then miss_demo = 1;
    LABEL miss_earn = "earnings data imputed";
    LABEL miss_demo = "demographic data imputed";
run;

proc means data=projdata1 n nmiss mean min max maxdec=3;
    title "Descriptive Stats of Created Variables";
run;

/* reading in CPS household data */
proc contents data=e625data.cps_hh_file;
run;

proc means data=e625data.cps_hh_file n nmiss mean min max maxdec=3;
    title "Descriptive Stats of CPS Household Data";
run;

/* merging person-level variables with household region data */
proc sort data=e625data.cps_hh_file out=hhdata;
    by hhid;
run;

proc sort data=projdata1 out=projdata1sorted;
    by hhid;
run;

data temp;
    merge projdata1sorted hhdata;
    by hhid;

    /* region variables from GEREG */
    northeast = 0;
    midwest = 0;
    south = 0;
    west = 0;
    if gereg = 1 then northeast = 1;
    if gereg = 2 then midwest = 1;
    if gereg = 3 then south = 1;
    if gereg = 4 then west = 1;
    region_cat = gereg;
    LABEL region_cat = "categorical region variable";
    LABEL northeast = "state in the northeast region of the united states";
    LABEL midwest = "state in the midwest region of the united states";
    LABEL south = "state in the southern region of the united states";
    LABEL west = "state in the western region of the united states";
run;

proc means data=temp n nmiss mean min max maxdec=3;
    title "Descriptive Stats of Merged Person + Household Data";
run;

/* merging state-level median income */
proc sort data=temp;
    by gestfips;
run;

proc means data=temp noprint;
    by gestfips;
    output out=medianinc median(earned_income)=median_income;
run;

data projdata2;
    merge medianinc temp;
    by gestfips;
    LABEL median_income = "median of state level income";
run;

proc means data=projdata2 n nmiss mean min max maxdec=3;
    title "Descriptive Stats of projdata2";
run;

/* merging additional CPS supplemental variables on person ID */
proc sort data=projdata2 out=projdata2sorted;
    by peridnum;
run;

proc sort data=e625data.cps_additional_variables out=add_vars;
    by peridnum;
run;

data projdata3;
    merge projdata2sorted add_vars;
    by peridnum;
run;

proc means data=projdata3 n nmiss mean min max maxdec=3;
    title "Descriptive Stats of projdata3";
run;

/* final analysis dataset: 17,292 observations, 92 variables */
data e625proj.analysis_data (drop=_TYPE_);
    set projdata3;
run;

proc means data=e625proj.analysis_data n mean min max maxdec=3;
    title "Descriptive Statistics of Project Analysis Data";
run;
