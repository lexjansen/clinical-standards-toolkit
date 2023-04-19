%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* cstutilmigrate_define20_21.sas                                                 *;
%*                                                                                *;
%* Migrates source metadata data sets from Define-XML v2.0 to Define-XML v2.1.    *;
%*                                                                                *;
%* Assumptions:                                                                   *;
%*   1. The librefs in the macro parameters have been allocated.                  *;
%*   2. If _cstSrcDS exists in the _cstTrgLib, it is overwritten.                 *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%*                                                                                *;
%* @param  _cstSrcLib - required - The libname for the Define-XML v2.0 source     *;
%*            metadata data set to migrate to Define-XML version 2.               *;
%* @param  _cstSrcDS - required - The name of the Define-XML v2.0 source          *;
%*            metadata data set to migrate to Define-XML version 2.               *;
%* @param  _cstSrcType - conditionally required - The type of the CRT-DDS version *;
%*            1 source metadata data set to migrate to Define-XML version 2.      *;
%*            Required in case _cstSrcDS does not have one of the values:         *;
%*              source_study, source_standards, source_tables, source_columns,    *;
%*              source_values,source_codelists, source_documents                  *;
%*            Values: study | standard | table| column | value | codelist |       *;
%*                     document | analysisresult                                  *;
%* @param  _cstTrgDS - required - The (libname.)member for the Define-XML         *;
%*            version 2 metadata data set to migrate from Define-XML v2.0.        *;
%* @param  _cstStudyVersion - required - The study identifier to use to bind      *;
%*            together the source data sets and as ODM/Study/MetaDataVersion/@OID *;
%*            in the define.xml file.                                             *;
%* @param  _cstTrgStandard - optional - The target standard. This value is used   *;
%*            for some standard-specific checking and migration.                  *;
%*            Values: CDISC-ADAM | CDISC-SDTM | CDISC-SEND                        *;
%* @param  _cstTrgStandardVersion - optional - The target standard version.       *;
%* @param  _cstReturn - required - The macro variable that contains the return    *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param  _cstReturnMsg - required - The macro variable that contains the return *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro cstutilmigrate_define20_21(
  _cstSrcLib=,
  _cstSrcDS=,
  _cstSrcType=, 
  _cstTrgDS=,
  _cstStudyVersion=, 
  _cstTrgStandard=, 
  _cstTrgStandardVersion=,
  _cstCheckValues=N,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des = "CST: migrate source metadata data sets";

  %local i 
    _cstReqParams 
    _cstReqParam 
    _cstRandom 
    _cstVars
    _cstTrgLib 
    _cstRecs

    _cstResultSeq
    _cstSeqCnt
    _cstUseResultsDS

    _cstThisMacro
    ;

  %let _cstThisMacro=&sysmacroname;
  %let _cstSrcData=&sysmacroname;

  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstUseResultsDS=0;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then %do;
    %* We are not able to communicate other than to the LOG;
    %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG can not be missing.;
    %goto exit_macro_nomsg;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;

  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));

  %if (%eval(not %symexist(_cstTrgStandard))) or
      (%eval(not %symexist(_cstTrgStandardVersion))) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstTrgStandard and _cstTrgStandardVersion must be specified as global macro variables.;
    %goto exit_macro;
  %end;

  %* Rule: _cstTrgStandard and _cstTrgStandardVersion must be specified  *;
  %if %sysevalf(%superq(_cstTrgStandard)=, boolean) or
      %sysevalf(%superq(_cstTrgStandardVersion)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstTrgStandard and _cstTrgStandardVersion must be specified as global macro variables.;
    %goto exit_macro;
  %end;

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

  %* Write information to the results data set about this run. *;
  %if %symexist(_cstResultsDS) %then
  %do;
    %cstutilwriteresultsintro(_cstResultID=DEF0097, _cstProcessType=FILEIO);
  %end;

  %******************************************************************************;
  %* Parameter checks                                                           *;
  %******************************************************************************;

  %* Check required parameters;
  %let _cstReqParams=_cstSrcLib _cstSrcDS _cstTrgDS _cstStudyVersion _cstCheckValues;
  %do i=1 %to %sysfunc(countw(&_cstReqParams));
     %let _cstReqParam=%kscan(&_cstReqParams, &i);
     %if %sysevalf(%superq(&_cstReqParam)=, boolean) %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=&_cstReqParam parameter value is required.;
        %goto exit_macro;
     %end;
  %end;

  %* This logic is needed to maintain backward compatibility because of the new _cstSrcType parameter;
  %if %sysevalf(%superq(_cstSrcType)=, boolean) %then %do;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_STUDY" %then %let _cstSrcType=study;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_STANDARD" %then %let _cstSrcType=standard;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_TABLES" %then %let _cstSrcType=table;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_COLUMNS" %then %let _cstSrcType=column;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_VALUES" %then %let _cstSrcType=value;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_CODELISTS" %then %let _cstSrcType=codelist;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_DOCUMENTS" %then %let _cstSrcType=document;
    %if "%upcase(&_cstSrcDS)" eq "SOURCE_ANALYSISRESULTS" %then %let _cstSrcType=analysisresult;
  %end;

  %if "%upcase(&_cstSrcType)" ne "STUDY" and 
      "%upcase(&_cstSrcType)" ne "STANDARD" and 
      "%upcase(&_cstSrcType)" ne "TABLE" and 
      "%upcase(&_cstSrcType)" ne "COLUMN" and 
      "%upcase(&_cstSrcType)" ne "VALUE" and 
      "%upcase(&_cstSrcType)" ne "CODELIST" and
      "%upcase(&_cstSrcType)" ne "DOCUMENT" and
      "%upcase(&_cstSrcType)" ne "ANALYSISRESULT" %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstSrcType=%str(&_cstSrcType) must be study, standard, table, column, value, codelist, document or analysisresult.;
    %goto exit_macro;
  %end;

  %if %upcase(&_cstCheckValues) ne N and %upcase(&_cstCheckValues) ne Y %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstCheckValues value must be Y or N.;
    %goto exit_macro;
  %end;
  %else %do;
    %* We can only check for known standards;    
    %if "%upcase(&_cstTrgStandard)" ne "CDISC-ADAM" and 
        "%upcase(&_cstTrgStandard)" ne "CDISC-SDTM" and 
        "%upcase(&_cstTrgStandard)" ne "CDISC-SEND" %then 
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=When _cstCheckValues=Y, _cstTrgStandard=%str(&_cstTrgStandard) value must be %str(CDISC-ADAM, CDISC-SDTM or CDISC-SEND).;
      %goto exit_macro;
    %end;
  %end;
  
  %* Check source libref;
  %if (%sysfunc(libref(&_cstSrcLib))) %then %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Libref _cstSrcLib=&_cstSrcLib has not been assigned.;
    %goto exit_macro;
  %end;  


  %* Check target library;
  %if %sysfunc(kindexc(&_cstTrgDS,.)) %then %do;  
    %let _cstTrgLib=%sysfunc(scan(%trim(%left(&_cstTrgDS)),1,.));
    %if %sysfunc(libref(&_cstTrgLib)) %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Libref &_cstTrgLib in _cstTrgDS parameter has not been assigned.;
      %goto exit_macro;
    %end;  
  %end;

  %******************************************************;
  %*   source_study metadata                            *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=STUDY %then %do;
    
    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set work.&_cstSrcDS._tmpl_&_cstRandom &_cstSrcLib..&_cstSrcDS(drop=formalstandardname formalstandardversion);
      context="Submission";
      if missing(metadataversionname) then metadataversionname = catx(" ", "Data Definitions for", studyname); 
     run;  
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;

  %******************************************************;
  %*   source_standards metadata                        *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=STANDARD %then %do;
    
    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set &_cstSrcLib..&_cstSrcDS;
     run;  
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;

  %******************************************************;
  %*   source_tables metadata                           *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=TABLE %then %do;
    
    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set &_cstSrcLib..&_cstSrcDS;
      %if %upcase("&_cstTrgStandard")="CDISC-ADAM" %then %do;
        cdiscstandard="ADaMIG";
        cdiscstandardversion="&_cstTrgStandardVersion";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SDTM" %then %do;
        cdiscstandard="SDTMIG";
        cdiscstandardversion="&_cstTrgStandardVersion";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SEND" %then %do;
        cdiscstandard="SENDIG";
        cdiscstandardversion="&_cstTrgStandardVersion";
      %end;  

    run;
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;
    
  %******************************************************;
  %*   source_columns metadata                          *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=COLUMN %then %do;
    
    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType, _cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom(drop=origin);
      set &_cstSrcLib..&_cstSrcDS;

      origintype=origin;
      %if %sysfunc(cexist(work.formats._cstorg.formatc)) %then %do;
        origintype = put(origintype, $_cstorg.);
      %end;

      %if %upcase("&_cstTrgStandard")="CDISC-ADAM" %then %do;
        if origintype in ("Protocol") then originsource = "Sponsor";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SDTM" %then %do;
        if origintype in ("Derived" "Assigned") then originsource = "Sponsor";
        if origin = "eDT" then originsource  = "Vendor";
      %end;  

      %if %upcase("&_cstTrgStandard")="CDISC-ADAM" %then %do;
        mandatory="No";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SDTM" or %upcase("&_cstTrgStandard")="CDISC-SEND" %then %do;
        if core = "Req" then mandatory="Yes";
                        else mandatory="No";
      %end;  

    run;
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;
    
  %******************************************************;
  %*   source_values metadata                           *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=VALUE %then %do;

    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom(drop=origin __:);
      length name $32 __CheckValue __RegEx_Varname $100 __RegEx_EQ __Pattern1 __Pattern2 $ 2000 __Pattern_ID1 __Pattern_ID2 __Pos1 __Pos2 8 __text1 __text3 $64;
      retain __Pattern1 __Pattern2 __Pattern_ID1 __Pattern_ID2;
      set &_cstSrcLib..&_cstSrcDS end=end;

      if _n_=1 then do;
        __CheckValue = '("[^"]*"|[^"\47][^"]*)';
        __RegEx_Varname='([a-zA-Z_][a-zA-Z0-9_]{0,31})';
        __RegEx_EQ=cats('(\s+EQ\s+)' , "(", __CheckValue, ")");
        __Pattern1 = cats(__RegEx_Varname, __RegEx_EQ);
        __Pattern1 = cats('/^\s*', __Pattern1, '\s*$/i');
        __Pattern2 = cats ('/^\s*', __RegEx_Varname, '\s*$/i');
        __Pattern_ID1=prxparse(__Pattern1);
        __Pattern_ID2=prxparse(__Pattern2);
      end;
      __Pos1 = prxmatch(__Pattern_ID1, whereclause);
      __text1 = prxposn(__Pattern_ID1, 1, whereclause);
      __text3 = prxposn(__Pattern_ID1, 3, whereclause);
      __text3=compress(__text3, '"');
      __text3=compress(__text3, '"');
      __text3=strip(__text3);
      put __text3=;
      __Pos2 = prxmatch(__Pattern_ID2, __text3);

      origintype=origin; 
      %if %sysfunc(cexist(work.formats._cstorg.formatc)) %then %do;
        origintype = put(origintype, $_cstorg.);
      %end;

      %if %upcase("&_cstTrgStandard")="CDISC-ADAM" %then %do;
        if origintype in ("Protocol") then originsource = "Sponsor";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SDTM" %then %do;
        if origintype in ("Derived" "Assigned") then originsource = "Sponsor";
        if origin = "eDT" then originsource  = "Vendor";
      %end;  

      %if %upcase("&_cstTrgStandard")="CDISC-ADAM" %then %do;
        mandatory="No";
      %end;  
      %if %upcase("&_cstTrgStandard")="CDISC-SDTM" or %upcase("&_cstTrgStandard")="CDISC-SEND" %then %do;
        if core = "Req" then mandatory="Yes";
                        else mandatory="No";
      %end;  
    
      if not missing(whereclause) and __Pos1=1 and __Pos2=1 then do;
        if missing(name) then do;
          name=column;
          if index(__text1, "PARAMCD") then name=__text3;
          if index(__text1, "PARMCD") then name=__text3;
          if index(__text1, "TESTCD") then name=__text3;
          if index(__text1, "QNAM") then name=__text3;
        end;  
      end;
    
      if end then do;
        call prxfree(__Pattern_ID1);  
        call prxfree(__Pattern_ID2);  
      end;  
    
    run;
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;

  %******************************************************;
  %*   source_codelists metadata                        *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=CODELIST %then %do;

    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set &_cstSrcLib..&_cstSrcDS;
    run;
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;

  %******************************************************;
  %*   source_documents metadata                        *;
  %******************************************************;
  %if %upcase(&_cstSrcType)=DOCUMENT %then %do;

    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType, _cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set &_cstSrcLib..&_cstSrcDS;
    run;
    
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;  

  %******************************************************;
  %*   source_analysisresults metadata                  *;
  %******************************************************;

  %if %upcase(&_cstSrcType)=ANALYSISRESULT %then %do;

    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=&_cstSrcType, _cstOutputDS=work.&_cstSrcDS._tmpl_&_cstRandom
      );
     %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom,_cstAttribute=LABEL);

    %* Check source dataset;
    %if not %sysfunc(exist(&_cstSrcLib..&_cstSrcDS)) %then %do;
      data &_cstTrgDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        set work.&_cstSrcDS._tmpl_&_cstRandom;
      run;  

      %if %sysfunc(exist(&_cstTrgDS)) %then
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

      %goto exit_macro;
    %end;  

    data work.&_cstSrcDS._&_cstRandom;
      set &_cstSrcLib..&_cstSrcDS;
    run;

    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgDS (%nrbquote(&_cstDSLabel))
            ,_cstResultParm2=(&_cstRecs)
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=1
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=0
            ,_cstRCParm=0
            ,_cstResultsDSParm=&_cstResultsDS
            );
      %end;
    %end;

  %end;

  %******************************************************;

  data &_cstTrgDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    set work.&_cstSrcDS._tmpl_&_cstRandom work.&_cstSrcDS._&_cstRandom;
    format _character_ _numeric_;
    if missing(SASRef) then SASRef="SRCDATA";
    if missing(StudyVersion) then StudyVersion="&_cstStudyVersion";
    if missing(Standard) then Standard="&_cstTrgStandard";   
    if missing(StandardVersion) then StandardVersion="&_cstTrgStandardVersion";   
  run;  
  
  %* Clean-up;
  %if not &_cstDebug %then %do;
    %cstutil_deleteDataSet(_cstDataSetName=work.&_cstSrcDS._&_cstRandom);
  %end;
  
  %if %sysfunc(exist(&_cstTrgDS)) %then
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstTrgDS has been created with %cstutilnobs(_cstDataSetName=&_cstTrgDS) observation(s).;

  %exit_macro:
    %if %length(&&&_cstReturnMsg) %then 
      %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&sysmacroname] &&&_cstReturnMsg;

  %if &&&_cstReturn %then 
  %do;
    %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] &&&_cstReturnMsg;

    %if %symexist(_cstResultsDS) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DEF0099
                  ,_cstResultParm1=&&&_cstReturnMsg
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstThisMacro
                  ,_cstResultFlagParm=&&&_cstReturn
                  ,_cstRCParm=&&&_cstReturn
                  );

    %end;
  %end;
  
  %* Persist the results if specified in sasreferences  *;
  %cstutil_saveresults();

  %if not &_cstDebug %then %do;
    %cstutil_deleteDataSet(_cstDataSetName=work.&_cstSrcDS._tmpl_&_cstRandom);
  %end;

  %exit_macro_nomsg:

%mend cstutilmigrate_define20_21;
