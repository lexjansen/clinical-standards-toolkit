%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* cstutilgetncimetadata                                                          *;
%*                                                                                *;
%* Creates a source_codelists data set.                                           *;
%*                                                                                *;
%* This macro creates a data set that conforms to the source_codelists structure  *;
%* as required by the define_sourcetodefine macro. This macro accepts several     *;
%* controlled terminology data sets as input.                                     *;
%*                                                                                *;
%* These columns are expected to exist in the NCI metadata data set:              *;
%*                                                                                *;
%*    codelist                                                                    *;
%*    codelist_name                                                               *;
%*    codelist_code                                                               *;
%*    fmtname                                                                     *;
%*    datatype                                                                    *;
%*    cdisc_submission_value                                                      *;
%*    code                                                                        *;
%*                                                                                *;
%* The input catalogs are processed in the order that they are provided in the    *;
%* list. The first occurence of a format (fmtname) is used in the output.         *;
%* If a format is available in both numeric format and character format in        *;
%* different data sets, the first occurence is used.                              *;
%*                                                                                *;
%* Assumption:                                                                    *;
%*   1. If _cstFmtDS exists, it is overwritten.                                   *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%*                                                                                *;
%* @param  _cstFormatCatalogs - conditional - A list of blank-separated format    *;
%*            catalogs to use for searching formats. If this parameter is not     *;
%*            specified, the FMTSEARCH option value is used to determine the      *;
%*            format catalogs.                                                    *;
%* @param  _cstNCICTerms - optional - The (libname.)member that refers to the     *;
%*             data set that contains the NCI metadata.                           *;
%*             If this parameter is not specified, a format catalog must exist,   *;
%*             either as specified in the the _cstFormatCatalogs parameter or     *;
%*             in the FMTSEARCH option.                                           *;
%* @param  _cstLang - optional - The ODM TranslatedText/@lang attribute.          *;
%* @param  _cstStudyVersion - required - The study identifier to use to bind      *;
%*            together the source data sets and as ODM/Study/MetaDataVersion/@OID *;
%*            in the define.xml file.                                             *;
%* @param  _cstStandard - required - The target standard.                         *;
%*            Values: CDISC-ADAM | CDISC-SDTM | CDISC-SEND                        *;
%* @param  _cstStandardVersion - required - The target standard version.          *;
%* @param  _cstFmtDS - required - The libname.memname of the data set to create.  *;
%* @param  _cstSASRef - required - The value of the SASRef column in the          *;
%*            _cstFmtDSdata set.                                                  *;
%*            Default: SRCDATA                                                    *;
%* @param  _cstReturn - required - The macro variable that contains the return    *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param  _cstReturnMsg - required - The macro variable that contains the return *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro cstutilgetncimetadata(
  _cstFormatCatalogs=,
  _cstNCICTerms=,
  _cstLang=,
  _cstStudyVersion=, 
  _cstStandard=,
  _cstStandardVersion=,
  _cstFmtDS=,
  _cstSASRef=SRCDATA,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des = "CST: get NCI Controlled Terms metadata";
  
  %local i _cstReqParams _cstReqParam _cstRandom _notexistvar 
           _cstCatalogs DatatypeVar 
           _cstDSLabel dsid rc;
  
  %*****************************************;
  %*  Check for existence of _cstDebug     *;
  %*****************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;
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

  %* Check required parameters;
  %let _cstReqParams=_cstStudyVersion _cstStandard _cstStandardVersion _cstFmtDS _cstSASRef;
  %do i=1 %to %sysfunc(countw(&_cstReqParams));
     %let _cstReqParam=%kscan(&_cstReqParams, &i);
     %if %sysevalf(%superq(&_cstReqParam)=, boolean) %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=&_cstReqParam parameter value is required.;        
        %goto exit_macro;
     %end;
  %end;

  %* Check NCI data set;
  %if %sysevalf(%superq(_cstNCICTerms)=, boolean)=0 %then %do;
    %if not %sysfunc(exist(&_cstNCICTerms)) %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Data set _cstNCICTerms=&_cstNCICTerms does not exist.;
        %goto exit_macro;
    %end;
    %else %do;
      %let _notexistvar=;
      %if not %cstutilcheckvarsexist(
          _cstDataSetName=&_cstNCICTerms,
          _cstVarList=codelist codelist_name codelist_code fmtname cdisc_submission_value code,
          _cstNotExistVarList=_notexistvar) %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=The following variables are missing in _cstNCICTerms=&_cstNCICTerms: &_notexistvar;
        %goto exit_macro;
      %end;   
    %end;  
  %end; 
  
  %* Check output library;
  %if %sysfunc(kindexc(&_cstFmtDS,.)) %then %do;   
    %if (%sysfunc(libref(%sysfunc(scan(%trim(%left(&_cstFmtDS)),1,.))))) %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Libref %sysfunc(scan(%trim(%left(&_cstFmtDS)),1,.)) in _cstFMTDS parameter has not been assigned.;
      %goto exit_macro;
    %end;  
  %end;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.0.0,
    _cstType=studymetadata,_cstSubType=codelist,_cstOutputDS=work.source_codelists_tmplt_&_cstRandom
    );

   %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=work.source_codelists_tmplt_&_cstRandom,_cstAttribute=LABEL);
   
  %*****************************************************************;
  %* No _cstFormatCatalogs defined, use FMTSEARCH                  *;
  %*****************************************************************;
  %if %sysevalf(%superq(_cstFormatCatalogs)=, boolean) %then %do;
    %let _cstFormatCatalogs=%sysfunc(getoption(FMTSEARCH));
    %if &_cstDebug %then 
      %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] _cstFormatCatalogs empty, %str
        ()use FMTSEARCH=%sysfunc(getoption(FMTSEARCH));
  %end;
  
  %*****************************************************************;
  %* First get all formats from catalogs in the FMTSEARCH  paths   *;
  %*****************************************************************;
  data _null_;
    attrib _cstCatalog format=$char17.
           _cstCatalogs format=$char200.
           _cstfmts format=$char200.;
    _cstfmts = ktranslate("&_cstFormatCatalogs",'','()');
    do i = 1 to countw(_cstfmts,' ');
      _cstCatalog=scan(_cstfmts,i,' ');
      if index(_cstCatalog,'.') = 0 then do;
        if libref(_cstcatalog)=0 then
          _cstCatalog = catx('.',_cstCatalog,'FORMATS');
      end;
      if exist(_cstCatalog,'CATALOG') then
        _cstCatalogs = catx(' ',_cstCatalogs,_cstCatalog);
      else put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Format catalog " _cstCatalog "does not exist and has been skipped";
    end ;
    if strip(_cstcatalog) ne ''
      then call symput('_cstCatalogs',STRIP(_cstCatalogs));
    else call symput('_cstCatalogs','');
  run;

  %* Concatenate format catalogs into a single reference  *;
  %if %sysfunc(strip("&_cstCatalogs")) ne "" %then %do;
    catname _cstfmts ( &_cstCatalogs ) ;
    proc format lib = work ._cstfmts cntlout=_CatFmt&_cstRandom;
    run ;
    catname _cstfmts clear;

    proc sort data=_CatFmt&_cstRandom; 
      by fmtname; 
    run;
    
    data _CatFmt&_cstRandom(keep=codelistdatatype sasformatname codedvaluechar codedvaluenum decodetext);
      length sasformatname $32 codelistdatatype $7. codedvaluechar $512 codedvaluenum 8;
      set _CatFmt&_cstRandom(rename=(start=decodetext fmtname=codelist));
      by codelist;
      select(type);
        when('C') do;
          codelistdatatype='text';
          sasformatname=cats('$', codelist);
          codedvaluechar=label;
        end;
        otherwise do;
          codelistdatatype='integer';
          sasformatname=codelist;
          codedvaluenum=input(kstrip(label), best.);
        end;
      end;
  
    run;


    %if %sysevalf(%superq(_cstNCICTerms)=, boolean)=0 %then 
    %do;

      %let DatatypeVar=;
      %let dsid=%sysfunc(open(&_cstNCICTerms,is));
      %if &dsid ne 0 %then %do;
        %if %sysfunc(varnum(&dsid,datatype)) %then %let DatatypeVar=datatype;
        %let rc=%sysfunc(close(&dsid));
      %end;
    
      data _NCICT&_cstRandom(rename=(fmtname=sasformatname));
        %if %sysevalf(%superq(DatatypeVar)=, boolean) %then retain datatype "text";;  
        set &_cstNCICTerms;
        format _character_;
        informat _character_;
        if datatype="text" and findc(fmtname, "$")=0 then fmtname=cats("$", fmtname); 
      run;
    
      proc sort data=_NCICT&_cstRandom out=_NCICT_cl&_cstRandom(keep=codelist_name codelist_code codelist sasformatname datatype) nodupkey;
      by codelist codelist_code &DatatypeVar;
      run;
  
      proc sort data=_NCICT&_cstRandom out=_NCICT_cli&_cstRandom(keep=sasformatname datatype code cdisc_submission_value);
      by codelist codelist_code &DatatypeVar;
      run;
      
      proc sql;
        create table &_cstFmtDS
        as select
          ncicl.codelist length=128,
          ncicl.codelist_name as codelistname,
          ncicl.codelist_code as codelistncicode,
          ncicli.code as codedvaluencicode,
          "&_cstLang" as decodelanguage,
          catfmt.*
        from
            _CatFmt&_cstRandom catfmt
          left join 
            _NCICT_cl&_cstRandom ncicl
        on (substr(catfmt.sasformatname,1,8)=substr(ncicl.sasformatname,1,8) and 
           (catfmt.codelistdatatype=ncicl.datatype))
          left join
            _NCICT_cli&_cstRandom ncicli
        on (substr(catfmt.sasformatname,1,8)=substr(ncicli.sasformatname,1,8) and 
            (catfmt.codelistdatatype=ncicli.datatype) and
            ((catfmt.codedvaluechar=ncicli.cdisc_submission_value and catfmt.codelistdatatype="text") or
             (catfmt.codedvaluenum=input(ncicli.cdisc_submission_value, ? best.) and catfmt.codelistdatatype ne "text")
            )
            )
        ;
       quit;   
     
    %end;
    %else
    %do;

      proc sql;
        create table &_cstFmtDS
        as select
          "&_cstLang" as decodelanguage,
          catfmt.*
        from
          _CatFmt&_cstRandom catfmt
        ;
       quit;   
      
    %end;  

  
    data &_cstFmtDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
      set work.source_codelists_tmplt_&_cstRandom &_cstFmtDS;
      format _character_ _numeric_;
    run;
      
    data &_cstFmtDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
      set &_cstFmtDS;
      
      if missing(codedvaluencicode) and (not missing(codelistncicode)) then extendedvalue="Yes";
      if missing(codelistname) then codelistname=compress(sasformatname, "$");
      if missing(codelist) then codelist=compress(sasformatname, "$");
      
      if not missing(codelist) then
      do;
        codelist=compress(codelist, "$");
        if ksubstr(upcase(codelist),1,3) ne "CL." then codelist="CL."||kstrip(codelist);
      end;
      
      if codedvaluechar = decodetext then do;
        decodetext = "";
        decodelanguage = "";
      end;
      
      SASRef="&_cstSASRef";
      StudyVersion="&_cstStudyVersion";
      standard="&_cstStandard";
      standardversion="&_cstStandardVersion";
    run;

    %if not &_cstDebug %then %do;
      %cstutil_deleteDataSet(_cstDataSetName=work.source_codelists_tmplt_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._catfmt&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._ncict&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._ncict_cl&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._ncict_cli&_cstRandom);
    %end;
    
  %end;
  %else %do; %* No format catalogs available;

    %if %sysevalf(%superq(_cstNCICTerms)=, boolean)=0 %then
      %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] No format catalogs available. _cstNCICTerms=&_cstNCICTerms will not be used.;

    data &_cstFmtDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
     set work.source_codelists_tmplt_&_cstRandom;
    run;
    
    %if not &_cstDebug %then %do;
      %cstutil_deleteDataSet(_cstDataSetName=work.source_codelists_tmplt_&_cstRandom);
    %end;
    
  %end;

  %if %sysfunc(exist(&_cstFmtDS)) %then
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstFmtDS has been created with %cstutilnobs(_cstDataSetName=&_cstFmtDS) observations.;
    
  %exit_macro:
    %if %length(&&&_cstReturnMsg) %then 
      %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&sysmacroname] &&&_cstReturnMsg;

  %exit_macro_nomsg:

%mend cstutilgetncimetadata;
