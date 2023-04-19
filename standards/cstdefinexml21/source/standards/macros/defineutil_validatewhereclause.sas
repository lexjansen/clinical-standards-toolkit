%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* defineutil_validatewhereclause                                                 *;
%*                                                                                *;
%* Validates the correctness and normalizes a WhereClause expression.             *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultSeq Results: Unique invocation of the macro                  *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstInputDS - required - The two-level data set name of the             *;
%*            data set to validate.                                               *;
%* @param _cstInputVar - required - The data set variable that contains the       *;
%*            WhereClause.                                                        *;
%* @param _cstOutputDS - required - The two-level data set name of the            *;
%*            data set to create.                                                 *;
%* @param _cstMessageColumns - optional - The columns to display in the message.  *;
%*            Default: %str(table= column=)                                       *;
%* @param _cstResultsDS - required - The two-level data set name of the table     *;
%*            that contains the validation results.                               *;
%* @param _cstReportResult - optional - Report to Results dataset?                *;
%*            Values:  N | Y                                                      *;
%*            Default: Y                                                          *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2023-03-12 Support "" as CheckValue                                   *;
%*                                                                                *;
%* @since 1.7.1                                                                   *;
%* @exposure internal                                                             *;

%macro defineutil_validatewhereclause(
  _cstInputDS=,
  _cstInputVar=,
  _cstOutputDS=,
  _cstMessageColumns=%str(Table= Column=),
  _cstResultsDS=,
  _cstReportResult=Y,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des='CST: Validate WhereClause';

  %local 
    _cstRandom 
    _cstSrcMacro 
    _cstThisMacroRC
    _cstMissing
    _cstSaveOptions
    _cstColumn
    _cstCounter
    ;
    
  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcMacro=&SYSMACRONAME;
  %let _cstThisMacroRC=0;


  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then
  %do;
    %********************************************************;
    %* We are not able to communicate other than to the LOG *;
    %********************************************************;
    %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] %str
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
  %*  Parameter checking  *;
  %************************;

  %*************************************************;
  %*  Check for missing parameters                 *;
  %*************************************************;
  %let _cstMissing=;
  %if %sysevalf(%superq(_cstInputDS)=, boolean) %then %let _cstMissing = &_cstMissing _cstInputDS;
  %if %sysevalf(%superq(_cstInputVar)=, boolean) %then %let _cstMissing = &_cstMissing _cstInputVar;
  %if %sysevalf(%superq(_cstOutputDS)=, boolean) %then %let _cstMissing = &_cstMissing _cstOutputDS;
  %if %sysevalf(%superq(_cstResultsDS)=, boolean) %then %let _cstMissing = &_cstMissing _cstResultsDS;
  %if %sysevalf(%superq(_cstReportResult)=, boolean) %then %let _cstMissing = &_cstMissing _cstReportResult;
  
  

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
    %let &_cstReturnMsg=Expected Value Level Metadata data set does not exist: &_cstMissing..;
    %goto exit_error;
  %end;

  %***********************************************;
  %*  Check that variable exists in data set     *;
  %***********************************************;
  
  %if %cstutilcheckvarsexist(_cstDataSetName=&_cstInputDS, _cstVarList=&_cstInputVar)=0 %then
  %do;
    %*let &_cstReturn=-1;
    %let &_cstReturnMsg=Variable &_cstInputVar does not exist in data set &_cstInputDS.;
    %goto exit_error;
  %end;

  %*************************************************************;
  %*  Check that the output libref is assigned                 *;
  %*************************************************************;
  %if %sysfunc(kindexc(%str(&_cstOutputDS),%str(.))) %then 
  %do;
    %let _cstlibname=%sysfunc(kscan(&_cstOutputDS,1,.));
    %if (%sysfunc(libref(&_cstlibname))) %then
    %do;
      %let &_cstReturn=-1;
      %let &_cstReturnMsg=The libref for the output data set (&_cstlibname) is not assigned.;
      %goto exit_error;
    %end;
  %end;

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

    %if "%upcase(&_cstReportResult)" ne "Y" and "%upcase(&_cstReportResult)" ne "N"
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Invalid _cstReportResult value (&_cstReportResult): should be Y or N;
        %goto exit_error;
      %end;

  %*******************************;
  %* End of Parameter checking   *;
  %*******************************;


  %if %symexist(_cstResultsDS) %then
  %do;
     %cstutil_writeresult(
        _cstResultId=DEF0097
        ,_cstResultParm1=Validating &_cstInputVar in &_cstInputDS (creating &_cstOutputDS)
        ,_cstResultParm2=
        ,_cstResultSeqParm=1
        ,_cstSeqNoParm=1
        ,_cstSrcDataParm=&_cstSrcMacro
        ,_cstResultFlagParm=0
        ,_cstRCParm=0
        ,_cstResultsDSParm=&_cstResultsDS
        );
  %end;

  data &_cstOutputDS(drop= __quote);
    length __quote 8 __KeepVar $%cstutilgetattribute(_cstDataSetName=&_cstInputDS, _cstVarName=&_cstInputVar, _cstAttribute=VARLEN);
    set &_cstInputDS;
    
    __KeepVar = &_cstInputVar;
    %* Replace single quotes with double quotes;
    __quote=PRXPARSE("s/\((\s)*'/(""/i");
    call prxchange(__quote, -1, &_cstInputVar);
    __quote=PRXPARSE("s/'(\s)*,(\s)*'/"",""/i");
    call prxchange(__quote, -1, &_cstInputVar);
    __quote=PRXPARSE("s/'(\s)*\)/"")/i");
    call prxchange(__quote, -1, &_cstInputVar);
    __quote=PRXPARSE("s/(\s)+'/ ""/i");
    call prxchange(__quote, -1, &_cstInputVar);
    __quote=PRXPARSE("s/('(\s)*$)/""/i");
    call prxchange(__quote, -1, &_cstInputVar);
    __quote=PRXPARSE("s/'(\s)+/"" /i");
    call prxchange(__quote, -1, &_cstInputVar);
  run;

  data &_cstOutputDS(drop=__Pattern __CheckValue __RegEx_Varname __RegEx_EQ_NE __RegEx_IN_NOTIN __Pos __KeepVar __cstError) 
       work._cstIssues_&_cstRandom;
    length __CheckValue __RegEx_Varname $100 __RegEx_EQ_NE __RegEx_IN_NOTIN __Pattern $ 2000 __Pattern_ID __Pos __cstError 8;
    retain __Pattern __Pattern_ID __cstError;
    set &_cstOutputDS end=end;
    if _n_=1 then do;
      __cstError=0;
      __CheckValue = '("[^"]*"|[^"\47][^"]*)';
      __RegEx_Varname='[a-zA-Z_][a-zA-Z0-9_]{0,31}';
      __RegEx_EQ_NE=cats('(EQ|NE|LT|LE|GT|GE)\s+' , __CheckValue);
      __RegEx_IN_NOTIN=cats('(IN|NOTIN)\s+\(\s*', __CheckValue, '(\s*,\s*', __CheckValue, ')*', '\s*\)');
  
      __Pattern = cats(__RegEx_Varname, '\s+', "(", __RegEx_EQ_NE, "|", __RegEx_IN_NOTIN, ")");
      %* Allow parentheses around a WhereClause;
      __Pattern = cats("(", __Pattern, "|", "\(\s*", __Pattern, "\s*\)", ")");
      %* Multiple conditions separated by AND;
      __Pattern = cats(__Pattern, "(\s+AND\s+", __Pattern, ")*");
      %* Allow parentheses around a WhereClause;
      __Pattern = cats('/^\s*', "(", __Pattern, "|", "\(\s*", __Pattern, "\s*\)", ")", '\s*$/i');
  
      
      %if &_cstDebug %then putlog "IN%str(FO): [CSTLOG%str(MESSAGE).&sysmacroname] " __Pattern=;;
      __Pattern_ID=prxparse(__Pattern);
  
    end;
    __Pos = prxmatch(__Pattern_ID, &_cstInputVar );
    if (__Pos ne 1) and (not missing(&_cstInputVar)) then do;
      %if %upcase(&_cstReportResult) eq Y %then
      %do;      
        putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Record with invalid &_cstInputVar deleted from &_cstInputDS: " 
               _n_= &_cstMessageColumns "&_cstInputVar.=" __KeepVar ;
      %end;
      __cstError=1;
      output work._cstIssues_&_cstRandom;
      delete;
    end;
    if end then do;
      call prxfree(__Pattern_ID);  
      call symputx('_cstThisMacroRC',__cstError);
    end;  
    output &_cstOutputDS;
  run;  


  %if %eval(&_cstThisMacroRC)=1 %then
  %do;
    %if %upcase(&_cstReportResult) eq Y %then
    %do;

      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;

        %cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK,_cstType=results,_cstSubType=results,_cstOutputDS=work._cstIssues0_&_cstRandom);

        %* The message variable might get very long, but it is ok if it gets truncated;
        %let _cstSaveOptions = %sysfunc(getoption(varlenchk, keyword));
        options varlenchk=nowarn;

        data work._cstIssues0_&_cstRandom(keep=resultid checkid resultseq seqno srcdata message resultseverity resultflag _cst_rc actual keyvalues resultdetails);
          set work._cstIssues0_&_cstRandom
             work._cstIssues_&_cstRandom;
          resultid="DEF0098";
          srcdata="&_cstThisMacro";
          resultseq=1;
          seqno=_n_;
          resultseverity="Warning";
          resultflag=1;
          _cst_rc=0;
          message="Record with invalid &_cstInputVar deleted from &_cstInputDS: ";
          %do _cstCounter=1 %to %sysfunc(countw(&_cstMessageColumns));
            %let _cstColumn=%scan(&_cstMessageColumns, &_cstCounter);
            message=catt(message, ", &_cstColumn");
            %let _cstColumn=%sysfunc(compress(&_cstColumn, %str(=)));
            message=catt(message, &_cstColumn);
          %end;  
          message=catt(message, ", &_cstInputVar.=", __KeepVar);
        run;


        options &_cstSaveOptions;    

        %if %symexist(_cstResultsDS) %then
        %do;
          %if %klength(&_cstResultsDS) > 0 and %sysfunc(exist(&_cstResultsDS)) %then
          %do;
             proc append base=&_cstResultsDS data=work._cstIssues0_&_cstRandom force;
             run;
          %end;
        %end;

        * Cleanup;
        %if not &_cstDebug %then %do;
           %cstutil_deleteDataSet(_cstDataSetName=work._cstIssues0_&_cstRandom);
        %end;

      %end;
    %end;
  %end;
  %else %do;
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %if %upcase(&_cstReportResult) eq Y %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DEF0097
                    ,_cstResultParm1=There were no issues with &_cstInputVar in &_cstInputDS
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;
  %end;  

  %cstutil_deleteDataSet(_cstDataSetName=work._cstIssues_&_cstRandom);

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
%exit_error:

  %if %length(&&&_cstReturnMsg)>0 %then
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&_cstSrcMacro] &&&_cstReturnMsg;

%exit_macro:

%exit_macro_nomsg:

%mend defineutil_validatewhereclause;

