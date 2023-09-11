
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
**# Bookmark #1
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

I change the diabetes deaths after assigning randomly to the total pop deaths if the diabetes deaths
are greater. This only really has an effect on HF and alzherimer's deaths at low ages. 

For Australia, three age groups have been provided because of small cell counts with smaller
age groups. My intuition is to use the most granular age group data and simply fill the missing
counts randomly, as I suspect this will have very little effect on the overall trends, which will be driven
by the age groups for which there are lots of deaths. I will check this below.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
cd /Users/jed/Documents/CM/
mkdir GPH
import delimited "Consortium COD database v1.csv", clear
keep if substr(country,1,9)=="Australia"
drop if cal < 2005
rename sex SEX
gen sex = 0 if SEX == "F"
replace sex = 1 if SEX == "M"
replace pys_nondm = pys_totpop-pys_dm
set seed 3488717
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
replace dmd_d_dm = dmd_d_pop if dmd_d_dm > dmd_d_pop
foreach i in cvd chd cbd  hfd can dmd inf flu res liv1 liv2 ckd azd {
quietly replace `i'_d_nondm = `i'_d_pop-`i'_d_dm
}

**PICKUP -- figure out the ranom replacement so we're getting an even spread

*So, the two to investigate are HF and AZD:
texdoc stlog cmdlog nodo
preserve
gen agegp = 1 if age_gp1!=""
replace agegp = 2 if age_gp3!=""
replace agegp = 3 if age_gp4!=""
collapse (sum) pys_dm pys_nondm cvd_d_dm-azd_d_dm cvd_d_nondm-azd_d_nondm, by(calendar agegp)
foreach i in cvd chd cbd hfd can dmd inf flu res liv1 liv2 ckd azd {
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
title("Diabetes, Heart failure", placement(west) size(medium) col(black))
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
caption(Crude mortality rate by age-grouping method, by cause of death. Australia.)
texdoc stlog close




/***
\color{black}


\clearpage
\section{Crude rates}



\color{Blue4}
***/


/***
\color{black}

\clearpage
\bibliography{/Users/jed/Documents/Library.bib}
\end{document}
***/

texdoc close
