
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
mkdir GPH
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
quietly replace `i'_d_pop = runiformint(1,9) if `i'_d_pop==.
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

A few suspected coding changes to note:
\begin{itemize}
\item Figure~\ref{CR2_Australia}, renal disease in 2013. 
\item Figure~\ref{CR1_Finland}, heart failure: while gradual, there is a massive decline in heart failure to near-zero by 2017. 
This suggests to me that coding practices could have changed over time to not include HF as the primary cause of death. 
\item Figure~\ref{CR2_Finland}, influenze and pneumonia from 2000-2005.
\item Figure~\ref{CR2_Scotland}, renal disease in 2017.
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
fit separately in people with and without diabetes and by sex. 

These models will be used to predict mortality rates for single year ages and calendar years.
These predicted rates will first be plotted by age and period, then used to generate
age-standardised rates in people with and without diabetes, using direct standardisation
(using the total diabetes population formed by pooling the consortium data) by period. 

Then, to generate an overall estimate of trends over time, we will fit a model with spline
effects of age but a linear effect of period and calculate the annual percent change for 
each data source in people with and without diabetes, by sex. 


\color{Blue4}
***/

use Australia, clear




cd /Users/jed/Documents/CM/



/***
\color{black}

\clearpage
\subsection{Age- and period-specific rates}

\subsection{Age-standardised rates}

\subsection{Annual percent changes}



\color{Blue4}
***/



/***
\color{black}


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
