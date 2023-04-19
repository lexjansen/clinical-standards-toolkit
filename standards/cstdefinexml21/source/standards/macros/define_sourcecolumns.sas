%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcecolumns                                                           *;
%*                                                                                *;
%* Creates Define-XML column metadata data sets from source metadata.             *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.ItemGroupItemRefs                                         *;
%*    _cstOutputLibrary.ItemDefs                                                  *;
%*    _cstOutputLibrary.ItemOrigin                                                *;
%*    _cstOutputLibrary.MethodDefs                                                *;
%*    _cstOutputLibrary.CommentDefs                                               *;
%*    _cstOutputLibrary.TranslatedText[parent="ItemDefs"]                         *;
%*    _cstOutputLibrary.TranslatedText[parent="ItemOrigin"]                       *;
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
%* @param _cstSourceColumns - required - The data set that contains the source    *;
%*            columns metadata to include in the Define-XML file.                 *;
%* @param _cstSourceTables - required - The data set that contains the source     *;
%*            table metadata to include in the Define-XML file.                   *;
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
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%* @history            Added support for AlgorithmName                            *;
%* @history 2023-03-12 Added Mandatory, IsNonStandard, HasNoData, StandardOID,    *;
%* @history            OriginType and OriginSource attributes                     *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcecolumns(
    _cstSourceColumns=,
    _cstSourceTables=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML columns metadata related data sets";

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
    %let _cstTables=ItemDefs MethodDefs CommentDefs ItemGroupItemRefs TranslatedText TranslatedText TranslatedText TranslatedText FormalExpressions ItemOrigin Aliases;
    %let _cstTabs=itd itd_met itd_cm igdir itd_des_tt itd_cm_tt itd_mt_tt itd_itor_tt itd_mt_fe itor itd_al _cstSourceTables _cstSourceColumns;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceTables _cstSourceColumns;
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
        _cstInputDS=&_cstSourceColumns,
        _cstSrcType=column,
        _cstMessageColumns=%str(table= column=),  
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
     from &_cstSourceColumns
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceColumns will be ignored: StudyVersion IN (&_cstStudyVersions));
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
      set &_cstSourceTables(where=(StudyVersion = "&_cstMDVOID"));
    run;

    %* Only keep records that are define in Tables metadata;
    proc sql;
      create table _cstSourceColumns_&_cstRandom
      as select
        col.*
      from &_cstSourceColumns col, 
           _cstSourceTables_&_cstRandom tab
      where (col.StudyVersion = "&_cstMDVOID") and col.table=tab.table 
      ;
    run;  

    data _cstSourceColumns_&_cstRandom;
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceColumns, _cstVarList=Mandatory)=0 %then %do;
        length Mandatory $3;
        call missing(Mandatory);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceColumns, _cstVarList=AlgorithmType)=0 %then %do;
        length AlgorithmType $11;
        call missing(AlgorithmType);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceColumns, _cstVarList=FormalExpressionContext)=0 %then %do;
        length FormalExpressionContext $2000;
        call missing(FormalExpressionContext);
      %end;  
      %if %cstutilcheckvarsexist(_cstDataSetName=&_cstSourceColumns, _cstVarList=FormalExpression)=0 %then %do;
        length FormalExpression $2000;
        call missing(FormalExpression);
      %end;  
      set _cstSourceColumns_&_cstRandom;
    run;  

    proc sql;
      %* ItemGroupItemRefs;
      create table igdir_&_cstRandom
      as select
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column) as ItemOID,
        col.Column,
        case when missing(col.Mandatory)
          then 
            case when upcase(col.Core) ="REQ"
              then 'Yes'
              else 'No'
            end  
          else col.Mandatory  
        end as Mandatory,
        col.Order as OrderNumber,
        col.Role
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemGroupItemRefs, _cstVarName=Role, _cstAttribute=VARLEN),
        case when not missing(col.algorithm)
          then "MT."||kstrip(col.table)||"."||kstrip(col.column)
          else ""
        end as MethodOID,
        tab.Keys,
        col.IsNonStandard,
        col.HasNoData,
        "IG."||kstrip(col.Table) as FK_ItemGroupDefs
      from _cstSourceColumns_&_cstRandom col
        left join _cstSourceTables_&_cstRandom tab
      on (col.table = tab.table)
      order by tab.Order, col.Order
      ;
      %* ItemDefs;
      create table itd_&_cstRandom
      as select
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column) as OID,
        col.Column as Name,
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
        ifc(length(col.Column) le 8,col.Column, "") as SASFieldName length=8,
        col.DisplayFormat,
        case when not missing(col.Comment)
          then "COM."||kstrip(col.table)||"."||kstrip(col.column)
          else ""
        end as CommentOID,
        col.StudyVersion as FK_MetaDataVersion
      from _cstSourceColumns_&_cstRandom col
      order by OID
      ;
      %* ItemOrigin;
      create table itor_&_cstRandom
      as select
        "OR."||kstrip(col.Table)||"."||kstrip(col.Column) as OID,
        col.OriginType as Type
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemOrigin, _cstVarName=Type, _cstAttribute=VARLEN),
        col.OriginSource as Source
          length=%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..ItemOrigin, _cstVarName=Source, _cstAttribute=VARLEN),
        "IT."||kstrip(col.Table)||"."||kstrip(col.Column) as FK_ItemDefs
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.originType)
      ;
      %* CommentDefs;
      create table itd_cm_&_cstRandom
      as select distinct
        "COM."||kstrip(col.table)||"."||kstrip(col.column) as OID,
        col.StudyVersion as FK_MetaDataVersion
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.comment)
      order by OID
      ;
      %* MethodDefs;
      create table itd_met_&_cstRandom
      as select distinct
        "MT."||kstrip(col.table)||"."||kstrip(col.column) as OID,
        case when not missing(col.AlgorithmName)
          then col.AlgorithmName
          else "MT."||kstrip(col.table)||"."||kstrip(col.column)
        end as Name length=&_cstOIDLength,
        case when not missing(col.AlgorithmType)
          then col.AlgorithmType
          else "Computation"
        end as Type,
        col.StudyVersion as FK_MetaDataVersion
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.algorithm)
      order by OID
      ;
      %* TranslatedText (Label - Description);
      create table itd_des_tt_&_cstRandom
      as select
        col.label as TranslatedText,
        "&_cstLang" as lang,
        "ItemDefs" as parent,
        "IT."||kstrip(col.table)||"."||kstrip(col.Column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.label)
      ;
      %* TranslatedText (ItemOrigin);
      create table itd_itor_tt_&_cstRandom
      as select distinct
        col.origindescription as TranslatedText,
        "&_cstLang" as lang,
        "ItemOrigin" as parent,
        "OR."||kstrip(col.table)||"."||kstrip(col.column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.origindescription)
      ;
      %* TranslatedText (Comment);
      create table itd_cm_tt_&_cstRandom
      as select distinct
        col.comment as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        "COM."||kstrip(col.table)||"."||kstrip(col.column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.comment)
      ;
      %* TranslatedText (Method);
      create table itd_mt_tt_&_cstRandom
      as select distinct
        col.algorithm as TranslatedText,
        "&_cstLang" as lang,
        "MethodDefs" as parent,
        "MT."||kstrip(col.table)||"."||kstrip(col.column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.algorithm)
      ;
      %* FormalExpression (Method);
      create table itd_mt_fe_&_cstRandom
      as select distinct
        col.formalexpression as Expression,
        col.formalexpressioncontext as Context,
        "MethodDefs" as parent,
        "MT."||kstrip(col.table)||"."||kstrip(col.column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where not missing(col.formalexpression)
      ;
      %* SAS - Alias;
      create table itd_al_&_cstRandom
      as select
        "SAS" as Context,
        col.Column as Name,
        "ItemDefs" as parent,
        "IT."||kstrip(col.table)||"."||kstrip(col.Column) as parentKey
      from _cstSourceColumns_&_cstRandom col
      where length(col.Column) gt 8
      ;
    quit;

    data igdir_&_cstRandom(drop=keys column i);
      length KeySequence 8;
      set igdir_&_cstRandom;
        KeySequence=.;
        if indexw(keys,column) then do;
          do i = 1 to countw(keys,' ');
            if column = scan(keys,i) then do;
              KeySequence=i;
              leave;
            end;
          end;
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

%mend define_sourcecolumns;
