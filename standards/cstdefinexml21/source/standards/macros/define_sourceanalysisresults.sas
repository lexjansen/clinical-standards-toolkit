%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourceanalysisresults                                                   *;
%*                                                                                *;
%* Creates Define-XML analysis results-related data sets from source metadata.    *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.analysisresultdisplays                                    *;
%*    _cstOutputLibrary.analysisresults                                           *;
%*    _cstOutputLibrary.analysisvariables                                         *;
%*    _cstOutputLibrary.analysiswhereclauserefs                                   *;
%*    _cstOutputLibrary.analysisdataset                                           *;
%*    _cstOutputLibrary.analysisdatasets                                          *;
%*    _cstOutputLibrary.analysisdocumentation                                     *;
%*    _cstOutputLibrary.analysisprogrammingcode                                   *;
%*    _cstOutputLibrary.TranslatedText[parent="AnalysisResultDisplays"]           *;
%*    _cstOutputLibrary.TranslatedText[parent="AnalysisResults"]                  *;
%*    _cstOutputLibrary.TranslatedText[parent="AnalysisDocumentation"]            *;
%*    _cstOutputLibrary.TranslatedText[parent="CommentDefs"]                      *;
%*    _cstOutputLibrary.WhereClauseDefs                                           *;
%*    _cstOutputLibrary.WhereClauseRangeChecks                                    *;
%*    _cstOutputLibrary.WhereClauseRangeCheckValues                               *;
%*    _cstOutputLibrary.MDVLeaf                                                   *;
%*    _cstOutputLibrary.MDVLeafTitles                                             *;
%*    _cstOutputLibrary.DocumentRefs                                              *;
%*    _cstOutputLibrary.PDFPageRefs                                               *;
%*    _cstOutputLibrary.CommentDefs                                               *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%*                                                                                *;
%* @param _cstSourceAnalysisResults - required - The data set that contains the   *;
%*            source analysis results metadata to include in the Define-XML file. *;
%* @param _cstOutputLibrary - required - The library to write the Define-XML data *;
%*            sets.                                                               *;
%*            Default: srcdata                                                    *;
%* @param _cstCheckLengths - required - Check the actual value lengths of         *;
%*            variables with DataType=text against the lengths defined in the     *;
%*            metadata templates. If the lengths are short, a warning is written  *;
%*            to the log file and the Results data set.                           *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstLang - optional - The ODM TranslatedText/@lang attribute.           *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @since 1.7.1                                                                   *;
%* @exposure external                                                             *;

%macro define_sourceanalysisresults(
    _cstSourceAnalysisResults=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML analysis results metadata related data sets";


    %local
     i
     _cstExpSrcTables
     _cstExpTrgTables
     _cstTable
     _cstTables
     _cstTabs
     _cstMissing
     _cstReadOnly
     _cstMDVIgnored
     _cstStudyVersions
     _cstMDVOID
     _cstRandom
     _cstRecs
     _cstThisMacro
     _cstOIDLength
     ;

    %let _cstThisMacro=&sysmacroname;
    %* The data sets to be created and the work data sets;
    %let _cstTables=analysisresultdisplays analysisresults analysisdatasets analysisdataset %str
                  ()analysiswhereclauserefs analysisvariables analysisdocumentation analysisprogrammingcode %str
                  ()WhereClauseDefs WhereClauseRangeChecks WhereClauseRangeCheckValues TranslatedText TranslatedText TranslatedText TranslatedText CommentDefs;
    %let _cstTabs=armrd armr armdss armds armwc armv armdoc armcode wcd wcrc wcrcv disp_tt res_tt doc_tt com_tt arm_cm %str
                ()_cstsourceanalysisresults _cstsourceanalysisresults2 _wcrc_arm_tmp _wc_tmp _cstwhereclause;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceAnalysisResults;
    %* Target table expected;
    %let _cstExpTrgTables=MetaDataVersion &_cstTables;

    %***************************************************;
    %*  Check _cstReturn and _cstReturnMsg parameters  *;
    %***************************************************;
    %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then %do;
      %* We are not able to communicate other than to the LOG;
      %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
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

    %******************************************************************************;
    %* Parameter checks                                                           *;
    %******************************************************************************;

    %let _cstMissing=;
    %do i=1 %to %sysfunc(countw(&_cstExpSrcTables));
       %let _cstTable=%scan(&_cstExpSrcTables, &i);
       %if %sysevalf(%superq(&_cstTable)=, boolean) %then %let _cstMissing = &_cstMissing &_cstTable;
    %end;
    %if %sysevalf(%superq(_cstOutputLibrary)=, boolean) %then %let _cstMissing = &_cstMissing _cstOutputLibrary;
    %if %sysevalf(%superq(_cstCheckLengths)=, boolean) %then %let _cstMissing = &_cstMissing _cstCheckLengths;

    %if %length(&_cstMissing) gt 0
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Required macro parameter(s) missing: &_cstMissing;
        %goto exit_macro;
      %end;

    %if "%upcase(&_cstCheckLengths)" ne "Y" and "%upcase(&_cstCheckLengths)" ne "N"
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Invalid _cstCheckLengths value (&_cstCheckLengths): should be Y or N;
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
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Expected source data set(s) not existing: &_cstMissing;
        %goto exit_macro;
      %end;

    %****************************************************************************;
    %*  Pre-requisite: Check that the output libref is assigned                 *;
    %****************************************************************************;
    %if (%sysfunc(libref(&_cstOutputLibrary))) %then
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The output libref(&_cstOutputLibrary) is not assigned.;
      %goto exit_macro;
    %end;

    %****************************************************************************;
    %*  Pre-requisite: Check that the output libref is not read-only            *;
    %****************************************************************************;
    %let _cstReadOnly=;
    proc sql noprint;
     select readonly into :_cstReadOnly
     from sashelp.vlibnam
     where upcase(libname) = "%upcase(&_cstOutputLibrary)"
     ;
    quit;
    %let _cstReadOnly=&_cstReadOnly;

    %if %upcase(&_cstReadOnly)=YES %then
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The output libref(&_cstOutputLibrary) is readonly.;
      %goto exit_macro;
    %end;

    %****************************************************************************;
    %*  Pre-requisite: Expected Define-XML data sets, may be 0-observation      *;
    %****************************************************************************;

    %let _cstMissing=;
    %do i=1 %to %sysfunc(countw(&_cstExpTrgTables));
       %if not %sysfunc(exist(&_cstOutputLibrary..%scan(&_cstExpTrgTables, &i))) %then
        %let _cstMissing = &_cstMissing &_cstOutputLibrary..%scan(&_cstExpTrgTables, &i);
    %end;
    %if %length(&_cstMissing) gt 0
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Expected Define-XML data set(s) missing: &_cstMissing;
        %goto exit_macro;
      %end;

    %******************************************************************************;
    %* End of parameter checks                                                    *;
    %******************************************************************************;

    %* Check lengths of incoming data against template *;
    %if %upcase(%substr(&_cstCheckLengths,1,1)) = Y 
    %then %do;
      %defineutil_validatelengths(
        _cstInputDS=&_cstSourceAnalysisResults,
        _cstSrcType=analysisresult,
        _cstMessageColumns=%str(displayidentifier= resultidentifier= table=),  
        _cstResultsDS=&_cstResultsDS
        );
    %end;

    %let _cstMDVIgnored=0;
    %let _cstStudyVersions=;
    %* get metadataversion/@oid  *;
    proc sql noprint;
     select OID into :_cstMDVOID
     from &_cstOutputLibrary..MetaDataVersion
     ;
     select distinct count(*), StudyVersion into :_cstMDVIgnored, :_cstStudyVersions separated by ', '
     from &_cstSourceAnalysisResults
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceAnalysisResults will be ignored: StudyVersion IN (&_cstStudyVersions));
        %put [CSTLOG%str(MESSAGE).&_cstThisMacro] Info: &&&_cstReturnMsg;
        %if %symexist(_cstResultsDS) %then
        %do;
           %cstutil_writeresult(
              _cstResultId=DEF0097
              ,_cstResultParm1=&&&_cstReturnMsg
              ,_cstResultSeqParm=1
              ,_cstSeqNoParm=1
              ,_cstSrcDataParm=&_cstThisMacro
              ,_cstResultFlagParm=0
              ,_cstRCParm=0
              ,_cstResultsDSParm=&_cstResultsDS
              );
        %end;
      %end;

    %******************************************************************************;
    %* Read source metadata (this part is source specific)                        *;
    %******************************************************************************;

    %cstutil_getRandomNumber(_cstVarname=_cstRandom);

    %let _cstOIDLength=128;

    proc sort data=&_cstSourceAnalysisResults(where=(StudyVersion = "&_cstMDVOID"))
      out=_cstSourceAnalysisResults_&_cstRandom;
    by DisplayIdentifier ResultIdentifier Table;
    run;

    %defineutil_validatewhereclause(
      _cstInputDS=_cstSourceAnalysisResults_&_cstRandom,
      _cstInputVar=WhereClause,
      _cstOutputDS=_cstSourceAnalysisResults_&_cstRandom,
      _cstMessageColumns=%str(DisplayIdentifier= DisplayDescription= Table=),
      _cstResultsDS=&_cstResultsDS,
      _cstReportResult=Y,
      _cstReturn=_cst_rc,
      _cstReturnMsg=_cst_rcmsg
      );

    data _cstSourceAnalysisResults_&_cstRandom;
      retain UUID UUIDds UUIDdoc UUIDcode;
      length UUID UUIDds UUIDdoc UUIDcode $32;
      set _cstSourceAnalysisResults_&_cstRandom;
      by DisplayIdentifier ResultIdentifier Table;
      if first.ResultIdentifier then do; 
        UUID=uuidgen();
        UUIDdoc=uuidgen();
        UUIDcode=uuidgen();
      end;
      UUIDds=uuidgen();
    run;   


    %* Create WhereClauseOID ;
    proc sort data=_cstSourceAnalysisResults_&_cstRandom
              out=_cstWhereClause_&_cstRandom(keep=DisplayIdentifier ResultIdentifier Table whereclause) nodupkey;
      by DisplayIdentifier ResultIdentifier Table whereclause;
      where not missing(whereclause);
    run;

    data _cstWhereClause_&_cstRandom;
      length WhereClauseOID $128;
      set _cstWhereClause_&_cstRandom;
      WhereClauseOID="WC.ARM."||kstrip(ResultIdentifier)||"."||kstrip(table)||"."||put(_n_, z5.);
    run;

    proc sql;
      create table _wc_tmp_&_cstRandom
      as select
        arm.*,
        wc.WhereClauseOID
      from
        _cstSourceAnalysisResults_&_cstRandom arm
        left join _cstWhereClause_&_cstRandom wc
      on (arm.DisplayIdentifier=wc.DisplayIdentifier) and (arm.ResultIdentifier=wc.ResultIdentifier) and 
         (arm.Table=wc.Table) and (arm.WhereClause=wc.WhereClause) and 
         (arm.StudyVersion = "&_cstMDVOID")
      ;
    quit;

    data _cstSourceAnalysisResults_&_cstRandom;
      set _wc_tmp_&_cstRandom;
    run;

    %*************************************************************;
    %* split multiple conditions in one condition per record     *;
    %*************************************************************;

    %defineutil_splitwhereclause(
      _cstDSIn=_cstSourceAnalysisResults_&_cstRandom, 
      _cstDSOut=_wcrc_arm_tmp_&_cstRandom, 
      _cstOutputLibrary=&_cstOutputLibrary,
      _cstType=ARM
    );

    %******************************************************************************;
    %* Create internal model tables                                               *;
    %******************************************************************************;



    data _cstSourceAnalysisResults2_&_cstRandom(keep=UUIDds AnalysisVariable Table);
      length AnalysisVariable $32;
      set _cstSourceAnalysisResults_&_cstRandom(where=(not missing(AnalysisVariables)));
      __CstCounter=1;
      AnalysisVariable=kscan(AnalysisVariables, __CstCounter);
      do while (not missing(AnalysisVariable));
        output;
        __CstCounter = __CstCounter + 1;
        AnalysisVariable=kscan(AnalysisVariables, __CstCounter);
      end;  
    run;

    proc sql;
      %* analysisresultdisplays;
      create table armrd_&_cstRandom
      as select
        unique armrd.DisplayIdentifier as OID,
        armrd.DisplayName as Name,
        armrd.StudyVersion as FK_MetaDataVersion
      from _cstSourceAnalysisResults_&_cstRandom armrd
      order by OID
      ;
      %* TranslatedText (Displays);
      create table disp_tt_&_cstRandom
      as select
        unique disp_tt.DisplayDescription as TranslatedText,
        "&_cstLang" as lang,
        "AnalysisResultDisplays" as parent,
        disp_tt.DisplayIdentifier as parentKey length=&_cstOIDLength
      from _cstSourceAnalysisResults_&_cstRandom disp_tt
      ;
      %* analysisresults;
      create table armr_&_cstRandom
      as select
        unique armr.ResultIdentifier as OID,
        armr_p.ParameterOID,
        armr.AnalysisReason,
        armr.AnalysisPurpose,
        armr.DisplayIdentifier as FK_AnalysisResultDisplays
      from 
        _cstSourceAnalysisResults_&_cstRandom armr
        left join (
          select 
            unique armr.ResultIdentifier,        
            "IT."||kstrip(armr.Table)||"."||kstrip(armr.ParameterColumn) as ParameterOID
          from _cstSourceAnalysisResults_&_cstRandom armr
          where not missing(armr.ParameterColumn)
          ) armr_p
        on armr.ResultIdentifier = armr_p.ResultIdentifier
      order by OID
      ;
      %* TranslatedText (DisplayResults);
      create table res_tt_&_cstRandom
      as select
        unique res_tt.ResultDescription as TranslatedText,
        "&_cstLang" as lang,
        "AnalysisResults" as parent,
        res_tt.ResultIdentifier as parentKey length=&_cstOIDLength
      from _cstSourceAnalysisResults_&_cstRandom res_tt
      ;
      %* analysisdatasets;
      create table armdss_&_cstRandom
      as select
        unique armdss.UUID as OID,
        case when not missing(armdss.TableJoinComment)
          then "COM.ARM."||kstrip(armdss.ResultIdentifier)
          else ""
        end as CommentOID length=&_cstOIDLength,
        armdss.ResultIdentifier as FK_AnalysisResults
      from _cstSourceAnalysisResults_&_cstRandom armdss
      order by FK_AnalysisResults
      ;
      %* CommentDefs;
      create table arm_cm_&_cstRandom
        as select distinct "COM.ARM."||kstrip(armc.ResultIdentifier) as OID length=&_cstOIDLength,
        armc.StudyVersion as FK_MetaDataVersion
      from _cstSourceAnalysisResults_&_cstRandom armc
      where not missing(armc.TableJoinComment)
      order by OID
      ;
      %* TranslatedText (CommentDefs);
      create table com_tt_&_cstRandom
      as select
        unique com_tt.TableJoinComment as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        "COM.ARM."||kstrip(com_tt.ResultIdentifier) as parentKey length=&_cstOIDLength
      from _cstSourceAnalysisResults_&_cstRandom com_tt
      ;
      %* analysisdataset;
      create table armds_&_cstRandom
      as select
        armds.UUIDds as OID,
        "IG."||kstrip(armds.Table) as ItemGroupOID,
        armds.UUID as FK_AnalysisDatasets
      from _cstSourceAnalysisResults_&_cstRandom armds
      ;
      %* analysiswhereclauserefs;
      create table armwc_&_cstRandom
      as select
        armwc.WhereClauseOID,
        armwc.UUIDds as FK_AnalysisDataset
      from _cstSourceAnalysisResults_&_cstRandom armwc
      where not missing(armwc.WhereClause);
      ;
      %* analysisvariables;
      create table armv_&_cstRandom
      as select
        "IT."||kstrip(armv.Table)||"."||kstrip(armv.AnalysisVariable) as ItemOID length=&_cstOIDLength,
        armv.UUIDds as FK_AnalysisDataset
      from _cstSourceAnalysisResults2_&_cstRandom armv
      ;
       %* analysisdocumentation;
      create table armdoc_&_cstRandom
      as select
        unique armdoc.UUIDdoc as OID,
        armdoc.ResultIdentifier as FK_AnalysisResults
      from _cstSourceAnalysisResults_&_cstRandom armdoc
      where not missing(armdoc.ResultDocumentation)
      ;
      %* TranslatedText (AnalysisDocumentation);
      create table doc_tt_&_cstRandom
      as select
        unique doc_tt.ResultDocumentation as TranslatedText,
        "&_cstLang" as lang,
        "AnalysisDocumentation" as parent,
        doc_tt.UUIDdoc as parentKey length=&_cstOIDLength
      from _cstSourceAnalysisResults_&_cstRandom doc_tt
      where not missing(doc_tt.ResultDocumentation)
      ;
       %* analysisprogrammingcode;
      create table armcode_&_cstRandom
      as select
        unique armcode.UUIDcode as OID,
        armcode.CodeContext as Context,
        armcode.Code as Code,
        armcode.ResultIdentifier as FK_AnalysisResults
      from _cstSourceAnalysisResults_&_cstRandom armcode
      ;


      %* WhereClauseDefs;
      create table wcd_&_cstRandom
      as select
        col.WhereClauseOID as OID,
        col.StudyVersion as FK_MetaDataVersion
      from _cstSourceAnalysisResults_&_cstRandom col
      ;
      %* WhereClauseRangeChecks;
      create table wcrc_&_cstRandom
      as select distinct
        wc.FK_WhereClauseRangeChecks as OID,
        wc.Comparator,
        "Soft" as SoftHard,
        wc.ItemOID,
        wc.WhereClauseOID as FK_WhereClauseDefs
      from _wcrc_arm_tmp_&_cstRandom wc
      ;
      %* WhereClauseRangeCheckValues;
      create table wcrcv_&_cstRandom
      as select
        wcrc.CheckValue,
        wcrc.FK_WhereClauseRangeChecks
      from _wcrc_arm_tmp_&_cstRandom wcrc
      order by FK_WhereClauseRangeChecks, CheckValue
      ;
    quit;

    %******************************************************************************;
    %* Create output data sets                                                    *;
    %* Write Results                                                              *;
    %******************************************************************************;

      %do i=1 %to %sysfunc(countw(&_cstTables));

        data &_cstOutputLibrary..%scan(&_cstTables, &i);
          set &_cstOutputLibrary..%scan(&_cstTables, &i)
              %scan(&_cstTabs, &i)_&_cstRandom;
        run;

        %if %symexist(_cstResultsDS) %then
        %do;
          %if %sysfunc(exist(&_cstOutputLibrary..%scan(&_cstTables, &i))) %then %do;
             %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstOutputLibrary..%scan(&_cstTables, &i));
             %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                     %else %let _cstRecs=&_cstRecs record;
             %cstutil_writeresult(
                _cstResultId=CST0102
                ,_cstResultParm1=&_cstOutputLibrary..%scan(&_cstTables, &i)
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

    %******************************************************************************;
    %* Cleanup                                                                    *;
    %******************************************************************************;
    %if not &_cstDebug %then %do;
      %do i=1 %to %sysfunc(countw(&_cstTabs));
         %cstutil_deleteDataSet(_cstDataSetName=%scan(&_cstTabs, &i)_&_cstRandom);
      %end;
    %end;

    %exit_macro:
    %if &&&_cstReturn %then %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): &&&_cstReturnMsg;

    %exit_macro_nomsg:

%mend define_sourceanalysisresults;
