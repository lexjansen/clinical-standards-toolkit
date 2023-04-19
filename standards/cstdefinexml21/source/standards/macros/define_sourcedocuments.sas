%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_sourcedocuments                                                         *;
%*                                                                                *;
%* Creates Define-XML document-related data sets from source metadata.            *;
%*                                                                                *;
%* These data sets are created:                                                   *;
%*                                                                                *;
%*      _cstOutputLibrary.AnnotatedCRFs                                           *;
%*      _cstOutputLibrary.SupplementalDocs                                        *;
%*      _cstOutputLibrary.MDVLeaf                                                 *;
%*      _cstOutputLibrary.MDVLeafTitles                                           *;
%*      _cstOutputLibrary.DocumentRefs                                            *;
%*      _cstOutputLibrary.PDFPageRefs                                             *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstSourceDocuments - required - The data set that contains the source  *;
%*            document refererences metadata to include in the Define-XML file.   *;
%* @param _cstSourceTables - required - The data set that contains the source     *;
%*            table metadata to include in the Define-XML file.                   *;
%* @param _cstSourceColumns - required - The data set that contains the source    *;
%*            columns metadata to include in the Define-XML file.                 *;
%* @param _cstSourceValues - optional - The data set that contains the source     *;
%*            value level metadata to include in the Define-XML file.             *;
%* @param _cstSourceAnalysisResults - optional - The data set that contains the   *;
%*            source analysis results metadata to include in the Define-XML file. *;
%* @param _cstOutputLibrary - required - The library to write the Define-XML data *;
%*            sets.                                                               *;
%*            Default: srcdata                                                    *;
%* @param _cstCheckLengths - optional - Check the actual value lengths of         *;
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
%* @history            Added support for PDFPageRefTitle                          *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_sourcedocuments(
    _cstSourceDocuments=,
    _cstSourceTables=,
    _cstSourceColumns=,
    _cstSourceValues=,
    _cstSourceAnalysisResults=,
    _cstOutputLibrary=srcdata,
    _cstCheckLengths=N,
    _cstLang=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des ="Creates SAS Define-XML document metadata related data sets";

    %local
     i
     _cstExpSrcTables
     _cstExpTrgTables
     _cstTable
     _cstTables
     _cstTabs
     _cstUseVLM
     _cstUseARM
     _cstMissing
     _cstReadOnly
     _cstMDVIgnored
     _cstStudyVersions
     _cstMDVOID
     _cstRandom
     _cstRecs
     _cstThisMacro
     _cstOIDLength
     _cstSaveOptions
     ;

    %if %sysevalf(%superq(_cstSourceValues)=, boolean) %then %let _cstUseVLM=0;
                                                       %else %let _cstUseVLM=1;
    %if %sysevalf(%superq(_cstSourceAnalysisResults)=, boolean) %then %let _cstUseARM=0;
                                                                %else %let _cstUseARM=1;

    %let _cstThisMacro=&sysmacroname;
    %* The data sets to be created and the work data sets;
    %let _cstTables=AnnotatedCRFs SupplementalDocs MDVLeaf MDVLeafTitles DocumentRefs PDFPageRefs;
    %let _cstTabs=acrf supp mdvl mdvlt docr pdfpr 
                  _cst_tabcol _cst_doc_tmp0 _cst_doc_tmp1 _cst_doc_tmp2 _cstWhereClause_VLM 
                  _cstSourceDocuments _cstSourceDocuments2 _cstSourceValues _cstSourceValues1;
    %* Source tables expected;
    %let _cstExpSrcTables=_cstSourceDocuments _cstSourceTables _cstSourceColumns;
    %if &_cstUseVLM %then %let _cstExpSrcTables=&_cstExpSrcTables _cstSourceValues;
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
        _cstInputDS=&_cstSourceDocuments,
        _cstSrcType=document,
        _cstMessageColumns=%str(doctype= href= title= table= column= whereclause=),  
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
     from &_cstSourceDocuments
     where (StudyVersion ne "&_cstMDVOID")
     ;
    quit;
    %let _cstMDVOID=&_cstMDVOID;
    %let _cstMDVIgnored=&_cstMDVIgnored;

    %* There should only be one MetaDataVersion element (StudyVersion) *;
    %if &_cstMDVIgnored gt 0
      %then %do;
        %let &_cstReturnMsg=%str(&_cstMDVIgnored records from &_cstSourceDocuments will be ignored: StudyVersion IN (&_cstStudyVersions));
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

    %defineutil_validatewhereclause(
      _cstInputDS=&_cstSourceDocuments,
      _cstInputVar=WhereClause,
      _cstOutputDS=_cstSourceDocuments_&_cstRandom,
      _cstMessageColumns=%str(DocType= Table= Column=),
      _cstResultsDS=&_cstResultsDS,
      _cstReportResult=Y,
      _cstReturn=_cst_rc,
      _cstReturnMsg=_cst_rcmsg
      );

    data _cstSourceDocuments_&_cstRandom;
      set _cstSourceDocuments_&_cstRandom(where=(StudyVersion = "&_cstMDVOID"));
    run;

    %*************************************************************;

    %if &_cstUseVLM=1 %then %do;

      %defineutil_validatewhereclause(
        _cstInputDS=&_cstSourceValues,
        _cstInputVar=WhereClause,
        _cstOutputDS=_cstSourceValues1_&_cstRandom,
        _cstMessageColumns=%str(Table= Column=),
        _cstResultsDS=&_cstResultsDS,
        _cstReportResult=N,
        _cstReturn=_cst_rc,
        _cstReturnMsg=_cst_rcmsg
        );
  
      data _cstSourceValues1_&_cstRandom;
        set _cstSourceValues1_&_cstRandom(where=(StudyVersion = "&_cstMDVOID"));
      run;

      proc sql;
        create table _cst_TabCol_&_cstRandom
        as select 
        col.table,
        col.column
        from &_cstSourceTables tab, 
             &_cstSourceColumns col 
        where (tab.StudyVersion = "&_cstMDVOID") and 
              (col.StudyVersion = "&_cstMDVOID") and
              tab.table=col.table
        ;
      quit;  
  
      %* Only keep VLM records that are define in Tables and Columns metadata;
      proc sql;
        create table _cstSourceValues_&_cstRandom
        as select
          val.*
        from _cstSourceValues1_&_cstRandom val,
             _cst_TabCol_&_cstRandom tabcol 
        where (val.table=tabcol.table) and (val.column=tabcol.column)
        ;
      quit;  

      %* Create WhereClauseOID ;
      proc sort data=_cstSourceValues_&_cstRandom(keep=table column whereclause)
                out=_cstWhereClause_VLM_&_cstRandom nodupkey;
        by table column whereclause;
        where not missing(whereclause);
      run;

      data _cstWhereClause_VLM_&_cstRandom;
        length WhereClauseOID $128;
        set _cstWhereClause_VLM_&_cstRandom;
        WhereClauseOID="WC."||kstrip(table)||"."||kstrip(column)||"."||put(_n_, z5.);
      run;

    %end; %* _cstUseVLM=1 ;

    %*************************************************************;


    proc sql;
      create table _cstSourceDocuments2_&_cstRandom
      as select
        doc.*,
        case
          when upcase(doc.doctype)="CRF" then "acrf"
          when upcase(doc.doctype)="SUPPDOC" then "supportdoc"
          when upcase(doc.doctype)="METHOD" then "supportdoc"
          when upcase(doc.doctype)="COMMENT" then "supportdoc"
          when upcase(doc.doctype)="DISPLAY" then "supportdoc"
          when upcase(doc.doctype)="RESULTDOC" then "supportdoc"
          when upcase(doc.doctype)="RESULTCODE" then "supportdoc"
          else ""
        end as doctype2
        %if &_cstUseVLM %then , wc_vlm.WhereClauseOID;
      from
        _cstSourceDocuments_&_cstRandom doc
      %if &_cstUseVLM %then %do;
          left join _cstWhereClause_VLM_&_cstRandom wc_vlm
        on (doc.table=wc_vlm.table) and (doc.column=wc_vlm.column) and (doc.WhereClause=wc_vlm.WhereClause)
      %end;
      ;
    quit;

    %*************************************************************;

    data _cst_doc_tmp0_&_cstRandom;
      set _cstSourceDocuments2_&_cstRandom(keep=studyversion doctype doctype2 href title Standard StandardVersion);
      if missing(doctype2) then put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Invalid " doctype= href= title=;
      if not missing(doctype2);
    run;

    proc sort data=_cst_doc_tmp0_&_cstRandom nodupkey;
    by studyversion doctype2 title href;
    run;

    data _cst_doc_tmp0_&_cstRandom(drop=_cstCounter);
      retain _cstCounter;
      length leafid $64 _cstCounter 8;
      set _cst_doc_tmp0_&_cstRandom;
      by studyversion doctype2 title href;
      if first.doctype2 then _cstCounter=1;
      leafid=cats('LF.', doctype2, ".", put(_cstCounter, z3.));
      _cstCounter+1;
    run;

    proc sql;
      create table _cst_doc_tmp2_&_cstRandom
      as select
        doc.*,
        tmp.leafID,
        case
          when upcase(doc.doctype)="CRF" then "ItemOrigin"
          when upcase(doc.doctype)="COMMENT" then "CommentDefs"
          when upcase(doc.doctype)="METHOD" then "MethodDefs"
          when upcase(doc.doctype)="DISPLAY" then "AnalysisResultDisplays"
          when upcase(doc.doctype)="RESULTDOC" then "AnalysisDocumentation"
          when upcase(doc.doctype)="RESULTCODE" then "AnalysisProgrammingCode"
          else ""
        end as parent,
        case
          when upcase(doc.doctype)="CRF" and missing(doc.whereclause)
            then "OR."||kstrip(doc.table)||"."||kstrip(doc.column)

          %if &_cstUseVLM %then when upcase(doc.doctype)="CRF" and not missing(doc.whereclause) and not missing(doc.WhereClauseOID)
            then "OR."||kstrip(doc.table)||"."||kstrip(doc.column)||"."||kstrip(doc.WhereClauseOID);

          when upcase(doc.doctype)="COMMENT" and not missing(igd.CommentOID) then igd.CommentOID
          when upcase(doc.doctype)="COMMENT" and not missing(itd.CommentOID) then itd.CommentOID
          when upcase(doc.doctype)="COMMENT" and not missing(cl.CommentOID) then cl.CommentOID

          when upcase(doc.doctype)="COMMENT" and upcase(doc.docsubtype)="MDV" and not missing(mdv.CommentOID) then mdv.CommentOID
          when upcase(doc.doctype)="COMMENT" and upcase(doc.docsubtype)="STANDARD" and not missing(stnd.CommentOID) then stnd.CommentOID

          %if &_cstUseVLM %then 
            when upcase(doc.doctype)="COMMENT" and not missing(itdv.CommentOID) then itdv.CommentOID;
          %if &_cstUseVLM %then 
            when upcase(doc.doctype)="COMMENT" and not missing(wcd.CommentOID) then wcd.CommentOID;

          when upcase(doc.doctype)="METHOD" and not missing(igir.MethodOID) then igir.MethodOID

          %if &_cstUseVLM %then 
            when upcase(doc.doctype)="METHOD" and not missing(vlir.MethodOID) then vlir.MethodOID;

          %if &_cstUseARM %then %do;
              when upcase(doc.doctype)="DISPLAY" and not missing(armrd.OID) then armrd.OID
              when upcase(doc.doctype)="RESULTDOC" and not missing(armdoc.OID) then armdoc.OID
              when upcase(doc.doctype)="RESULTCODE" and not missing(armcode.OID) then armcode.OID
          %end;
          else ""
        end as parentKey length=&_cstOIDLength
      from
        _cstSourceDocuments2_&_cstRandom doc
        left join _cst_doc_tmp0_&_cstRandom tmp
      on (doc.doctype2=tmp.doctype2 and doc.href=tmp.href and doc.title=tmp.title)
        left join &_cstOutputLibrary..ItemGroupDefs igd
      on (doc.doctype="COMMENT" and "IG."||kstrip(doc.Table)=igd.OID and
          missing(doc.Column) and not missing(igd.CommentOID))
        left join &_cstOutputLibrary..ItemDefs itd
      on (doc.doctype="COMMENT" and "IT."||kstrip(doc.Table)||"."||kstrip(doc.Column)=itd.OID and
          missing(doc.WhereClause) and not missing(itd.CommentOID))

        left join &_cstOutputLibrary..MetaDataVersion mdv
      on (doc.doctype="COMMENT" and doc.docsubtype="MDV" and doc.StudyVersion=mdv.OID and not missing(mdv.CommentOID))

        left join &_cstOutputLibrary..Standards stnd
      on (doc.doctype="COMMENT" and doc.docsubtype="STANDARD" and stnd.name = doc.CDISCStandard and 
                                    stnd.version = doc.CDISCStandardVersion and 
                                    stnd.PublishingSet = doc.PublishingSet and 
                                    not missing(stnd.CommentOID))
        left join &_cstOutputLibrary..CodeLists cl
      on (doc.doctype="COMMENT" and doc.docsubtype="CODELIST" and doc.codelist=cl.OID and not missing(cl.CommentOID))

      %if &_cstUseVLM %then %do;
          left join &_cstOutputLibrary..ItemDefs itdv
        on (doc.doctype="COMMENT" and "IT."||kstrip(doc.Table)||"."||kstrip(doc.Column)||"."||kstrip(doc.WhereClauseOID)=itdv.OID and
            not missing(doc.WhereClause) and not missing(itdv.CommentOID))
          left join &_cstOutputLibrary..whereclausedefs wcd
        on (doc.doctype="COMMENT" and kstrip(doc.WhereClauseOID)=wcd.OID and
            not missing(doc.WhereClause) and not missing(wcd.CommentOID))
      %end;

        left join &_cstOutputLibrary..ItemGroupItemRefs igir
      on (doc.doctype="METHOD" and "IT."||kstrip(doc.Table)||"."||kstrip(doc.Column)=igir.ItemOID and
          missing(doc.WhereClause) and not missing(igir.MethodOID))

      %if &_cstUseVLM %then %do;
          left join &_cstOutputLibrary..ValueListItemRefs vlir
        on (doc.doctype="METHOD" and "IT."||kstrip(doc.Table)||"."||kstrip(doc.Column)||"."||kstrip(doc.WhereClauseOID)=vlir.ItemOID and
            not missing(doc.WhereClause) and not missing(vlir.MethodOID))
      %end;

      %if &_cstUseARM %then %do;
          left join &_cstOutputLibrary..AnalysisResultDisplays armrd
        on (doc.doctype="DISPLAY" and doc.DisplayIdentifier=armrd.OID)
          left join &_cstOutputLibrary..AnalysisDocumentation armdoc
        on (doc.doctype="RESULTDOC" and doc.ResultIdentifier=armdoc.FK_AnalysisResults)
          left join &_cstOutputLibrary..AnalysisProgrammingCode armcode
        on (doc.doctype="RESULTCODE" and doc.ResultIdentifier=armcode.FK_AnalysisResults)
      %end;
      ;
    quit;


    %* The message variable might get very long, but it is ok if it gets truncated;
    %let _cstSaveOptions = %sysfunc(getoption(varlenchk, keyword));
    options varlenchk=nowarn;

    data _cst_doc_tmp2_&_cstRandom;
      length OID $6 FirstPage LastPage 8 message $500 _cstDeleteRecord 8;
      set _cst_doc_tmp2_&_cstRandom end=end;
      OID="D"||strip(put(_N_, z5.));
      PDFPageRefs=strip(PDFPageRefs);
      if PDFPageRefType="PhysicalRef" then do;
        if index(PDFPageRefs, "-") then do;
          /* PDFPageRefs = compress(PDFPageRefs, '0123456789-', 'k'); */
          FirstPage=input(scan(PDFPageRefs, 1, "-"), ?? best.);
          if missing(FirstPage) or kverify(kstrip(kscan(PDFPageRefs, 1, "-")),'0123456789') 
            then do;
              put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Invalid FirstPage in " 
                  DocType= DocSubType= table= column= whereclause= parent= parentKey= PDFPageRefs=;
              FirstPage=.;
              message = "Invalid FirstPage in PDFPageRefs";
            end;
          LastPage=input(scan(PDFPageRefs, 2, "-"), ?? best.);
          if missing(LastPage) or kverify(kstrip(kscan(PDFPageRefs, 2, "-")),'0123456789')
            then do;
              put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Invalid LastPage in " 
                  DocType= DocSubType= table= column= whereclause= parent= parentKey= PDFPageRefs=;
              LastPage=.;
              message = "Invalid LastPage in PDFPageRefs=";
            end;  
          if (not missing(FirstPage)) and (not missing(LastPage)) 
            then PDFPageRefs="";
            else PDFPageRefs=tranwrd(PDFPageRefs, '-', ' - ');
        end;
        else do;
           if compress(pdfpagerefs, , 'kds') ne pdfpagerefs 
             then do;
               put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Invalid physical PDFPageRefs in " 
                   DocType= DocSubType= table= column= whereclause= parent= parentKey= PDFPageRefs=;
              message = "Invalid physical PDFPageRefs";
             end;
        end;  
      end;  
      if (missing(parent) or missing(parentKey)) and doctype ne "SUPPDOC" then do;
        put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Document is not referenced and will be ignored: " 
            DocType= DocSubType= href= title= standard= standardversion= table= column= whereclause= codelist= parent= parentKey=;
        message='Document is not referenced and will be ignored';
        _cstDeleteRecord=1;
      end;
      
    run;

    %cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK,_cstType=results,_cstSubType=results,_cstOutputDS=work._cstIssues_&_cstRandom);

    data work._cstIssues_&_cstRandom(drop=href title DocType DocSubType PDFPageRefType PDFPageRefs standard standardversion table column whereclause codelist);
      set work._cstIssues_&_cstRandom
         work._cst_doc_tmp2_&_cstRandom(where=(not missing(message)) keep=message href title DocType DocSubType PDFPageRefType PDFPageRefs standard standardversion table column whereclause codelist);
      resultid="DEF0098";
      srcdata="&_cstThisMacro";
      resultseq=1;
      seqno=_n_;
      resultseverity="Warning";
      resultflag=1;
      _cst_rc=0;
      message=catt(message, ": DocType=", DocType, ", DocSubType=", DocSubType, ", href=", href, ", Title=", title);
      if not missing(PDFPageRefs) then message=catt(message, ", PDFPageRefType=", PDFPageRefType, ", PDFPageRefs=", PDFPageRefs);
      message=catt(message, ", Standard=", standardVersion, ", Table=", table, ", Column=", column, ", WhereClause=", whereclause, ", CodeList=", codelist);
    run;

    options &_cstSaveOptions;    

    %if %symexist(_cstResultsDS) %then
    %do;
      %if %klength(&_cstResultsDS) > 0 and %sysfunc(exist(&_cstResultsDS)) %then
      %do;
         proc append base=&_cstResultsDS data=work._cstIssues_&_cstRandom force;
         run;
      %end;
    %end;

    * Cleanup;
    %if (&_cstDebug=0) %then %do;
      %cstutil_deleteDataSet(_cstDataSetName=work._cstIssues_&_cstRandom);
    %end;

    proc sort data=_cst_doc_tmp2_&_cstRandom(Where=(_cstDeleteRecord ne 1))
      out=_cst_doc_tmp1_&_cstRandom(keep=studyversion doctype2 title href leafid) nodupkey;
    by studyversion doctype2 title href;
    run;  


    %***********************************************;


    proc sql;
      %* AnnotatedCRFs;
      create table acrf_&_cstRandom
      as select
        leafID,
        StudyVersion as FK_MetaDataVersion
      from _cst_doc_tmp1_&_cstRandom
      where upcase(doctype2) = 'ACRF'
      ;
      %* SupplementalDocs;
      create table supp_&_cstRandom
      as select
        leafID,
        StudyVersion as FK_MetaDataVersion
      from _cst_doc_tmp2_&_cstRandom
      where upcase(doctype)="SUPPDOC"
      order by title
      ;
      %* MDVLeaf;
      create table mdvl_&_cstRandom
      as select
        leafID as ID,
        href,
        StudyVersion as FK_MetaDataVersion
      from _cst_doc_tmp1_&_cstRandom
      ;
      %* MDVLeafTitles;
      create table mdvlt_&_cstRandom
      as select
        title,
        leafID as FK_MDVLeaf
      from _cst_doc_tmp1_&_cstRandom
      ;

      %* DocumentRefs;
      create table docr_&_cstRandom
      as select
        OID,
        leafID,
        parent,
        parentKey
      from _cst_doc_tmp2_&_cstRandom
      ;
      %* PDFPageRefs;
      create table pdfpr_&_cstRandom
      as select
        PDFPageRefs as PageRefs,
        FirstPage,
        LastPage,
        PDFPageRefType as Type ,
        PDFPageRefTitle as Title,
        OID as FK_DocumentRefs
      from _cst_doc_tmp2_&_cstRandom
      where not missing(PDFPageRefType)
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

%mend define_sourcedocuments;
