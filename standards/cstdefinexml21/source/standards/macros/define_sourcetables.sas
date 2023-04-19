%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcetables                                                            *;
%*                                                                                *;
%* Creates Define-XML table metadata data sets from source metadata.              *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.ItemGroupDefs                                             *;
%*    _cstOutputLibrary.TranslatedText[parent="ItemGroupDefs"]                    *;
%*    _cstOutputLibrary.Aliases[parent="ItemGroupDefs"]                           *;
%*    _cstOutputLibrary.ItemGroupClass                                            *;
%*    _cstOutputLibrary.ItemGroupClassSubbClass                                   *;
%*    _cstOutputLibrary.ItemGroupLeaf                                             *;
%*    _cstOutputLibrary.ItemGroupLeafTitles                                       *;
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
%* @param _cstSourceTables - required - The data set that contains the source     *;
%*            table metadata to include in the Define-XML file.                   *;
%* @param _cstSourceStandards - required - The data set that contains the source  *;
%*            standards metadata to include in the Define-XML file.               *;
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
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added _cstSourceStandards parameter                        *;
%* @history 2023-03-12 Added IsNonStandard, HasNoData, StandardOID attributes     *;
%*                     Added Class and SubClass elements                          *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcetables(
    _cstSourceTables=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML tables metadata related data sets";

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
     ;

    %let _cstThisMacro=&sysmacroname;
    %* The data sets to be created and the work data sets;
    %let _cstTables=ItemGroupDefs ItemGroupClass ItemGroupClassSubClass CommentDefs TranslatedText TranslatedText Aliases Aliases ItemGroupLeaf ItemGroupLeafTitles;
    %let _cstTabs=igd igd_cl igd_clsc igd_cm igd_cm_tt igd_des_tt igd_al1 igd_al2 igd_lf igd_lft _ClassSubClass _cstSourceTables;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceTables;
    %* Target table expected;
    %let _cstExpTrgTables=MetaDataVersion Standards &_cstTables;

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
        _cstInputDS=&_cstSourceTables,
        _cstSrcType=table,
        _cstMessageColumns=%str(table=),  
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
     from &_cstSourceTables
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceTables will be ignored: StudyVersion IN (&_cstStudyVersions));
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

    data _cstSourceTables_&_cstRandom;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceTables, _cstVarList=Repeating)=0 %then %do;
        length Repeating $3;
        call missing(Repeating);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceTables, _cstVarList=IsReferenceData)=0 %then %do;
        length IsReferenceData $3;
        call missing(IsReferenceData);
      %end;  
      set &_cstSourceTables(where=(StudyVersion = "&_cstMDVOID"));
    run;

    data work._ClassSubClass_&_cstRandom;
      length OID_cl $5;
      set _cstSourceTables_&_cstRandom(where=(not missing(class)));
      OID_cl="CL"||strip(put(_N_, z3.));
    run;  
  
    proc sql;
      create table igd_&_cstRandom
      as select
        "IG."||kstrip(tab.Table) as OID,
        tab.Table as Name,
        tab.keys as Keys,
        tab.Repeating as Repeating,
        tab.IsReferenceData as IsReferenceData,

        ifc(length(tab.Table) le 8,tab.Table, "") as SASDatasetName length=8,
        tab.Domain as Domain,
        tab.Purpose as Purpose,
        tab.Structure as Structure,
        tab.Class as Class,
        case when not missing(tab.xmlpath)
          then "LF."||kstrip(tab.Table) 
          else ""
        end as ArchiveLocationID,
        case when not missing(tab.Comment)
          then "COM."||kstrip(tab.table)
          else ""
        end as CommentOID,
        tab.HasNoData as HasNoData,
        tab.IsNonStandard as IsNonStandard,
        stnd.OID as StandardOID,
        tab.StudyVersion as FK_MetaDataVersion
      from _cstSourceTables_&_cstRandom tab
       left join &_cstOutputLibrary..standards stnd
     on stnd.name = tab.CDISCStandard and stnd.version = tab.CDISCStandardVersion
      
      order by Order
      ;
      %* ItemGroupClass;
      create table igd_cl_&_cstRandom
      as select distinct
        tab.OID_cl as OID,
        tab.Class as Name,
        "IG."||kstrip(tab.table) as FK_ItemGroupDefs
      from _ClassSubClass_&_cstRandom tab
      where not missing(tab.class)
      order by OID
      ;
      %* ItemGroupClassSubClass;
      create table igd_clsc_&_cstRandom
      as select distinct
        tab.SubClass as Name,
        tab.OID_cl as FK_ItemGroupClass
      from _ClassSubClass_&_cstRandom tab
      where not missing(tab.subclass)
      ;
      %* CommentDefs;
      create table igd_cm_&_cstRandom
      as select distinct
        "COM."||kstrip(tab.table) as OID,
        tab.StudyVersion as FK_MetaDataVersion
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.comment)
      order by OID
      ;
      %* TranslatedText (Label - Description);
      create table igd_des_tt_&_cstRandom
      as select
        tab.label as TranslatedText,
        "&_cstLang" as lang,
        "ItemGroupDefs" as parent,
        "IG."||kstrip(tab.table) as parentKey
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.label)
      ;
      %* TranslatedText (Comment);
      create table igd_cm_tt_&_cstRandom
      as select distinct
        tab.comment as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        "COM."||kstrip(tab.table) as parentKey
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.comment)
      ;
      %* DomainDescription - Alias;
      create table igd_al1_&_cstRandom
      as select
        "DomainDescription" as Context,
        tab.DomainDescription as Name,
        "ItemGroupDefs" as parent,
        "IG."||kstrip(tab.table) as parentKey
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.domaindescription)
      ;
      %* SAS - Alias;
      create table igd_al2_&_cstRandom
      as select
        "SAS" as Context,
        tab.Table as Name,
        "ItemGroupDefs" as parent,
        "IG."||kstrip(tab.table) as parentKey
      from _cstSourceTables_&_cstRandom tab
      where length(tab.Table) gt 8
      ;
      %* Leaf;
      create table igd_lf_&_cstRandom
      as select
        "LF."||kstrip(tab.table) as ID,
        tab.xmlpath as href,
        "IG."||kstrip(tab.table) as FK_ItemGroupDefs
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.xmlpath)
      ;
      %* LeafTitles;
      create table igd_lft_&_cstRandom
      as select
        tab.xmltitle as title,
        "LF."||kstrip(tab.table) as FK_ItemGroupLeaf
      from _cstSourceTables_&_cstRandom tab
      where not missing(tab.xmltitle)
      ;
    quit;

    %* Calculate Repeating and IsReferenceData if missing;
    data igd_&_cstRandom(drop=keys);
      set igd_&_cstRandom;
      if missing(Repeating) then do;
        if indexw(upcase(strip(reverse(Keys))),"DIJBUSU")>1
          then Repeating = "Yes";
          else Repeating = "No";
      end;
      if missing(IsReferenceData) then do;
        if indexw(upcase(Keys) ,"USUBJID")
          then IsReferenceData = "No";
          else IsReferenceData = "Yes";
      end;
    run;  
    
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

%mend define_sourcetables;
