%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcevalues                                                            *;
%*                                                                                *;
%* Creates Define-XML value level metadata data sets from source metadata.        *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.ValueLists                                                *;
%*    _cstOutputLibrary.ValueListItemRefs                                         *;
%*    _cstOutputLibrary.ItemValueListRefs                                         *;
%*    _cstOutputLibrary.ItemRefWhereClauseRefs                                    *;
%*    _cstOutputLibrary.WhereClauseDefs                                           *;
%*    _cstOutputLibrary.WhereClauseRangeChecks                                    *;
%*    _cstOutputLibrary.WhereClauseRangeCheckValues                               *;
%*    _cstOutputLibrary.ItemDefs                                                  *;
%*    _cstOutputLibrary.ItemOrigin                                                *;
%*    _cstOutputLibrary.MethodDefs                                                *;
%*    _cstOutputLibrary.CommentDefs                                               *;
%*    _cstOutputLibrary.TranslatedText[parent="ItemDefs"]                         *;
%*    _cstOutputLibrary.TranslatedText[parent="CommentDefs"]                      *;
%*    _cstOutputLibrary.TranslatedText[parent="MethodDefs"]                       *;
%*    _cstOutputLibrary.FormalExpressions[parent="MethodDefs"]                    *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstSourceValues - required - The data set that contains the source     *;
%*            value level metadata to include in the Define-XML file.             *;
%* @param _cstSourceTables - required - The data set that contains the source     *;
%*            table metadata to include in the Define-XML file.                   *;
%* @param _cstSourceColumns - required - The data set that contains the source    *;
%*            columns metadata to include in the Define-XML file.                 *;
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
%* @history 2017-03-10 Added support for AlgorithmType and FormalExpressions.     *;
%*          2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added support for AlgorithmName                            *;
%*          2023-03-12 Added Mandatory, HasNoData, OriginType, OriginSource and   *;
%*                     Name attributes                                            *;
%*          2023-04-17 added support for ValueListDef Descripts.                  *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcevalues(
    _cstSourceValues=,
    _cstSourceTables=,
    _cstSourceColumns=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML VLM related data sets";

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
    %let _cstTables=ItemDefs MethodDefs CommentDefs ValueLists ValueListItemRefs ItemValueListRefs
                    ItemRefWhereClauseRefs WhereClauseDefs WhereClauseRangeChecks WhereClauseRangeCheckValues
                    TranslatedText TranslatedText TranslatedText TranslatedText TranslatedText FormalExpressions ItemOrigin;
    %let _cstTabs=itd itd_met itd_cm vl vlir ivlr irwcr wcd wcrc wcrcv itd_des_tt itd_cm_tt itd_mt_tt itd_itor_tt vl_des_tt itd_mt_fe itor
         _wc_tmp _wcrc_tmp _cstWhereClause _cstSourceValues _cstSourceValues1 _cstTabCol itd_cm1 itd_cm2 itd_cm_tt1 itd_cm_tt2;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceValues _cstSourceTables _cstSourceColumns;
    %* Target table expected;
    %let _cstExpTrgTables=MetaDataVersion &_cstTables;

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

    %* Check lengths of incoming data against template *;
    %if %upcase(%substr(&_cstCheckLengths,1,1)) = Y
    %then %do;
      %defineutil_validatelengths(
        _cstInputDS=&_cstSourceValues,
        _cstSrcType=value,
        _cstMessageColumns=%str(table= column= whereclause=),
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
     from &_cstSourcevalues
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceValues will be ignored: StudyVersion IN (&_cstStudyVersions));
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

    %defineutil_validatewhereclause(
      _cstInputDS=&_cstSourceValues,
      _cstInputVar=WhereClause,
      _cstOutputDS=_cstSourceValues1_&_cstRandom,
      _cstMessageColumns=%str(table= column=),
      _cstResultsDS=&_cstResultsDS,
      _cstReportResult=Y,
      _cstReturn=_cst_rc,
      _cstReturnMsg=_cst_rcmsg
      );

    data _cstSourceValues1_&_cstRandom;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceValues, _cstVarList=OriginDescription)=0 %then %do;
        length OriginDescription $1000;
        call missing(OriginDescription);
      %end;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceValues, _cstVarList=Mandatory)=0 %then %do;
        length Mandatory $3;
        call missing(Mandatory);
      %end;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceValues, _cstVarList=AlgorithmType)=0 %then %do;
        length AlgorithmType $11;
        call missing(AlgorithmType);
      %end;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceValues, _cstVarList=FormalExpressionContext)=0 %then %do;
        length FormalExpressionContext $2000;
        call missing(FormalExpressionContext);
      %end;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceValues, _cstVarList=FormalExpression)=0 %then %do;
        length FormalExpression $2000;
        call missing(FormalExpression);
      %end;
      set _cstSourceValues1_&_cstRandom(where=(StudyVersion = "&_cstMDVOID"));
    run;

    proc sql;
      create table _cstTabCol_&_cstRandom
      as select
      col.table,
      col.column
      from &_cstSourceTables tab,
           &_cstSourceColumns col
      where (tab.StudyVersion = "&_cstMDVOID") and
            (col.StudyVersion = "&_cstMDVOID") and
            tab.table=col.table
      order by table, column
      ;
    run;

    %* Only keep VLM records that are define in Tables and Columns metadata;
    proc sql;
      create table _cstSourceValues_&_cstRandom
      as select
        val.*
      from _cstSourceValues1_&_cstRandom val,
           _cstTabCol_&_cstRandom tabcol
      where (val.table=tabcol.table) and (val.column=tabcol.column)
      ;
    run;


    %* Create WhereClauseOID ;
    proc sort data=_cstSourceValues_&_cstRandom(keep=table column whereclause)
              out=_cstWhereClause_&_cstRandom nodupkey;
      by table column whereclause;
      where not missing(whereclause);
    run;

    data _cstWhereClause_&_cstRandom;
      length WhereClauseOID $128;
      set _cstWhereClause_&_cstRandom;
      WhereClauseOID="WC."||kstrip(table)||"."||kstrip(column)||"."||put(_n_, z5.);
    run;

    proc sql;
      create table _wc_tmp_&_cstRandom
      as select
        val.*,
        wc.WhereClauseOID
      from
        _cstSourceValues_&_cstRandom val
        left join _cstWhereClause_&_cstRandom wc
      on (val.table=wc.table) and (val.column=wc.column) and (val.WhereClause=wc.WhereClause)
         and (val.StudyVersion = "&_cstMDVOID")
      ;
    quit;

    data _wc_tmp_&_cstRandom;
      length ItemRefOID $128;
      set _wc_tmp_&_cstRandom;
      ItemRefOID="IT"||strip(put(_N_, z5.));
    run;

    %*************************************************************;
    %* split multiple conditions in one condition per record     *;
    %*************************************************************;

    %defineutil_splitwhereclause(
      _cstDSIn=_wc_tmp_&_cstRandom,
      _cstDSOut=_wcrc_tmp_&_cstRandom,
      _cstOutputLibrary=&_cstOutputLibrary,
      _cstType=VAL
    );

    %******************************************************************************;
    %* Create internal model tables                                               *;
    %******************************************************************************;

    proc sql;
      %* ValueListItemRefs;
      create table vlir_&_cstRandom
      as select
        col.ItemRefOID as OID,
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column)||"."||kstrip(col.WhereClauseOID) as ItemOID length=&_cstOIDLength,
        case when missing(col.Mandatory)
          then
            case when upcase(col.Core) ="REQ"
              then 'Yes'
              else 'No'
            end
          else col.Mandatory
        end as Mandatory,
        col.Order as OrderNumber,
        col.Role length=&_cstOIDLength,
        case when not missing(col.algorithm)
          then "MT."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID)
          else ""
        end as MethodOID length=&_cstOIDLength,
        col.HasNoData,
        "VL."||kstrip(col.Table)||"."||kstrip(col.Column) as FK_ValueLists
      from _wc_tmp_&_cstRandom col
      order by col.Table, col.Order
      ;
      %* ItemRefWhereClauseRefs;
      create table irwcr_&_cstRandom
      as select
        col.ItemRefOID as ValueListItemRefsOID,
        col.WhereClauseOID as FK_WhereClauseDefs
      from _wc_tmp_&_cstRandom col
      ;
      %* WhereClauseDefs;
      create table wcd_&_cstRandom
      as select
        col.WhereClauseOID as OID,
        case when not missing(col.WhereClauseComment)
          then "COM."||kstrip(col.table)||"."||kstrip(col.column)||".WC."||kstrip(col.WhereClauseOID)
          else ""
        end as CommentOID length=&_cstOIDLength,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      ;
      %* WhereClauseRangeChecks;
      create table wcrc_&_cstRandom
      as select distinct
        wc.FK_WhereClauseRangeChecks as OID,
        wc.Comparator,
        "Soft" as SoftHard,
        wc.ItemOID,
        wc.WhereClauseOID as FK_WhereClauseDefs
      from _wcrc_tmp_&_cstRandom wc
      ;
      %* WhereClauseRangeCheckValues;
      create table wcrcv_&_cstRandom
      as select
        wcrc.CheckValue,
        wcrc.FK_WhereClauseRangeChecks
      from _wcrc_tmp_&_cstRandom wcrc
      order by FK_WhereClauseRangeChecks, CheckValue
      ;
      %* ItemDefs;
      create table itd_&_cstRandom
      as select
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column)||"."||kstrip(col.WhereClauseOID) as OID length=&_cstOIDLength,
        case when not missing(col.Name)
          then col.Name
          else col.Column
        end as Name,
        col.XMLDataType as DataType,
        case when not missing(col.XMLCodeList)
          then Ifc(ksubstr(upcase(col.XMLCodeList),1,3)="CL.",compress(col.XMLCodeList, '$'),"CL."||compress(col.XMLCodeList, '$'))
          else ""
        end as CodeListRef
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemDefs, _cstVarName=CodeListRef, _cstAttribute=VARLEN),
        case when col.XMLDatatype in ('text' 'string' 'integer' 'float')
          then col.Length
          else .
        end as Length,
        col.SignificantDigits,
        case when not missing(col.Name)
          then ifc(length(col.Name) le 8,col.Name, "")
          else ifc(length(col.Column) le 8,col.Column, "")
        end as SASFieldName length=8,
        col.DisplayFormat,
        case when not missing(col.Comment)
          then "COM."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID)
          else ""
        end as CommentOID length=&_cstOIDLength,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      order by OID
      ;
      %* ItemOrigin;
      create table itor_&_cstRandom
      as select
        "OR."||kstrip(col.Table)||"."||kstrip(col.Column)||"."||kstrip(col.WhereClauseOID) as OID length=&_cstOIDLength,
        col.OriginType as Type
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemOrigin, _cstVarName=Type, _cstAttribute=VARLEN),
        col.OriginSource as Source
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemOrigin, _cstVarName=Source, _cstAttribute=VARLEN),
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column)||"."||kstrip(col.WhereClauseOID) as FK_ItemDefs length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.originType)
      ;
      %* ValueLists;
      create table vl_&_cstRandom
      as select distinct
        "VL."||kstrip(col.Table)||"."||kstrip(col.Column) as OID,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      order by OID
      ;
      %* TranslatedText (Description);
      create table vl_des_tt_&_cstRandom
      as select unique
        col.valuelistdescription as TranslatedText,
        "&_cstLang" as lang,
        "ValueLists" as parent,
        "VL."||kstrip(col.Table)||"."||kstrip(col.Column) as parentKey
      from _wc_tmp_&_cstRandom col
      where not missing(col.valuelistdescription)
      ;
      %* ItemValueListRefs;
      create table ivlr_&_cstRandom
      as select distinct
        "VL."||kstrip(col.Table)||"."||kstrip(col.Column) as ValueListOID,
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column) as FK_ItemDefs
      from _wc_tmp_&_cstRandom col
      order by ValueListOID
      ;
      %* CommentDefs;
      create table itd_cm1_&_cstRandom
      as select distinct
        case
          when not missing(col.comment)
            then "COM."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID)
          else ""
        end as OID length=&_cstOIDLength,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      where not missing(col.comment)
      order by OID
      ;
      create table itd_cm2_&_cstRandom
      as select distinct
        case
          when not missing(col.whereclausecomment)
            then "COM."||kstrip(col.table)||"."||kstrip(col.column)||".WC."||kstrip(col.WhereClauseOID)
          else ""
        end as OID length=&_cstOIDLength,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      where not missing(col.whereclausecomment)
      order by OID
      ;
    quit;

    data itd_cm_&_cstRandom;
      set itd_cm1_&_cstRandom
          itd_cm2_&_cstRandom;
    run;
    proc sort data=itd_cm_&_cstRandom;
      by OID;
    run;

    proc sql;
      %* MethodDefs;
      create table itd_met_&_cstRandom
      as select distinct
        "MT."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID) as OID length=&_cstOIDLength,
        case when not missing(col.AlgorithmName)
          then col.AlgorithmName
          else "MT."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID)
        end as Name length=&_cstOIDLength,
        case when not missing(col.AlgorithmType)
          then col.AlgorithmType
          else "Computation"
        end as Type,
        col.StudyVersion as FK_MetaDataVersion
      from _wc_tmp_&_cstRandom col
      where not missing(col.algorithm)
      order by OID
      ;
      %* TranslatedText (Label - Description);
      create table itd_des_tt_&_cstRandom
      as select
        col.label as TranslatedText,
        "&_cstLang" as lang,
        "ItemDefs" as parent,
        "IT."||kstrip(col.table)||"."||kstrip(col.Column)||"."||kstrip(col.WhereClauseOID) as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.label)
      ;
      %* TranslatedText (ItemOrigin);
      create table itd_itor_tt_&_cstRandom
      as select distinct
        col.origindescription as TranslatedText,
        "&_cstLang" as lang,
        "ItemOrigin" as parent,
        "OR."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID) as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.origindescription)
      ;
      %* TranslatedText (Comment);
      create table itd_cm_tt1_&_cstRandom
      as select distinct
        case
          when not missing(col.comment) then col.comment
        end as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        case
          when not missing(col.comment)
            then "COM."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID)
          else ""
        end as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.comment)
      ;
      create table itd_cm_tt2_&_cstRandom
      as select distinct
        case
          when not missing(col.whereclausecomment) then col.whereclausecomment
        end as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        case
          when not missing(col.whereclausecomment)
            then "COM."||kstrip(col.table)||"."||kstrip(col.column)||".WC."||kstrip(col.WhereClauseOID)
          else ""
        end as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.whereclausecomment)
      ;
    quit;

    data itd_cm_tt_&_cstRandom;
      set itd_cm_tt1_&_cstRandom
          itd_cm_tt2_&_cstRandom;
    run;

    proc sql;
      %* TranslatedText (Method);
      create table itd_mt_tt_&_cstRandom
      as select distinct
        col.algorithm as TranslatedText,
        "&_cstLang" as lang,
        "MethodDefs" as parent,
        "MT."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID) as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.algorithm)
      ;
      %* FormalExpression (Method);
      create table itd_mt_fe_&_cstRandom
      as select distinct
        col.formalexpression as Expression,
        col.formalexpressioncontext as Context,
        "MethodDefs" as parent,
        "MT."||kstrip(col.table)||"."||kstrip(col.column)||"."||kstrip(col.WhereClauseOID) as parentKey length=&_cstOIDLength
      from _wc_tmp_&_cstRandom col
      where not missing(col.formalexpression)
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

%mend define_sourcevalues;
