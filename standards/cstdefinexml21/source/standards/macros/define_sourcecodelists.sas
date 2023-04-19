%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcecodelists                                                         *;
%*                                                                                *;
%* Creates Define-XML codelist metadata data sets from source metadata.           *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*    _cstOutputLibrary.CodeLists                                                 *;
%*    _cstOutputLibrary.EnumeratedItems                                           *;
%*    _cstOutputLibrary.CodeListItems                                             *;
%*    _cstOutputLibrary.ExternalCodeLists                                         *;
%*    _cstOutputLibrary.TranslatedText[parent="CodeListItems"]                    *;
%*    _cstOutputLibrary.Aliases[parent="CodeLists"]                               *;
%*    _cstOutputLibrary.Aliases[parent="EnumeratedItems"]                         *;
%*    _cstOutputLibrary.Aliases[parent="CodeListItems"]                           *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstSourceCodelists - required - The data set that contains the source  *;
%*            codelist metadata to include in the Define-XML file.                *;
%* @param _cstSourceTables - required - The data set that contains the source     *;
%*            table metadata to include in the Define-XML file.                   *;
%* @param _cstSourceColumns - required - The data set that contains the source    *;
%*            columns metadata to include in the Define-XML file.                 *;
%* @param _cstSourceValues - optional - The data set that contains the source     *;
%*            value level metadata to include in the Define-XML file.             *;
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
%*          2023-03-12 Added IsNonStandard, StandardOID, Comment and Description  *;
%*                     attributes                                                 *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcecodelists(
    _cstSourceCodelists=,
    _cstSourceTables=,
    _cstSourceColumns=,
    _cstSourceValues=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML codelists metadata related data sets";


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
     _cstClLen
     _cstThisMacro
     ;

    %let _cstThisMacro=&sysmacroname;
    %* The data sets to be created and the work data sets;
    %let _cstTables=CodeLists CommentDefs TranslatedText TranslatedText EnumeratedItems CodeListItems TranslatedText TranslatedText TranslatedText ExternalCodeLists Aliases Aliases Aliases Aliases;
    %let _cstTabs=cl cl_cm cl_cm_tt cl_tt clen clci clit_dec_tt clit_desc_tt enit_desc_tt clext cl_al1 cl_al2 clen_al clci_al cl0 cl1 cl2 _cstCodeListRefs _cstCodeListRefs2 _cstSourceCodeLists _cstSourceCodeLists0;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceCodeLists _cstSourceTables _cstSourceColumns;
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
        _cstInputDS=&_cstSourceCodeLists,
        _cstSrcType=codelist,
        _cstMessageColumns=%str(codelist= codedvaluechar= codedvaluenum=),  
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
     from &_cstSourceCodeLists
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceCodeLists will be ignored: StudyVersion IN (&_cstStudyVersions));
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

    %* Create a dataset with the unique codelist references, strip $;    
    data _cstCodeListRefs_&_cstRandom(keep=table XMLCodeList);
      set &_cstSourceColumns &_cstSourceValues;
        XMLCodeList=upcase(compress(XMLCodeList, '$'));
        if not missing(XMLCodeList) and (StudyVersion = "&_cstMDVOID");
    run;

    proc sql;
      create table _cstCodeListRefs2_&_cstRandom
      as select
      XMLCodeList
      from  _cstCodeListRefs_&_cstRandom cr,
            &_cstSourceTables tab
      where (tab.StudyVersion = "&_cstMDVOID") and (tab.table=cr.table)
      ;
    quit;

    proc sort data=_cstCodeListRefs2_&_cstRandom nodupkey;
    by XMLCodeList;
    run;

    data _cstSourceCodeLists0_&_cstRandom;
      set &_cstSourceCodeLists;
      retain __order__ 0;
      by codelist notsorted;
      if first.codelist then __order__=0;
      __order__ +1;
    run;

    %* Only keep CodeLists that are referenced;
    proc sql;
      create table _cstSourceCodeLists_&_cstRandom 
      as select
      cl.*
      from _cstSourceCodeLists0_&_cstRandom cl, 
           _cstCodeListRefs2_&_cstRandom cr
      where (StudyVersion = "&_cstMDVOID") and 
            ((upcase(compress(cl.CodeList, '$')) = upcase(compress(cr.XMLCodeList, '$'))) or 
             (upcase(compress(cl.CodeList, '$')) = "CL."||upcase(compress(cr.XMLCodeList, '$'))))
      ;
    quit;

    data cl0_&_cstRandom;
      length CodedValue $%cstutilgetattribute(_cstDataSetName=&_cstSourceCodelists, _cstVarName=CodedValueChar, _cstAttribute=VARLEN);;
      set _cstSourceCodeLists_&_cstRandom;
      if not missing(CodedValueChar)
        then CodedValue = CodedValueChar;
        else CodedValue = kstrip(put(CodedValueNum, best.));
    run;

    proc sort data=cl0_&_cstRandom;
     by CodeList Rank OrderNumber CodedValue;
    run;

    data cl0_&_cstRandom;
      length ItemOID $8;
      set cl0_&_cstRandom;
      ItemOID="CLI"||strip(put(_N_, z5.));
    run;

    data cl1_&_cstRandom;
      set cl0_&_cstRandom;
      by CodeList Rank OrderNumber CodedValue;
      if first.CodeList;
      if not missing(SASFormatName) then do;
        if CodeListDataType = "text" and substr(SASFormatName, 1, 1) ne '$' then SASFormatName = cats('$', SASFormatName);
      end;
    run;

    data cl2_&_cstRandom(keep=CodeList CodeListType);
      retain CodeListType;
      length CodeListType $10;
      set cl0_&_cstRandom(where=(missing(dictionary)));
      by CodeList Rank OrderNumber CodedValue;
      if first.CodeList then CodeListType="Enumerated";
      if (not missing(DecodeText)) and (DecodeText ne CodedValue) then CodeListType="CodeDecode";
      if last.CodeList;
    run;

    %let _cstClLen=%cstutilgetattribute(_cstDataSetName=&_cstSourceCodeLists, _cstVarName=CodeList, _cstAttribute=VARLEN);

    proc sql;
      %* CodeLists;
      create table cl_&_cstRandom
      as select
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as OID length=&_cstClLen,
        cl.CodeListName as name,
        cl.CodeListDataType as DataType,
        ifc(length(cl.SASFormatName) le 8,cl.SASFormatName, "") as SASFormatName length=8,
        case when not missing(cl.Comment)
          then ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.","COM."||cl.CodeList,"COM.CL."||cl.CodeList)
          else ""
        end as CommentOID length=&_cstClLen,
        cl.IsNonStandard,
        stnd.OID as StandardOID,
        cl.StudyVersion as FK_MetaDataVersion
      from cl1_&_cstRandom cl
        left join &_cstOutputLibrary..standards stnd
      on stnd.name = cl.CDISCStandard and stnd.version = cl.CDISCStandardVersion and stnd.PublishingSet=cl.PublishingSet
      order by cl.dictionary, CodeList
      ;

      %* CommentDefs;
      create table cl_cm_&_cstRandom
      as select distinct
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.","COM."||cl.CodeList,"COM.CL."||cl.CodeList) as OID length=&_cstClLen,
        cl.StudyVersion as FK_MetaDataVersion
      from cl1_&_cstRandom cl
      where not missing(cl.comment)
      order by OID
      ;
       %* TranslatedText (Comment);
      create table cl_cm_tt_&_cstRandom
      as select distinct
        cl.comment as TranslatedText,
        "&_cstLang" as lang,
        "CommentDefs" as parent,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.","COM."||cl.CodeList,"COM.CL."||cl.CodeList) as parentKey length=&_cstClLen
      from cl1_&_cstRandom cl
      where not missing(cl.comment)
      ;

 
      %* TranslatedText (CodeList description);
      create table cl_tt_&_cstRandom
      as select
        cl.CodeListDescription as TranslatedText,
        "&_cstLang" as lang,
        "CodeLists" as parent,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as parentKey length=&_cstClLen
      from cl1_&_cstRandom cl
      where not missing(cl.CodeListDescription)
      ;

      %* EnumeratedItems;
      create table clen_&_cstRandom
      as select
        cl.ItemOID as OID,
        cl.CodedValue as CodedValue,
        cl.Rank as Rank,
        cl.OrderNumber as OrderNumber,
        cl.ExtendedValue as ExtendedValue,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as FK_CodeLists length=&_cstClLen
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where cl2.CodeListType="Enumerated" and cl.CodeList=cl2.CodeList
      order by cl.CodeList, Rank, OrderNumber, __order__, CodedValue
      ;

      %* CodeListItems;
      create table clci_&_cstRandom
      as select
        cl.ItemOID as OID,
        cl.CodedValue as CodedValue,
        cl.Rank as Rank,
        cl.OrderNumber as OrderNumber,
        cl.ExtendedValue as ExtendedValue,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as FK_CodeLists length=&_cstClLen
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where cl2.CodeListType="CodeDecode" and cl.CodeList=cl2.CodeList
      order by cl.CodeList, Rank, OrderNumber, __order__, CodedValue
      ;
      %* TranslatedText (CodeListItems);
      create table clit_dec_tt_&_cstRandom
      as select
        cl.DecodeText as TranslatedText,
        cl.DecodeLanguage as lang,
        "CodeListItems" as parent,
        cl.ItemOID as parentKey
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where cl2.CodeListType="CodeDecode" and cl.CodeList=cl2.CodeList
      ;

      %* TranslatedText (CodeListItems descriptions);
      create table clit_desc_tt_&_cstRandom
      as select
        cl.CodeListItemDescription as TranslatedText,
        "&_cstLang" as lang,
        "CodeListItemDescription" as parent,
        cl.ItemOID as parentKey
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where cl2.CodeListType="CodeDecode" and cl.CodeList=cl2.CodeList and
            not missing(cl.CodeListItemDescription)
      ;
      %* TranslatedText (EnumeratedItems descriptions);
      create table enit_desc_tt_&_cstRandom
      as select
        cl.CodeListItemDescription as TranslatedText,
        "&_cstLang" as lang,
        "EnumeratedItemDescription" as parent,
        cl.ItemOID as parentKey
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where cl2.CodeListType="Enumerated" and cl.CodeList=cl2.CodeList and
            not missing(cl.CodeListItemDescription)
      ;

      %* ExternalCodeLists;
      create table clext_&_cstRandom
      as select
        cl.Dictionary as Dictionary,
        cl.Version as Version,
        cl.ref as ref,
        cl.href as href,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as FK_CodeLists length=&_cstClLen
      from cl0_&_cstRandom cl
      where not missing(cl.dictionary)
      order by CodeList
      ;

      %* CodeList Alias;
      create table cl_al1_&_cstRandom
      as select
        "nci:ExtCodeID" as Context,
        cl.CodeListNCICode as Name,
        "CodeLists" as parent,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as parentKey length=&_cstClLen
      from cl1_&_cstRandom cl
      where not missing(cl.CodeListNCICode)
      ;

      %* CodeList Alias;
      create table cl_al2_&_cstRandom
      as select
        "SAS" as Context,
        cl.SASFormatName as Name,
        "CodeLists" as parent,
        ifc(ksubstr(upcase(cl.CodeList),1,3)="CL.",cl.CodeList,"CL."||cl.CodeList) as parentKey length=&_cstClLen
      from cl1_&_cstRandom cl
      where length(cl.SASFormatName) gt 8 
      ;

      %* CodeList EnumeratedItem Alias;
      create table clen_al_&_cstRandom
      as select
        "nci:ExtCodeID" as Context,
        cl.CodedValueNCICode as Name,
        "EnumeratedItems" as parent,
        cl.ItemOID as parentKey
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where not missing(cl.CodedValueNCICode) and
        cl2.CodeListType="Enumerated" and
        cl.CodeList=cl2.CodeList
      ;
      %* CodeList CodeListItem Alias;
      create table clci_al_&_cstRandom
      as select
        "nci:ExtCodeID" as Context,
        cl.CodedValueNCICode as Name,
        "CodeListItems" as parent,
        cl.ItemOID as parentKey
      from cl0_&_cstRandom cl, cl2_&_cstRandom cl2
      where not missing(cl.CodedValueNCICode)
        and cl2.CodeListType="CodeDecode"
        and cl.CodeList=cl2.CodeList
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

%mend define_sourcecodelists;
