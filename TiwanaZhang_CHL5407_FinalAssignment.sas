/*********************************************************************************/
*** CHL5407H: CATEGORICAL DATA ANALYSIS FOR EPIDEMIOLOGIC STUDIES - FALL 2023	
***
*** Final Assignment			
***
*** Instructor: Dr. Jennifer Brooks		
***
*** Authors: Amrit Tiwana and Benjamin Zhang			
*** 			
*** Date: December 15, 2023			
***	
/*********************************************************************************/;

/*** Set Up ***/

/* Importing text data file */;
PROC IMPORT OUT = CCHS
	DATAFILE = '\\PHSAhome2.phsabc.ehcnet.ca\amrit.tiwana\Profile\Desktop\BMI and Asthma\cchs18.txt'
	DBMS = 'TAB';
RUN;

/* Create a copy of the dataset */
DATA WORK.CCHS_COPY;
  SET WORK.CCHS;
RUN;

/* Look at the properties of the dataset */
PROC CONTENTS DATA = WORK.CCHS;
RUN;

/* Rename variables */
DATA WORK.CCHS;
  SET WORK.CCHS;
  RENAME CCC_015 = has_asthma
		 DHH_SEX = sex
		 CCC_020 = asthma_attack
		 CCC_025 = asthma_med
		 HWTDGISW = bmi
		 DHHGAGE = age
		 SMK_005 = smoke
		 SMK_095 = past_smoke
		 ALC_015 = alcohol
		 PAA_105 = physical_activity
		 PAADVWHO = physical_who
		 SDCDGCGT = white
		 INCDGPER = personal_income
		 INCDGHH = household_income
		 INCG035 = personal_income_source
		 INCG015 = household_income_source
		 FVCDVTOT = fruitveg_consumption
		 HWT_050 = percieved_weight
		 GEN_005 = percieved_health
		 GEN_020 = percieved_lifestress
		 CCC_065 = hypertension
		 CCC_050 = arthritis
		 CCC_085 = heart_disease
		 CCC_095 = diabetes;
RUN;

/*** Exploratory Data Analysis ***/

/* Subset to population of interest - those who have asthma and 18+ */
DATA WORK.CCHS;
  SET WORK.CCHS;
  WHERE has_asthma = 1 and age >= 3;
RUN;

/* Look at the properties of the subsetted dataset */
PROC CONTENTS DATA = WORK.CCHS;
RUN; /* N = 8,903 */

/* Create histogram of continous variables - fruitveg_consumption */
PROC UNIVARIATE DATA = WORK.CCHS;
  VAR fruitveg_consumption;
  HISTOGRAM;
  WHERE fruitveg_consumption < 15;
RUN; /* retrict to counts under 100 to get a more accurate distribution (exclude 999) */

PROC FREQ DATA = WORK.CCHS;
  TABLES fruitveg_consumption;
RUN; /* will need to drop this variable because there is a high degress of missingness (98% missing) */

/* Calculate median and range of fruitveg_consumption */
PROC MEANS DATA=WORK.CCHS N MEDIAN Q1 Q3;
  VAR fruitveg_consumption;
  WHERE fruitveg_consumption < 15;
RUN;

/* Create histogram of continous variables - physical_activity */
PROC UNIVARIATE DATA = WORK.CCHS;
  VAR physical_activity;
  HISTOGRAM;
  WHERE physical_Activity < 150;
RUN; /* Very skewed distrbution, lots of outliers, and excess amount of zeros. Not going to use this variable */

PROC FREQ DATA = WORK.CCHS;
  TABLES physical_activity;
RUN; 

/* Calculate median and range of physical_activity */
PROC MEANS DATA=WORK.CCHS N MEDIAN Q1 Q3;
  VAR physical_activity;
RUN;

/* Create frequency tables of categorical variables */ 
PROC FREQ DATA = WORK.CCHS;
  TABLES sex white asthma_attack asthma_med bmi age smoke past_smoke alcohol physical_who
		 personal_income household_income personal_income_source household_income_source
		 percieved_weight percieved_health percieved_lifestress 
		 hypertension arthritis heart_disease diabetes;
RUN;

/* Personal income has small cell counts. We will need to re-categorize groups */
DATA WORK.CCHS;
	SET WORK.CCHS;
	IF personal_income = 1 or personal_income = 2 THEN personal_income = 1;
	ELSE IF personal_income = 3 THEN personal_income = 2;
	ELSE IF personal_income = 4 THEN personal_income = 3;
	ELSE IF personal_income = 5 THEN personal_income = 4;
	ELSE IF personal_income = 6 THEN personal_income = 5;
	ELSE IF personal_income = 99 THEN personal_income = 99;
	ELSE personal_income = .;
RUN;

/* Personal income source has small cell counts. We will need to re-categorize groups */
DATA WORK.CCHS;
	SET WORK.CCHS;
	IF personal_income_source = 1 THEN personal_income_source = 1;
	ELSE IF personal_income_source = 2 or personal_income_source = 4 THEN personal_income_source = 2;
	ELSE IF personal_income_source = 3 THEN personal_income_source = 3;
	ELSE IF personal_income_source = 6 THEN personal_income_source = 6;
	ELSE IF personal_income_source = 9 THEN personal_income_source = 9;
	ELSE personal_income_source = .;
RUN;

/* Age has small cell counts. We will need to re-categorize groups */
DATA WORK.CCHS;
  SET WORK.CCHS;
  IF age = 3 or age = 4 or age = 5 THEN age = 1;
  ELSE IF age = 6 or age = 7 THEN age = 2;
  ELSE IF age = 8 or age = 9 THEN age = 3;
  ELSE IF age = 10 or age = 11 THEN age = 4;
  ELSE IF age = 12 or age = 13 THEN age = 5;
  ELSE IF age = 14 or age = 15 THEN age = 6;
  ELSE IF age = 16 THEN age = 7;
  ELSE age = .;
RUN;

/* Alcohol has small cell counts. We will need to re-categorize groups */
DATA WORK.CCHS;
  SET WORK.CCHS;
  IF alcohol = 96 THEN alcohol = 1;
  ELSE IF alcohol = 1 or alcohol = 2 THEN alcohol = 2;
  ELSE IF alcohol = 3 or alcohol = 4 THEN alcohol = 3;
  ELSE IF alcohol = 5 or alcohol = 6 or alcohol = 7 THEN alcohol = 4;
  ELSE IF alcohol = 97 THEN alcohol = 97;
  ELSE IF alcohol = 98 THEN alcohol = 98;
  ELSE IF alcohol= 99 THEN alcohol = 99; 
  ELSE alcohol = .;
RUN;

/* combine smoke and past_smoke */
DATA WORK.CCHS;
  SET WORK.CCHS;
  IF smoke = 1 THEN smoke = 1;
  ELSE IF smoke = 2 THEN smoke = 2;
  ELSE IF past_smoke = 1 AND smoke = 3 THEN smoke = 3;
  ELSE IF past_smoke ne 1 AND smoke = 3 THEN smoke = 4;
  ELSE IF smoke = 7 THEN smoke = 7;
  ELSE IF smoke = 8 THEN smoke = 8;
  ELSE smoke = .;
RUN;

/* collapse categories in percieved health for easier interpretation in analyses */
DATA WORK.CCHS;
	SET WORK.CCHS;
	IF percieved_health = 1 or percieved_health = 2 THEN percieved_health = 1;
	ELSE IF percieved_health = 3 THEN percieved_health = 2;
	ELSE IF percieved_health = 4 or percieved_health = 5 THEN percieved_health = 3;
	ELSE IF percieved_health = 7 THEN percieved_health = 7;
	ELSE percieved_health = .;
RUN;

/* collapse categories in percieved life stress for easier interpretation in analyses */
DATA WORK.CCHS;
	SET WORK.CCHS;
	IF percieved_lifestress = 1 or percieved_lifestress = 2 THEN percieved_lifestress = 1;
	ELSE IF percieved_lifestress = 3 THEN percieved_lifestress = 2;
	ELSE IF percieved_lifestress = 4 or percieved_lifestress = 5 THEN percieved_lifestress = 3;
	ELSE IF percieved_lifestress = 7 THEN percieved_lifestress = 7;
	ELSE IF percieved_lifestress = 8 THEN percieved_lifestress = 8;
	ELSE percieved_lifestress = .;
RUN;

/* Drop missing data in covariates */
DATA WORK.CCHS;
  SET WORK.CCHS;
  IF asthma_med = 7 THEN DELETE;
  IF smoke = 7 or smoke = 8 THEN DELETE;
  IF alcohol = 97 or alcohol = 98 or alcohol = 99 THEN DELETE;
  IF personal_income = 99 THEN DELETE;
  /* IF household_income = 9 THEN DELETE; */ 
  /* IF personal_income_source = 9 THEN DELETE; */
  /* IF household_income_source = 9 THEN DELETE; */
  /* IF percieved_weight = 6 or percieved_weight = 7 or percieved_weight = 8 or percieved_weight = 9 THEN DELETE; */
  /* IF percieved_health = 7 THEN DELETE; */
  IF percieved_lifestress = 7 or percieved_lifestress = 8 THEN DELETE;
  IF hypertension = 7 THEN DELETE;
  IF arthritis = 7 THEN DELETE;
  IF heart_disease = 7 THEN DELETE;
  IF diabetes = 7 THEN DELETE;
  IF white = 6 or white = 9 THEN DELETE;
  IF physical_who = 9 THEN DELETE;
  /* IF physical_activity = 9997 or physical_activity = 9999 THEN DELETE; */
RUN;

/* Look at the properties of the dataset with missing data in covariates removed */
PROC CONTENTS DATA = WORK.CCHS;
RUN; /* N = 7,616 */

/* Drop missing data in focal exposure and outcome */
DATA WORK.CCHS;
  SET WORK.CCHS;
  IF asthma_attack = 7 THEN DELETE;
  IF bmi = 9 THEN DELETE;
RUN;

/* Look at the properties of the dataset with missing data in covariates and focal exposure and outcome removed */
PROC CONTENTS DATA = WORK.CCHS;
RUN; /* N = 7,090 */

/* Create frequency tables of categorical variables with no missing data */ 
PROC FREQ DATA = WORK.CCHS;
  TABLES sex asthma_attack asthma_med bmi age smoke alcohol white physical_who personal_income
		 percieved_lifestress hypertension arthritis heart_disease diabetes;
RUN;

/* Collapse bmi categories underweight with normal weight */
DATA WORK.CCHS;
	SET WORK.CCHS;
	IF bmi = 1 or bmi = 2 THEN bmi = 1;
	ELSE IF bmi = 3 THEN bmi = 2;
	ELSE IF bmi = 4 THEN bmi = 3;
	ELSE bmi = .;
RUN;

/*** Testing Functional Forms and Interactions ***/

PROC GENMOD DATA = WORK.CCHS;
	MODEL asthma_attack (EVENT = '1') = physical_activity*physical_activity / DIST = BIN LINK = LOG TYPE3;
RUN; /* Since physical_activity*physical_activity is not statistically significant (p-value = 0.9897 > alpha level = 0.05), 
	 there is insufficient evidence to conclude that physical activity has a non-linear association with asthma attacks.*/

PROC GENMOD DATA = WORK.CCHS;
	CLASS sex (REF = '1') age (REF = '4') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = age sex age*sex / DIST = BIN LINK = LOG TYPE3;
RUN; /* Based on the Joint Test, since the interaction term PRETERM*PRECARE is not statistically significant 
	 (p-value = 0.5828 > alpha level = 0.05), there is insufficient evidence to conclude that there is a 
	 multiplicative interaction between age and sex. */

/*** Univariable Log-Binomial Analyses ***/

/* BMI */
PROC FREQ DATA = WORK.CCHS;
TABLES asthma_attack*bmi / CHISQ;
RUN;

PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Overweight vs Normal/Under Weight' bmi 1 0 / EXP;
	ESTIMATE 'PR Obese vs Normal/Under Weight' bmi 0 1 / EXP;  
RUN; /* P-value = 0.0072 < P-value 0.25 */

/* sex */
PROC GENMOD DATA = WORK.CCHS;
	CLASS sex (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = sex / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Female vs Male' sex 1 / EXP;
	ESTIMATE 'PR Male vs Female' sex 0 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* racial background */
PROC GENMOD DATA = WORK.CCHS;
	CLASS white (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = white / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR White vs Non-white' white 1 / EXP;
RUN; /* P-value = 0.3263 < P-value 0.25 */

/* asthma medication use */
PROC GENMOD DATA = WORK.CCHS;
	CLASS asthma_med (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = asthma_med / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Asthma Meds vs No Asthma Meds' asthma_med 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* age */
PROC GENMOD DATA = WORK.CCHS;
	CLASS age (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = age / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE '30-39 vs 18-29' age 1 0 0 0 0 0 / EXP;
	ESTIMATE '40-49 vs 18-29' age 0 1 0 0 0 0 / EXP;
	ESTIMATE '50-59 vs 18-29' age 0 0 1 0 0 0 / EXP;
	ESTIMATE '60-69 vs 18-29' age 0 0 0 1 0 0 / EXP;
	ESTIMATE '70-79 vs 18-29' age 0 0 0 0 1 0 / EXP;
	ESTIMATE '80+ vs 18-29' age 0 0 0 0 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* smoking status */
PROC GENMOD DATA = WORK.CCHS;
	CLASS smoke (REF = '4') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = smoke / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'daily vs non-smoker' smoke 1 0 0 / EXP;
	ESTIMATE 'occasional vs non-smoker' smoke 0 1 0 / EXP;
	ESTIMATE 'former vs non-smoker' smoke 0 0 1 / EXP;
RUN; /* P-value = 0.4757 > P-value 0.25 */

/* physical activity continous */
PROC GENMOD DATA = WORK.CCHS;
	MODEL asthma_attack (EVENT = '1') = physical_activity / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'Mean Ten-Unit Increase in PA' physical_activity 10 / EXP;
RUN;/* P-value = 0.1878 < P-value 0.25 */

/* alcohol consumption */
PROC GENMOD DATA = WORK.CCHS;
	CLASS alcohol (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = alcohol / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'not that often vs never' alcohol 1 0 0 / EXP;
	ESTIMATE 'often vs never' alcohol 0 1 0 / EXP;
	ESTIMATE 'frequent vs never' alcohol 0 0 1 / EXP;
RUN; /* P-value = 0.0118 < P-value 0.25 */

/* physical activity categorical */
PROC GENMOD DATA = WORK.CCHS;
	CLASS physical_who (REF = '4') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = physical_who / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'active vs sedentary' physical_who 1 0 0 / EXP;
	ESTIMATE 'moderately active vs sedentary' physical_who 0 1 0 / EXP;
	ESTIMATE 'somewhat active vs sedentary' physical_who 0 0 1 / EXP;
RUN;

/* personal income */
PROC GENMOD DATA = WORK.CCHS;
	CLASS personal_income (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = personal_income / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR 20-40k vs no income' personal_income 1 0 0 0 / EXP;
	ESTIMATE 'PR 40-60k vs no income' personal_income 0 1 0 0 / EXP;
	ESTIMATE 'PR 60-80k vs no income' personal_income 0 0 1 0 / EXP;
	ESTIMATE 'PR 80k+ vs no income' personal_income 0 0 0 1 / EXP;
RUN; /* P-value = 0.0332 < P-value 0.25 */

/* household income */
PROC GENMOD DATA = WORK.CCHS;
	CLASS household_income (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = household_income / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR $80k+ vs No Income' household_income 0 0 0 1 / EXP;
RUN; /* P-value = 0.0581 < P-value 0.25 */

/* personal income source */
PROC GENMOD DATA = WORK.CCHS;
	CLASS personal_income_source (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = personal_income_source / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR $80k+ vs No Income' personal_income_source 0 0 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* household income source */
PROC GENMOD DATA = WORK.CCHS;
	CLASS household_income_source (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = household_income_source / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR $80k+ vs No Income' household_income_source 0 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* percieved weight */
PROC GENMOD DATA = WORK.CCHS;
	CLASS percieved_weight (REF = '3') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = percieved_weight / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'Overweight vs Just About Right' percieved_weight 1 0 / EXP;
	ESTIMATE 'Underweight vs Just About Right' percieved_weight 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* percieved health */
PROC GENMOD DATA = WORK.CCHS;
	CLASS percieved_health (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = percieved_health / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'good vs excellent' percieved_health 1 0 / EXP;
	ESTIMATE 'poor vs excellent' percieved_health 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* percieved lifestress */
PROC GENMOD DATA = WORK.CCHS;
	CLASS percieved_lifestress (REF = '1') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = percieved_lifestress / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'very stressful vs not at all' percieved_lifestress 1 0  / EXP;
	ESTIMATE 'a bit stressful vs not at all' percieved_lifestress 0 1 / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* percieved lifestress as an ordinal vriable since the PR increases in a linear fashion*/
PROC GENMOD DATA = WORK.CCHS;
	MODEL asthma_attack (EVENT = '1') = percieved_lifestress / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR life stress increase' percieved_lifestress 1  / EXP;
RUN; /* P-value <.0001 < P-value 0.25 */

/* hypertension */
PROC GENMOD DATA = WORK.CCHS;
	CLASS hypertension (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = hypertension / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Hypertension vs No Hypertension' hypertension 1 / EXP;
RUN; /* P-value = 0.0149 < P-value 0.25 */

/* arthritis */
PROC GENMOD DATA = WORK.CCHS;
	CLASS arthritis (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = arthritis / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Arthritis vs No Arthritis' arthritis 1 / EXP;
RUN; /* P-value = 0.0961 < P-value 0.25 */

/* heart_disease */
PROC GENMOD DATA = WORK.CCHS;
	CLASS heart_disease (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = heart_disease / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Heart Disease vs No No Heart Disease' heart_disease 1 / EXP;
RUN; /* P-value = 0.3002 > P-value 0.25 */

/* diabetes */
PROC GENMOD DATA = WORK.CCHS;
	CLASS diabetes (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = diabetes / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Diabetes vs No Diabetes' diabetes 1 / EXP;
RUN; /* P-value = 0.8868 > P-value 0.25 */

/*** Multivariable Adjusted Log-Binomial Analysis ***/

/* Step 1 */
/* variables with p<0.25 in univariable analyses include: 
bmi sex age asthma_med alcohol physical_who personal_income percieved_lifestress hypertension arthritis */

/* Step 2 */
PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2') alcohol (REF = '1') 
	physical_who (REF = '4') personal_income (REF = '1') hypertension (REF = '2') arthritis (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med alcohol physical_who 
	personal_income percieved_lifestress arthritis hypertension / DIST = BIN LINK = LOG TYPE3;
RUN;

/* Step 3 */
/* alcohol, personal_income and arthritis were not significant in step 2 so lets take it out and see if model fit improves */
PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension / DIST = BIN LINK = LOG TYPE3;
RUN; /* model fit improved */

/* Step 4 */
/* Add back in variables not selected in step 1: white smoke heart_disease diabetes one at a time (order based on effect size) */
PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') smoke (REF = '4') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension smoke / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 7.8, cutoff value = 7.815, DF = 3, alpha = 0.05, therefore remove smoke */

PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 7.923, cutoff value = 3.841, DF = 1, alpha = 0.05, therefore keep heart_disease */

PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') white (REF='2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease white / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 0.1712, cutoff value = 3.841, DF = 1, alpha = 0.05, therefore remove white */

PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') diabetes (REF = '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease diabetes / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 0.0284, cutoff value = 3.841, DF = 1, alpha = 0.05, therefore remove diabetes */

/* Step 5 */ 
/* Testing appropriate functional forms, appropriate categories for categorical predictors */
/* No continous variables were used in the analysis and categorical forms were dealt with earlier */

/* Step 6 */
/* Testing a priori identified interactions */
PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease sex*age / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 11.2352, cutoff value = 12.59, DF = 1, alpha = 0.05, therefore remove sex*age */

PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '2') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease bmi*physical_who / DIST = BIN LINK = LOG TYPE3;
RUN; /* LRT test: test value = 13.5634, cutoff value = 16.919, DF = 9, alpha = 0.05, therefore remove bmi*physical_who */

/* Step 7 */
/* Verify GOF and other diagnositics */
PROC GENMOD DATA = WORK.CCHS;
	CLASS bmi (REF = '1') sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Overweight vs Norma/Under Weight' bmi 1 0 / EXP;
	ESTIMATE 'PR Obese vs Normal/Under Weight' bmi 0 1 / EXP;  
	ESTIMATE 'PR Female vs Male' sex 1 / EXP;
	ESTIMATE '30-39 vs 18-29' age 1 0 0 0 0 0 / EXP;
	ESTIMATE '40-49 vs 18-29' age 0 1 0 0 0 0 / EXP;
	ESTIMATE '50-59 vs 18-29' age 0 0 1 0 0 0 / EXP;
	ESTIMATE '60-69 vs 18-29' age 0 0 0 1 0 0 / EXP;
	ESTIMATE '70-79 vs 18-29' age 0 0 0 0 1 0 / EXP;
	ESTIMATE '80+ vs 18-29' age 0 0 0 0 0 1 / EXP;
	ESTIMATE 'asthma meds vs no asthma meds' asthma_med 1 / EXP;
	ESTIMATE 'active vs sedentary' physical_who 1 0 0 / EXP;
	ESTIMATE 'moderately active vs sedentary' physical_who 0 1 0 / EXP;
	ESTIMATE 'somewhat active vs sedentary' physical_who 0 0 1 / EXP;
	ESTIMATE 'percieved life stress increase' percieved_lifestress 1 / EXP;
	ESTIMATE 'hypertension vs no hypertension' hypertension 1 / EXP;
	ESTIMATE 'heart disease vs no heart disease' heart_disease 1 / EXP;
RUN;

/* Step 8 */
/* check for trend - put BMI in the model as an ordinal categorical variable and check p-value. Take out of class statement */
PROC GENMOD DATA = WORK.CCHS;
	CLASS sex (REF = '1') age (REF = '1') asthma_med (REF = '2')
	physical_who (REF = '4') hypertension (REF = '2') heart_disease (REF= '2') / PARAM = REF;
	MODEL asthma_attack (EVENT = '1') = bmi sex age asthma_med physical_who 
	percieved_lifestress hypertension heart_disease / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Normal/Under Weight vs Obese' bmi 1 0 / EXP;
	ESTIMATE 'PR Overweight vs. Obese' bmi 0 0 1 / EXP;  
	ESTIMATE 'PR Female vs Male' sex 1 / EXP;
	ESTIMATE '30-39 vs 18-29' age 1 0 0 0 0 0 / EXP;
	ESTIMATE '40-49 vs 18-29' age 0 1 0 0 0 0 / EXP;
	ESTIMATE '50-59 vs 18-29' age 0 0 1 0 0 0 / EXP;
	ESTIMATE '60-69 vs 18-29' age 0 0 0 1 0 0 / EXP;
	ESTIMATE '70-79 vs 18-29' age 0 0 0 0 1 0 / EXP;
	ESTIMATE '80+ vs 18-29' age 0 0 0 0 0 1 / EXP;
	ESTIMATE 'asthma meds vs no asthma meds' asthma_med 1 / EXP;
	ESTIMATE 'active vs sedentary' physical_who 1 0 0 / EXP;
	ESTIMATE 'moderately active vs sedentary' physical_who 0 1 0 / EXP;
	ESTIMATE 'somewhat active vs sedentary' physical_who 0 0 1 / EXP;
	ESTIMATE 'percieved life stress increase' percieved_lifestress 1 / EXP;
	ESTIMATE 'hypertension vs no hypertension' hypertension 1 / EXP;
	ESTIMATE 'heart disease vs no heart disease' heart_disease 1 / EXP;
RUN; /* p-value is 0.0342, suggesting that there is a statistically significant trend in BMI */

PROC GENMOD DATA = WORK.CCHS;
	MODEL asthma_attack (EVENT = '1') = bmi / DIST = BIN LINK = LOG TYPE3;
	ESTIMATE 'PR Normal Weight vs Obese' bmi 1 0 / EXP;
	ESTIMATE 'PR Overweight vs. Obese' bmi 0 1 / EXP;  
RUN; /* p-value is 0.0542, suggesting that there is not a statistically significant trend in BMI */

proc freq data=WORK.CCHS;
    tables asthma_attack*bmi / trend;
run;
