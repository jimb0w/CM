
texdoc init CM, replace logdir(CM_log) gropts(optargs(width=0.8\textwidth))
set linesize 100

*ssc install texdoc, replace
*net from http://www.stata-journal.com/production
*net install sjlatex
*copy "http://www.stata-journal.com/production/sjlatex/stata.sty" stata.sty

! rm -r "/home/jimb0w/Documents/CM/Library"
cd /home/jimb0w/Documents/CM
! git clone https://github.com/jimb0w/Library.git


texdoc stlog, nolog nodo
cd /home/jimb0w/Documents/CM
texdoc do CM.do
texdoc stlog close

/***

\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{stata}
\usepackage[x11names]{xcolor}
\bibliographystyle{unsrt}
\usepackage{natbib}
\usepackage{pdflscape}
\usepackage[section]{placeins}

\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}
\renewcommand{\bibsection}{}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{International trends in cause-specific mortality among people with and without diabetes}
\color{black}
\rule{16cm}{2mm} \\
\Large
\color{black}
\thedate \\
\color{blue}
https://github.com/jimb0w/CM \\
\color{black}
       \vfill
    \end{flushright}
        \Large

\noindent
Correspondence to: \\
\noindent
Jedidiah Morton \\
\color{blue}
\href{mailto:Jedidiah.Morton@Monash.edu}{Jedidiah.Morton@monash.edu} \\ 
\color{black}
Research Fellow \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
Monash University, Melbourne, Australia \\

\end{titlepage}

\clearpage
\tableofcontents

\clearpage
\section{Data cleaning}

This is the protocol for an analysis of trends in cause of death (COD) in people with and without 
diabetes across several countries over the period spanning 2000 to 2021. 

We have been provided with many different variables and some countries have restrictions
on what data they can provide, so we need to harmonize and clean the data into an analysable format.

The variables we will derive are:
\begin{itemize}
\item Calendar year
\item Sex
\item Mid-point age for the age-group
\item Person-years of follow-up in people with diabetes
\item Person-years of follow-up in people without diabetes
\item Number of deaths for each COD in people with diabetes
\item Number of deaths for each COD in people without diabetes
\end{itemize}

The COD are shown in Table~\ref{CODtab}.

\begin{table}[h!]
    \caption{Causes of death in the present analysis}
    \label{CODtab}
	\begin{tabular}{p{6cm}p{2.5cm}p{3cm}p{3cm}}
\hline
Causes of death & Abbreviation & ICD-10 & ICD-9 \\ 
\hline
Cardiovascular diseases & CVD & I00-I99 & 390-434, 436-459 \\ 
Ischaemic heart diseases & CHD & I20-I25 & 410-414, 429.2 \\ 
Cerebrovascular diseases & CBD & I60-I69 & 430-434, 436-438 \\ 
Heart failure & HFD & I50 & 428 \\ 
Cancer & CAN & C00-C97 & 140-208 \\ 
Diabetes & DMD & E10-E14 & 250 \\ 
Infectious diseases & INF & A00-B99 & 001–033, 034.1–134, 136–139, 771.3 \\ 
Influenza and pneumonia & FLU & J09-J18 & 480-487 \\ 
Chronic lower respiratory diseases & RES & J40-J47 & 490-494, 496 \\ 
Liver diseases & LIV1 & K70-K76 & 570-572, 573.0, 573.3-573.9 \\ 
Liver diseases (exclude alcoholic liver disease) & LIV2 & K71-K76 & 570, 571.4-571.9, 572, 573.0, 573.3-573.9 \\ 
Renal diseases & CKD & N00-N08, N17-N19, N25-N27 & 580-589 \\ 
Dementia & AZD & F00, F01, F03, G30 & 290.0-290.2, 290.4, 331.0 \\ 
\hline
\end{tabular}

\end{table}



\subsection{Australia}

For Australia, we have the following variables (by age, sex, and calendar year): 
total population size, person-years in people with diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two [this has been performed before
I got the dataset--JM]. From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

Australian data restrictions prohibit the use of any cell count $<$6 
for the diabetes population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 0 to 5 with equal probability, unless the number of deaths in the
total population for the age/sex group is $<$5, in which case the upper bound will be the 
number of deaths in the total population. 
Further, because of this, data has been provided in both 10-year age groups and
overall (i.e., the actual counts). My intuition is that the small cell counts
won't drive any overall results anyway, which I check below (Figure~\ref{chk1}), 
and that the uncertainty associated with such low numbers will be reflected in very wide
confidence intervals for the younger ages.

\color{Blue4}
***/

texdoc stlog, cmdlog
cd /home/jimb0w/Documents/CM
texdoc stlog close
texdoc stlog, cmdlog
import delimited "Consortium COD database v8.csv", clear
save uncleandbase, replace
texdoc stlog close
texdoc stlog, cmdlog
set seed 3488717
use uncleandbase, clear
keep if substr(country,1,9)=="Australia"
keep if age_gp1!="" | age_gp4!=""
drop if cal < 2005
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,5)
quietly replace `i'_d_dm = runiformint(0,max_`i') if `i'_d_dm ==.
}
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
gen diff = dmd_d_dm-dmd_d_pop
ta diff if diff >0
replace dmd_d_dm = dmd_d_pop if dmd_d_dm > dmd_d_pop
texdoc stlog close

/***
\color{black}

We see that it is predominately younger age groups affected by
missing data, which makes sense. Also, there were some age groups in which
the number of deaths due to diabetes among people with diabetes was greater
than that recorded for the whole population. This likely has to do with 
differences with how we (Australian researchers) and the Australian
Institute of Health and Welfare (who supplied the total population numbers)
define residence in a state, or something similar. The differences were tiny, 
so I have just corrected the diabetes counts to not be more than the total
population counts. 

We should also check that the randomly generated death counts
haven't produced nonsensical results. This could happen in three ways:
\begin{enumerate}
\item The number of deaths in each cause of death together is greater than for all causes
\item The number of deaths in CHD, CBD, and 
HFD together is greater than for CVD as a whole
\item The number of deaths in liver disease (excluding alcoholic liver disease) is greater
than liver disease. 
\end{enumerate}

In the first case, we can just regenerate the random numbers until the error goes away;
in the second, we can set the maximum number of deaths for the simulation
of the other three causes of death
as that for CVD (and because order matters, we will do this in the order of CVD,
CBD, and HFD, based on their relative frequency in the overall population/ages where
there is data); and for the third, we can set the maximum number of deaths for liver
disease (excluding alcoholic liver disease) as that for 
overall liver diease.

\color{Blue4}
***/

texdoc stlog
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_chd = min(cvd_d_dm,5)
replace chd_d_dm = runiformint(0,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_cbd = min(cvd_d_dm-chd_d_dm,5)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,5)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,5)
replace liv2_d_dm = runiformint(0,max_liv2) if liv1_d_dm < liv2_d_dm
count if liv1_d_dm < liv2_d_dm
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
texdoc stlog close
texdoc stlog, cmdlog nodo
*mkdir GPH
preserve
gen agegp = 1 if age_gp1!=""
replace agegp = 2 if age_gp4!=""
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar agegp)
foreach i in can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
if "`i'" == "can" {
local ii = "Cancer"
}
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "cbd" {
local ii = "Cerebrovascular disease"
}
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "chd" {
local ii = "Coronary heart disease"
}
if "`i'" == "azd" {
local ii = "Dementia"
}
if "`i'" == "dmd" {
local ii = "Diabetes"
}
if "`i'" == "hfd" {
local ii = "Heart failure"
}
if "`i'" == "inf" {
local ii = "Infectious diseases"
}
if "`i'" == "flu" {
local ii = "Influenza and pneumonia"
}
if "`i'" == "ckd" {
local ii = "Kidney disease"
}
if "`i'" == "liv1" {
local ii = "Liver disease"
}
if "`i'" == "liv2" {
local ii = "Liver disease (excluding alcoholic liver disease)"
}
gen dm_`i' = 1000*`i'_d_dm/pys_dm
twoway ///
(connected dm_`i' cal if agegp == 1, col(blue)) ///
(connected dm_`i' cal if agegp == 2, col(red)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "10-year age-groups" ///
2 "Overall" ///
) cols(3) position(12) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("`ii'", placement(west) size(medium) col(black))
graph save GPH/dm_`i'_chk1, replace
}
restore
texdoc stlog close
texdoc stlog, cmdlog 
graph combine ///
GPH/dm_can_chk1.gph ///
GPH/dm_cvd_chk1.gph ///
GPH/dm_cbd_chk1.gph ///
GPH/dm_res_chk1.gph ///
GPH/dm_chd_chk1.gph ///
GPH/dm_azd_chk1.gph ///
GPH/dm_dmd_chk1.gph ///
GPH/dm_hfd_chk1.gph ///
GPH/dm_inf_chk1.gph ///
GPH/dm_flu_chk1.gph ///
GPH/dm_ckd_chk1.gph ///
GPH/dm_liv1_chk1.gph ///
GPH/dm_liv2_chk1.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(3.5)
texdoc graph, label(chk1) figure(h!) cabove ///
caption(Crude mortality rate by age-grouping method, by cause of death. Australia. People with diabetes.)
texdoc stlog close

/***
\color{black}

So, from Figure~\ref{chk1} we see that there doesn't appear to be any systematic
issue introduced using random numbers.
I will assume the mid-point of the age interval for people with diabetes aged $<$40 is 35, 
for people without diabetes aged $<$40 is 20, and for both people with and without diabetes
aged 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
keep if age_gp1!=""
replace country = substr(country,1,9)
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Australia, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Canada (Alberta)}

For Canada (Alberta), 
we have the following variables (by age, sex, and calendar year): 
total population size, prevalence of diabetes, incidence of diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two [this has been performed before
I got the dataset--JM]. We can calculate person-years 
in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes 
to half the number of people with 
incident diabetes and subtracting half the number of 
all-cause deaths [again, performed before I got the dataset--JM]. 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

Alberta data restrictions prohibit the use of any cell count between 1 and 9
for people with diabetes and in the total population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 1 to 9 with equal probability, unless the number of deaths in the
total population for the age/sex group is $<$9 (after being randomly generated), 
in which case the upper bound will be the 
number of deaths in the total population.

Sense checks will be as for Australia, above.

\color{Blue4}
***/

texdoc stlog, cmdlog
set seed 17812854
use uncleandbase, clear
keep if substr(country,1,9)=="Canada (A"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_pop ==.
gen min_`i' = max(`i'_d_dm,1) if `i'_d_dm!=.
replace min_`i' = 1 if `i'_d_dm==.
replace `i'_d_dm=0 if `i'_d_pop==0 
quietly replace `i'_d_pop = runiformint(min_`i',9) if `i'_d_pop==.
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,9)
quietly replace `i'_d_dm = runiformint(1,max_`i') if `i'_d_dm ==.
}
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
count if cvd_d_pop + can_d_pop + dmd_d_pop + inf_d_pop + flu_d_pop + res_d_pop + liv1_d_pop + ckd_d_pop + azd_d_pop > alldeath_d_pop
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_dm = runiformint(1,max_`i') if (cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm) & inrange(`i'_d_dm,1,9)
}
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_pop + cbd_d_pop + hfd_d_pop > cvd_d_pop
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_chd = min(cvd_d_dm,9)
replace chd_d_dm = runiformint(1,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(chd_d_dm,1,9)
replace max_cbd = min(cvd_d_dm-chd_d_dm,9)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(cbd_d_dm,1,9)
replace max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,9)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(hfd_d_dm,1,9)
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_pop < liv2_d_pop
ta age_gp1 if liv1_d_pop < liv2_d_pop
replace max_liv2 = min(liv1_d_pop,9)
replace liv2_d_pop = runiformint(1,max_liv2) if liv1_d_pop < liv2_d_pop & inrange(liv2_d_pop,1,9)
count if liv1_d_pop < liv2_d_pop
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,liv2_d_pop,9)
replace liv2_d_dm = runiformint(1,max_liv2) if ((liv1_d_dm < liv2_d_dm) | liv2_d_dm > liv2_d_pop & liv2_d_dm!=.) & inrange(liv2_d_dm,1,9)
count if liv1_d_dm < liv2_d_dm
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
texdoc stlog close
texdoc stlog, cmdlog nodo
keep if age_gp1!=""
replace country = "Canada1"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Canada1, replace
texdoc stlog close


/***
\color{black}

\clearpage
\subsection{Canada (Ontario)}

For Canada (Ontario), 
we have the following variables (by age, sex, and calendar year): 
total population size, prevalence of diabetes, incidence of diabetes, person-years in people with diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two [this has been performed before
I got the dataset--JM]. 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

Ontario data restrictions prohibit the use of any cell count between 1 and 5
for people with diabetes and in the total population. I will fill them in randomly, where the number
can be any number from 1 to 5 with equal probability, unless the number of deaths in the
total population for the age/sex group is $<$5 (after being randomly generated), 
in which case the upper bound will be the 
number of deaths in the total population.

Sense checks will be as for Australia, above.

\color{Blue4}
***/

texdoc stlog, cmdlog
set seed 46792303
use uncleandbase, clear
keep if substr(country,1,9)=="Canada (O"
drop if cal < 2013
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_pop ==.
gen min_`i' = max(`i'_d_dm,1) if `i'_d_dm!=.
replace min_`i' = 1 if `i'_d_dm==.
replace `i'_d_dm=0 if `i'_d_pop==0 
quietly replace `i'_d_pop = runiformint(min_`i',5) if `i'_d_pop==.
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,5)
quietly replace `i'_d_dm = runiformint(1,max_`i') if `i'_d_dm ==.
}
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
count if cvd_d_pop + can_d_pop + dmd_d_pop + inf_d_pop + flu_d_pop + res_d_pop + liv1_d_pop + ckd_d_pop + azd_d_pop > alldeath_d_pop
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_pop + cbd_d_pop + hfd_d_pop > cvd_d_pop
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
replace max_chd = min(cvd_d_dm,5)
replace chd_d_dm = runiformint(1,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(chd_d_dm,1,5)
replace max_cbd = min(cvd_d_dm-chd_d_dm,5)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(cbd_d_dm,1,5)
replace max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,5)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(hfd_d_dm,1,5)
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_pop < liv2_d_pop
ta age_gp1 if liv1_d_pop < liv2_d_pop
replace max_liv2 = min(liv1_d_pop,9)
replace liv2_d_pop = runiformint(1,max_liv2) if liv1_d_pop < liv2_d_pop & inrange(liv2_d_pop,1,9)
count if liv1_d_pop < liv2_d_pop
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,9)
replace liv2_d_dm = runiformint(1,max_liv2) if liv1_d_dm < liv2_d_dm & inrange(liv2_d_dm,1,9)
count if liv1_d_dm < liv2_d_dm
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
texdoc stlog close
texdoc stlog, cmdlog nodo
keep if age_gp1!=""
replace country = "Canada2"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Canada2, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Denmark}

For Denmark, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Denmark restricts counts between 1 and 3 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 1 to 3 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
set seed 10239835
use uncleandbase, clear
keep if substr(country,1,7)=="Denmark"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
replace `i'_d_nondm = runiformint(1,3) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
replace `i'_d_dm = runiformint(1,3) if `i'_d_dm ==.
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
forval ii = 1/4 {
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_dm = runiformint(1,3) if (cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm) & inrange(`i'_d_dm,1,3)
}
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
}
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
gen max_chd = min(cvd_d_dm,3)
replace chd_d_dm = runiformint(1,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(chd_d_dm,1,3)
gen max_cbd = min(cvd_d_dm-chd_d_dm,3)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(cbd_d_dm,1,3)
gen max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,3)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(hfd_d_dm,1,3)
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
ta age_gp1 if liv1_d_nondm < liv2_d_nondm
gen max_liv2 = min(liv1_d_nondm,3)
replace liv2_d_nondm = runiformint(1,max_liv2) if liv1_d_nondm < liv2_d_nondm & inrange(liv2_d_nondm,1,3)
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,3)
replace liv2_d_dm = runiformint(1,max_liv2) if liv1_d_dm < liv2_d_dm & inrange(liv2_d_dm,1,3)
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
replace country = "Denmark"
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Denmark, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Finland}

For Finland, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Finland restricts counts between 1 and 5 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 1 to 5 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
set seed 8467215
use uncleandbase, clear
keep if substr(country,1,7)=="Finland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(1,5) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(1,5) if `i'_d_dm ==.
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
ta age_gp1 if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
gen max_chd = min(cvd_d_dm,5)
replace chd_d_dm = runiformint(1,max_chd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(chd_d_dm,1,5)
gen max_cbd = min(cvd_d_dm-chd_d_dm,5)
replace cbd_d_dm = runiformint(0,max_cbd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(cbd_d_dm,1,5)
gen max_hfd = min(cvd_d_dm-chd_d_dm-cbd_d_dm,5)
replace hfd_d_dm = runiformint(0,max_hfd) if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm & inrange(hfd_d_dm,1,5)
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
ta age_gp1 if liv1_d_nondm < liv2_d_nondm
gen max_liv2 = min(liv1_d_nondm,5)
replace liv2_d_nondm = runiformint(1,max_liv2) if liv1_d_nondm < liv2_d_nondm & inrange(liv2_d_nondm,1,5)
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
replace max_liv2 = min(liv1_d_dm,5)
replace liv2_d_dm = runiformint(1,max_liv2) if liv1_d_dm < liv2_d_dm & inrange(liv2_d_dm,1,5)
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Finland, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{France}

For France, we have the following variables (by age, sex, and calendar year): 
person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
France has excluded counts between 1 and 4, which I will fill in randomly. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
set seed 051968
use uncleandbase, clear
keep if substr(country,1,8)=="France_1"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
recode dmd_d_nondm .=0
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(1,4) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(1,4) if `i'_d_dm ==.
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
ta age_gp1 if liv1_d_dm < liv2_d_dm
gen max_liv2 = min(liv1_d_dm,4)
replace liv2_d_dm = runiformint(1,max_liv2) if liv1_d_dm < liv2_d_dm & inrange(liv2_d_dm,1,4)
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
replace country = substr(country,1,6)
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save France, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Lithuania}

For Lithuania, we have the following variables (by age, sex, and calendar year): 
total population size, prevalence of diabetes, incidence of diabetes, 
deaths in people with diabetes, and deaths in people without diabetes. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two. We can calculate person-years in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes to half the number of people with 
incident diabetes and subtracting half the number of all-cause deaths. 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
[All of this has been performed before I got the dataset--JM.]

\color{Blue4}
***/

texdoc stlog, cmdlog
use uncleandbase, clear
keep if country == "Lithuania"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
recode dmd_d_nondm .=0
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Lithuania, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Scotland}

For Scotland, we have the following variables (by age, sex, and calendar year): 
total population size, person-years in people with diabetes,
deaths in people with diabetes, and deaths in the total population.
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two [this has been performed before
I got the dataset -- JM]. I then calculate person-years in people without diabetes by substracting
the person-years in people with diabetes from person-years in the total population; similarly
for deaths in people without diabetes. There were a few age groups in whom the number of deaths
from diabetes in people with diabetes was slightly greater than the total population deaths; 
I will simply make these zero in people without diabetes. 

Also note we have received two different age
groupings for Scotland for total population deaths -- from 2006-2015: 0-39, 40-49, \ldots , 80+; from 2016-2020:
0-39, 40-49, \ldots, 90+. For the 80+ age grouping I will assume the mean age is 87.5 years. 

\color{Blue4}
***/

texdoc stlog
use uncleandbase, clear
keep if country == "Scotland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
di "`i'"
ta `i'_d_nondm if `i'_d_nondm <0
}
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
replace dmd_d_nondm = 0 if dmd_d_nondm <0
replace pys_nondm = pys_totpop-pys_dm
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = substr(age_gp2,1,2) if cal <= 2015
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
replace age_nondm = age_nondm+2.5 if age_nondm == 85 & cal <= 2015
replace pys_dm =. if age_dm==.
replace pys_nondm =. if age_nondm==.
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd liv1 liv2 {
replace `i'_d_dm = . if age_dm==.
replace `i'_d_nondm = . if age_nondm==.
}
drop if age_dm==. & age_nondm==.
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Scotland, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{South Korea}

For South Korea, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Note that from 2007-2010, there is no data for people aged 90 and above, although
this shouldn't have a huge impact on any results.  
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
use uncleandbase, clear
keep if country=="South Korea"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
drop if age_gp4=="all ages"
drop if age_gp1 == "90+" & cal <= 2010
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
replace country = "SKorea"
texdoc stlog close
texdoc stlog
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm > alldeath_d_nondm
count if cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm > alldeath_d_dm
count if chd_d_nondm + cbd_d_nondm + hfd_d_nondm > cvd_d_nondm
count if chd_d_dm + cbd_d_dm + hfd_d_dm > cvd_d_dm
count if liv1_d_nondm < liv2_d_nondm
count if liv1_d_dm < liv2_d_dm
texdoc stlog close
texdoc stlog, cmdlog nodo
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save SKorea, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Summary}

Table~\ref{cleansumtab} shows a summary of the data included in this analysis. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*mkdir CSV
clear
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using `c'
}
gen other_d_dm = alldeath_d_dm - ///
(cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv1_d_dm + ckd_d_dm + azd_d_dm)
gen other_d_nondm = alldeath_d_nondm - ///
(cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv1_d_nondm + ckd_d_nondm + azd_d_nondm)
save cleandbase, replace
use cleandbase, clear
foreach i in chd cbd hfd liv2 {
drop `i'_d_dm `i'_d_nondm
}
rename (liv1_d_dm liv1_d_nondm) (liv_d_dm liv_d_nondm)
save CMdata, replace
use cleandbase, clear
foreach i in alldeath can res azd dmd inf flu ckd liv1 liv2 {
drop `i'_d_dm `i'_d_nondm
}
save CMdataCVD, replace
use cleandbase, clear
foreach i in alldeath can cvd chd cbd hfd res azd dmd inf flu ckd {
drop `i'_d_dm `i'_d_nondm
}
save CMdataLIV, replace
use cleandbase, clear
foreach i in alldeath can cvd chd cbd hfd res dmd inf flu ckd liv1 liv2 {
drop `i'_d_dm `i'_d_nondm
}
save CMdataDEM, replace
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `c', clear
foreach i in chd cbd hfd liv2 {
drop `i'_d_dm `i'_d_nondm
}
rename (liv1_d_dm liv1_d_nondm) (liv_d_dm liv_d_nondm)
save `c', replace
}
erase uncleandbase.dta
use CMdata, clear
bysort country (cal) : egen lb = min(cal)
bysort country (cal) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
recode dmd_d_nondm .=0
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm other_d_dm other_d_nondm, by(country sex rang)
expand 2
bysort country sex : gen DM = _n-1
tostring sex pys_dm-DM, replace force format(%15.0fc)
gen pys = pys_dm if DM == "1"
replace pys = pys_nondm if DM == "0"
foreach i in can cvd res azd dmd inf flu ckd liv other {
gen `i' = `i'_d_dm if DM == "1"
replace `i' = `i'_d_nondm if DM == "0"
}
keep country-rang DM-other
order country rang DM sex
sort country rang DM sex
gen njm = _n
bysort country DM (njm) : replace DM ="" if _n!=1
bysort country (njm) : replace rang ="" if _n!=1
bysort country (njm) : replace country ="" if _n!=1
sort njm
replace DM = "No diabetes" if DM == "0"
replace DM = "Diabetes" if DM == "1"
replace sex = "Female" if sex == "0"
replace sex = "Male" if sex == "1"
drop njm
replace country = "South Korea" if country == "SKorea"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
export delimited using CSV/T1.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{landscape}
\thispagestyle{empty}

\begin{table}[h!]
  \begin{center}
    \caption{Summary of data included in the analysis.}
	\hspace*{-1.5cm}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{4}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{4}{*}{##1}}}},
	  display columns/2/.style={column name=Diabetes status,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/3/.style={column name=Sex, column type={l}, text indicator="},
      display columns/4/.style={column name=Person-years of follow-up, column type={r}},
      display columns/5/.style={column name=DEM, column type={r}},
      display columns/6/.style={column name=CAN, column type={r}},
      display columns/7/.style={column name=CVD, column type={r}},
      display columns/8/.style={column name=RES, column type={r}},
      display columns/9/.style={column name=DMD, column type={r}},
      display columns/10/.style={column name=INF, column type={r}},
      display columns/11/.style={column name=FLU, column type={r}},
      display columns/12/.style={column name=CKD, column type={r}},
      display columns/13/.style={column name=LIV, column type={r}},
      display columns/14/.style={column name=OTH, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & & & \multicolumn{10}{c}{Death counts by cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={4}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/T1.csv}
  \end{center}
Abbreviations: DEM -- Dementia; CAN -- Cancer; CVD -- Cardiovascular disease; 
RES -- Chronic lower respiratory disease; DMD -- Diabetes; INF -- Infectious diseases; 
FLU -- Influenza and pneumonia; CKD -- Kidney disease; LIV -- Liver disease;
OTH -- All other causes.
\end{table}
\end{landscape}


\clearpage
\section{Crude rates}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `c', clear
if "`c'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`c'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar sex)
foreach i in can cvd res azd dmd inf flu ckd liv {
if "`i'" == "can" {
local ii = "Cancer"
}
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "azd" {
local ii = "Dementia"
}
if "`i'" == "dmd" {
local ii = "Diabetes"
}
if "`i'" == "inf" {
local ii = "Infectious diseases"
}
if "`i'" == "flu" {
local ii = "Influenza and pneumonia"
}
if "`i'" == "ckd" {
local ii = "Kidney disease"
}
if "`i'" == "liv" {
local ii = "Liver disease"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
gen `iii'_`i' = 1000*`i'_d_`iii'/pys_`iii'
twoway ///
(connected `iii'_`i' cal if sex == 0, col(red)) ///
(connected `iii'_`i' cal if sex == 1, col(blue)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years), margin(a+2)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "Females" ///
2 "Males" ///
) cols(1) position(3) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("People `dd' diabetes", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
graph combine ///
GPH/cr_`i'_dm_`c'.gph ///
GPH/cr_`i'_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(10)
}
}
texdoc stlog close
texdoc stlog, nolog
foreach c in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `c', clear
if "`c'" == "Canada1" {
local co = "Canada (Alberta)"
}
else if "`c'" == "Canada2" {
local co = "Canada (Ontario)"
}
else if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar sex)
foreach i in can cvd res azd dmd inf flu ckd liv {
if "`i'" == "can" {
local ii = "Cancer"
}
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "azd" {
local ii = "Dementia"
}
if "`i'" == "dmd" {
local ii = "Diabetes"
}
if "`i'" == "inf" {
local ii = "Infectious diseases"
}
if "`i'" == "flu" {
local ii = "Influenza and pneumonia"
}
if "`i'" == "ckd" {
local ii = "Kidney disease"
}
if "`i'" == "liv" {
local ii = "Liver disease"
}
foreach iii in dm nondm {
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
gen `iii'_`i' = 1000*`i'_d_`iii'/pys_`iii'
twoway ///
(connected `iii'_`i' cal if sex == 0, col(red)) ///
(connected `iii'_`i' cal if sex == 1, col(blue)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years), margin(a+2)) ///
xtitle(Calendar year) ///
xlabel(,nogrid) legend(order( ///
1 "Females" ///
2 "Males" ///
) cols(1) position(3) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f) glpattern(solid) glcolor(gs10%20)) ///
title("People `dd' diabetes", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
graph combine ///
GPH/cr_`i'_dm_`c'.gph ///
GPH/cr_`i'_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(10)
texdoc graph, label(cr_`i'_`c') figure(h!) cabove ///
caption(Crude mortality rate by cause of death, sex, and diabetes status. `ii'. `co'.)
}
texdoc stlog close
/***
\clearpage
***/
texdoc stlog, nolog
}
texdoc stlog close

/***
\color{black}

\clearpage
A few potential coding changes to note:
\begin{itemize}
\item Figure~\ref{cr_ckd_Australia}, Australia, kidney disease in 2013 -- there is a big drop,
suggesting a change in how kidney disease deaths were coded. Indeed, there were changes in coding 
kidney disease deaths by the Australian Burea of Statistics with the implementation of new
software, which were as follows: 
\begin{itemize}
\item ``N17-N19 Renal failure: 
There has been an increase in the number of conditions that have a causal 
relationship with renal failure. 
As a result, fewer deaths have been 
assigned to the code block N17-N19 as an 
underlying cause of death. Of note, 
E11 Non-insulin-dependent diabetes 
mellitus now combines with renal failure to 
form the code E11.2 Non-insulin- dependent diabetes mellitus with renal complications.''
\item ``N18 Chronic kidney disease: 
The title of code N18 has changed from Chronic renal failure to 
Chronic kidney disease. With the title update a coding change 
has occurred. Previously the term `Chronic kidney disease' was 
coded to N03 Chronic nephritic syndrome. 
It is now coded to N18 Chronic kidney disease. 
Consequently, deaths assigned to N03 as an underlying cause have decreased.''
\end{itemize}
\item Figure~\ref{cr_flu_Finland}, Finland, influenza and pneumonia from 2000-2005 -- the continuous
drop suggests a gradual change in how these deaths were coded.
\item Figure~\ref{cr_ckd_Scotland}, Scotland, kidney disease in 2017 -- the big drop in 2017 for people
with and without diabetes suggests a coding change. 
\end{itemize}

We will not present this data.  


\clearpage
\section{Cause-specific mortality rates}

\subsection{Methods}

The methods are largely derived from Magliano et al. \cite{MaglianoLDE2022}.
To generate age- and period-specific rates, which will be used to generate age-standardised rates, 
we will model mortality rates using age-period-cohort models \cite{CarstensenSTATMED2007}.
Each model will be a Poisson model, parameterised using 
spline effects of age, period, and cohort (period $-$ age), with log 
of person-years as the offset. 
Age is defined as above (i.e., the midpoint of the interval in most cases) and models are
fit separately for each cause of death and country in people with and without diabetes and by sex. 
Because this will be \begin{math} 9 \times 9 \times 2 \times 2 = 324 \end{math} models, 
we won't check model fit for each model. Instead, 
to check model fit we will select a few at random and check the modelled and crude rates as well as 
the Pearson residuals. 
These models will be used to estimate mortality rates for single year ages and calendar years.
These modelled rates will be used to generate
age-standardised rates in people with and without diabetes by period, using direct standardisation
(using the total diabetes population formed by pooling the consortium data).

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*mkdir MD
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
predict pred
gen OC = "`ii'"
gen DM = "`iii'"
save MD/RC_pred_`i'_`ii'_`iii'_`iiii', replace
keep calendar
bysort cal : keep if _n == 1
expand 10
bysort cal : replace cal = cal+((_n-6)/10)
expand 700
bysort cal : gen age_`iii' = (_n/10)+29.9
gen pys_`iii' = 1
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
predict errr, stdp
replace _Rate = _Rate*1000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
gen sex = `iiii'
replace cal = cal+2010
tostring age_`iii', replace force format(%9.1f)
destring age_`iii', replace
save MD/R_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
}
set seed 1312
clear
gen A =.
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
foreach iiii in 0 1 {
local B = runiform()
append using MD/RC_pred_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A > 0.985
}
}
}
}
}
save RCc, replace
set seed 1312
clear
gen A =.
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
foreach iiii in 0 1 {
local B = runiform()
append using MD/R_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A > 0.985
}
}
}
}
}
save Rc, replace
texdoc stlog close
texdoc stlog
use Rc, clear
bysort A : keep if _n == 1
list country OC DM sex
texdoc stlog close
texdoc stlog, cmdlog nodo
forval i = 1/10 {
use Rc, clear
bysort A : keep if _n == 1
local c=country[`i']
local o=OC[`i']
local d=DM[`i']
local s=sex[`i']
if "`o'" == "can" {
local oo = "Cancer"
}
if "`o'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`o'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`o'" == "azd" {
local oo = "Dementia"
}
if "`o'" == "dmd" {
local oo = "Diabetes"
}
if "`o'" == "inf" {
local oo = "Infectious diseases"
}
if "`o'" == "flu" {
local oo = "Influenza and pneumonia"
}
if "`o'" == "ckd" {
local oo = "Kidney disease"
}
if "`o'" == "liv" {
local oo = "Liver disease"
}
if "`d'" == "dm" {
local dd = "with"
}
if "`d'" == "nondm" {
local dd = "without"
}
if `s' == 0 {
local ss = "Females"
}
if `s' == 1 {
local ss = "Males"
}
use Rc, clear
keep if country == "`c'" & OC == "`o'" & sex == `s' & DM == "`d'"
drop pys_nondm pys_dm
merge 1:1 age_`d' sex cal using `c'
drop if _merge == 2
gen rate = 1000*`o'_d_`d'/pys_`d'
egen calmen = mean(calendar)
replace calmen = round(calmen,1)
local cmu = calmen[1]
twoway ///
(rarea ub lb age_`d' if cale == `cmu', color(black%30) fintensity(inten80) lwidth(none)) ///
(line _Rate age_`d' if cale == `cmu', color(black)) ///
(scatter rate age_`d' if cale == `cmu' & rate !=0, col(black)) ///
, graphregion(color(white)) ylabel(, angle(0) glpattern(solid) glcolor(gs10%20)) ///
xlabel(30(10)100, nogrid) ytitle("Mortality rate (per 1000 person-years)") ///
xtitle(Age) yscale(nolog) legend(order( ///
2 "Modelled" ///
3 "Crude" ///
) ring(0) cols(1) position(11) region(lcolor(none) col(none))) ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/Rc_`c'_`o'_`d'_`s'_age, replace
twoway ///
(rarea ub lb cale if age_`d' == 45, color(gs0%30) fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`d' == 45, color(gs0)) ///
(scatter rate cale if age_`d' == 45 & rate !=0, col(gs0)) ///
(rarea ub lb cale if age_`d' == 65, color(gs5%30) fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`d' == 65, color(gs5)) ///
(scatter rate cale if age_`d' == 65 & rate !=0, col(gs5)) ///
(rarea ub lb cale if age_`d' == 85, color(gs10%30) fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`d' == 85, color(gs10)) ///
(scatter rate cale if age_`d' == 85 & rate !=0, col(gs10)) ///
, graphregion(color(white)) ylabel(, angle(0) glpattern(solid) glcolor(gs10%20)) ///
ytitle("Mortality rate (per 1000 person-years)") ///
xtitle(Year) yscale(log) legend(order( ///
2 "Modelled" ///
2 "45" 5 "65" 8 "85" ///
3 "Crude" ///
3 "40-49" 6 "60-69" 9 "80-89" ///
) ring(0) cols(4) position(11) region(lcolor(none) col(none))) ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/Rc_`c'_`o'_`d'_`s'_period, replace
use RCc, clear
replace coh= coh+2010
keep if country == "`c'" & OC == "`o'" & sex == `s' & DM == "`d'"
gen res = (`o'_d_`d'-pred)/sqrt(pred)
twoway ///
(scatter res age_`d', col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0) glpattern(solid) glcolor(gs10%20)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Age (years)") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_age, replace
twoway ///
(scatter res cale, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0) glpattern(solid) glcolor(gs10%20)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Period") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_period, replace
twoway ///
(scatter res coh, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0) glpattern(solid) glcolor(gs10%20)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Cohort") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_cohort, replace
}
texdoc stlog close
texdoc stlog, cmdlog
use Rc, clear
bysort A : keep if _n == 1
forval i = 1/10 {
local c`i'=country[`i']
local o`i'=OC[`i']
local d`i'=DM[`i']
local s`i'=sex[`i']
}
graph combine ///
GPH/Rc_`c1'_`o1'_`d1'_`s1'_age.gph ///
GPH/Rc_`c2'_`o2'_`d2'_`s2'_age.gph ///
GPH/Rc_`c3'_`o3'_`d3'_`s3'_age.gph ///
GPH/Rc_`c4'_`o4'_`d4'_`s4'_age.gph ///
GPH/Rc_`c5'_`o5'_`d5'_`s5'_age.gph ///
GPH/Rc_`c6'_`o6'_`d6'_`s6'_age.gph ///
GPH/Rc_`c7'_`o7'_`d7'_`s7'_age.gph ///
GPH/Rc_`c8'_`o8'_`d8'_`s8'_age.gph ///
GPH/Rc_`c9'_`o9'_`d9'_`s9'_age.gph ///
GPH/Rc_`c10'_`o10'_`d10'_`s10'_age.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC1) figure(h!) cabove ///
caption(Modelled and crude mortality rates by age for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/Rc_`c1'_`o1'_`d1'_`s1'_period.gph ///
GPH/Rc_`c2'_`o2'_`d2'_`s2'_period.gph ///
GPH/Rc_`c3'_`o3'_`d3'_`s3'_period.gph ///
GPH/Rc_`c4'_`o4'_`d4'_`s4'_period.gph ///
GPH/Rc_`c5'_`o5'_`d5'_`s5'_period.gph ///
GPH/Rc_`c6'_`o6'_`d6'_`s6'_period.gph ///
GPH/Rc_`c7'_`o7'_`d7'_`s7'_period.gph ///
GPH/Rc_`c8'_`o8'_`d8'_`s8'_period.gph ///
GPH/Rc_`c9'_`o9'_`d9'_`s9'_period.gph ///
GPH/Rc_`c10'_`o10'_`d10'_`s10'_period.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC2) figure(h!) cabove ///
caption(Modelled and crude mortality rates by year for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/RCc_`c1'_`o1'_`d1'_`s1'_age.gph ///
GPH/RCc_`c2'_`o2'_`d2'_`s2'_age.gph ///
GPH/RCc_`c3'_`o3'_`d3'_`s3'_age.gph ///
GPH/RCc_`c4'_`o4'_`d4'_`s4'_age.gph ///
GPH/RCc_`c5'_`o5'_`d5'_`s5'_age.gph ///
GPH/RCc_`c6'_`o6'_`d6'_`s6'_age.gph ///
GPH/RCc_`c7'_`o7'_`d7'_`s7'_age.gph ///
GPH/RCc_`c8'_`o8'_`d8'_`s8'_age.gph ///
GPH/RCc_`c9'_`o9'_`d9'_`s9'_age.gph ///
GPH/RCc_`c10'_`o10'_`d10'_`s10'_age.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC3) figure(h!) cabove ///
caption(Pearson residuals by age for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/RCc_`c1'_`o1'_`d1'_`s1'_period.gph ///
GPH/RCc_`c2'_`o2'_`d2'_`s2'_period.gph ///
GPH/RCc_`c3'_`o3'_`d3'_`s3'_period.gph ///
GPH/RCc_`c4'_`o4'_`d4'_`s4'_period.gph ///
GPH/RCc_`c5'_`o5'_`d5'_`s5'_period.gph ///
GPH/RCc_`c6'_`o6'_`d6'_`s6'_period.gph ///
GPH/RCc_`c7'_`o7'_`d7'_`s7'_period.gph ///
GPH/RCc_`c8'_`o8'_`d8'_`s8'_period.gph ///
GPH/RCc_`c9'_`o9'_`d9'_`s9'_period.gph ///
GPH/RCc_`c10'_`o10'_`d10'_`s10'_period.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC4) figure(h!) cabove ///
caption(Pearson residuals by period for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
texdoc stlog close

/***
\color{black}

We see that the models fit the data reasonably well (Figures~\ref{MC1}-~\ref{MC4}). 

\clearpage
\subsection{Age- and sex-standardised rates}

We are going to calculate age-standardised mortality rates among people
aged 40-89 years. We will first generate cause-specific mortality
rates for people aged 40-89. 
Then, we will use direct standardisation to generate the 
age-standardised rates, using a reference population constructed by
pooling the person-years among people with diabetes from all datasets.
There will be two reference populations:
first, one stratified by sex so that we can age and sex-standardise
the overall results; second, one overall population to age-standardise
the sex-stratified results to. 

\color{Blue4}
***/

texdoc stlog, cmdlog
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `i', clear
collapse (sum) pys_dm, by(age_dm)
save `i'_pysdm, replace
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using `i'_pysdm
}
collapse (sum) pys_dm, by(age_dm)
drop if age_dm > 90 | age_dm == 35
expand 10
replace pys_dm=pys_dm/10
bysort age : replace age = age+_n-5.5
mkspline agesp = age, cubic knots(45 65 85)
glm pys_dm agesp*, family(gamma) link(log)
predict A
preserve
replace pys_dm = pys_dm/1000000
replace A = A/1000000
twoway ///
(scatter pys_dm age_dm, col(dknavy)) ///
(line A age_dm, col(magenta)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Crude" ///
2 "Modelled") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) angle(0) nogrid) ///
ytitle("Population size (millions)") xtitle("Age") xlabel(, nogrid)
texdoc graph, label(SPN) figure(h!) cabove caption(Pooled standard population)
restore
su(pys_dm)
gen age_dm_prop = pys_dm/r(sum)
su(A)
gen B = A/r(sum)
twoway ///
(bar age_dm_prop age_dm, color(dknavy%70)) ///
(bar B age_dm, color(magenta%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Crude" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.04, angle(0) format(%9.2f) nogrid) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age") xlabel(, nogrid)
texdoc graph, label(SPP) figure(h!) cabove caption(Pooled standard population proportion)
keep age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpop, replace
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `i', clear
collapse (sum) pys_dm, by(sex age_dm)
save `i'_pysdm_s, replace
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using `i'_pysdm_s
}
collapse (sum) pys_dm, by(sex age_dm)
drop if age_dm > 90 | age_dm == 35
expand 10
replace pys_dm=pys_dm/10
bysort sex age : replace age = age+_n-5.5
mkspline agesp = age, cubic knots(35 45 60 75 90)
glm pys_dm agesp* if sex == 0, family(gamma) link(log)
predict A0 if sex == 0
glm pys_dm agesp* if sex == 1, family(gamma) link(log)
predict A1 if sex == 1
preserve
replace pys_dm = pys_dm/1000000
replace A0 = A0/1000000
replace A1 = A1/1000000
twoway ///
(scatter pys_dm age_dm if sex == 0, col(cranberry)) ///
(line A0 age_dm, col(red)) ///
(scatter pys_dm age_dm if sex == 1, col(dknavy)) ///
(line A1 age_dm, col(blue)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Crude, females" ///
2 "Modelled, females" ///
3 "Crude, males" ///
4 "Modelled, males") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) angle(0) nogrid) xlabel(, nogrid) ///
ytitle("Population size (millions)") xtitle("Age")
texdoc graph, label(SPNs) figure(h!) cabove caption(Pooled standard population by sex)
restore
su(pys_dm)
gen age_dm_prop = pys_dm/r(sum)
gen A = A0
replace A = A1 if A ==.
su(A)
gen B = A/r(sum)
twoway ///
(bar age_dm_prop age_dm if sex == 0, color(cranberry%90)) ///
(bar B age_dm if sex == 0, color(red%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Crude" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.02, angle(0) format(%9.2f) nogrid) xlabel(, nogrid) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age") ///
title("Females", col(black) placement(west) size(medium))
graph save stdprop_0, replace
twoway ///
(bar age_dm_prop age_dm if sex == 1, color(dknavy%70)) ///
(bar B age_dm if sex == 1, color(blue%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Crude" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.02, angle(0) format(%9.2f) nogrid) xlabel(, nogrid) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age") ///
title("Males", col(black) placement(west) size(medium))
graph save stdprop_1, replace
graph combine ///
stdprop_0.gph stdprop_1.gph ///
, graphregion(color(white)) altshrink cols(1) xsize(2.5)
texdoc graph, label(SPPs) figure(h!) cabove caption(Pooled standard population proportion by sex)
keep sex age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpops, replace
texdoc stlog close

/***
\clearpage
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep sex calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
keep if inrange(age_`iii',40,89)
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
keep if inrange(age_`iii',40,89)
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
save MD/STDi_`i'_`ii'_`iii'_`iiii', replace
rename age_`iii' age
merge m:1 age using refpop
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'" " " "`iiii'"
}
keep cal stdrate lb ub sex
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
clear
append using MD/STDi_`i'_`ii'_`iii'_0 MD/STDi_`i'_`ii'_`iii'_1
rename age_`iii' age
merge m:1 sex age using refpops
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'"
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
}
}
texdoc stlog close
texdoc stlog
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep sex calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
keep if inrange(age_`iii',40,89)
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
keep if inrange(age_`iii',40,89)
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 9.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',10,14.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
save MD/STDi_`i'_`ii'_`iii'_`iiii', replace
rename age_`iii' age
merge m:1 age using refpop
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'" " " "`iiii'"
}
keep cal stdrate lb ub sex
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
clear
append using MD/STDi_`i'_`ii'_`iii'_0 MD/STDi_`i'_`ii'_`iii'_1
rename age_`iii' age
merge m:1 sex age using refpops
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 1000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_`iii'
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 1000*(expdeath1-1.96*SE)
gen ub = 1000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
count if lb < 0
if r(N) != 0 {
noisily di "`i'" " " "`ii'" " " "`iii'"
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2009.5
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
}
}
texdoc stlog close

/***
\color{black}

\clearpage
The standardisation confidence interval crosses 0 for CKD deaths among males from Lithuania, 
reflecting extremely low numbers. I simply won't plot these. 
Similarly for Dementia deaths among males from South Korea. 

\color{Blue4}
***/

texdoc stlog, cmdlog
clear
set obs 1
gen country = "Australia"
save MD/STD_Australia_ckd_nondm, replace
save MD/STD_Australia_ckd_dm, replace
save MD/STD_Australia_ckd_nondm_0, replace
save MD/STD_Australia_ckd_nondm_1, replace
save MD/STD_Australia_ckd_dm_0, replace
save MD/STD_Australia_ckd_dm_1, replace
clear
set obs 1
gen country = "Finland"
save MD/STD_Finland_flu_dm, replace
save MD/STD_Finland_flu_nondm, replace
save MD/STD_Finland_flu_nondm_0, replace
save MD/STD_Finland_flu_nondm_1, replace
save MD/STD_Finland_flu_dm_0, replace
save MD/STD_Finland_flu_dm_1, replace
clear
set obs 1
gen country = "Scotland"
save MD/STD_Scotland_ckd_nondm, replace
save MD/STD_Scotland_ckd_dm, replace
save MD/STD_Scotland_ckd_nondm_0, replace
save MD/STD_Scotland_ckd_nondm_1, replace
save MD/STD_Scotland_ckd_dm_0, replace
save MD/STD_Scotland_ckd_dm_1, replace
clear
set obs 1
gen country = "Lithuania"
save MD/STD_Lithuania_ckd_dm_1, replace
clear
set obs 1
gen country = "SKorea"
save MD/STD_SKorea_azd_dm_1, replace
texdoc stlog close
texdoc stlog, cmdlog nodo
*ssc install palettes
*ssc install colrspace
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
if "`ii'" == "can" {
local oo = "Cancer"
local ylab = "2 5 10 20"
local yform = "%9.0f"
local yrange = "1.8 20"
}
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
local ylab = "2 5 10 20 50"
local yform = "%9.0f"
local yrange = "1.8 50"
}
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
local ylab = "0.1 0.2 0.5 1 2"
local yform = "%9.1f"
local yrange = "0.05 4"
}
if "`ii'" == "azd" {
local oo = "Dementia"
local ylab = "0.01 0.02 0.05 0.1 0.2 0.5 1 2 5"
local yform = "%9.2f"
local yrange = "0.005 5"
}
if "`ii'" == "dmd" {
local oo = "Diabetes"
local ylab = "1 2 5 10"
local yform = "%9.0f"
local yrange = "0.5 10"
}
if "`ii'" == "inf" {
local oo = "Infectious diseases"
local ylab = "0.1 0.2 0.5 1 2"
local yform = "%9.1f"
local yrange = "0.05 2"
}
if "`ii'" == "flu" {
local oo = "Influenza and pneumonia"
local ylab = "0.1 0.2 0.5 1 2"
local yform = "%9.1f"
local yrange = "0.05 3"
}
if "`ii'" == "ckd" {
local oo = "Kidney disease"
local ylab = "0.01 0.02 0.05 0.1 0.2 0.5 1 2"
local yform = "%9.2f"
local yrange = "0.005 2"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
local ylab = "0.02 0.05 0.1 0.2 0.5 1 2"
local yform = "%9.2f"
local yrange = "0.02 2.1"
}
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/STD_`i'_`ii'_`iii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/9 {
local C`i' = country[`i']
}
restore
colorpalette hue, n(9) luminance(50) nograph
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`r(p1)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`r(p1)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`r(p2)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`r(p2)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`r(p3)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`r(p3)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`r(p4)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`r(p4)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`r(p5)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`r(p5)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`r(p6)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`r(p6)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`r(p7)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`r(p7)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`r(p8)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`r(p8)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C9'", color("`r(p9)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C9'", color("`r(p9)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C10'", color("`r(p10)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C10'", color("`r(p10)'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'" ///
20 "`C10'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid glpattern(solid) glcolor(gs10%20) angle(0)) ///
yscale(log range(`yrange')) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', people `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii'_`iii', replace
forval iiii = 0/1 {
if `iiii' == 0 {
local s = "females"
}
if `iiii' == 1 {
local s = "males"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/STD_`i'_`ii'_`iii'_`iiii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/9 {
local C`i' = country[`i']
}
restore
colorpalette hue, n(9) luminance(50) nograph
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`r(p1)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`r(p1)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`r(p2)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`r(p2)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`r(p3)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`r(p3)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`r(p4)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`r(p4)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`r(p5)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`r(p5)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`r(p6)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`r(p6)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`r(p7)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`r(p7)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`r(p8)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`r(p8)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C9'", color("`r(p9)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C9'", color("`r(p9)'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C10'", color("`r(p10)'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C10'", color("`r(p10)'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'" ///
20 "`C10'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid  glpattern(solid) glcolor(gs10%20) angle(0)) ///
yscale(log range(`yrange')) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', `s' `w' diabetes", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii'_`iii'_`iiii', replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in can cvd res azd dmd inf flu ckd liv {
if "`ii'" == "can" {
local oo = "Cancer"
}
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "azd" {
local oo = "Dementia"
}
if "`ii'" == "dmd" {
local oo = "Diabetes"
}
if "`ii'" == "inf" {
local oo = "Infectious diseases"
}
if "`ii'" == "flu" {
local oo = "Influenza and pneumonia"
}
if "`ii'" == "ckd" {
local oo = "Kidney disease"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "dmd" {
graph combine ///
GPH/STD_GPH_`ii'_dm.gph ///
GPH/STD_GPH_`ii'_dm_0.gph ///
GPH/STD_GPH_`ii'_dm_1.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(2)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove optargs(width=0.6\textwidth) ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `oo'.)
}
else {
graph combine ///
GPH/STD_GPH_`ii'_dm.gph ///
GPH/STD_GPH_`ii'_nondm.gph ///
GPH/STD_GPH_`ii'_dm_0.gph ///
GPH/STD_GPH_`ii'_nondm_0.gph ///
GPH/STD_GPH_`ii'_dm_1.gph ///
GPH/STD_GPH_`ii'_nondm_1.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(4)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `oo'.)
}
}
texdoc stlog close


/***
\color{black}

\clearpage
\section{Cause-specific mortality rate ratios}

To estimate the mortality rate ratios (MRRs) by calendar time, I will fit a model with spline effects of 
age, a binary effect of sex, and an interaction between spline effects of calendar time and diabetes status. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
use `i', clear
expand 2
bysort cal age_dm sex : gen dm = _n-1
foreach ii in cvd_d can_d dmd_d inf_d flu_d res_d liv_d ckd_d azd_d pys age {
gen `ii' = `ii'_dm if dm == 1
replace `ii' = `ii'_nondm if dm == 0
drop `ii'_dm `ii'_nondm
}
drop if age==.
save `i'_long, replace
}
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd inf flu ckd liv {
use `i'_long, clear
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
local minn = r(min)
if `rang' < 10 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
}
restore
}
else if inrange(`rang',10,14.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
local A2`a' = timesp2[`a']
}
restore
}
else {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
preserve
clear
local rang1 = `rang'+1
set obs `rang1'
gen calendar = _n-1+`minn'
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
forval a = 1/`rang1' {
local A1`a' = timesp1[`a']
local A2`a' = timesp2[`a']
local A3`a' = timesp3[`a']
}
restore
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
preserve
poisson `ii'_d agesp* sex c.timesp*##i.dm, exposure(pys)
matrix A = (.,.,.)
if `rang' < 10 {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',10,14.9) {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' timesp3==`A3`a'') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
local rang2 = `rang1'+1
mat A = A[2..`rang2',1..3]
keep country cal
bysort cal : keep if _n == 1
svmat A
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
gen OC = "`ii'"
replace cal = cal+2009.5
save MD/SMR_`i'_`ii', replace
restore
forval iii = 0/1 {
preserve
su agesp1
local B1 = r(mean)
su agesp2
local B2 = r(mean)
su agesp3
local B3 = r(mean)
keep if sex == `iii'
poisson `ii'_d agesp* c.timesp*##i.dm, exposure(pys)
matrix A = (.,.,.)
if `rang' < 10 {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',10,14.9) {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/`rang1' {
margins, dydx(dm) at(timesp1==`A1`a'' timesp2==`A2`a'' timesp3==`A3`a'' agesp1==`B1' agesp2==`B2' agesp3==`B3') predict(xb) atmeans
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
local rang2 = `rang1'+1
mat A = A[2..`rang2',1..3]
keep country cal
bysort cal : keep if _n == 1
svmat A
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
gen OC = "`ii'"
replace cal = cal+2009.5
save MD/SMR_`i'_`ii'_`iii', replace
restore
}
}
}
}
clear
set obs 1
gen country = "Australia"
save MD/SMR_Australia_ckd, replace
save MD/SMR_Australia_ckd_0, replace
save MD/SMR_Australia_ckd_1, replace
clear
set obs 1
gen country = "Finland"
save MD/SMR_Finland_flu, replace
save MD/SMR_Finland_flu_0, replace
save MD/SMR_Finland_flu_1, replace
clear
set obs 1
gen country = "Scotland"
save MD/SMR_Scotland_ckd, replace
save MD/SMR_Scotland_ckd_0, replace
save MD/SMR_Scotland_ckd_1, replace
clear
set obs 1
gen country = "Lithuania"
save MD/SMR_Lithuania_ckd_1, replace
clear
set obs 1
gen country = "SKorea"
save MD/SMR_SKorea_azd_1, replace
foreach ii in can cvd res azd inf flu ckd liv {
if "`ii'" == "can" {
local oo = "Cancer"
local ylab = "1 1.5 2"
local yform = "%9.1f"
local yrange = "1 2"
}
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
local ylab = "1 1.5 2 2.5 3"
local yform = "%9.1f"
local yrange = "1 3"
}
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
local ylab = "0.5 1 1.5 2 2.5"
local yform = "%9.1f"
local yrange = "0.5 2.5"
}
if "`ii'" == "azd" {
local oo = "Dementia"
local ylab = "0.5 1 1.5"
local yform = "%9.1f"
local yrange = "0.3 1.5"
}
if "`ii'" == "inf" {
local oo = "Infectious diseases"
local ylab = "0.5 1 2 3 4 5"
local yform = "%9.1f"
local yrange = "0.5 5.5"
}
if "`ii'" == "flu" {
local oo = "Influenza and pneumonia"
local ylab = "0.5 1 2 3"
local yform = "%9.1f"
local yrange = "0.4 3.1"
}
if "`ii'" == "ckd" {
local oo = "Kidney disease"
local ylab = "0.5 1 2 5 10"
local yform = "%9.0f"
local yrange = "0.5 11"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
local ylab = "1 2 5 10"
local yform = "%9.0f"
local yrange = "1 10"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMR_`i'_`ii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/9 {
local C`i' = country[`i']
}
restore
colorpalette hue, n(9) luminance(50) nograph
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`r(p1)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`r(p1)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`r(p2)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`r(p2)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`r(p3)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`r(p3)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`r(p4)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`r(p4)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`r(p5)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`r(p5)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`r(p6)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`r(p6)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`r(p7)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`r(p7)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`r(p8)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`r(p8)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C9'", color("`r(p9)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C9'", color("`r(p9)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C10'", color("`r(p10)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C10'", color("`r(p10)'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'" ///
20 "`C10'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', grid format(`yform') angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(`yrange')) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
graph save GPH/SMR_`ii', replace
forval iii = 0/1 {
if `iii' == 0 {
local s = "females"
}
if `iii' == 1 {
local s = "males"
}
clear
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
append using MD/SMR_`i'_`ii'_`iii'
}
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/9 {
local C`i' = country[`i']
}
restore
colorpalette hue, n(9) luminance(50) nograph
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`r(p1)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`r(p1)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`r(p2)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`r(p2)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`r(p3)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`r(p3)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`r(p4)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`r(p4)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`r(p5)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`r(p5)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`r(p6)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`r(p6)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`r(p7)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`r(p7)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`r(p8)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`r(p8)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C9'", color("`r(p9)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C9'", color("`r(p9)'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C10'", color("`r(p10)'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C10'", color("`r(p10)'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'" ///
18 "`C9'" ///
20 "`C10'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(`yrange')) ///
ytitle("Mortality rate ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', `s'", placement(west) color(black) size(medium))
graph save GPH/SMR_`ii'_`iii', replace
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in can cvd res azd inf flu ckd liv {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "can" {
local oo = "Cancer"
}
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "azd" {
local oo = "Dementia"
}
if "`ii'" == "dmd" {
local oo = "Diabetes"
}
if "`ii'" == "inf" {
local oo = "Infectious diseases"
}
if "`ii'" == "flu" {
local oo = "Influenza and pneumonia"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "ckd" {
local oo = "Kidney disease"
}
graph combine ///
GPH/SMR_`ii'.gph ///
GPH/SMR_`ii'_0.gph ///
GPH/SMR_`ii'_1.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(2.5)
texdoc graph, label(STDMRF_`ii') figure(h!) cabove ///
caption(Mortality rate ratio by cause of death and sex. `oo'.)
}
texdoc stlog close

/***
\color{black}

\clearpage
\section{Average annual changes}

Finally, we will estimate the average annual change (measured via APC) 
in both mortality rates
and MRRs. For mortality rates, the APC comes from a model
with a linear effect of calendar time (the APC is derived
from the coefficient associated with this term in the model)
, spline effects of age, 
a binary effect of sex, and the interaction between spline effects
of age and binary effect of sex. 
For MRRs, the APC comes from a model with spline effects of 
age, a binary effect of sex, a linear effect of calendar time, 
a binary effect of diabetes status, and the interaction between
calendar time and diabetes status (the APC is derived
from the coefficient associated with this term in the model). 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
use `i', clear
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d_`iii' cal c.agesp*##sex, exposure(pys_`iii')
matrix A_`i'_`ii'_`iii' = (r(table)[1,1], r(table)[5,1], r(table)[6,1], r(table)[4,1])
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2009.5
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d_`iii' cal c.agesp*, exposure(pys_`iii')
matrix A_`i'_`ii'_`iii'_`iiii' = (r(table)[1,1], r(table)[5,1], r(table)[6,1], r(table)[4,1])
}
}
}
}
}
}
matrix A = (.,.,.,.,.,.,.,.)
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in can cvd res azd dmd inf flu ckd liv {
local a2 = `a2'+1
local a3 = 0
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
local a3 = `a3'+1
matrix A = (A\0`a1',`a2',`a3',2,A_`i'_`ii'_`iii')
foreach iiii in 0 1 {
matrix A = (A\0`a1',`a2',`a3',`iiii',A_`i'_`ii'_`iii'_`iiii')
}
}
}
}
}
clear
svmat A
sort A1 A2 A3 A4
drop if A1==.
tostring A2-A3, replace format(%9.0f) force
gen country=""
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in can cvd res azd dmd inf flu ckd liv {
local a2 = `a2'+1
replace A2 = "`ii'" if A2 == "`a2'"
local a3 = 0
foreach iii in dm nondm {
local a3 = `a3'+1
replace A3 = "`iii'" if A3 == "`a3'"
}
}
}
replace A2 = "dmd" if A2 == "13"
replace A5 = 100*(exp(A5)-1)
replace A6 = 100*(exp(A6)-1)
replace A7 = 100*(exp(A7)-1)
forval i = 5/8 {
replace A`i' = . if country == "Australia" & A2 == "ckd"
replace A`i' = . if country == "Finland" & A2 == "flu"
replace A`i' = . if country == "Scotland" & A2 == "ckd"
replace A`i' = . if country == "Lithuania" & A2 == "ckd" & A3 == "dm" & A4 == 1
replace A`i' = . if country == "SKorea" & A2 == "ckd" & A3 == "dm" & A4 == 1
}
save APCs, replace
quietly {
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
foreach ii in can cvd res azd inf flu ckd liv {
use `i'_long, clear
replace calendar = calendar-2009.5
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d agesp* sex c.cal*##i.dm, exposure(pys)
matrix A_`i'_`ii' = (r(table)[1,9], r(table)[5,9], r(table)[6,9], r(table)[4,9])
foreach iii in 0 1 {
use `i'_long, clear
keep if sex == `iii'
replace calendar = calendar-2009.5
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
poisson `ii'_d agesp* sex c.cal*##i.dm, exposure(pys)
matrix A_`i'_`ii'_`iii' = (r(table)[1,9], r(table)[5,9], r(table)[6,9], r(table)[4,9])
}
}
}
}
matrix A = (.,.,.,.,.,.,.)
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in can cvd res azd inf flu ckd liv {
local a2 = `a2'+1
matrix A = (A\0`a1',`a2',2,A_`i'_`ii')
foreach iii in 0 1 {
matrix A = (A\0`a1',`a2',`iii',A_`i'_`ii'_`iii')
}
}
}
clear
svmat A
sort A1 A2 A3
drop if A1==.
tostring A2, replace format(%9.0f) force
gen country=""
local a1 = 0
foreach i in Australia Canada1 Canada2 Denmark Finland France Lithuania Scotland SKorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in can cvd res azd inf flu ckd liv {
local a2 = `a2'+1
replace A2 = "`ii'" if A2 == "`a2'"
}
}
replace A4 = 100*(exp(A4)-1)
replace A5 = 100*(exp(A5)-1)
replace A6 = 100*(exp(A6)-1)
forval i = 4/7 {
replace A`i' = . if country == "Australia" & A2 == "ckd"
replace A`i' = . if country == "Finland" & A2 == "flu"
replace A`i' = . if country == "Scotland" & A2 == "ckd"
replace A`i' = . if country == "Lithuania" & A2 == "ckd" & A3 == 1
replace A`i' = . if country == "SKorea" & A2 == "ckd" & A3 == 1
}
save SMR_APCs, replace
foreach i in can cvd res azd dmd inf flu ckd liv {
if "`i'" == "cvd" {
local ii = "cardiovascular disease"
local xlab = "-8(2)0"
local xlabs = "-4(1)1"
local legp = 11
}
if "`i'" == "can" {
local ii = "cancer"
local xlab = "-6(2)4"
local xlabs = "-2(1)3"
local legp = 1
}
if "`i'" == "res" {
local ii = "chronic lower respiratory disease"
local xlab = "-15(5)10"
local xlabs = "-10(5)10"
local legp = 11
}
if "`i'" == "azd" {
local ii = "dementia"
local xlab = "-5(5)30"
local xlabs = "-10(5)20"
local legp = 1
}
if "`i'" == "dmd" {
local ii = "diabetes"
local xlab = "-20(10)20"
local legp = 11
}
if "`i'" == "inf" {
local ii = "infectious diseases"
local xlab = "-15(5)10"
local xlabs = "-10(5)10"
local legp = 11
}
if "`i'" == "flu" {
local ii = "influenza and pneumonia"
local xlab = "-10(5)15"
local xlabs = "-10(5)10"
local legp = 1
}
if "`i'" == "liv" {
local ii = "liver disease"
local xlab = "-10(5)5"
local xlabs = "-10(5)5"
local legp = 11
}
if "`i'" == "ckd" {
local ii = "kidney disease"
local xlab = "-10(5)10"
local xlabs = "-10(5)5"
local legp = 1
}
use APCs, clear
gen AA = -A1+0.15 if A3 == "dm"
replace AA = -A1-0.15 if A3 == "nondm"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
twoway ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "dm" & A4 == 2, horizontal col(blue)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "dm" & A4 == 2, col(blue)) ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "nondm" & A4 == 2, horizontal col(green)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "nondm" & A4 == 2, col(green)) ///
, graphregion(color(white)) legend(order( ///
2 "Diabetes" 4 "No diabetes") cols(1) ///
ring(0) region(lcolor(none) color(none)) position(`legp')) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlab', format(%9.0f)) ///
title("Mortality rate, `ii'", placement(west) col(black) size(medium))
graph save GPH/APCo_`i', replace
use APCs, clear
gen AA = -A1-0.1 if A4 == 0
replace AA = -A1-0.25 if A4 == 1
replace AA = AA + 0.35 if A3=="nondm"
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
twoway ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "nondm" & A4 == 0, horizontal col(red)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "nondm" & A4 == 0, col(red) msize(small) msymbol(S)) ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "nondm" & A4 == 1, horizontal col(blue)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "nondm" & A4 == 1, col(blue) msize(small) msymbol(S)) ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "dm" & A4 == 0, horizontal col(red)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "dm" & A4 == 0, col(red) msize(small)) ///
(rcap A7 A6 AA if A2 == "`i'" & A3 == "dm" & A4 == 1, horizontal col(blue)) ///
(scatter AA A5 if A2 == "`i'" & A3 == "dm" & A4 == 1, col(blue) msize(small)) ///
, graphregion(color(white)) legend(order( ///
2 "Females without diabetes" 4 "Males without diabetes" ///
6 "Females with diabetes" 8 "Males with diabetes" ///
) cols(1) ///
ring(0) region(lcolor(none) color(none)) position(`legp')) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlab', format(%9.0f)) ///
title("Mortality rate, `ii'", placement(west) col(black) size(medium))
graph save GPH/APCs_`i', replace
if "`i'" != "dmd" {
use SMR_APCs, clear
gen AA = -A1
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
twoway ///
(rcap A6 A5 AA if A2 == "`i'" & A3 == 2, horizontal col(black)) ///
(scatter AA A4 if A2 == "`i'" & A3 == 2, col(black)) ///
, graphregion(color(white)) legend(off) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlabs', format(%9.0f)) ///
title("MRR, `ii'", placement(west) col(black) size(medium))
graph save GPH/SAPCo_`i', replace
use SMR_APCs, clear
gen AA = -A1+0.15 if A3 == 0
replace AA = -A1-0.15 if A3 == 1
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/9 {
local C`c' = country[`c']
}
restore
twoway ///
(rcap A6 A5 AA if A2 == "`i'" & A3 == 0, horizontal col(red)) ///
(scatter AA A4 if A2 == "`i'" & A3 == 0, col(red)) ///
(rcap A6 A5 AA if A2 == "`i'" & A3 == 1, horizontal col(blue)) ///
(scatter AA A4 if A2 == "`i'" & A3 == 1, col(blue)) ///
, graphregion(color(white)) legend(order( ///
2 "Females" 4 "Males") cols(1) ///
ring(0) region(lcolor(none) color(none)) position(`legp')) ///
ylabel( ///
-1 "`C1'" ///
-2 "`C2'" ///
-3 "`C3'" ///
-4 "`C4'" ///
-5 "`C5'" ///
-6 "`C6'" ///
-7 "`C7'" ///
-8 "`C8'" ///
-9 "`C9'" ///
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlabs', format(%9.0f)) ///
title("MRR, `ii'", placement(west) col(black) size(medium))
graph save GPH/SAPCs_`i', replace
}
}
foreach i in can cvd res azd dmd inf flu ckd liv {
use SMR_APCs, clear
keep if A2 == "`i'"
tostring A4-A6, force replace format(%9.2f)
gen AA = A4 + " (" + A5 + ", " + A6 + ")"
replace AA = "" if AA == ". (., .)"
keep A3 country AA
rename A3 A4
save MD/SMR_APC_`i', replace
use APCs, clear
keep if A2 == "`i'"
tostring A5-A7, force replace format(%9.2f)
gen A = A5 + " (" + A6 + ", " + A7 + ")"
replace A = "" if A == ". (., .)"
keep A3 A4 A country
reshape wide A, i(country A4) j(A3) string
merge 1:1 country A4 using MD/SMR_APC_`i'
drop _merge
bysort country (A4) : replace country = "" if _n!=1
tostring A4, replace force
replace A4 = "Females" if A4 == "0"
replace A4 = "Males" if A4 == "1"
replace A4 = "Overall" if A4 == "2"
order country A4
replace country = "Canada (Alberta)" if country == "Canada1"
replace country = "Canada (Ontario)" if country == "Canada2"
replace country = "South Korea" if country == "SKorea"
if "`i'" == "dmd" {
drop AA
}
export delimited using CSV/APCt_`i'.csv, delimiter(":") novarnames replace
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in can cvd res azd dmd inf flu ckd liv {
if "`ii'" == "can" {
local oo = "Cancer"
}
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "azd" {
local oo = "Dementia"
}
if "`ii'" == "dmd" {
local oo = "Diabetes"
}
if "`ii'" == "inf" {
local oo = "Infectious diseases"
}
if "`ii'" == "flu" {
local oo = "Influenza and pneumonia"
}
if "`ii'" == "ckd" {
local oo = "Kidney disease"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "dmd" {
local ii = "dmd"
graph combine ///
GPH/APCo_`ii'.gph ///
GPH/APCs_`ii'.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(3)
texdoc graph, label(APC_`ii') figure(h!) cabove ///
caption(Average annual change in mortality rate by country. Overall (top) and by sex (bottom). `oo'.)
}
else {
graph combine ///
GPH/APCo_`ii'.gph ///
GPH/SAPCo_`ii'.gph ///
GPH/APCs_`ii'.gph ///
GPH/SAPCs_`ii'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(6)
texdoc graph, label(APC_`ii') figure(h!) cabove ///
caption(Average annual change in mortality rate and mortality rate ratio (MRR) by country. ///
Overall (top) and by sex (bottom). `oo'.)
}
}
texdoc stlog close

/***
\color{black}

\clearpage

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Cancer.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_can.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Cardiovascular disease.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_cvd.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Chronic lower respiratory disease.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_res.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Dementia.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_azd.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Diabetes.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_dmd.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Infectious diseases.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_inf.csv}
  \end{center}
\end{table}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Influenza and pneumonia.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_flu.csv}
  \end{center}
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Kidney disease.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_ckd.csv}
  \end{center}
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in mortality rates and mortality rate ratios, 
by country and sex. Liver disease.}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/1/.style={column name=Sex, column type={l}, text indicator="},
      display columns/2/.style={column name=\specialcell{Mortality rate \\ in people with diabetes}, column type={r}},
      display columns/3/.style={column name=\specialcell{Mortality rate \\ in people without diabetes}, column type={r}},
      display columns/4/.style={column name=\specialcell{Mortality rate ratio \\ for people with vs. without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CSV/APCt_liv.csv}
  \end{center}
\end{table}

***/




/***
\color{black}
\clearpage
\section*{References}
\addcontentsline{toc}{section}{References}
\bibliography{/home/jimb0w/Documents/CM/Library/Library.bib}
\end{document}
***/


texdoc close

! pdflatex CM
! pdflatex CM
! bibtex CM
! pdflatex CM
! bibtex CM
! pdflatex CM

erase CM.aux
erase CM.log
erase CM.out
erase CM.toc
erase CM.bbl
erase CM.blg


! git init .
! git add CM.do CM.pdf
! git commit -m "0"
! git remote remove origin
! git remote add origin https://github.com/jimb0w/CM.git
! git remote set-url origin git@github.com:jimb0w/CM.git
! git push --set-upstream origin master

