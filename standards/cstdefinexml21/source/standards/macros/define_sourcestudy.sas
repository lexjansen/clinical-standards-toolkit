%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcestudy                                                             *;
%*                                                                                *;
%* Creates Define-XML study metadata data sets from source metadata.              *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.definedocument                                            *;
%*    _cstOutputLibrary.study                                                     *;
%*    _cstOutputLibrary.metadataversion                                           *;
%*    _cstOutputLibrary.CommentDefs                                               *;
%*    _cstOutputLibrary.TranslatedText[parent="CommentDefs"]                      *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstSourceStudy - required - The data set that contains the source      *;
%*            study metadata to include in the Define-XML file.                   *;
%* @param _cstOutputLibrary - required - The library to write the Define-XML data *;
%*            sets.                                                               *;
%*            Default: srcdata                                                    *;
%* @param _cstCheckLengths - required - Check the actual value lengths of         *;
%*            variables with DataType=text against the lengths defined in the     *;
%*            metadata templates. If the lengths are short, a warning is written  *;
%*            to the log file and the Results data set.                           *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added CommentOID attribute                                 *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcestudy(
    _cstSourceStudy=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML study metadata related data sets";

    %local
     i
     _cstExpSrcTables
     _cstExpTrgTables
     _cstTable
     _cstTables
     _cstTabs
      _cstMissing
     _cstReadOnly
     _cstRandom
     _styStudyName
     _styStudyVersion
     _styFileOID
     _styOriginator
     _styContext
     _cstGroupName
     _cstRecs
     _cstThisMacro
     _cstOIDLength
     ;

    %let _cstThisMacro=&sysmacroname;
    %* The data sets to be created and the work data sets;
    %let _cstTables=DefineDocument Study MetaDataVersion CommentDefs TranslatedText;
    %let _cstTabs=def sty mdv mdv_cm mdv_cm_tt _cstSourceStudy;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceStudy;
    %* Target table expected;
    %let _cstExpTrgTables=&_cstTables;

    %let _cstOIDLength=128;

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

    %* There should only be one Source Study record *;
    %if %cstutilnobs(_cstDatasetName=&_cstSourceStudy) ne 1
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=The &sysmacroname process only allows 1 record in &_cstSourceStudy;
        %goto exit_macro;
      %end;

    %* Check lengths of incoming data against template *;
    %if %upcase(%substr(&_cstCheckLengths,1,1)) = Y 
    %then %do;
      %defineutil_validatelengths(
        _cstInputDS=&_cstSourceStudy,
        _cstSrcType=study,
        _cstMessageColumns=%str(studyname=),  
        _cstResultsDS=&_cstResultsDS
        );
    %end;
  
    %******************************************************************************;
    %* Read source metadata (this part is source specific)                        *;
    %******************************************************************************;

    %cstutil_getRandomNumber(_cstVarname=_cstRandom);

    data _null_;
      set &_cstSourceStudy;
        if _n_=1;
        call symputx('_styStudyName', kstrip(StudyName));
        call symputx('_styStudyVersion', kstrip(StudyVersion));
    run;

    data _cstSourceStudy_&_cstRandom;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=FileOID)=0 %then %do;
        length FileOID $128;
        call missing(FileOID);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=Originator)=0 %then %do;
        length Originator $128;
        call missing(Originator);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=StudyOID)=0 %then %do;
        length StudyOID $128;
        call missing(StudyOID);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=MetaDataVersionName)=0 %then %do;
        length MetaDataVersionName $1000;
        call missing(MetaDataVersionName);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=MetaDataVersionDescription)=0 %then %do;
        length MetaDataVersionDescription $1000;
        call missing(MetaDataVersionDescription);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=Context)=0 %then %do;
        length Context $2000;
        call missing(Context);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceStudy, _cstVarList=Comment)=0 %then %do;
        length Comment $1000;
        call missing(Comment);
      %end;  
      set &_cstSourceStudy;
      if missing(FileOID) then FileOID="DEFINE";
      if missing(StudyOID) then StudyOID=cats("STUDY", put(_n_, best.));
      /* if missing(MetaDataVersionName) then MetaDataVersionName="Data Definitions for %nrbquote(&_styStudyName), %nrbquote(&_styFormalStandardName) %nrbquote(&_styFormalStandardVersion)"; */
      if missing(MetaDataVersionName) then MetaDataVersionName="Data Definitions for %nrbquote(&_styStudyName)";
      if missing(Context) then Context="Submission";
      call symputx('_styFileOID', kstrip(FileOID));
      call symputx('_styOriginator', kstrip(Originator));
      call symputx('_styContext', kstrip(Context));
    run;

    proc sql;
      %* DefineDocument;
      create table def_&_cstRandom like &_cstOutputLibrary..definedocument;
      insert into def_&_cstRandom (FileOID, AsOfDateTime, FileType, ODMVersion, Originator, SourceSystem, SourceSystemVersion, Context)
        values("&_styFileOID", "", "Snapshot", "1.3.2", "&_styOriginator", "SAS Clinical Standards Toolkit (openCST)", "&_cstVersion", "&_styContext")
        ;
      %* Study;
      create table sty_&_cstRandom
      as select
        StudyOID as OID,
        StudyName,
        StudyDescription,
        ProtocolName,
        "&_styFileOID" as FK_DefineDocument
      from _cstSourceStudy_&_cstRandom
      ;
      %* MetaDataVersion;
      create table mdv_&_cstRandom
      as select
        StudyVersion as OID,
        "2.1.0" as DefineVersion,
        metadataversiondescription as description,
        metadataversionname as name length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..MetaDataVersion, _cstVarName=Name, _cstAttribute=VARLEN),
        case when not missing(Comment)
          then catx(".", "COM", StudyVersion)
          else ""
        end as CommentOID length=&_cstOIDLength,
        StudyOID as FK_Study
      from _cstSourceStudy_&_cstRandom
      ;
      %* CommentDefs;
      create table mdv_cm_&_cstRandom
      as select distinct
        "COM."||kstrip(StudyVersion) as OID length=&_cstOIDLength,
        StudyVersion as FK_MetaDataVersion
      from _cstSourceStudy_&_cstRandom
      where not missing(comment)
      order by OID
      ;
      %* TranslatedText (Comment);
      create table mdv_cm_tt_&_cstRandom
      as select distinct
        comment as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        "COM."||kstrip(StudyVersion) as parentKey length=&_cstOIDLength
      from _cstSourceStudy_&_cstRandom
      where not missing(comment)
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

%mend define_sourcestudy;
