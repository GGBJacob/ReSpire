%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                %
%                                   szablonPG.cls                                %
%                                                                                %
% 	 Szablon pracy dyplomowej zgodny z wymaganiami edytorskimi przedstawionymi   %
%				 w Zarz¹dzeniu Rektora PG nr 22/2018 z 20 czerwca 2018 r.		 %
%                                                                                %
%  							(c) 2019 Jakub Maksymiuk                             %					
%		 							 Paweł Spławski							     %
%									 Paweł Zarembski							 %
%								   	 Kamil Andrzejewski							 %
%                                                                                %
%                                         										 %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%--------------------------------------------------------------------
% Zdeklarowanie opcji 
%--------------------------------------------------------------------

\newif\ifnostrict

\DeclareOption{strict}{\nostrictfalse }
\DeclareOption{nostrict}{\nostricttrue }
\ProcessOptions \relax

%--------------------------------------------------------------------
% Pobranie ustawień podstawowej klasy dokumentu - klasa report
%--------------------------------------------------------------------

\LoadClass[
  a4paper,                      % format A4
  10pt,                         % rozmiar czcionki
  oneside,                      % druk jednostronny
  notitlepage,                  % brak strony tytułowej
  openright,                    % orientacja otwierania dokumentu
]{report}

%--------------------------------------------------------------------
% Ustawienie domyślnego języka i kodowania
%--------------------------------------------------------------------

\usepackage[utf8]{inputenc}    
\usepackage[T1]{fontenc}        
\usepackage[polish]{babel}

%--------------------------------------------------------------------
% Podstawowa czcionka - Helvetica (Zamiennik dla czcionki Arial)
%--------------------------------------------------------------------

\RequirePackage{helvet}
\renewcommand{\familydefault}{\sfdefault}

%--------------------------------------------------------------------
% Ustawienie interlinii
%--------------------------------------------------------------------

\linespread{1.3} % 1.3 odpowiada interlinii 1.5, 1.6 dla interlinii 2

%--------------------------------------------------------------------
% Ustawienie marginesów
%--------------------------------------------------------------------

\RequirePackage[%
    margin=2.5cm,
    a4paper,
    bindingoffset=1cm
]{geometry}

%--------------------------------------------------------------------
% Ustawienia akapitów
%--------------------------------------------------------------------

\RequirePackage{indentfirst}

\setlength{\parindent}{0.9cm}

%--------------------------------------------------------------------
% Numeracja stron 
%--------------------------------------------------------------------

\pagenumbering{arabic}

\RequirePackage{fancyhdr}

\fancypagestyle{plain}{
  \fancyhf{}
  \fancyfoot[C]{\fontsize{9pt}{9pt}\selectfont\thepage}%
   \renewcommand{\headrulewidth}{0.0pt}
}

\pagestyle{plain}

%--------------------------------------------------------------------
% Ustawienia nagłówków
%--------------------------------------------------------------------
\RequirePackage[explicit, clearempty]{titlesec}

% konfiguracja dla tytułu rozdziału
\titleformat{\chapter}[hang]                    
{\bfseries\fontsize{12pt}{24pt}\selectfont}
{\thechapter.\quad}
{0pt}
{\MakeUppercase{#1}}
\titlespacing*{\chapter}{0pt}{0pt}{6pt}

% konfiguracja dla tytułu podrozdziału
\titleformat{\section}                          
{\fontsize{11pt}{22pt}\selectfont\bfseries\itshape}
{\thesection.\quad}
{0pt}
{#1}
\titlespacing{\section}{0pt}{6pt}{6pt}

% konfiruacja dla pod-podrozdziałów
\titleformat{\subsection}                      
{\normalfont\itshape}
{\thesubsection.\quad}
{0pt}
{#1}
\titlespacing{\subsection}{0pt}{6pt}{6pt}

%--------------------------------------------------------------------
% Spis treści - konfiguracja 
%--------------------------------------------------------------------

\RequirePackage{titletoc}

% ustawienia dla rozdziałów w spisie treści
\titlecontents{chapter}
    [0em] % no indentation
    {}
    {\contentslabel[\thecontentslabel.]{1em}} 
    {\hspace*{-1em}}                         
    {\dotfill\contentspage}
    
% ustawienia dla podrozdziałów w spisie treści
\titlecontents{section}
    [2em] % ie, 1.5em (chapter) + 0.5em
    {}
    {\contentslabel[\thecontentslabel.]{2em}}  
    {\hspace*{-2.3em}}                          
    {\dotfill\contentspage}

% ustawienia dla pod-podrozdziałów w spisie treści
\titlecontents{subsection}
    [5em] % ie, 2em (section) + 3em
    {}
    {\contentslabel[\thecontentslabel.]{3em}}  
    {\hspace*{-2.3em}}                        
    {\dotfill\contentspage}
%--------------------------------------------------------------------
% Konfiguracja list numerowanych i nienumerowanych
%--------------------------------------------------------------------

\RequirePackage{enumitem}

\setenumerate{
    topsep=0pt,
    nolistsep,
    noitemsep,
    }
\setenumerate[1]{label=\arabic*.}  
\setenumerate[2]{label=\alph*)}     

\setitemize{
    topsep=0pt,
    noitemsep,
    nolistsep,
}


%--------------------------------------------------------------------
% Konfiguracja prezentacji aparatu matematycznego
%--------------------------------------------------------------------

\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{amsthm}


%%%%%%%% Środowiska twierdzeń %%%%%%%%
\newtheoremstyle{SPPG_th1}% hname
{10pt plus5pt minus2pt}% hSpace above
{10pt plus3pt}% hSpace below
{}% hBody font
{}% hIndent amount
{\bfseries}% hTheorem head font
{.}% hPunctuation after theorem head
{.5em}% hSpace after theorem head
{}% hTheorem head spec 
\theoremstyle{SPPG_th1}

\newtheorem{definicja}{Definicja}[chapter]
\newtheorem{twierdzenie}[definicja]{Twierdzenie}
\newtheorem{lemat}[definicja]{Lemat}
\newtheorem{fakt}[definicja]{Fakt}
\newtheorem{wniosek}[definicja]{Wniosek}
\newtheorem{przyklad}[definicja]{Przykład}

%--------------------------------------------------------------------
% Konfiguracja obrazków oraz tabel
%--------------------------------------------------------------------
\RequirePackage{subfig}
\RequirePackage[unicode=true]{hyperref}
\RequirePackage{setspace}
\RequirePackage[skip=2pt]{caption}
\RequirePackage{pdfpages}
\RequirePackage{multicol} % do składu w dwóch kolumnach
\RequirePackage{color}
\RequirePackage{wrapfig}
\RequirePackage{graphicx} 
\usepackage{etoolbox}	


% Modyfikacja podpisu rysunków i tabel  (zmiana na Rys. X niepogrubione)
% Separator po identyfikatorze rysunku
\renewcommand{\figurename}{Rys.}
\DeclareCaptionLabelSeparator{dot}{. }
\captionsetup[figure]{justification=centering,labelfont=md} % centrowanie podpisu rysunku
\captionsetup[figure]{labelsep=dot} % kropka jako separator, bez pogrubiania
\captionsetup[table]{labelsep=dot} % kropka jako separator, bez pogrubiania

% Zmniejszenie czcionki oraz interlinii w podpisach
\captionsetup{font={small,stretch=1.0}}

\setlength{\intextsep}{3mm}		 % odległości separacji tekstu od rysunków/tabel
\setlength{\textfloatsep}{3mm}


%--------------------------------------------------------------------
% Dodatkowe ustawienia
%--------------------------------------------------------------------
 
\renewcommand\bibname{Wykaz literatury} % Zamiana na tytuł "Wykaz literatury"

% Zmiana na tytuł "Wykaz rysunków"
\renewcommand{\listfigurename}{Wykaz rysunków}

% Zmiana na tytuł "Wykaz tabel"
\renewcommand{\listtablename}{Wykaz tabel}

% Brak "wdów" i "sierot"
\widowpenalty10000
\clubpenalty10000

% Nazwy rozdziałów w Spisie treści WIELKIMI LITERAMI
\makeatletter
\renewcommand\chapter{\if@openright\cleardoublepage\else\clearpage\fi
                    \thispagestyle{plain}%
                    \global\@topnum\z@
                    \@afterindentfalse
                    \secdef\@chapter\@schapter}
\def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne
                       \if@mainmatter
                         \refstepcounter{chapter}%
                         \typeout{\@chapapp\space\thechapter.}%
                         \addcontentsline{toc}{chapter}%
                         {\protect\numberline{\thechapter}\texorpdfstring{\MakeUppercase{#1}}{#1}}%
                       \else
                       \addcontentsline{toc}{chapter}{\texorpdfstring{\MakeUppercase{#1}}{#1}}%
                       \fi
                    \else
                    \addcontentsline{toc}{chapter}{\texorpdfstring{\MakeUppercase{#1}}{#1}}%
                    \fi
                    \chaptermark{#1}%
                    \addtocontents{lof}{\protect\addvspace{10\p@}}%
                    \addtocontents{lot}{\protect\addvspace{10\p@}}%
                    \if@twocolumn
                      \@topnewpage[\@makechapterhead{#2}]%
                    \else
                      \@makechapterhead{#2}%
                      \@afterheading
                    \fi}
\makeatother