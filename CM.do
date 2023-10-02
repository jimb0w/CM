
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

\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{International trends in cause-specific mortality among people with diabetes}
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
Steno Diabetes Center Copenhagen, Gentofte, Denmark \\
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
\section{Preface}

To generate this document, the Stata package texdoc \cite{Jann2016Stata} was used, which is 
available from: \color{blue} \url{http://repec.sowi.unibe.ch/stata/texdoc/} \color{black} (accessed 14 November 2022). The 
final Stata do file and this pdf are available at: \color{blue} \url{https://github.com/jimb0w/YO} \color{black}.
The ordinal colour schemes used are \emph{inferno} and \emph{viridis} from the
\emph{viridis} package \cite{GarnierR2021}.

\clearpage
\section{Introduction}

This is the protocol for an analysis of trends in cause of death in people with and without 
diabetes across several countries over the period X to X. Details of each dataset included
are available in Table~\ref{introtab1}. The causes of death studied are outlined in Table~\ref{introtab2}.

\color{red}
TBD CITE previous mortality paper for methods, or do in methods?
TBD 2 tables
\color{black}




\clearpage
\section{Data cleaning}

Most countries have some restiction on counts and beccause we are doing lots of COD
we have lots of small counts. Also been provided with many different variables. 
So we need to harmonize and just have a few variables that are the same for each country. 

The variables I'm aiming to have for each:
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

The Australia data comes from the National Diabetes Services Scheme and has been
described previously \cite{MortonDC2022}.
For Australia, we have the following variables (by age, sex, and calendar year): 
Total population size, person-years in people with diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset). From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

However, Australian data restrictions prohibit the use of any cell count <6 for the diabetes population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 0 to 5 with equal probabilitiy, unless the number of deaths in the
total population for the age/sex group is <5, in which case the upper bound will be the 
number of deaths in the total population. 
Further, because of this, data has been provided in both 10 and 20-year age groups, as well as
overall (i.e., the actual counts). My intuition is that the small cell counts
won't drive any overall results anyway, which I check below (Figure~\ref{chk1}), 
and that the uncertainty associated with such low numbers will be reflected in very wide
confidence intervals for age-specific analyses. 

Because Australian data are unreliable before 2005, I will drop data from 2002-2004. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
cd /Users/jed/Documents/CM/
*mkdir GPH
texdoc stlog close
texdoc stlog, cmdlog 
import delimited "Consortium COD database v1.csv", clear
keep if substr(country,1,9)=="Australia"
drop if cal < 2005
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
set seed 3488717
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
di "`i'"
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,5)
quietly replace `i'_d_dm = runiformint(0,max_`i') if `i'_d_dm ==.
}
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
di "`i'"
count if `i'_d_dm > `i'_d_pop
}
gen diff = dmd_d_dm-dmd_d_pop
ta diff if diff >0
replace dmd_d_dm = dmd_d_pop if dmd_d_dm > dmd_d_pop
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
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
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "chd" {
local ii = "Ischaemic heart disease"
}
if "`i'" == "cbd" {
local ii = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local ii = "Heart failure"
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
if "`i'" == "liv1" {
local ii = "Liver disease"
}
if "`i'" == "liv2" {
local ii = "Liver disease (excluding alcoholic liver disease)"
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
GPH/dm_chd_chk1.gph ///
GPH/dm_cbd_chk1.gph ///
GPH/dm_hfd_chk1.gph ///
GPH/dm_can_chk1.gph ///
GPH/dm_dmd_chk1.gph ///
GPH/dm_inf_chk1.gph ///
GPH/dm_flu_chk1.gph ///
GPH/dm_res_chk1.gph ///
GPH/dm_liv1_chk1.gph ///
GPH/dm_liv2_chk1.gph ///
GPH/dm_ckd_chk1.gph ///
GPH/dm_azd_chk1.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(4)
texdoc graph, label(chk1) ///
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
replace age_dm = "30" if age_dm == "<4"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "<4"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Australia, replace
texdoc stlog close


/***
\color{black}


\clearpage
\subsection{Canada}

The Canadian data comes from X and has been described previously (citation). 
For Canada, we have the following variables (by age, sex, and calendar year): 
Total population size, prevalence of diabetes, incidence of diabetes, 
deaths in people with diabetes, and deaths in the total population. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset). We can calculate person-years in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes to half the number of people with 
incident diabetes and subtracting half the number of all-cause deaths (again, performed before I got the dataset). 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.
Similarly, for deaths in people without diabetes, we can subtract the deaths in people with diabetes
from the total deaths. 

However, Canadian data restrictions prohibit the use of any cell count between 1 and 9
for people with diabetes and in the total population; thus, 
there are many blank values (see below). I will fill them in randomly, where the number
can be any number from 1 to 9 with equal probabilitiy, unless the number of deaths in the
total population for the age/sex group is <9 (after being randomly generated), 
in which case the upper bound will be the 
number of deaths in the total population. 
Further, because of this, data has been provided in both 10 and 20-year age groups, as well as
overall (i.e., the actual counts). My intuition is that the small cell counts
won't drive any overall results anyway, which I check below (Figure~\ref{chk2}), 
and that the uncertainty associated with such low numbers will be reflected in very wide
confidence intervals for age-specific analyses. 

\color{Blue4}
***/

texdoc stlog, cmdlog
import delimited "Consortium COD database v1.csv", clear
keep if substr(country,1,6)=="Canada"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
set seed 44542517
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
di "`i'"
ta age_gp1 if `i'_d_pop ==.
gen min_`i' = max(`i'_d_dm,1) if `i'_d_dm!=.
replace min_`i' = 1 if `i'_d_dm==.
quietly replace `i'_d_pop = runiformint(min_`i',9) if `i'_d_pop==.
ta age_gp1 if `i'_d_dm ==.
gen max_`i' = min(`i'_d_pop,9)
quietly replace `i'_d_dm = runiformint(1,max_`i') if `i'_d_dm ==.
}
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
di "`i'"
count if `i'_d_dm > `i'_d_pop
gen diff = `i'_d_dm-`i'_d_pop
ta diff if diff >0
replace `i'_d_dm = `i'_d_pop if `i'_d_dm > `i'_d_pop
drop diff
}
texdoc stlog close
texdoc stlog, cmdlog nodo
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
texdoc stlog close

/***
\color{black}

We see that it is predominately younger age groups affected by
missing data, which makes sense. Also, there were some age groups in which
the number of deaths due to heart failure, diabetes, and renal disease 
among people with diabetes was greater
than that recorded for the whole population. The differences were tiny, 
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
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "chd" {
local ii = "Ischaemic heart disease"
}
if "`i'" == "cbd" {
local ii = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local ii = "Heart failure"
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
if "`i'" == "liv1" {
local ii = "Liver disease"
}
if "`i'" == "liv2" {
local ii = "Liver disease (excluding alcoholic liver disease)"
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
graph save GPH/dm_`i'_chk2, replace
gen ndm_`i' = 1000*`i'_d_nondm/pys_nondm
twoway ///
(connected ndm_`i' cal if agegp == 1, col(black)) ///
(connected ndm_`i' cal if agegp == 2, col(blue)) ///
(connected ndm_`i' cal if agegp == 3, col(red)) ///
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
graph save GPH/ndm_`i'_chk2, replace
}
restore
texdoc stlog close
texdoc stlog, cmdlog 
graph combine ///
GPH/dm_cvd_chk2.gph ///
GPH/dm_chd_chk2.gph ///
GPH/dm_cbd_chk2.gph ///
GPH/dm_hfd_chk2.gph ///
GPH/dm_can_chk2.gph ///
GPH/dm_dmd_chk2.gph ///
GPH/dm_inf_chk2.gph ///
GPH/dm_flu_chk2.gph ///
GPH/dm_res_chk2.gph ///
GPH/dm_liv1_chk2.gph ///
GPH/dm_liv2_chk2.gph ///
GPH/dm_ckd_chk2.gph ///
GPH/dm_azd_chk2.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(4)
texdoc graph, label(chk2d) ///
caption(Crude mortality rate by age-grouping method, by cause of death. Canada. People with diabetes.)
graph combine ///
GPH/ndm_cvd_chk2.gph ///
GPH/ndm_chd_chk2.gph ///
GPH/ndm_cbd_chk2.gph ///
GPH/ndm_hfd_chk2.gph ///
GPH/ndm_can_chk2.gph ///
GPH/ndm_dmd_chk2.gph ///
GPH/ndm_inf_chk2.gph ///
GPH/ndm_flu_chk2.gph ///
GPH/ndm_res_chk2.gph ///
GPH/ndm_liv1_chk2.gph ///
GPH/ndm_liv2_chk2.gph ///
GPH/ndm_ckd_chk2.gph ///
GPH/ndm_azd_chk2.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(4)
texdoc graph, label(chk2n) ///
caption(Crude mortality rate by age-grouping method, by cause of death. Canada. People without diabetes.)
texdoc stlog close

/***
\color{black}

As with Australia, we see that there doesn't appear to be any systematic
issue introduced using random numbers (Figures~\ref{chk2d}-~\ref{,chk2n}). I will proceed using the most granular age groupings. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
keep if age_gp1!=""
replace country = substr(country,1,6)
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "0-"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "15" if age_nondm == "0-"
destring age_nondm, replace
replace age_nondm = age_nondm+5
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Canada, replace
texdoc stlog close


/***
\color{black}

\subsection{Finland}

The Finnish data comes from X and has been described previously (citation). 
For Finland, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
Nevertheless, Finland restricts counts between 1 and 5 for both people with and without
diabetes. I will fill them in randomly, where the number
can be any number from 1 to 5 with equal probability. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ are
35 and 95, respectively.

\color{Blue4}
***/

texdoc stlog, cmdlog
import delimited "Consortium COD database v1.csv", clear
keep if substr(country,1,7)=="Finland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
set seed 09843382
texdoc stlog close
texdoc stlog
ta age_gp1
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
di "`i'"
ta age_gp1 if `i'_d_nondm ==.
quietly replace `i'_d_nondm = runiformint(1,5) if `i'_d_nondm==.
ta age_gp1 if `i'_d_dm ==.
quietly replace `i'_d_dm = runiformint(1,5) if `i'_d_dm ==.
}
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
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Finland, replace
texdoc stlog close

/***
\color{black}

There's a considerable amount of missing data here,
although again, it's always for small cell counts, so shouldn't
have a major impact, as we saw for Australia and Canada (Finland 
hasn't provided the full data, so there is no way to check counts).

\clearpage
\subsection{France}

The French data comes from X and has been described previously (citation). 
For France, we have the following variables (by age, sex, and calendar year): 
Person-years and deaths in people with and without diabetes. I.e., no further
variables need to be derived. 
I will assume the mid-point of the age interval for people aged $<$40 is 35 and for 90$+$ are
35 and 95, respectively.

France provided data for 2013-2017 and 2020, but because we are analysing trends, 
we will exclude the data from 2020. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
import delimited "Consortium COD database v1.csv", clear
keep if substr(country,1,8)=="France_1"
drop if cal == 2020
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
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save France, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Lithuania}

The Lithuanian data comes from X and has been described previously (citation). 
For Lithuania, we have the following variables (by age, sex, and calendar year): 
Total population size, prevalence of diabetes, incidence of diabetes, 
deaths in people with diabetes, and deaths in people without diabetes. 
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset). We can calculate person-years in people with diabetes, in a given calendar year, 
by adding the number of people with prevalent diabetes to half the number of people with 
incident diabetes and subtracting half the number of all-cause deaths (again, performed before I got the dataset). 
From there, person-years in people
without diabetes is just person-years in the total population minus person-years in people with diabetes.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
import delimited "Consortium COD database v1.csv", clear
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
replace country = substr(country,1,6)
recode dmd_d_nondm .=0
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Lithuania, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Scotland}

The Sottish data comes from X and has been described previously (citation). 
For Scotland, we have the following variables (by age, sex, and calendar year): 
Total population size, person-years in people with diabetes,
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
import delimited "Consortium COD database v1.csv", clear
keep if country == "Scotland"
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
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
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
replace `i'_d_dm = . if age_dm==.
replace `i'_d_nondm = . if age_nondm==.
}
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Scotland, replace
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Sweden}

The Swedish data comes from X and has been described previously (citation). 
For Sweden, we have the following variables (by age, sex, and calendar year): 
Total population size, person-years in people with diabetes,
deaths in people with diabetes, and deaths in the total population.
We can calculate person-years in the total population by assuming that the person-years
of follow-up in a given calendar year are equal to the population size in the current year
plus the population size in the next year, divided by two (this has been performed before
I got the dataset). I then calculate person-years in people without diabetes by substracting
the person-years in people with diabetes from person-years in the total population; similarly
for deaths in people without diabetes. 

The age groups are slightly different for Sweden -- the youngest age group is 18-39, not 0-39 like other
ages; for people with diabetes, the mean age is still probably 35, but for people without diabetes I will assume
it is 29. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
import delimited "Consortium COD database v1.csv", clear
keep if country == "Sweden"
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}
replace pys_nondm = pys_totpop-pys_dm
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
gen age_dm = substr(age_gp1,1,2)
replace age_dm = "30" if age_dm == "18"
destring age_dm, replace
replace age_dm = age_dm+5
gen age_nondm = substr(age_gp1,1,2)
replace age_nondm = "24" if age_nondm == "18"
destring age_nondm, replace
replace age_nondm = age_nondm+5
replace country = substr(country,1,6)
recode dmd_d_nondm .=0
keep country calendar sex age_dm age_nondm pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm
save Sweden, replace
texdoc stlog close


/***
\color{black}

\clearpage
\subsection{Summary}

Table~\ref{cleansumtab} shows a summary of the data included in this analysis. 

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
      display columns/6/.style={column name=CHD, column type={r}},
      display columns/7/.style={column name=CBD, column type={r}},
      display columns/8/.style={column name=HFD, column type={r}},
      display columns/9/.style={column name=CAN, column type={r}},
      display columns/10/.style={column name=DMD, column type={r}},
      display columns/11/.style={column name=INF, column type={r}},
      display columns/12/.style={column name=FLU, column type={r}},
      display columns/13/.style={column name=RES, column type={r}},
      display columns/14/.style={column name=LIV1, column type={r}},
      display columns/15/.style={column name=LIV2, column type={r}},
      display columns/16/.style={column name=CKD, column type={r}},
      display columns/17/.style={column name=AZD, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & & & \multicolumn{13}{c}{Death counts by cause of death} \\
					},
        after row={\midrule}
            },
        every nth row={4}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{T1.csv}
  \end{center}
Abbreviations: CVD -- Cardiovascular disease; CHD -- Ischaemic heart disease; CBD -- Cerebrovascular disease;
HFD -- Heart failure; CAN -- Cancer; DMD -- Diabetes; INF -- Infectious diseases; FLU --
Influenza and pneumonia; RES -- Chronic lower respiratory disease; LIV1 -- Liver disease; 
LIV2 -- Liver disease (excluding alcoholic liver disease); CKD -- Renal disease; 
AZD -- Alzheimer's disease.
\end{table}
\end{landscape}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
clear
foreach c in Australia Canada Finland France Lithuania Scotland Sweden {
append using `c'
}
bysort country (cal) : egen lb = min(cal)
bysort country (cal) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(country sex rang)
expand 2
bysort country sex : gen DM = _n-1
tostring sex pys_dm-DM, replace force format(%15.0fc)
gen pys = pys_dm if DM == "1"
replace pys = pys_nondm if DM == "0"
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
gen `i' = `i'_d_dm if DM == "1"
replace `i' = `i'_d_nondm if DM == "0"
}
keep country-rang DM-azd
order country rang DM sex
sort country rang DM sex
gen njm = _n
bysort country DM (njm) : replace DM ="" if _n!=1
bysort country (njm) : replace country ="" if _n!=1
bysort rang (njm) : replace rang ="" if _n!=1
sort njm
replace DM = "No diabetes" if DM == "0"
replace DM = "Diabetes" if DM == "1"
replace sex = "Female" if sex == "0"
replace sex = "Male" if sex == "1"
drop njm
export delimited using T1.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\clearpage
\section{Crude rates}

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach c in Australia Canada Finland France Lithuania Scotland Sweden {
use `c', clear
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar sex)
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
if "`i'" == "cvd" {
local ii = "Cardiovascular disease"
}
if "`i'" == "chd" {
local ii = "Ischaemic heart disease"
}
if "`i'" == "cbd" {
local ii = "Cerebrovascular disease"
}
if "`i'" == "hfd" {
local ii = "Heart failure"
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
if "`i'" == "liv1" {
local ii = "Liver disease"
}
if "`i'" == "liv2" {
local ii = "Liver disease (excluding alcoholic liver disease)"
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
title("`ii', people `dd' diabetes, `c'", placement(west) size(medium) col(black))
graph save GPH/cr_`i'_`iii'_`c', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
foreach c in Australia Canada Finland France Lithuania Scotland Sweden {
graph combine ///
GPH/cr_cvd_dm_`c'.gph ///
GPH/cr_cvd_nondm_`c'.gph ///
GPH/cr_chd_dm_`c'.gph ///
GPH/cr_chd_nondm_`c'.gph ///
GPH/cr_cbd_dm_`c'.gph ///
GPH/cr_cbd_nondm_`c'.gph ///
GPH/cr_hfd_dm_`c'.gph ///
GPH/cr_hfd_nondm_`c'.gph ///
GPH/cr_can_dm_`c'.gph ///
GPH/cr_can_nondm_`c'.gph ///
GPH/cr_dmd_dm_`c'.gph ///
GPH/cr_dmd_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(2)
texdoc graph, label(CR1_`c') optargs(width=0.5\textwidth) ///
caption(Crude mortality rate by cause of death, sex, and diabetes status. `c'. ///
Cardiovascular disease, ischaemic heart disease, cerebrovascular disease, ///
heart failure, cancer, and diabetes.)
graph combine ///
GPH/cr_inf_dm_`c'.gph ///
GPH/cr_inf_nondm_`c'.gph ///
GPH/cr_flu_dm_`c'.gph ///
GPH/cr_flu_nondm_`c'.gph ///
GPH/cr_res_dm_`c'.gph ///
GPH/cr_res_nondm_`c'.gph ///
GPH/cr_liv1_dm_`c'.gph ///
GPH/cr_liv1_nondm_`c'.gph ///
GPH/cr_liv2_dm_`c'.gph ///
GPH/cr_liv2_nondm_`c'.gph ///
GPH/cr_ckd_dm_`c'.gph ///
GPH/cr_ckd_nondm_`c'.gph ///
GPH/cr_azd_dm_`c'.gph ///
GPH/cr_azd_nondm_`c'.gph ///
, graphregion(color(white)) cols(2) altshrink xsize(2)
texdoc graph, label(CR2_`c') optargs(width=0.5\textwidth) ///
caption(Crude mortality rate by cause of death, sex, and diabetes status. `c'. ///
Infectious diseases, influenza and pneumonia, chronic lower respiratory disease, ///
liver disease, liver disease (excluding alcoholic liver disease), renal disease, and Alzheimer's disease.)
}
texdoc stlog close

/***
\color{black}

\clearpage
A few suspected coding changes to note:
\begin{itemize}
\item Figure~\ref{CR2_Australia}, Australia, renal disease in 2013. 
\item Figure~\ref{CR1_Finland}, Finland, heart failure: while gradual, there is a massive decline in heart failure to near-zero by 2017. 
This suggests to me that coding practices could have changed over time to not include HF as the primary cause of death. 
\item Figure~\ref{CR2_Finland}, Finland, influenze and pneumonia from 2000-2005.
\item Figure~\ref{CR2_Scotland}, Scotland, renal disease in 2017.
\end{itemize}

Additionally, the data from Sweden (Figure~\ref{CR1_Sweden}) is clearly ``wrong'' -- most major causes
of death increase in people with diabetes from 2007-2012(ish) before stabilising or dropping, while 
dropping continuously in the general population. Indeed, the size of the Swedish registry increased 
massively over time (Figure~\ref{Swchk}), potentially explaining this. 

\color{Blue4}
***/

texdoc stlog, cmdlog
use Sweden, clear
collapse (sum) pys_dm, by(cal)
twoway ///
(connected pys_dm cal, col(black)) ///
, graphregion(color(white)) ///
ytitle(Person-years in people with diabetes) ///
ylabel(0(100000)600000, format(%9.0fc) angle(0)) ///
xtitle(Year)
texdoc graph, label(Swchk) ///
caption(Person-years in people with diabetes by calendar year in the Swedish dataset.)
texdoc stlog close

/***
\color{black}

\clearpage
\section{Cause-specific mortality rates}

\subsection{Methods}

To generate age- and period-specific rates, as well as age-standardised rates, 
We will model mortality rates using age-period-cohort models \cite{CarstensenSTATMED2007}.
Each model will be a Poisson model, parameterised using 
spline effects of age, period, and cohort (period-age), with log 
of person-years as the offset. 
Age is defined as above (i.e., the midpoint of the interval in most cases) and models are
fit separately for each cause of death and country in people with and without diabetes and by sex. 
Because this will be \begin{math} 13 \times 7 \ times 2 \times 2 = 364 \end{math} models, 
we won't check model fit with different knot numbers and placements for each model. Instead, 
to check model fit we will select ten at random and check the predicted and actual rates as well as 
the Pearson residuals. 

These models will be used to predict mortality rates for single year ages and calendar years.
These predicted rates will first be plotted by age and period, then used to generate
age-standardised rates in people with and without diabetes, using direct standardisation
(using the total diabetes population formed by pooling the consortium data) by period. 

Then, to generate an overall estimate of trends over time, we will fit a model with spline
effects of age but a linear effect of period and calculate the annual percent change for 
each data source in people with and without diabetes, by sex. 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
*mkdir MD
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
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
bysort cal : replace cal = cal+((_n-1)/10)
expand 700
bysort cal : gen age_`iii' = (_n/10)+29.9
gen pys_`iii' = 1
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
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
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in dmd {
foreach iii in dm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
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
bysort cal : replace cal = cal+((_n-1)/10)
expand 700
bysort cal : gen age_`iii' = (_n/10)+29.9
gen pys_`iii' = 1
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
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
set seed 1234
clear
gen A =.
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
local B = runiform()
append using MD/RC_pred_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A < 0.021
}
}
}
}
save RCc, replace
set seed 1234
clear
gen A =.
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
local B = runiform()
append using MD/R_`i'_`ii'_`iii'_`iiii'
recode A .=`B'
keep if A < 0.021
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
2 "Predicted" ///
3 "Actual" ///
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
2 "Predicted" ///
2 "45" 5 "65" 8 "85" ///
3 "Actual" ///
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
texdoc graph, label(MC1) ///
caption(Predicted and actual mortality rates by age for 10 randomly selected ///
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
texdoc graph, label(MC2) ///
caption(Predicted and actual mortality rates by year for 10 randomly selected ///
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
texdoc graph, label(MC3) ///
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
texdoc graph, label(MC4) ///
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
texdoc graph, label(MC5) ///
caption(Pearson residuals by cohort for 10 randomly selected ///
country/cause of death/diabetes status/sex combinations.) 
texdoc stlog close

/***
\color{black}

\clearpage
We see that the models fit the data well (Figures~\ref{MC1}-~\ref{MC5}). 

\color{red}
Maybe another knot or two for age? I am not sure it would effect overall conclusions but the fit 
is good enough in my opinion (Figure~\ref{MC1}).
\color{black}


\clearpage
\subsection{Age- and period-specific rates}


\color{Blue4}
***/

texdoc stlog, cmdlog nodo
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
{
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Ischaemic heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
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
if "`ii'" == "liv1" {
local oo = "Liver disease"
}
if "`ii'" == "liv2" {
local oo = "Liver disease (excluding alcoholic liver disease)"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
if `iiii' == 0 {
use inferno, clear
local ss = "females"
}
if `iiii' == 1 {
use viridis, clear
local ss = "males"
}
local col1 = var4[4]
local col2 = var4[3]
local col3 = var4[2]
local col4 = var7[7]
local col5 = var7[6]
local col6 = var7[5]
local col7 = var7[4]
local col8 = var7[3]
local col9 = var7[2]
}
use MD/R_`i'_`ii'_`iii'_`iiii', clear
egen calmin = min(calendar)
egen calmen = mean(calendar)
replace calmen = round(calmen,1)
egen calmax = max(calendar)
replace calmax = calmax-0.9
local cmn = calmin[1]
local cmu = calmen[1]
local cmx = calmax[1]
twoway ///
(rarea ub lb age_`iii' if cale == `cmn', color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmn', color("`col1'")) ///
(rarea ub lb age_`iii' if cale == `cmu', color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmu', color("`col2'")) ///
(rarea ub lb age_`iii' if cale == `cmx', color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmx', color("`col3'")) ///
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
xlabel(30(10)100) ytitle("Mortality rate (per 1000 person-years)", margin(a+2)) ///
xtitle(Age) yscale(log range(0.001 100)) legend(order( ///
2 "`cmn'" ///
4 "`cmu'" ///
6 "`cmx'" ///
) ring(0) cols(3) position(11) region(lcolor(none) col(none))) ///
title("`i', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/R_`i'_`ii'_`iii'_`iiii'_age, replace
twoway ///
(rarea ub lb cale if age_`iii' == 40, color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 40, color("`col4'")) ///
(rarea ub lb cale if age_`iii' == 50, color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 50, color("`col5'")) ///
(rarea ub lb cale if age_`iii' == 60, color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 60, color("`col6'")) ///
(rarea ub lb cale if age_`iii' == 70, color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 70, color("`col7'")) ///
(rarea ub lb cale if age_`iii' == 80, color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 80, color("`col8'")) ///
(rarea ub lb cale if age_`iii' == 90, color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 90, color("`col9'")) ///
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
ytitle("Mortality rate (per 1000 person-years)") ///
xtitle(Year) yscale(log range(0.001 100)) legend(order( ///
2 "40" ///
4 "50" ///
6 "60" ///
8 "70" ///
10 "80" ///
12 "90" ///
) ring(0) cols(6) position(11) region(lcolor(none) col(none))) ///
title("`i', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/R_`i'_`ii'_`iii'_`iiii'_period, replace
}
}
}
}
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in dmd {
foreach iii in dm {
foreach iiii in 0 1 {
{
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Ischaemic heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
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
if "`ii'" == "liv1" {
local oo = "Liver disease"
}
if "`ii'" == "liv2" {
local oo = "Liver disease (excluding alcoholic liver disease)"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
if "`iii'" == "dm" {
local dd = "with"
}
if "`iii'" == "nondm" {
local dd = "without"
}
if `iiii' == 0 {
use inferno, clear
local ss = "females"
}
if `iiii' == 1 {
use viridis, clear
local ss = "males"
}
local col1 = var4[4]
local col2 = var4[3]
local col3 = var4[2]
local col4 = var7[7]
local col5 = var7[6]
local col6 = var7[5]
local col7 = var7[4]
local col8 = var7[3]
local col9 = var7[2]
}
use MD/R_`i'_`ii'_`iii'_`iiii', clear
egen calmin = min(calendar)
egen calmen = mean(calendar)
replace calmen = round(calmen,1)
egen calmax = max(calendar)
replace calmax = calmax-0.9
local cmn = calmin[1]
local cmu = calmen[1]
local cmx = calmax[1]
twoway ///
(rarea ub lb age_`iii' if cale == `cmn', color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmn', color("`col1'")) ///
(rarea ub lb age_`iii' if cale == `cmu', color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmu', color("`col2'")) ///
(rarea ub lb age_`iii' if cale == `cmx', color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age_`iii' if cale == `cmx', color("`col3'")) ///
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
xlabel(30(10)100) ytitle("Mortality rate (per 1000 person-years)", margin(a+2)) ///
xtitle(Age) yscale(log range(0.001 100)) legend(order( ///
2 "`cmn'" ///
4 "`cmu'" ///
6 "`cmx'" ///
) ring(0) cols(3) position(11) region(lcolor(none) col(none))) ///
title("`i', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/R_`i'_`ii'_`iii'_`iiii'_age, replace
twoway ///
(rarea ub lb cale if age_`iii' == 40, color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 40, color("`col4'")) ///
(rarea ub lb cale if age_`iii' == 50, color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 50, color("`col5'")) ///
(rarea ub lb cale if age_`iii' == 60, color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 60, color("`col6'")) ///
(rarea ub lb cale if age_`iii' == 70, color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 70, color("`col7'")) ///
(rarea ub lb cale if age_`iii' == 80, color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 80, color("`col8'")) ///
(rarea ub lb cale if age_`iii' == 90, color("`col9'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate cale if age_`iii' == 90, color("`col9'")) ///
, graphregion(color(white)) ylabel( ///
0.01 "0.01" 0.1 "0.1" 1 10 100, angle(0)) ///
ytitle("Mortality rate (per 1000 person-years)") ///
xtitle(Year) yscale(log range(0.001 100)) legend(order( ///
2 "40" ///
4 "50" ///
6 "60" ///
8 "70" ///
10 "80" ///
12 "90" ///
) ring(0) cols(6) position(11) region(lcolor(none) col(none))) ///
title("`i', `oo', `ss' `dd' diabetes", col(black) placement(west) size(medium))
graph save GPH/R_`i'_`ii'_`iii'_`iiii'_period, replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
graph combine ///
GPH/R_`i'_cvd_dm_0_age.gph ///
GPH/R_`i'_cvd_nondm_0_age.gph ///
GPH/R_`i'_cvd_dm_1_age.gph ///
GPH/R_`i'_cvd_nondm_1_age.gph ///
GPH/R_`i'_chd_dm_0_age.gph ///
GPH/R_`i'_chd_nondm_0_age.gph ///
GPH/R_`i'_chd_dm_1_age.gph ///
GPH/R_`i'_chd_nondm_1_age.gph ///
GPH/R_`i'_cbd_dm_0_age.gph ///
GPH/R_`i'_cbd_nondm_0_age.gph ///
GPH/R_`i'_cbd_dm_1_age.gph ///
GPH/R_`i'_cbd_nondm_1_age.gph ///
GPH/R_`i'_hfd_dm_0_age.gph ///
GPH/R_`i'_hfd_nondm_0_age.gph ///
GPH/R_`i'_hfd_dm_1_age.gph ///
GPH/R_`i'_hfd_nondm_1_age.gph ///
GPH/R_`i'_can_dm_0_age.gph ///
GPH/R_`i'_can_nondm_0_age.gph ///
GPH/R_`i'_can_dm_1_age.gph ///
GPH/R_`i'_can_nondm_1_age.gph ///
GPH/R_`i'_dmd_dm_0_age.gph ///
GPH/R_`i'_dmd_dm_1_age.gph ///
, graphregion(color(white)) cols(4) altshrink xsize(4) holes(22)
texdoc graph, label(MR1_age_`i') ///
caption(Mortality rate by age, stratified by calendar year, cause of death, sex, and diabetes status. `i'. ///
Cardiovascular disease, ischaemic heart disease, cerebrovascular disease, ///
heart failure, cancer, and diabetes.)
graph combine ///
GPH/R_`i'_inf_dm_0_age.gph ///
GPH/R_`i'_inf_nondm_0_age.gph ///
GPH/R_`i'_inf_dm_1_age.gph ///
GPH/R_`i'_inf_nondm_1_age.gph ///
GPH/R_`i'_flu_dm_0_age.gph ///
GPH/R_`i'_flu_nondm_0_age.gph ///
GPH/R_`i'_flu_dm_1_age.gph ///
GPH/R_`i'_flu_nondm_1_age.gph ///
GPH/R_`i'_res_dm_0_age.gph ///
GPH/R_`i'_res_nondm_0_age.gph ///
GPH/R_`i'_res_dm_1_age.gph ///
GPH/R_`i'_res_nondm_1_age.gph ///
GPH/R_`i'_liv1_dm_0_age.gph ///
GPH/R_`i'_liv1_nondm_0_age.gph ///
GPH/R_`i'_liv1_dm_1_age.gph ///
GPH/R_`i'_liv1_nondm_1_age.gph ///
GPH/R_`i'_liv2_dm_0_age.gph ///
GPH/R_`i'_liv2_nondm_0_age.gph ///
GPH/R_`i'_liv2_dm_1_age.gph ///
GPH/R_`i'_liv2_nondm_1_age.gph ///
GPH/R_`i'_ckd_dm_0_age.gph ///
GPH/R_`i'_ckd_nondm_0_age.gph ///
GPH/R_`i'_ckd_dm_1_age.gph ///
GPH/R_`i'_ckd_nondm_1_age.gph ///
GPH/R_`i'_azd_dm_0_age.gph ///
GPH/R_`i'_azd_nondm_0_age.gph ///
GPH/R_`i'_azd_dm_1_age.gph ///
GPH/R_`i'_azd_nondm_1_age.gph ///
, graphregion(color(white)) cols(4) altshrink xsize(4)
texdoc graph, label(MR2_age_`i') ///
caption(Mortality rate by age, stratified by calendar year, cause of death, sex, and diabetes status. `i'. ///
Infectious diseases, influenza and pneumonia, chronic lower respiratory disease, ///
liver disease, liver disease (excluding alcoholic liver disease), renal disease, and Alzheimer's disease.)
graph combine ///
GPH/R_`i'_cvd_dm_0_period.gph ///
GPH/R_`i'_cvd_nondm_0_period.gph ///
GPH/R_`i'_cvd_dm_1_period.gph ///
GPH/R_`i'_cvd_nondm_1_period.gph ///
GPH/R_`i'_chd_dm_0_period.gph ///
GPH/R_`i'_chd_nondm_0_period.gph ///
GPH/R_`i'_chd_dm_1_period.gph ///
GPH/R_`i'_chd_nondm_1_period.gph ///
GPH/R_`i'_cbd_dm_0_period.gph ///
GPH/R_`i'_cbd_nondm_0_period.gph ///
GPH/R_`i'_cbd_dm_1_period.gph ///
GPH/R_`i'_cbd_nondm_1_period.gph ///
GPH/R_`i'_hfd_dm_0_period.gph ///
GPH/R_`i'_hfd_nondm_0_period.gph ///
GPH/R_`i'_hfd_dm_1_period.gph ///
GPH/R_`i'_hfd_nondm_1_period.gph ///
GPH/R_`i'_can_dm_0_period.gph ///
GPH/R_`i'_can_nondm_0_period.gph ///
GPH/R_`i'_can_dm_1_period.gph ///
GPH/R_`i'_can_nondm_1_period.gph ///
GPH/R_`i'_dmd_dm_0_period.gph ///
GPH/R_`i'_dmd_dm_1_period.gph ///
, graphregion(color(white)) cols(4) altshrink xsize(4) holes(22)
texdoc graph, label(MR1_period_`i') ///
caption(Mortality rate by period, stratified by age, cause of death, sex, and diabetes status. `i'. ///
Cardiovascular disease, ischaemic heart disease, cerebrovascular disease, ///
heart failure, cancer, and diabetes.)
graph combine ///
GPH/R_`i'_inf_dm_0_period.gph ///
GPH/R_`i'_inf_nondm_0_period.gph ///
GPH/R_`i'_inf_dm_1_period.gph ///
GPH/R_`i'_inf_nondm_1_period.gph ///
GPH/R_`i'_flu_dm_0_period.gph ///
GPH/R_`i'_flu_nondm_0_period.gph ///
GPH/R_`i'_flu_dm_1_period.gph ///
GPH/R_`i'_flu_nondm_1_period.gph ///
GPH/R_`i'_res_dm_0_period.gph ///
GPH/R_`i'_res_nondm_0_period.gph ///
GPH/R_`i'_res_dm_1_period.gph ///
GPH/R_`i'_res_nondm_1_period.gph ///
GPH/R_`i'_liv1_dm_0_period.gph ///
GPH/R_`i'_liv1_nondm_0_period.gph ///
GPH/R_`i'_liv1_dm_1_period.gph ///
GPH/R_`i'_liv1_nondm_1_period.gph ///
GPH/R_`i'_liv2_dm_0_period.gph ///
GPH/R_`i'_liv2_nondm_0_period.gph ///
GPH/R_`i'_liv2_dm_1_period.gph ///
GPH/R_`i'_liv2_nondm_1_period.gph ///
GPH/R_`i'_ckd_dm_0_period.gph ///
GPH/R_`i'_ckd_nondm_0_period.gph ///
GPH/R_`i'_ckd_dm_1_period.gph ///
GPH/R_`i'_ckd_nondm_1_period.gph ///
GPH/R_`i'_azd_dm_0_period.gph ///
GPH/R_`i'_azd_nondm_0_period.gph ///
GPH/R_`i'_azd_dm_1_period.gph ///
GPH/R_`i'_azd_nondm_1_period.gph ///
, graphregion(color(white)) cols(4) altshrink xsize(4)
texdoc graph, label(MR2_period_`i') ///
caption(Mortality rate by period, stratified by age, cause of death, sex, and diabetes status. `i'. ///
Infectious diseases, influenza and pneumonia, chronic lower respiratory disease, ///
liver disease, liver disease (excluding alcoholic liver disease), renal disease, and Alzheimer's disease.)
}
texdoc stlog close

/***
\color{black}

\clearpage
\subsection{Age-standardised rates}

Before calculating rates, we must generate the standard population. To do this, 
we will pool the person-years among people with diabetes from all datasets except Sweden (because
the person-years in the youngest age group are only for people aged 18-39)
and convert the estimates into a single-year values for our standard population. 

\color{red}

Sweden poses a problem -- the rates are from a different population (18+) than the others,
so how should we standardise Swedish data? One idea is to just use the 40+ population. 

\color{Blue4}
***/

texdoc stlog, cmdlog
foreach i in Australia Canada Finland France Lithuania Scotland {
use `i', clear
collapse (sum) pys_dm, by(age_dm)
save `i'_pysdm, replace
}
clear
foreach i in Australia Canada Finland France Lithuania Scotland {
append using `i'_pysdm
}
collapse (sum) pys_dm, by(age_dm)
drop if age_dm ==.
expand 10 if age!=35
expand 40 if age==35
replace pys_dm=pys_dm/10 if age!=35
replace pys_dm=pys_dm/40 if age==35
bysort age : replace age = age+_n-5.5 if age!=35
bysort age : replace age = age+_n-35.5 if age==35
mkspline agesp = age, cubic knots(35 45 60 75 90)
glm pys_dm agesp*, family(gamma) link(log)
predict A
preserve
replace pys_dm = pys_dm/1000000
replace A = A/1000000
twoway ///
(scatter pys_dm age_dm, col(dknavy)) ///
(line A age_dm, col(magenta)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) angle(0)) ///
ytitle("Population size (millions)") xtitle("Age")
texdoc graph, label(ESP2010N) caption(European standard population in 2010)
restore
su(pys_dm)
gen age_dm_prop = pys_dm/r(sum)
su(A)
gen B = A/r(sum)
twoway ///
(bar age_dm_prop age_dm, color(dknavy%70)) ///
(bar B age_dm, color(magenta%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.04, angle(0) format(%9.2f)) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age")
texdoc graph, label(ESP2010P) caption(European standard population proportions in 2010)
keep age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpop, replace
texdoc stlog close
texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
use `i', clear
collapse (sum) pys_dm-azd_d_nondm, by(country age_dm age_nondm calendar)
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina & age_`iii'!=87.5
expand 20 if age_`iii'==87.5
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina & age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina & age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
else if "`i'" == "Sweden" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 22 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/22 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n+17 if age_`iii'==mina
}
else {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in dmd {
foreach iii in dm {
use `i', clear
collapse (sum) pys_dm-azd_d_nondm, by(country age_dm age_nondm calendar)
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina & age_`iii'!=87.5
expand 20 if age_`iii'==87.5
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina & age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina & age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
else if "`i'" == "Sweden" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 22 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/22 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n+17 if age_`iii'==mina
}
else {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii', replace
}
}
}
*By sex
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina & age_`iii'!=87.5
expand 20 if age_`iii'==87.5
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina & age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina & age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
else if "`i'" == "Sweden" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 22 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/22 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n+17 if age_`iii'==mina
}
else {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
gen sex = `iiii'
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach ii in dmd {
foreach iii in dm {
foreach iiii in 0 1 {
use `i', clear
keep if sex == `iiii'
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina & age_`iii'!=87.5
expand 20 if age_`iii'==87.5
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina & age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina & age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
else if "`i'" == "Sweden" {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 22 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/22 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n+17 if age_`iii'==mina
}
else {
egen mina = min(age_`iii')
expand 10 if age_`iii'!=mina
expand 40 if age_`iii'==mina
replace pys = pys/10 if age_`iii'!=mina
replace pys = pys/40 if age_`iii'==mina
bysort cal age : replace age = age+_n-6 if age_`iii'!=mina
bysort cal age : replace age = _n-1 if age_`iii'==mina
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
gen sex = `iiii'
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii'_`iiii', replace
}
}
}
}
}
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Ischaemic heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
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
if "`ii'" == "liv1" {
local oo = "Liver disease"
}
if "`ii'" == "liv2" {
local oo = "Liver disease (excluding alcoholic liver disease)"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
clear
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach iii in dm nondm {
append using MD/STD_`i'_`ii'_`iii'
}
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
preserve
bysort country : keep if _n == 1
forval i = 1/6 {
local C`i' = country[`i']
}
restore
if "`ii'" == "cvd" {
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C1'" & DM == "nondm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "nondm", color("`col1'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "nondm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "nondm", color("`col2'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "nondm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "nondm", color("`col3'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "nondm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "nondm", color("`col4'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "nondm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "nondm", color("`col5'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "nondm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "nondm", color("`col6'") lpattern(shortdash)) ///
, legend(symxsize(0.13cm) position(7) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(2 5 10 20 50, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C1'" & DM == "nondm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "nondm", color("`col1'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "nondm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "nondm", color("`col2'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "nondm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "nondm", color("`col3'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "nondm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "nondm", color("`col4'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "nondm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "nondm", color("`col5'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "nondm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "nondm", color("`col6'") lpattern(shortdash)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
}
graph save GPH/STD_GPH_`ii', replace
}
foreach ii in dmd {
if "`ii'" == "dmd" {
local oo = "Diabetes"
}
clear
foreach i in Australia Canada Finland France Lithuania Scotland {
foreach iii in dm {
append using MD/STD_`i'_`ii'_`iii'
}
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
preserve
bysort country : keep if _n == 1
forval i = 1/6 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii', replace
}
texdoc stlog close
texdoc stlog, cmdlog 
graph combine ///
GPH/STD_GPH_cvd.gph ///
GPH/STD_GPH_chd.gph ///
GPH/STD_GPH_cbd.gph ///
GPH/STD_GPH_hfd.gph ///
GPH/STD_GPH_can.gph ///
GPH/STD_GPH_dmd.gph ///
GPH/STD_GPH_inf.gph ///
GPH/STD_GPH_flu.gph ///
GPH/STD_GPH_res.gph ///
GPH/STD_GPH_liv1.gph ///
GPH/STD_GPH_liv2.gph ///
GPH/STD_GPH_ckd.gph ///
GPH/STD_GPH_azd.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(4)
texdoc graph, label(STDMRF) ///
caption(Crude mortality rate by age-grouping method, by cause of death. Australia. People with diabetes.)
texdoc stlog close

/***
\color{red}

What is wrong with Canada (Figure~\ref{STDMRF})?
It looks like the variation in person-years for people aged over 90 years with diabetes is large (Figure~\ref{Canpy}),
which is giving us weird confidence intervals. Also, the jump in 2020 seems implausible. 

Also, for Lithuania, the confidence intervals for HF go below zero because using Stata formula for confidence intervals. 
Need another formula, Bendix or Agus?

\color{Blue4}
***/

texdoc stlog, cmdlog
use Canada, clear
keep if age_dm > 90
collapse (sum) pys_dm, by(cal)
twoway ///
(scatter pys_dm cal, col(black)) ///
, graphregion(color(white)) ///
ytitle(Person-years) xtitle(Year) ///
ylabel(, angle(0))
texdoc graph, label(Canpy) ///
caption(Person-years  of follow-up among people aged 90 and above with diabetes in Canada)
texdoc stlog close

/***
\color{red}

To address both the Sweden and Canada problems, let's repeat the age-standardisation among people aged 40-90 only.
This introduce another problem though -- Scotland has an 80+ age group in people without diabetes 
for a large part of follow-up; for this, 
I'll predict rates as above, but drop the people above 90 after. 

\color{Blue4}
***/

cd /Users/jed/Documents/CM/



texdoc stlog, cmdlog
clear
foreach i in Australia Canada Finland France Lithuania Scotland {
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
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) angle(0)) ///
ytitle("Population size (millions)") xtitle("Age")
texdoc graph, label(ESP2010N) caption(European standard population in 2010)
restore
su(pys_dm)
gen age_dm_prop = pys_dm/r(sum)
su(A)
gen B = A/r(sum)
twoway ///
(bar age_dm_prop age_dm, color(dknavy%70)) ///
(bar B age_dm, color(magenta%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.04, angle(0) format(%9.2f)) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age")
texdoc graph, label(ESP2010P) caption(European standard population proportions in 2010)
keep age_dm B
replace age_dm = age-0.5
rename age_dm age
save refpop_1, replace
texdoc stlog close
texdoc stlog, cmdlog nodo
quietly {
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
foreach iii in dm nondm {
use `i', clear
collapse (sum) pys_dm-azd_d_nondm, by(country age_dm age_nondm calendar)
keep if inrange(age_`iii',40,90)
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
rename age_`iii' age
merge m:1 age using refpop_1
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii'_49, replace
}
}
}



foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach ii in dmd {
foreach iii in dm {
use `i', clear
collapse (sum) pys_dm-azd_d_nondm, by(country age_dm age_nondm calendar)
keep if inrange(age_`iii',40,90)
replace calendar = calendar-2010
gen coh = calendar-age_`iii'
centile(age_`iii'), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age_`iii', cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `ii'_d_`iii' agesp* timesp* cohsp*, exposure(pys_`iii')
keep calendar pys_`iii' age_`iii'
if "`i'" == "Scotland" & "`iii'" == "nondm" {
expand 10 if age_`iii'!=87.5
expand 20 if age_`iii'==87.5
replace pys = pys/10 if age_`iii'!=87.5
replace pys = pys/20 if age_`iii'==87.5
bysort cal age : replace age = age+_n-6 if age_`iii'!=87.5
bysort cal age : replace age = age+_n-8.5 if age_`iii'==87.5
drop if age_`iii' >= 90
}
else {
expand 10
replace pys = pys/10
bysort cal age : replace age = age+_n-6
}
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
rename age_`iii' age
merge m:1 age using refpop_1
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
replace lb = 0.001 if lb < 0
}
keep cal stdrate lb ub
gen country = "`i'"
gen OC = "`ii'"
gen DM = "`iii'"
replace cal = cal+2010
save MD/STD_`i'_`ii'_`iii'_49, replace
}
}
}



}
foreach ii in cvd chd cbd hfd can inf flu res liv1 liv2 ckd azd {
if "`ii'" == "cvd" {
local oo = "Cardiovascular disease"
}
if "`ii'" == "chd" {
local oo = "Ischaemic heart disease"
}
if "`ii'" == "cbd" {
local oo = "Cerebrovascular disease"
}
if "`ii'" == "hfd" {
local oo = "Heart failure"
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
if "`ii'" == "liv1" {
local oo = "Liver disease"
}
if "`ii'" == "liv2" {
local oo = "Liver disease (excluding alcoholic liver disease)"
}
if "`ii'" == "ckd" {
local oo = "Renal disease"
}
if "`ii'" == "azd" {
local oo = "Alzheimer's disease"
}
clear
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach iii in dm nondm {
append using MD/STD_`i'_`ii'_`iii'_49
}
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
preserve
bysort country : keep if _n == 1
forval i = 1/7 {
local C`i' = country[`i']
}
restore
if "`ii'" == "cvd" {
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'" & DM == "dm", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'" & DM == "dm", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C1'" & DM == "nondm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "nondm", color("`col1'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "nondm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "nondm", color("`col2'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "nondm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "nondm", color("`col3'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "nondm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "nondm", color("`col4'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "nondm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "nondm", color("`col5'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "nondm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "nondm", color("`col6'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C7'" & DM == "nondm", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'" & DM == "nondm", color("`col7'") lpattern(shortdash)) ///
, legend(symxsize(0.13cm) position(7) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(2 5 10 20 50, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'" & DM == "dm", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'" & DM == "dm", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C1'" & DM == "nondm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "nondm", color("`col1'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "nondm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "nondm", color("`col2'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "nondm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "nondm", color("`col3'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "nondm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "nondm", color("`col4'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "nondm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "nondm", color("`col5'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "nondm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "nondm", color("`col6'") lpattern(shortdash)) ///
(rarea ub lb calendar if country == "`C7'" & DM == "nondm", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'" & DM == "nondm", color("`col7'") lpattern(shortdash)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
}
graph save GPH/STD_GPH_`ii'_49, replace
}
foreach ii in dmd {
if "`ii'" == "dmd" {
local oo = "Diabetes"
}
clear
foreach i in Australia Canada Finland France Lithuania Scotland Sweden {
foreach iii in dm {
append using MD/STD_`i'_`ii'_`iii'_49
}
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
preserve
bysort country : keep if _n == 1
forval i = 1/7 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea ub lb calendar if country == "`C1'" & DM == "dm", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'" & DM == "dm", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'" & DM == "dm", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'" & DM == "dm", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'" & DM == "dm", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'" & DM == "dm", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'" & DM == "dm", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'" & DM == "dm", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'" & DM == "dm", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'" & DM == "dm", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'" & DM == "dm", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'" & DM == "dm", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'" & DM == "dm", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'" & DM == "dm", color("`col7'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.1f) grid angle(0)) ///
yscale(log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Mortality rate (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oo'", placement(west) color(black) size(medium))
graph save GPH/STD_GPH_`ii'_49, replace
}
texdoc stlog close
texdoc stlog, cmdlog 
graph combine ///
GPH/STD_GPH_cvd_49.gph ///
GPH/STD_GPH_chd_49.gph ///
GPH/STD_GPH_cbd_49.gph ///
GPH/STD_GPH_hfd_49.gph ///
GPH/STD_GPH_can_49.gph ///
GPH/STD_GPH_dmd_49.gph ///
GPH/STD_GPH_inf_49.gph ///
GPH/STD_GPH_flu_49.gph ///
GPH/STD_GPH_res_49.gph ///
GPH/STD_GPH_liv1_49.gph ///
GPH/STD_GPH_liv2_49.gph ///
GPH/STD_GPH_ckd_49.gph ///
GPH/STD_GPH_azd_49.gph ///
, graphregion(color(white)) cols(3) altshrink xsize(4)
texdoc graph, label(STDMRF) ///
caption(Crude mortality rate by age-grouping method, by cause of death. Australia. People with diabetes.)
texdoc stlog close














/***
\color{black}

\clearpage
\subsection{Annual percent changes}


\clearpage
\section{Cause-specific standardised mortality ratios}

 We calculated the standardised mortality ratio (SMR) by 
calculating the ratio of the observed number of deaths in the diabetes population to the expected 
number if mortality was the same as in the population without diabetes. An SMR of 1 implies 
identical mortality in people with and without diabetes.

We modelled the SMR similarly to how we modelled the mortality rates, 
using Poisson regression for multiplicative models with observed number 
of deaths as the outcome and the log(expected number of deaths) as the offset. 
We modelled SMR by fitting models with a linear effect of calendar time for each data source, 
providing an overall summary of the annual changes in SMR by sex for each data source. 
A description of statistical models used is in the appendix (pp 5–7).

\color{Blue4}
***/


/***
\color{black}

\clearpage
\bibliography{/Users/jed/Documents/Library.bib}
\end{document}
***/

texdoc close
