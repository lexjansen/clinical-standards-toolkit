%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* defineutil_validatelengths.sas                                                 *;
%*                                                                                *;
%* Validates the lengths of columns in source metadata against their templates.   *;
%*                                                                                *;
%* This macro sets the _cstReturn and _cstReturnMsg parameters to indicate that   *;
%* there were issues with the macro parameters (_cstReturn=-1), that the data set *:
%* is valid (_cstReturn=0), or that the data set is not valid (_cstReturn=1).     *;
%*                                                                                *;
%* @param _cstInputDS - required - The two-level data set name of the             *;
%*            external codelists data set.                                        *;
%* @param  _cstSrcType - required - The type of the CRT-DDS version 1 source      *;
%*            metadata data set to migrate to Define-XML version 2.               *;
%*            Values: study | standard | table| column | value | document |       *;
%*                    analysisresult                                              *;
%* @param _cstMessageColumns - optional - The columns to display in the message.  *;
%* @param _cstResultsDS - required - The two-level data set name of the table     *;
%*            that contains the validation results.                               *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2023-03-12 Add _cstSrcType=standard                                   *;
%*                                                                                *;
%* @since 1.7.1                                                                   *;
%* @exposure internal                                                             *;

%macro defineutil_validatelengths(
  _cstInputDS=,
  _cstSrcType=,
  _cstMessageColumns=,
  _cstResultsDS=,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des='Validate Source Metadata Column lengths';


  %local
    _cstRandom
    _cstMissing
    _cstSrcMacro
    _cstlibname
    _cstCounter
    _charvars
    _varlengths
  ;

  %cstutil_getRandomNumber(_cstVarname=_cstRandom);

  %let _cstSrcMacro=&SYSMACRONAME;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then
  %do;
    %********************************************************;
    %* We are not able to communicate other than to the LOG *;
    %********************************************************;
    %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG cannot be missing.;
    %goto exit_macro_nomsg;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;

  %*************************************************;
  %*  Check for existence of _cstDebug             *;
  %*************************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;

  %************************;
  %* Parameter checking   *;
  %************************;

  %*************************************************;
  %*  Check for missing parameters                 *;
  %*************************************************;
  %let _cstMissing=;
  %if %sysevalf(%superq(_cstInputDS)=, boolean) %then %let _cstMissing = &_cstMissing _cstInputDS;
  %if %sysevalf(%superq(_cstSrcType)=, boolean) %then %let _cstMissing = &_cstMissing _cstSrcType;
  %if %sysevalf(%superq(_cstResultsDS)=, boolean) %then %let _cstMissing = &_cstMissing _cstResultsDS;

  %if %klength(&_cstMissing) gt 0 %then 
  %do;
    %let &_cstReturn=-1;
    %let &_cstReturnMsg=Required macro parameter(s) missing: &_cstMissing;
    %goto exit_error;
  %end;

  %***********************************************;
  %*  Check that data sets exist                 *;
  %***********************************************;
  %if not %sysfunc(exist(&_cstInputDS)) %then %let _cstMissing = &_cstMissing &_cstInputDS;

  %if %klength(&_cstMissing) gt 0 %then 
  %do;
    %let &_cstReturn=-1;
    %let &_cstReturnMsg=Expected Source Metadata data set does not exist: &_cstMissing..;
    %goto exit_error;
  %end;

  %***********************************************;
  %*  Check _cstSrcType                          *;
  %***********************************************;
  %if "%upcase(&_cstSrcType)" ne "STUDY" and 
      "%upcase(&_cstSrcType)" ne "STANDARD" and 
      "%upcase(&_cstSrcType)" ne "TABLE" and 
      "%upcase(&_cstSrcType)" ne "COLUMN" and 
      "%upcase(&_cstSrcType)" ne "CODELIST" and 
      "%upcase(&_cstSrcType)" ne "VALUE" and 
      "%upcase(&_cstSrcType)" ne "DOCUMENT" and
      "%upcase(&_cstSrcType)" ne "ANALYSISRESULT" %then 
  %do;
    %let &_cstReturn=-1;
    %let &_cstReturnMsg=_cstSrcType=%str(&_cstSrcType) must be study, standard, table, column, codelist, value, document or analysisresult.;
    %goto exit_error;
  %end;

  %*************************************************************;
  %*  Check that the output libref is assigned                 *;
  %*************************************************************;
  %if %sysfunc(kindexc(%str(&_cstResultsDS),%str(.))) %then 
  %do;
    %let _cstlibname=%sysfunc(kscan(&_cstResultsDS,1,.));
    %if (%sysfunc(libref(&_cstlibname))) %then
    %do;
      %let &_cstReturn=-1;
      %let &_cstReturnMsg=The libref for the results data set (&_cstlibname) is not assigned.;
      %goto exit_error;
    %end;
  %end;

  %*******************************;
  %* End of Parameter checking   *;
  %*******************************;

  data work._cstResultsDS_&_cstRandom;
    %cstutil_resultsdsattr;
    call missing(of _all_);
    stop;
  run;  

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=&_cstSrcType,_cstOutputDS=work._template_&_cstRandom,
    _cstResultsOverrideDS=work._cstResultsDS_&_cstRandom
    );

  %let _charvars=;
  %let _varlengths=;
  proc sql noprint;
    select upcase(name), length into :_charvars separated by ' ',
                                     :_varlengths separated by ' '
    from dictionary.columns
    where upcase(libname)="WORK" and
          upcase(memname)=upcase("_TEMPLATE_&_cstRandom") and
          type="char"
    ;
  quit;


  data work._temp_&_cstRandom;                                                                         
    set &_cstInputDS;

    %do _cstCounter=1 %to %sysfunc(countw(&_charvars, ' '));
      %let _cstVar=%scan(&_charvars, &_cstCounter, %str( ));
      %let _cstVarLen=%scan(&_varlengths, &_cstCounter, %str( ));
  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstInputDS, _cstVarList=&_cstVar) %then %do;
        if length(&_cstVar) > &_cstVarLen then
        do;
          putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] " &_cstMessageColumns 
                 ": Value &_cstVar=" &_cstVar "in dataset &_cstInputDS exceeds the template length (&_cstVarLen).";
                                                                          
          output;  
        end;
      %end;
    %end;
  run;
  
  %if %cstutilnobs(_cstDatasetName=work._temp_&_cstRandom) gt 0 %then 
  %do;

    %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Please check the LOG. %str
      ()There may be length issues in &_cstInputDS..;
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DEF0098
                  ,_cstResultParm1=Please check the LOG. There may be length issues in dataset &_cstInputDS
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=1
                  ,_cstRCParm=&_cst_rc
                  );
    %end;

  %end;

  %cstutil_deleteDataSet(_cstDataSetName=work._template_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work._temp_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work._cstResultsDS_&_cstRandom);
  

%************************************************************************;

  %goto exit_macro_nomsg;

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
%exit_error:

  %if %length(&&&_cstReturnMsg)>0 %then
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&_cstSrcMacro] &&&_cstReturnMsg;

%exit_macro_nomsg:

%mend defineutil_validatelengths;
