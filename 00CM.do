
texdoc init CM, replace logdir(CM_log) gropts(optargs(width=0.8\textwidth))
set linesize 100

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
Jedidiah Morton \\
\color{blue}
\href{mailto:Jedidiah.Morton@Monash.edu}{Jedidiah.Morton@monash.edu} \\ 
\color{black}
Research Fellow \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
Monash University, Melbourne, Australia \\\
\\
\noindent
Lei Chen \\
Research Officer \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
\\
\noindent
Bendix Carstensen \\
Senior Statistician \\
Steno Diabetes Center Copenhagen, Herlev, Denmark \\
Department of Biostatistics, University of Copenhagen \\
\\
\noindent
Dianna Magliano \\
Professor and Head of Diabetes and Population Health \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\

\end{titlepage}

\clearpage
\tableofcontents

\clearpage
\section{Data cleaning}

This is the protocol for an analysis of trends in cause of death in people with and without 
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

\subsection{Australia}

For Australia, we have the following variables (by age, sex, and calendar year): 
total population size, person-years in people with diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset--JM). From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

However, Australian data restrictions prohibit the use of any cell count $<$6 for the diabetes population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 0 to 5 with equal probability, unless the number of deaths in the
total population for the age/sex group is <5, in which case the upper bound will be the 
number of deaths in the total population. 
Further, because of this, data has been provided in both 10 and 20-year age groups, as well as
overall (i.e., the actual counts). My intuition is that the small cell counts
won't drive any overall results anyway, which I check below (Figure~\ref{chk1}), 
and that the uncertainty associated with such low numbers will be reflected in very wide
confidence intervals for age-specific analyses (which aren't actually done here).

\color{Blue4}
***/

texdoc stlog, cmdlog
cd /Users/jed/Documents/CM/
set seed 3488717
*mkdir GPH
texdoc stlog close
texdoc stlog, cmdlog nodo
import delimited "Consortium COD database v4.csv", clear
foreach i in chd cbd hfd liv2 {
drop `i'_d_dm `i'_d_pop `i'_d_nondm
}
rename (liv1_d_dm liv1_d_pop liv1_d_nondm) (liv_d_dm liv_d_pop liv_d_nondm)
save uncleandbase, replace
texdoc stlog close
texdoc stlog, cmdlog
use uncleandbase, clear
keep if substr(country,1,9)=="Australia"
drop if cal < 2005
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
di "`i'"
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,5)
quietly replace `i'_d_dm = runiformint(0,max_`i') if `i'_d_dm ==.
}
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
gen diff = dmd_d_dm-dmd_d_pop
ta diff if diff >0
replace dmd_d_dm = dmd_d_pop if dmd_d_dm > dmd_d_pop
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
gen alldeathc_nondm = cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm
count if alldeathc_nondm > alldeath_d_nondm
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

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
preserve
gen agegp = 1 if age_gp1!=""
replace agegp = 2 if age_gp3!=""
replace agegp = 3 if age_gp4!=""
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar agegp)
foreach i in azd can cvd res dmd inf flu ckd liv {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "can" {
local ii = "Cancer"
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
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "liv" {
local ii = "Liver disease"
}
if "`i'" == "ckd" {
local ii = "Renal disease"
}
if "`i'" == "azd" {
local ii = "Alzheimer's disease"
}
gen dm_`i' = 1000*`i'_d_dm/pys_dm
twoway ///
(connected dm_`i' cal if agegp == 1, col(black)) ///
(connected dm_`i' cal if agegp == 2, col(blue)) ///
(connected dm_`i' cal if agegp == 3, col(red)) ///
, graphregion(color(white)) ///
ytitle(Mortality rate (per 1,000 person-years)) ///
xtitle(Calendar year) ///
legend(order( ///
1 "10-year age-groups" ///
2 "20-year age-groups" ///
3 "Overall" ///
) cols(3) position(12) region(lcolor(none) color(none))) ///
ylabel(,angle(0) format(%9.2f)) ///
title("`ii'", placement(west) size(medium) col(black))
graph save GPH/dm_`i'_chk1, replace
}
restore
texdoc stlog close
texdoc stlog, cmdlog 
graph combine ///
GPH/dm_cvd_chk1.gph ///
GPH/dm_can_chk1.gph ///
GPH/dm_dmd_chk1.gph ///
GPH/dm_inf_chk1.gph ///
GPH/dm_flu_chk1.gph ///
GPH/dm_res_chk1.gph ///
GPH/dm_liv_chk1.gph ///
GPH/dm_ckd_chk1.gph ///
GPH/dm_azd_chk1.gph ///
, graphregion(color(white)) cols(3) altshrink
texdoc graph, label(chk1) figure(h!) ///
caption(Crude mortality rate by age-grouping method, by cause of death. Australia. People with diabetes.)
texdoc stlog close

/***
\color{black}

So, from Figure~\ref{chk1} we see that there doesn't appear to be any systematic
issue introduced using random numbers. I will proceed using the most granular age groupings. 
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
\subsection{Canada}

For Canada (really it's just Alberta, but it's easier to call it Canada here), 
we have the following variables (by age, sex, and calendar year): 
total population size, prevalence of diabetes, incidence of diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset--JM). We can calculate person-years in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes to half the number of people with 
incident diabetes and subtracting half the number of all-cause deaths (again, performed before I got the dataset--JM). 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

However, Canadian data restrictions prohibit the use of any cell count between 1 and 9
for people with diabetes and in the total population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 1 to 9 with equal probability, unless the number of deaths in the
total population for the age/sex group is $<$9 (after being randomly generated), 
in which case the upper bound will be the 
number of deaths in the total population.

\color{Blue4}
***/

texdoc stlog, cmdlog
use uncleandbase, clear
keep if substr(country,1,6)=="Canada"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
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
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
texdoc stlog close
/***
\color{black}

Because there are some age groups where the randomly allocated deaths exceed total deaths, 
I will re-randomise until this is fixed. 

\color{Blue4}
***/

texdoc stlog
forval ii = 1/10 {
gen A = 1 if alldeathc_dm > alldeath_d_dm
foreach i in azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_dm = runiformint(1,max_`i') if A==1 & inrange(`i'_d_dm,1,9)
}
drop alldeathc_dm A
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
}
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
gen alldeathc_nondm = cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm
count if alldeathc_nondm > alldeath_d_nondm
texdoc stlog close
texdoc stlog, cmdlog nodo
keep if age_gp1!=""
replace country = "Canada"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Canada, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Denmark}

For Denmark, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Nevertheless, Denmark restricts counts between 1 and 3 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 1 to 3 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
use uncleandbase, clear
keep if substr(country,1,7)=="Denmark"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in azd can cvd res dmd inf flu ckd liv {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(1,3) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(1,3) if `i'_d_dm ==.
}
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
gen A = 1 if alldeathc_dm > alldeath_d_dm
foreach i in azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_dm = runiformint(1,3) if A==1 & inrange(`i'_d_dm,1,3)
}
drop alldeathc_dm A
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
gen alldeathc_nondm = cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm
count if alldeathc_nondm > alldeath_d_nondm
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

There's a considerable amount of missing data here,
although again, it's always for small cell counts, so shouldn't
have a major impact.

\clearpage
\subsection{Finland}

For Finland, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Nevertheless, Finland restricts counts between 1 and 5 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 1 to 5 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
use uncleandbase, clear
keep if substr(country,1,7)=="Finland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(1,5) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(1,5) if `i'_d_dm ==.
}
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
gen alldeathc_nondm = cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm
count if alldeathc_nondm > alldeath_d_nondm
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
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

France provided data for 2013-2017 and 2020, but because we are analysing trends, 
we will exclude the data from 2020. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
use uncleandbase, clear
keep if substr(country,1,8)=="France_1"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace country = substr(country,1,6)
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
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
plus the population size in the next year, divided by two (this has been performed before
I got the dataset--JM). We can calculate person-years in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes to half the number of people with 
incident diabetes and subtracting half the number of all-cause deaths (again, performed before I got the dataset). 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
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
keep country calendar sex alldeath_d_dm alldeath_d_nondm age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Lithuania, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Netherlands}

For Netherland, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Nevertheless, Netherlands restricts counts between 0 and 9 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 0 to 9 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ is 95.

\color{Blue4}
***/

texdoc stlog, cmdlog
use uncleandbase, clear
keep if country == "Netherlands"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(0,9) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(0,9) if `i'_d_dm ==.
}
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
forval ii = 1/1000 {
gen A = 1 if alldeathc_dm > alldeath_d_dm
foreach i in azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_dm = runiformint(0,9) if A==1 & inrange(`i'_d_dm,0,9)
}
drop alldeathc_dm A
gen alldeathc_dm = cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm
count if alldeathc_dm > alldeath_d_dm
}
gen alldeathc_nondm = cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm
count if alldeathc_nondm > alldeath_d_nondm
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
save Netherlands, replace
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
plus the population size in the next year, divided by two (this has been performed before
I got the dataset). I then calculate person-years in people without diabetes by substracting
the person-years in people with diabetes from person-years in the total population; similarly
for deaths in people without diabetes. There were a few age groups in whom the number of deaths
from diabetes in people with diabetes was slightly greater than the total population deaths; 
I will simply make these zero in people without diabetes. 

Also note we have received two different age
groupings for Scotland for total population deaths -- from 2006-2015: 0-39, 40-49, \ldots , 80+; from 2016-2020:
0-39, 40-49, \ldots, 90+. For the 80+ age grouping I will assume the mean age is 87.5 years. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
use uncleandbase, clear
keep if country == "Scotland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
rename (alldeath_dm alldeath_nondm alldeath_totpop) (alldeath_d_dm alldeath_d_nondm alldeath_d_pop)
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
di "`i'"
ta `i'_d_nondm if `i'_d_nondm <0
}
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
foreach i in alldeath azd can cvd res dmd inf flu ckd liv {
replace `i'_d_dm = . if age_dm==.
replace `i'_d_nondm = . if age_nondm==.
}
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

texdoc stlog, cmdlog
use uncleandbase, clear
keep if substr(country,1,7)=="S.Korea"
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
clear
foreach c in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
append using `c'
}
bysort country (cal) : egen lb = min(cal)
bysort country (cal) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
recode dmd_d_nondm .=0
gen other_d_dm = alldeath_d_dm - ///
(cvd_d_dm + can_d_dm + dmd_d_dm + inf_d_dm + flu_d_dm + res_d_dm + liv_d_dm + ckd_d_dm + azd_d_dm)
gen other_d_nondm = alldeath_d_nondm - ///
(cvd_d_nondm + can_d_nondm + dmd_d_nondm + inf_d_nondm + flu_d_nondm + res_d_nondm + liv_d_nondm + ckd_d_nondm + azd_d_nondm)
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm other_d_dm other_d_nondm, by(country sex rang)
expand 2
bysort country sex : gen DM = _n-1
tostring sex pys_dm-DM, replace force format(%15.0fc)
gen pys = pys_dm if DM == "1"
replace pys = pys_nondm if DM == "0"
foreach i in azd can cvd res dmd inf flu ckd liv other {
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
replace country = "Canada (Alberta)" if country == "Canada"
export delimited using T1.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{landscape}

\begin{table}[h!]
  \begin{center}
    \caption{Summary of data included in the analysis.}
	\hspace*{-2.5cm}
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
      display columns/5/.style={column name=CVD, column type={r}},
      display columns/6/.style={column name=CAN, column type={r}},
      display columns/7/.style={column name=DMD, column type={r}},
      display columns/8/.style={column name=INF, column type={r}},
      display columns/9/.style={column name=FLU, column type={r}},
      display columns/10/.style={column name=RES, column type={r}},
      display columns/11/.style={column name=LIV, column type={r}},
      display columns/12/.style={column name=CKD, column type={r}},
      display columns/13/.style={column name=AZD, column type={r}},
      display columns/14/.style={column name=OTH, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & & & \multicolumn{10}{c}{Death counts by cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={4}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{T1.csv}
  \end{center}
Abbreviations: CVD -- Cardiovascular disease; CAN -- Cancer; DMD -- Diabetes; INF -- Infectious diseases; FLU --
Influenza and pneumonia; RES -- Chronic lower respiratory disease; LIV -- Liver disease; 
CKD -- Renal disease; AZD -- Alzheimer's disease; OTH -- All other causes.
\end{table}
\end{landscape}


\clearpage
\section{Crude rates}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach c in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
use `c', clear
if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar sex)
foreach i in azd can cvd res dmd inf flu ckd liv {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "can" {
local ii = "Cancer"
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
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "liv" {
local ii = "Liver disease"
}
if "`i'" == "ckd" {
local ii = "Renal disease"
}
if "`i'" == "azd" {
local ii = "Alzheimer's disease"
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
foreach c in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
use `c', clear
if "`c'" == "SKorea" {
local co = "South Korea"
}
else {
local co = "`c'"
}
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar sex)
foreach i in azd can cvd res dmd inf flu ckd liv {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "can" {
local ii = "Cancer"
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
if "`i'" == "res" {
local ii = "Chronic lower respiratory disease"
}
if "`i'" == "liv" {
local ii = "Liver disease"
}
if "`i'" == "ckd" {
local ii = "Renal disease"
}
if "`i'" == "azd" {
local ii = "Alzheimer's disease"
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
texdoc graph, label(cr_`i'_`c') figure(h!) ///
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
A few suspected coding changes to note:
\begin{itemize}
\item Figure~\ref{cr_ckd_Australia}, Australia, renal disease in 2013. 
\item Figure~\ref{cr_cvd_Finland}, Finland, cardiovascular disease.
\item Figure~\ref{cr_flu_Finland}, Finland, influenza and pneumonia from 2000-2005.
\item Figure~\ref{cr_ckd_Scotland}, Scotland, renal disease in 2017.
\end{itemize}

\clearpage
\section{Cause-specific mortality rates}

\subsection{Methods}

The methods are largely derived from Magliano et al. \cite{MaglianoLDE2022}.
To generate age- and period-specific rates, which will be used to generate age-standardised rates, 
we will model mortality rates using age-period-cohort models \cite{CarstensenSTATMED2007}.
Each model will be a Poisson model, parameterised using 
spline effects of age, period, and cohort (period-age), with log 
of person-years as the offset. 
Age is defined as above (i.e., the midpoint of the interval in most cases) and models are
fit separately for each cause of death and country in people with and without diabetes and by sex. 
Because this will be \begin{math} 9 \times 7 \times 2 \times 2 = 252 \end{math} models, 
we won't check model fit for each model. Instead, 
to check model fit we will select ten at random and check the modelled and crude rates as well as 
the Pearson residuals. 

These models will be used to estimate mortality rates for single year ages and calendar years.
These modelled rates will first be plotted by age and period, then used to generate
age-standardised rates in people with and without diabetes, using direct standardisation
(using the total diabetes population formed by pooling the consortium data) by period. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*mkdir MD
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
set seed 1234
clear
gen A =.
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in cvd can inf flu res liv ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
local B = runiform()
append using MD/RC_pred_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A < 0.03
}
}
}
}
save RCc, replace
set seed 1234
clear
gen A =.
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in cvd can inf flu res liv ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
local B = runiform()
append using MD/R_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A < 0.03
}
}
}
}
save Rc, replace
texdoc stlog close
texdoc stlog
use RCc, clear
bysort A : keep if _n == 1
list country OC DM sex
texdoc stlog close




*PICKUP NEEDS TO BE FIXED WHEN FINALISED







texdoc stlog, cmdlog nodo
forval i = 1/10 {
if `i' == 1 {
local c = "France"
local o = "liv2"
local oo = "liver disease (excluding alcoholic liver disease)"
local s = 1
local ss = "males"
local d = "dm"
local dd = "with"
}
if `i' == 2 {
local c = "France"
local o = "ckd"
local oo = "renal disease"
local s = 0
local ss = "females"
local d = "nondm"
local dd = "without"
}
if `i' == 3 {
local c = "Scotland"
local o = "liv1"
local oo = "liver disease"
local s = 1
local ss = "males"
local d = "dm"
local dd = "with"
}
if `i' == 4 {
local c = "Canada"
local o = "res"
local oo = "chronic lower respiratory disease"
local s = 0
local ss = "females"
local d = "dm"
local dd = "with"
}
if `i' == 5 {
local c = "Canada"
local o = "res"
local oo = "chronic lower respiratory disease"
local s = 0
local ss = "females"
local d = "nondm"
local dd = "without"
}
if `i' == 6 {
local c = "Sweden"
local o = "can"
local oo = "cancer"
local s = 1
local ss = "males"
local d = "nondm"
local dd = "without"
}
if `i' == 7 {
local c = "Australia"
local o = "res"
local oo = "chronic lower respiratory disease"
local s = 1
local ss = "males"
local d = "nondm"
local dd = "without"
}
if `i' == 8 {
local c = "Canada"
local o = "chd"
local oo = "ischaemic heart disease"
local s = 0
local ss = "females"
local d = "dm"
local dd = "with"
}
if `i' == 9 {
local c = "Australia"
local o = "flu"
local oo = "influenza and pneumonia"
local s = 1
local ss = "males"
local d = "nondm"
local dd = "without"
}
if `i' == 10 {
local c = "Sweden"
local o = "cvd"
local oo = "cardiovascular disease"
local s = 0
local ss = "females"
local d = "dm"
local dd = "with"
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
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
xlabel(30(10)100) ytitle("Mortality rate (per 1000 person-years)") ///
xtitle(Age) yscale(log) legend(order( ///
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
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
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
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Age (years)") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_age, replace
twoway ///
(scatter res cale, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Period") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_period, replace
twoway ///
(scatter res coh, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Cohort") ///
title("`c', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/RCc_`c'_`o'_`d'_`s'_cohort, replace
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
GPH/Rc_France_liv2_dm_1_age.gph ///
GPH/Rc_France_ckd_nondm_0_age.gph ///
GPH/Rc_Scotland_liv1_dm_1_age.gph ///
GPH/Rc_Canada_res_dm_0_age.gph ///
GPH/Rc_Canada_res_nondm_0_age.gph ///
GPH/Rc_Sweden_can_nondm_1_age.gph ///
GPH/Rc_Australia_res_nondm_1_age.gph ///
GPH/Rc_Canada_chd_dm_0_age.gph ///
GPH/Rc_Australia_flu_nondm_1_age.gph ///
GPH/Rc_Sweden_cvd_dm_0_age.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC1) figure(h!) ///
caption(Modelled and crude mortality rates by age for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/Rc_France_liv2_dm_1_period.gph ///
GPH/Rc_France_ckd_nondm_0_period.gph ///
GPH/Rc_Scotland_liv1_dm_1_period.gph ///
GPH/Rc_Canada_res_dm_0_period.gph ///
GPH/Rc_Canada_res_nondm_0_period.gph ///
GPH/Rc_Sweden_can_nondm_1_period.gph ///
GPH/Rc_Australia_res_nondm_1_period.gph ///
GPH/Rc_Canada_chd_dm_0_period.gph ///
GPH/Rc_Australia_flu_nondm_1_period.gph ///
GPH/Rc_Sweden_cvd_dm_0_period.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC2) figure(h!) ///
caption(Modelled and crude mortality rates by year for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/RCc_France_liv2_dm_1_age.gph ///
GPH/RCc_France_ckd_nondm_0_age.gph ///
GPH/RCc_Scotland_liv1_dm_1_age.gph ///
GPH/RCc_Canada_res_dm_0_age.gph ///
GPH/RCc_Canada_res_nondm_0_age.gph ///
GPH/RCc_Sweden_can_nondm_1_age.gph ///
GPH/RCc_Australia_res_nondm_1_age.gph ///
GPH/RCc_Canada_chd_dm_0_age.gph ///
GPH/RCc_Australia_flu_nondm_1_age.gph ///
GPH/RCc_Sweden_cvd_dm_0_age.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC3) figure(h!) ///
caption(Pearson residuals by age for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/RCc_France_liv2_dm_1_period.gph ///
GPH/RCc_France_ckd_nondm_0_period.gph ///
GPH/RCc_Scotland_liv1_dm_1_period.gph ///
GPH/RCc_Canada_res_dm_0_period.gph ///
GPH/RCc_Canada_res_nondm_0_period.gph ///
GPH/RCc_Sweden_can_nondm_1_period.gph ///
GPH/RCc_Australia_res_nondm_1_period.gph ///
GPH/RCc_Canada_chd_dm_0_period.gph ///
GPH/RCc_Australia_flu_nondm_1_period.gph ///
GPH/RCc_Sweden_cvd_dm_0_period.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC4) figure(h!) ///
caption(Pearson residuals by period for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.)
graph combine ///
GPH/RCc_France_liv2_dm_1_cohort.gph ///
GPH/RCc_France_ckd_nondm_0_cohort.gph ///
GPH/RCc_Scotland_liv1_dm_1_cohort.gph ///
GPH/RCc_Canada_res_dm_0_cohort.gph ///
GPH/RCc_Canada_res_nondm_0_cohort.gph ///
GPH/RCc_Sweden_can_nondm_1_cohort.gph ///
GPH/RCc_Australia_res_nondm_1_cohort.gph ///
GPH/RCc_Canada_chd_dm_0_cohort.gph ///
GPH/RCc_Australia_flu_nondm_1_cohort.gph ///
GPH/RCc_Sweden_cvd_dm_0_cohort.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(3)
texdoc graph, label(MC5) figure(h!) ///
caption(Pearson residuals by cohort for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.) 
texdoc stlog close

/***
\color{black}

\clearpage
We see that the models fit the data reasonably well (Figures~\ref{MC1}-~\ref{MC5}). 

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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
use `i', clear
collapse (sum) pys_dm, by(age_dm)
save `i'_pysdm, replace
}
clear
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
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
ylabel(, format(%9.1f) angle(0)) ///
ytitle("Population size (millions)") xtitle("Age")
texdoc graph, label(SPN) figure(h!) caption(Pooled standard population)
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
ylabel(0(0.01)0.04, angle(0) format(%9.2f)) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age")
texdoc graph, label(SPP) figure(h!) caption(Pooled standard population proportion)
keep age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpop, replace
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
use `i', clear
collapse (sum) pys_dm, by(sex age_dm)
save `i'_pysdm_s, replace
}
clear
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
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
ylabel(, format(%9.1f) angle(0)) ///
ytitle("Population size (millions)") xtitle("Age")
texdoc graph, label(SPNs) figure(h!) caption(Pooled standard population by sex)
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
ylabel(0(0.01)0.02, angle(0) format(%9.2f)) ///
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
ylabel(0(0.01)0.02, angle(0) format(%9.2f)) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age") ///
title("Males", col(black) placement(west) size(medium))
graph save stdprop_1, replace
graph combine ///
stdprop_0.gph stdprop_1.gph ///
, graphregion(color(white)) altshrink cols(1) xsize(2.5)
texdoc graph, label(SPPs) figure(h!) caption(Pooled standard population proportion by sex)
keep sex age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpops, replace
texdoc stlog close
texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
So, there are a few data issues, meaning some rates should probably
not be presented on these plots. The standardisation
confidence interval crosses 0 for CKD deaths among males from Lithuania, 
reflecting extremely low numbers. I simply won't plot these. 
Similarly for Alzheimer's disease deaths among males from South Korea. 

Additionally, the coding issues noticed above will be dealt with here. 

\color{Blue4}
***/

texdoc stlog, cmdlog
clear
set obs 1
gen country = "Lithuania"
save MD/STD_Lithuania_ckd_dm_1, replace
clear
set obs 1
gen country = "SKorea"
save MD/STD_SKorea_azd_dm_1, replace
clear
set obs 1
gen country = "Australia"
save MD/STD_Australia_ckd_dm, replace
save MD/STD_Australia_ckd_nondm, replace
save MD/STD_Australia_ckd_dm_0, replace
save MD/STD_Australia_ckd_dm_1, replace
save MD/STD_Australia_ckd_nondm_0, replace
save MD/STD_Australia_ckd_nondm_1, replace
clear
set obs 1
gen country = "Finland"
save MD/STD_Finland_flu_dm, replace
save MD/STD_Finland_flu_nondm, replace
save MD/STD_Finland_flu_dm_0, replace
save MD/STD_Finland_flu_dm_1, replace
save MD/STD_Finland_flu_nondm_0, replace
save MD/STD_Finland_flu_nondm_1, replace
clear
set obs 1
gen country = "Scotland"
save MD/STD_Scotland_ckd_dm, replace
save MD/STD_Scotland_ckd_nondm, replace
save MD/STD_Scotland_ckd_dm_0, replace
save MD/STD_Scotland_ckd_dm_1, replace
save MD/STD_Scotland_ckd_nondm_0, replace
save MD/STD_Scotland_ckd_nondm_1, replace
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach ii in azd can cvd res dmd inf flu ckd liv {
foreach iii in dm nondm {
if "`ii'" == "dmd" & "`iii'" == "nondm" {
}
else {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
local ylab = "2 5 10 20 50"
local yform = "%9.0f"
local yrange = "1.8 50"
}
if "`ii'" == "can" {
local oo = "Cancer"
local ylab = "2 5 10 20"
local yform = "%9.0f"
local yrange = "1.8 20"
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
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
local ylab = "0.1 0.2 0.5 1 2"
local yform = "%9.1f"
local yrange = "0.05 4"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
local ylab = "0.02 0.05 0.1 0.2 0.5 1 2"
local yform = "%9.2f"
local yrange = "0.02 2.1"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
local ylab = "0.01 0.02 0.05 0.1 0.2 0.5 1 2"
local yform = "%9.2f"
local yrange = "0.005 2"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
local ylab = "0.01 0.02 0.05 0.1 0.2 0.5 1 2 5"
local yform = "%9.2f"
local yrange = "0.005 5"
}
if "`iii'" == "dm" {
local w = "with"
}
if "`iii'" == "nondm" {
local w = "without"
}
clear
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
append using MD/STD_`i'_`ii'_`iii'
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid angle(0)) ///
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
append using MD/STD_`i'_`ii'_`iii'_`iiii'
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid angle(0)) ///
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
foreach ii in azd can cvd res dmd inf flu ckd liv {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "can" {
local oo = "Cancer"
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
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}

if "`ii'" == "dmd" {
graph combine ///
GPH/STD_GPH_`ii'_dm.gph ///
GPH/STD_GPH_`ii'_dm_0.gph ///
GPH/STD_GPH_`ii'_dm_1.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(2)
texdoc graph, label(STDMRF_`ii') figure(h!) optargs(width=0.6\textwidth) ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `oo')
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
texdoc graph, label(STDMRF_`ii') figure(h!) ///
caption(Age-standardised mortality rate by cause of death, people aged 40-89. `oo')
}
}
texdoc stlog close

/***
\color{black}

\clearpage
\section{Cause-specific standardised mortality ratios}

To estimate the SMR, I will fit a model with spline effects of 
age, a binary effect of sex, and an interaction between spline effects of calendar time and diabetes status. 
I will then use this model to estimate the SMR for each country by calendar time. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in cvd can inf flu res liv ckd azd {
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
}
}
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in cvd can inf flu res liv ckd azd {
forval iii = 0/1 {
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
}
}
}
}
clear
set obs 1
gen country = "Lithuania"
save MD/SMR_Lithuania_ckd_1, replace
clear
set obs 1
gen country = "SKorea"
save MD/SMR_SKorea_azd_1, replace

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
foreach ii in cvd can inf flu res liv ckd azd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
local ylab = "1 1.5 2 2.5 3"
local yform = "%9.1f"
local yrange = "1 3"
}
if "`ii'" == "can" {
local oo = "Cancer"
local ylab = "1 1.5 2"
local yform = "%9.1f"
local yrange = "1 2"
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
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
local ylab = "0.5 1 1.5 2 2.5"
local yform = "%9.1f"
local yrange = "0.5 2.5"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
local ylab = "1 2 5 10"
local yform = "%9.0f"
local yrange = "1 10"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
local ylab = "0.5 1 2 5 10"
local yform = "%9.0f"
local yrange = "0.5 11"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
local ylab = "0.5 1 1.5"
local yform = "%9.0f"
local yrange = "0.3 1.5"
}
clear
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
append using MD/SMR_`i'_`ii'
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', grid format(`yform') angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(`yrange')) ///
ytitle("Standardised mortality ratio", margin(a+2)) ///
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
append using MD/SMR_`i'_`ii'_`iii'
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
replace country = "South Korea" if country == "SKorea"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea A3 A2 calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea A3 A2 calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yform') grid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
yline(1, lcol(black)) yscale(log range(`yrange')) ///
ytitle("Standardised mortality ratio", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo', `s'", placement(west) color(black) size(medium))
graph save GPH/SMR_`ii'_`iii', replace
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in cvd can inf flu res liv ckd azd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "can" {
local oo = "Cancer"
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
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
graph combine ///
GPH/SMR_`ii'.gph ///
GPH/SMR_`ii'_0.gph ///
GPH/SMR_`ii'_1.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(15)
texdoc graph, label(STDMRF_`ii') figure(h!) ///
caption(Standardised mortality ratio by cause of death and sex. `oo')
}

texdoc stlog close

/***
\color{black}

\clearpage
\section{Annual percent changes}

Finally, we will estimate the APC in both mortality rates
and SMRs. For mortality rates, the APC comes from a model
with a linear effect of calendar time (the APC is derived
from the coefficient associated with this term in the model)
, spline effects of age, 
a binary effect of sex, and the interaction between spline effects
of age and binary effect of sex. 
For SMRs, the APC comes from a model with spline effects of 
age, a binary effect of sex, a linear effect of calendar time, 
a binary effect of diabetes status, and the interaction between
calendar time and diabetes status (the APC is derived
from the coefficient associated with this term in the model). 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in azd can cvd res dmd inf flu ckd liv {
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
foreach var of varlist A5-A7 {
replace `var' = . if country == "Lithuania" & (A2 == "ckd")
replace `var' = . if country == "Australia" & (A2 == "ckd")
replace `var' = . if country == "Finland" & (A2 == "flu")
replace `var' = . if country == "Scotland" & (A2 == "ckd")
replace `var' = . if country == "SKorea" & (A2 == "azd")
}
save APCs, replace
quietly {
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
foreach ii in cvd can inf flu res liv ckd azd {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
local a1 = `a1'+1
local a2 = 0
foreach ii in cvd can inf flu res liv ckd azd {
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
foreach i in Australia Canada Denmark Finland France Lithuania Netherlands Scotland Skorea {
local a1 = `a1'+1
replace country = "`i'" if A1 == `a1'
local a2 = 0
foreach ii in cvd can inf flu res liv ckd azd {
local a2 = `a2'+1
replace A2 = "`ii'" if A2 == "`a2'"
}
}
replace A4 = 100*(exp(A4)-1)
replace A5 = 100*(exp(A5)-1)
replace A6 = 100*(exp(A6)-1)
foreach var of varlist A4-A6 {
replace `var' = . if country == "Lithuania" & (A2 == "ckd")
replace `var' = . if country == "Australia" & (A2 == "ckd")
replace `var' = . if country == "Finland" & (A2 == "flu")
replace `var' = . if country == "Scotland" & (A2 == "ckd")
replace `var' = . if country == "SKorea" & (A2 == "azd")
}
save SMR_APCs, replace
foreach i in azd can cvd res dmd inf flu ckd liv {
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
if "`i'" == "res" {
local ii = "chronic lower respiratory disease"
local xlab = "-15(5)10"
local xlabs = "-10(5)10"
local legp = 11
}
if "`i'" == "liv" {
local ii = "liver disease"
local xlab = "-10(5)5"
local xlabs = "-10(5)5"
local legp = 11
}
if "`i'" == "ckd" {
local ii = "renal disease"
local xlab = "-10(5)10"
local xlabs = "-10(5)5"
local legp = 1
}
if "`i'" == "azd" {
local ii = "alzheimer's disease"
local xlab = "-5(5)30"
local xlabs = "-10(5)20"
local legp = 1
}
use APCs, clear
gen AA = -A1+0.15 if A3 == "dm"
replace AA = -A1-0.15 if A3 == "nondm"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/8 {
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
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlab', format(%9.0f)) ///
title("Mortality rate, `ii'", placement(west) col(black) size(medium))
graph save GPH/APCo_`i', replace
use APCs, clear
gen AA = -A1-0.1 if A4 == 0
replace AA = -A1-0.25 if A4 == 1
replace AA = AA + 0.35 if A3=="nondm"
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/8 {
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
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlab', format(%9.0f)) ///
title("Mortality rate, `ii'", placement(west) col(black) size(medium))
graph save GPH/APCs_`i', replace
if "`i'" != "dmd" {
use SMR_APCs, clear
gen AA = -A1
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/8 {
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
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlabs', format(%9.0f)) ///
title("SMR, `ii'", placement(west) col(black) size(medium))
graph save GPH/SAPCo_`i', replace
use SMR_APCs, clear
gen AA = -A1+0.15 if A3 == 0
replace AA = -A1-0.15 if A3 == 1
replace country = "South Korea" if country == "SKorea"
preserve
bysort A1 : keep if _n == 1
forval c = 1/8 {
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
, angle(0) nogrid) ytitle("") xline(0, lcol(black)) ///
xlabel(`xlabs', format(%9.0f)) ///
title("SMR, `ii'", placement(west) col(black) size(medium))
graph save GPH/SAPCs_`i', replace
}
}
texdoc stlog close
texdoc stlog, cmdlog 
foreach ii in azd can cvd res dmd inf flu ckd liv {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "can" {
local oo = "Cancer"
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
if "`ii'" == "res" {
local oo = "Chronic lower respiratory disease"
}
if "`ii'" == "liv" {
local oo = "Liver disease"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
if "`ii'" == "dmd" {
local ii = "dmd"
graph combine ///
GPH/APCo_`ii'.gph ///
GPH/APCs_`ii'.gph ///
, graphregion(color(white)) cols(1) altshrink xsize(3)
texdoc graph, label(APC_`ii') figure(h!) ///
caption(Annual percent change in mortality rate by country. Overall (top) and by sex (bottom). `oo'.)
}
else {
graph combine ///
GPH/APCo_`ii'.gph ///
GPH/SAPCo_`ii'.gph ///
GPH/APCs_`ii'.gph ///
GPH/SAPCs_`ii'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(6)
texdoc graph, label(APC_`ii') figure(h!) ///
caption(Annual percent change in mortality rate and SMR by country. Overall (top) and by sex (bottom). `oo'.)
}
}
texdoc stlog close

/***
\color{black}

pwd
\clearpage
\section*{References}
\addcontentsline{toc}{section}{References}
\bibliography{/Users/jed/Documents/Library.bib}
\end{document}
***/

texdoc close
