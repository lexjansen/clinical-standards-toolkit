%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcetodefine                                                          *;
%*                                                                                *;
%* Populates most of the tables in the SAS representation of Define-XML V2.1      *;
%*                                                                                *;
%* This macro extracts data from the metadata files (_cstSource*) and converts    *;
%* the metadata into a subset of all of the tables in the SAS representation of   *;
%* the Define-XML V2.1 model.                                                     *;
%*                                                                                *;
%* These Define-XML core tables are populated:                                    *;
%*                                                                                *;
%*      aliases                                                                   *;
%*      annotatedcrfs                                                             *;
%*      codelistitems                                                             *;
%*      codelists                                                                 *;
%*      commentdefs                                                               *;
%*      definedocument                                                            *;
%*      documentrefs                                                              *;
%*      enumerateditems                                                           *;
%*      externalcodelists                                                         *;
%*      itemdefs                                                                  *;
%*      itemgroupdefs                                                             *;
%*      itemgroupitemrefs                                                         *;
%*      itemgroupleaf                                                             *;
%*      itemgroupleaftitles                                                       *;
%*      itemorigin                                                                *;
%*      itemrefwhereclauserefs                                                    *;
%*      itemvaluelistrefs                                                         *;
%*      mdvleaf                                                                   *;
%*      mdvleaftitles                                                             *;
%*      metadataversion                                                           *;
%*      methoddefs                                                                *;
%*      pdfpagerefs                                                               *;
%*      standards                                                                 *;
%*      study                                                                     *;
%*      supplementaldocs                                                          *;
%*      translatedtext                                                            *;
%*      valuelistitemrefs                                                         *;
%*      valuelists                                                                *;
%*      whereclausedefs                                                           *;
%*      whereclauserangechecks                                                    *;
%*      whereclauserangecheckvalues                                               *;
%*                                                                                *;
%* The following tables will also be created when the macro parameter             *;
%* _cstSourceAnalysisResults has a value:                                         *;
%*                                                                                *;
%*      analysisdataset                                                           *;
%*      analysisdatasets                                                          *;
%*      analysisdocumentation                                                     *;
%*      analysisprogrammingcode                                                   *;
%*      analysisresultdisplays                                                    *;
%*      analysisresults                                                           *;
%*      analysisvariables                                                         *;
%*      analysiswhereclauserefs                                                   *;
%*                                                                                *;
%* The metadata source is specified in a SASReferences file.                      *;
%*                                                                                *;
%* @macvar _cst_rc Task error status                                              *;
%* @macvar _cst_rcmsg Message associated with _cst_rc                             *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%* @macvar _cstSASRefs Run-time SASReferences data set derived in process setup   *;
%* @macvar _cstTrgStandardVersion The standard version of interest, defined in    *;
%*             the calling driver module                                          *;
%* @macvar _cstVersion Version of the SAS Clinical Standards Toolkit              *;
%*                                                                                *;
%* @param  _cstOutLib - required - The library to write the Define-XML data sets. *;
%* @param  _cstSourceStudy - required - The data set that contains the metadata   *;
%*             for the studies to include in the Define-XML file.                 *;
%* @param  _cstSourceStandards - required - The data set that contains the        *;
%*             metadata for the standards to include in the Define-XML file.      *;
%* @param  _cstSourceTables - required - The data set that contains the metadata  *;
%*             for the domains to include in the Define-XML file.                 *;
%* @param  _cstSourceColumns - required - The data set that contains the metadata *;
%*             for the Domain columns to include in the Define-XML file.          *;
%* @param  _cstSourceCodeLists - optional - The data set that contains the        *;
%*             metadata for the CodeLists to include in the Define-XML file.      *;
%* @param  _cstSourceValues  - optional - The data set that contains the metadata *;
%*             for the Value Level columns to include in the Define-XML file      *;
%* @param  _cstSourceDocuments - optional - The data set that contains the        *;
%*             metadata for document references to include in the Define-XML file.*;
%* @param _cstSourceAnalysisResults - optional - The data set that contains the   *;
%*            source analysis results metadata to include in the Define-XML file. *;
%* @param  _cstFullModel - required - Create all data sets in the Define-XML      *;
%*             model (Y) or only the core model (N)                               *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstCheckLengths - required - Check the actual value lengths of         *;
%*            variables with DataType=text against the lengths defined in the     *;
%*            metadata templates. If the lengths are short, a warning is written  *;
%*            to the log file and the Results data set.                           *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%*                                                                                *;
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added _cstSourceStandards parameter                        *;
%*                                                                                *;
%* @param _cstLang - optional - The ODM TranslatedText/@lang attribute.           *;
%* @since 1.4                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcetodefine(
    _cstOutLib=,
    _cstSourceStudy=,
    _cstSourceStandards=,
    _cstSourceTables=,
    _cstSourceColumns=,
    _cstSourceCodelists=,
    _cstSourceValues=,
    _cstSourceDocuments=,
    _cstSourceAnalysisResults=,
    _cstFullModel=N,
    _cstCheckLengths=N,
    _cstLang=en
    ) / des='CST: Build Define-XML datasets from source';

    %local
      _cstExpSrcTables
      _cstMissing
      _cstZero
      _cstReadOnly
      _cstRandom
      _cstSrcData

      _cstResultSeq
      _cstSeqCnt
      _cstUseResultsDS

      _cstThisMacro
      _cst_thisrc
      _cst_thisrcmsg
    ;

    %let _cstThisMacro=&sysmacroname;
    %let _cstSrcData=&sysmacroname;
    %let _cst_thisrc=0;
    %let _cst_thisrcmsg=;
 
    %let _cstResultSeq=1;
    %let _cstSeqCnt=0;
    %let _cstUseResultsDS=0;
    
    %let _cstExpSrcTables=_cstSourceStudy _cstSourceStandards _cstSourceTables _cstSourceColumns;

    %* Reporting will be to the CST results data set if available, otherwise to the SAS log.  *;  
    %if (%symexist(_cstResultsDS)=1) %then 
    %do;
      %if (%sysfunc(exist(&_cstResultsDS))) %then 
      %do;
        %let _cstUseResultsDS=1;
        %******************************************************;
        %*  Create a temporary messages data set if required  *;
        %******************************************************;
        %cstutil_createTempMessages(_cstCreationFlag=_cstNeedToDeleteMsgs);
      %end;
    %end;

    %***************************************************;
    %*  Check for existence of _cst_rc macro variable  *;
    %***************************************************;
    %if ^%symexist(_cst_rc) %then 
    %do;
      %global _cst_rc _cst_rcmsg;
    %end;
  
    %let _cst_rc=0;
    %let _cst_rcmsg=;


    %******************************************************************************;
    %* Parameter checks                                                           *;
    %******************************************************************************;
    %let _cstMissing=;
    %do i=1 %to %sysfunc(countw(&_cstExpSrcTables));
       %let _cstTable=%scan(&_cstExpSrcTables, &i);
       %if %sysevalf(%superq(&_cstTable)=, boolean) %then %let _cstMissing = &_cstMissing &_cstTable;
    %end;
    %if %sysevalf(%superq(_cstOutLib)=, boolean) %then %let _cstMissing = &_cstMissing _cstOutLib;
    %if %sysevalf(%superq(_cstFullModel)=, boolean) %then %let _cstMissing = &_cstMissing _cstFullModel;
    %if %sysevalf(%superq(_cstCheckLengths)=, boolean) %then %let _cstMissing = &_cstMissing _cstCheckLengths;

    %if %length(&_cstMissing) gt 0
      %then %do;
        %let _cst_thisrc=1;
        %let _cst_thisrcmsg=Required macro parameter(s) missing: &_cstMissing;
        %goto exit_macro;
      %end;

    %if "%upcase(&_cstFullModel)" ne "Y" and "%upcase(&_cstFullModel)" ne "N"
      %then %do;
        %let _cst_thisrc=1;
        %let _cst_thisrcmsg=Invalid _cstFullModel value (&_cstFullModel): should be Y or N;
        %goto exit_macro;
      %end;

    %if "%upcase(&_cstCheckLengths)" ne "Y" and "%upcase(&_cstCheckLengths)" ne "N"
      %then %do;
        %let _cst_thisrc=1;
        %let _cst_thisrcmsg=Invalid _cstCheckLengths value (&_cstCheckLengths): should be Y or N;
        %goto exit_macro;
      %end;

    %****************************************************************************;
    %*  Pre-requisite: Expected source data sets                                *;
    %****************************************************************************;
    %let _cstMissing=;
    %do i=1 %to %sysfunc(countw(&_cstExpSrcTables));
      %let _cstTable=%scan(&_cstExpSrcTables, &i);
      %if not %sysfunc(exist(&&&_cstTable)) %then
        %let _cstMissing = &_cstMissing &&&_cstTable;
    %end;

    %if %length(&_cstMissing) gt 0
      %then %do;
        %let _cst_thisrc=1;
        %let _cst_thisrcmsg=Expected source data set(s) not existing: &_cstMissing;
        %goto exit_macro;
      %end;

    %let _cstZero=;
    %do i=1 %to %sysfunc(countw(&_cstExpSrcTables));
      %let _cstTable=%scan(&_cstExpSrcTables, &i);
      %if %cstutilnobs(_cstDatasetName=&&&_cstTable) eq 0 %then
        %let _cstZero = &_cstZero &&&_cstTable;
    %end;

    %if %length(&_cstZero) gt 0
      %then %do;
        %let _cst_thisrc=1;
        %let _cst_thisrcmsg=Expected source data set(s) have 0 observations: &_cstZero;
        %goto exit_macro;
      %end;

    %****************************************************************************;
    %*  Pre-requisite: Check that the output libref is assigned                 *;
    %****************************************************************************;
    %if (%sysfunc(libref(&_cstOutLib))) %then
    %do;
      %let _cst_thisrc=1;
      %let _cst_thisrcmsg=The output libref(&_cstOutLib) is not assigned.;
      %goto exit_macro;
    %end;

    %****************************************************************************;
    %*  Pre-requisite: Check that the output libref is not read-only            *;
    %****************************************************************************;
    %let _cstReadOnly=;
    proc sql noprint;
     select readonly into :_cstReadOnly 
     from sashelp.vlibnam
     where upcase(libname) = "%upcase(&_cstOutLib)"
     ;
    quit;
    %let _cstReadOnly=&_cstReadOnly;

    %if %upcase(&_cstReadOnly)=YES %then
    %do;
      %let _cst_thisrc=1;
      %let _cst_thisrcmsg=The output libref(&_cstOutLib) is readonly.;
      %goto exit_macro;
    %end;
    
    %****************************************************************************;

    %cstutil_getRandomNumber(_cstVarname=_cstRandom);

    %*************************************************************;
    %* Write information to the results data set about this run. *;
    %*************************************************************;
    %* Write information about this process to the results data set  *;
    %if %symexist(_cstResultsDS) %then
    %do;
       %cstutilwriteresultsintro(_cstProcessType=SOURCE TO DEFINE-XML);
    %end;


    %* create Define-XML sastables;
    %if %upcase(&_cstFullModel)=N %then %do;
      %if %sysevalf(%superq(_cstSourceAnalysisResults)=, boolean) %then %do;      
        %* Do not create table for Analysis Results Metadata;
        %cst_createtablesfordatastandard(
          _CSTSTANDARD=&_cstStandard,
          _CSTOUTPUTLIBRARY=&_cstOutLib,
          _cstWhereClause=%nrstr(where upcase(tablecore) ne 'EXT' and not(upcase(standardref)=:"ARM"))
        );
      %end;
      %else %do;
        %cst_createtablesfordatastandard(
          _CSTSTANDARD=&_cstStandard,
          _CSTOUTPUTLIBRARY=&_cstOutLib,
          _cstWhereClause=%nrstr(where upcase(tablecore) ne 'EXT')
        );
      %end;
    %end;
    %else %do;
      %cst_createtablesfordatastandard(
        _CSTSTANDARD=&_cstStandard,
        _CSTOUTPUTLIBRARY=&_cstOutLib
      );
    %end;


    %*************************************************************;
    %* Map Study source metadata                                 *;
    %*************************************************************;
    %define_sourcestudy(
        _cstSourceStudy=&_cstSourceStudy,
        _cstOutputLibrary=&_cstOutLib,
        _cstCheckLengths=&_cstCheckLengths,
        _cstReturn=_cst_thisrc,
        _cstReturnMsg=_cst_thisrcmsg
        );
    %if &_cst_thisrc %then %goto exit_macro;

    %*************************************************************;
    %* Map Standard source metadata                              *;
    %*************************************************************;
    %define_sourcestandards(
        _cstSourceStandards=&_cstSourceStandards,
        _cstOutputLibrary=&_cstOutLib,
        _cstCheckLengths=&_cstCheckLengths,
        _cstReturn=_cst_thisrc,
        _cstReturnMsg=_cst_thisrcmsg
        );
    %if &_cst_thisrc %then %goto exit_macro;

    %*************************************************************;
    %* Map Table source metadata                                 *;
    %*************************************************************;
    %define_sourcetables(
        _cstSourceTables=&_cstSourceTables,
        _cstOutputLibrary=&_cstOutLib,
        _cstCheckLengths=&_cstCheckLengths,
        _cstLang=&_cstLang,
        _cstReturn=_cst_thisrc,
        _cstReturnMsg=_cst_thisrcmsg
        );
    %if &_cst_thisrc %then %goto exit_macro;


    %*************************************************************;
    %* Map Study Columns metadata                                *;
    %*************************************************************;
    %define_sourcecolumns(
        _cstSourceColumns=&_cstSourceColumns,
        _cstSourceTables=&_cstSourceTables,
        _cstOutputLibrary=&_cstOutLib,
        _cstCheckLengths=&_cstCheckLengths,
        _cstLang=&_cstLang,
        _cstReturn=_cst_thisrc,
        _cstReturnMsg=_cst_thisrcmsg
        );
    %if &_cst_thisrc %then %goto exit_macro;

    %*************************************************************;
    %* Map CodeList source metadata                              *;
    %*************************************************************;
    %if %sysevalf(%superq(_cstSourceCodeLists)=, boolean)=0 %then %do;
      %define_sourcecodelists(
          _cstSourceCodelists=&_cstSourceCodeLists,
          _cstSourceTables=&_cstSourceTables,
          _cstSourceColumns=&_cstSourceColumns,
          _cstSourceValues=&_cstSourceValues,
          _cstOutputLibrary=&_cstOutLib,
          _cstCheckLengths=&_cstCheckLengths,
          _cstLang=&_cstLang,
          _cstReturn=_cst_thisrc,
          _cstReturnMsg=_cst_thisrcmsg
          );
      %if &_cst_thisrc %then %goto exit_macro;
    %end;

    %*************************************************************;
    %* Map Study Value Level metadata                            *;
    %*************************************************************;
    %if %sysevalf(%superq(_cstSourceValues)=, boolean)=0 %then %do;
      %define_sourcevalues(
          _cstSourceValues=&_cstSourceValues,
          _cstSourceTables=&_cstSourceTables,
          _cstSourceColumns=&_cstSourceColumns,
          _cstOutputLibrary=&_cstOutLib,
          _cstCheckLengths=&_cstCheckLengths,
          _cstLang=&_cstLang,
          _cstReturn=_cst_thisrc,
          _cstReturnMsg=_cst_thisrcmsg
          );
      %if &_cst_thisrc %then %goto exit_macro;
    %end;

    %*************************************************************;
    %* Map Analysis Results source metadata                      *;
    %*************************************************************;
    %if %sysevalf(%superq(_cstSourceAnalysisResults)=, boolean)=0 %then %do;
      %define_sourceanalysisresults(
          _cstSourceAnalysisResults=&_cstSourceAnalysisResults,
          _cstOutputLibrary=&_cstOutLib,
          _cstCheckLengths=&_cstCheckLengths,
          _cstLang=&_cstLang,
          _cstReturn=_cst_thisrc,
          _cstReturnMsg=_cst_thisrcmsg
      );
      %if &_cst_thisrc %then %goto exit_macro;
    %end;
    
    %*************************************************************;
    %* Map Document source metadata                              *;
    %*************************************************************;
    %if %sysevalf(%superq(_cstSourceDocuments)=, boolean)=0 %then %do;
      %define_sourcedocuments(
          _cstSourceDocuments=&_cstSourceDocuments,
          _cstSourceTables=&_cstSourceTables,
          _cstSourceColumns=&_cstSourceColumns,
          _cstSourceValues=&_cstSourceValues,
          _cstSourceAnalysisResults=&_cstSourceAnalysisResults,
          _cstOutputLibrary=&_cstOutLib,
          _cstCheckLengths=&_cstCheckLengths,
          _cstLang=&_cstLang,
          _cstReturn=_cst_thisrc,
          _cstReturnMsg=_cst_thisrcmsg
      );
      %if &_cst_thisrc %then %goto exit_macro;
    %end;
    


%exit_macro:

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
  %if &_cst_thisrc %then %do;
    %if (&_cstUseResultsDS=1) %then 
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DEF0099
                  ,_cstResultParm1=&_cst_thisrcmsg
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstThisMacro
                  ,_cstResultFlagParm=&_cst_thisrc
                  ,_cstRCParm=&_cst_thisrc
                  );
    %end;
    
    %if %length(&_cst_thisrcmsg) ne 0 %then %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): &_cst_thisrcmsg;

  %end;

  %* Persist the results if specified in sasreferences  *;
  %cstutil_saveresults();

  %let _cst_rc=&_cst_thisrc;
  %let _cst_rcmsg=&_cst_thisrcmsg;

%mend define_sourcetodefine;
