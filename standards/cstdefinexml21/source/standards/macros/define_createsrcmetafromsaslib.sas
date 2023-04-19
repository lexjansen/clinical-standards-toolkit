%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_createsrcmetafromsaslib                                                 *;
%*                                                                                *;
%* Derives source study metadata files from a SAS data library.                   *;
%*                                                                                *;
%* This macro derives source metadata files from a data library that contains SAS *;
%* data set.                                                                      *;
%*                                                                                *;
%* These source metadata files are used by the SAS Clinical Standards Toolkit to  *;
%* support CDISC model validation and to derive CDISC Define-XML v2.1 (define.xml)*;
%* files:                                                                         *;
%*          source_study                                                          *;
%*          source_standards                                                      *;
%*          source_tables                                                         *;
%*          source_columns                                                        *;
%*          source_values                                                         *;
%*          source_codelists                                                      *;
%*          source_documents                                                      *;
%*          source_analysisresults                                                *;
%*                                                                                *;
%* This is the general strategy:                                                  *;
%*    1. Use PROC CONTENTS output as the primary source of the information.       *;
%*    2. Use reference_tables, reference_columns, class_tables, and class_columns *;
%*       for matching the columns to impute missing metadata by specifying        *;
%*       _cstUseRefLib=Y.                                                         *;
%*                                                                                *;
%* Notes:                                                                         *;
%*   1. This is ONLY an attempted approximation of source metadata. No            *;
%*      assumptions should be made that the result accurately represents the      *;
%*      study data. Incomplete reference metadata may not enable imputation of    *;
%*      missing metadata.                                                         *;
%*   2. _cstSASDataLib must be specified. If this parameter is not specified, the *;
%*      macro attempts to get _cstSASDataLib from the SASReferences data set that *;
%*      is specified by the macro variable _cstSASRefs (type=sourcedata, subtype=,*;
%*      reftype=libref, filetype=folder).                                         *;
%*   3. _cstStudyMetadata references a data set with Study metadata.              *;
%*   4. _cstStandardMetadata references a data set with Standard metadata.        *;
%*   5. _cstTrg<table>DS must be specified (table=Study|Standard|Table|Column|    *;
%*      CodeList|Value|Document). If this parameter is not specified, the macro   *;
%*      attempts to get _cstSAS<table>DS from the SASReferences data set that is  *;
%*      specified by the macro variable _cstSASRefs (type=studymetadata,          *;
%*      subtype=<table>, reftype=libref, filetype=dataset).                       *;
%*      _cstTrgAnalysisResultDS is optionally specified. If this parameter is not *;
%*      specified, the macro attempts to get _cstSASAnalysisResultDS from the     *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=studymetadata, subtype=AnalysisResult, reftype=libref,  *;
%*      filetype=dataset).                                                        *;
%*   6. _cstUseRefLib=Y _cstRefTableDS must be specified. If this parameter is    *;
%*      not specified, the macro attempts to get _cstRefTableDS from the          *;
%*      SASReferences data set that is specified by the macro variable _cstSASRefs*;
%*      (type=referencemetadata, subtype=table, reftype=libref, filetype=dataset).*;
%*   7. _cstUseRefLib=Y _cstRefColumnDS must be specified. If this parameter is   *;
%*      not specified, the macro attempts to get _cstRefColumnDS from the         *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencemetadata, subtype=column, reftype=libref,      *;
%*      filetype=dataset).                                                        *;
%*   8. _cstUseRefLib=Y _cstClassTableDS must be specified. If this parameter is  *;
%*      not specified, the macro attempts to get _cstClassTableDS from the        *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=classmetadata, subtype=table, reftype=libref,           *;
%*      filetype=dataset).                                                        *;
%*   9. _cstUseRefLib=Y _cstClassColumnDS must be specified. If this parameter is *;
%*      not specified, the macro attempts to get _cstClassColumnDS from the       *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencemetadata, subtype=column, reftype=libref,      *;
%*      filetype=dataset).                                                        *;
%*                                                                                *;
%* Assumptions:                                                                   *;
%*    1. The source data is read from a single SAS library. You can modify the    *;
%*       code to reference multiple libraries by using library concatenation.     *;
%*    2. Only one study reference can be specified. Multiple study references     *;
%*       require modification of the code.                                        *;
%*                                                                                *;
%*                                                                                *;
%* @macvar _cstStandard Name of a standard registered to the SAS Clinical         *;
%*             Standards Toolkit                                                  *;
%* @macvar _cstStandardVersion Version of the standard referenced in _cstStandard *;
%* @macvar _cstDebug Turns debugging on or off for the session. Set _cstDebug=1   *;
%*             before this macro call to retain work files created in this macro. *;
%* @macvar _cst_rc Task error status                                              *;
%* @macvar _cst_rcmsg Message associated with _cst_rc                             *;
%* @macvar _cstResultSeq Results: Unique invocation of macro                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%*                                                                                *;
%* @param  _cstSASDataLib - required - The library where the SAS data sets are    *;
%*             located.                                                           *;
%* @param  _cstStudyMetadata - required - The data set that contains study        *;
%*             metadata in columns: studyname, studydescription, protocolname,    *;
%*             and studyversion. None of these columns can be missing.            *;
%* @param  _cstStandardMetadata - required - The data set that contains           *;
%*             standards metadata in columns:                                     *;
%*             formalstandardname, formalstandardversion, type, publishingset,    *;
%*             status, comment                                                    *;
%*             and studyversion. None of these columns can be missing.            *;
%* @param  _cstTrgStandard - required - The name of the study standard for which  *;
%*             the macro creates source study metadata.                           *;
%* @param  _cstTrgStandardVersion - required - The version of the study standard  *;
%*             for which the macro creates source study metadata.                 *;
%* @param  _cstTrgStudyDS - required - The data set that contains the metadata    *;
%*             for the studies to include in the Define-XML file.                 *;
%* @param  _cstTrgStandardDS - required - The data set that contains the metadata *;
%*             for the standards to include in the Define-XML file.               *;
%* @param  _cstTrgTableDS - required - The data set that contains the metadata    *;
%*             for the domains to include in the Define-XML file.                 *;
%* @param  _cstTrgColumnDS - required - The data set that contains the metadata   *;
%*             for the Domain columns to include in the Define-XML file.          *;
%* @param  _cstTrgCodeListDS - required - The data set that contains the          *;
%*             metadata for the CodeLists to include in the Define-XML file.      *;
%* @param  _cstTrgValueDS  - required - The data set that contains the metadata   *;
%*             for the Value Level columns to include in the Define-XML file      *;
%* @param  _cstTrgDocumentDS - required - The data set that contains the          *;
%*             metadata for document references to include in the Define-XML file.*;
%* @param  _cstTrgAnalysisResultDS - optional - The data set that contains the    *;
%*             metadata for analysis results to include in the Define-XML file.   *;
%* @param  _cstLang - optional - The ODM TranslatedText/@lang attribute.          *;
%*             If _cstLang is specifided, it must conform to this                 *;
%*             Regular Expression: ^([a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*)$          *;
%* @param  _cstUseRefLib - required - Use reference and class metadata to impute  *;
%*             missing information in target metadata.                            *;
%*             Values:  N | Y                                                     *;
%*             Default: N                                                         *;
%* @param  _cstRefTableDS - conditional - The data set that contains table        *;
%*             reference metadata for the target data standard. Here is an        *;
%*             example: refmeta.reference_tables                                  *;
%* @param  _cstRefColumnDS - conditional - The data set that contains column      *;
%*             reference metadata for the target data standard. Here is an        *;
%*             example: refmeta.reference_columns                                 *;
%* @param  _cstClassTableDS - conditional - The data set that contains table      *;
%*             reference metadata for the target data standard. Here is an        *;
%*             example: refmeta.class_tables                                      *;
%*             Required in case _cstUseRefLib=Y.                                  *;
%* @param  _cstClassColumnDS - conditional - The data set that contains column    *;
%*             reference metadata for the target data standard. Here is an        *;
%*             example: refmeta.class_columns                                     *;
%*             Required in case _cstUseRefLib=Y.                                  *;
%* @param  _cstKeepAllCodeLists - required - Keep all codelists (Y) or keep only  *;
%*             the codelists that are referenced by source_columns.xmlcodelist or *;
%*             source_columns.xmlcodelist (N).                                    *;
%*             Values:  N | Y                                                     *;
%*             Default: Y                                                         *;
%* @param  _cstFormatCatalogs - optional - A list of blank-separated format       *;
%*            catalogs to use for searching formats. If this parameter is not     *;
%*            specified, the FMTSEARCH option value is used to determine the      *;
%*            format catalogs.                                                    *;
%* @param  _cstNCICTerms - optional - The (libname.)member that refers to the     *;
%*             data set that contains the NCI metadata.                           *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added _cstTrgStandardDS parameter                          *;
%*                     Added _cstStandardMetadata parameter                       *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro define_createsrcmetafromsaslib(
    _cstSASDataLib=,
    _cstStudyMetadata=,
    _cstStandardMetadata=,
    _cstTrgStandard=,
    _cstTrgStandardVersion=,
    _cstTrgStudyDS=,
    _cstTrgStandardDS=,
    _cstTrgTableDS=,
    _cstTrgColumnDS=,
    _cstTrgCodeListDS=,
    _cstTrgValueDS=,
    _cstTrgDocumentDS=,
    _cstTrgAnalysisResultDS=,
    _cstLang=en,
    _cstUseRefLib=N,
    _cstRefTableDS=,
    _cstRefColumnDS=,
    _cstClassTableDS=,
    _cstClassColumnDS=,
    _cstKeepAllCodeLists=Y,
    _cstFormatCatalogs=,
    _cstNCICTerms=,
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des='CST: Create source metadata from Define';


  %local
    _cstRandom
    _cstRegex
    _cstRegexID
    _cstRecs
    _cstRecs_contents
    _cstCounter
    _cstTable
    _cstMissing
    _cstNotAssigned

    _cstResultSeq
    _cstSeqCnt
    _cstUseResultsDS

    _cstThisMacro
    
    _cstXMLPath
    
    _cstTrgMetaLibrary
    _cstSrcLibrary
    _cstReflibrary

    _cstNCIlibrary
    _cstNCIDS

    _cstTypeStudyMetadata
    _cstTypeClassMetadata
    _cstTypeReferenceMetadata
    _cstTypeSourceData
    _cstTypeSourceMetaData
    _cstTypeReferenceCTerm
    _cstDSLabel
    _cstStudyVersion
    
    _cstCDISCIGStandard
    _cstCDISCIGStandardVersion
    _cstCDISCCTStandard
    _cstCDISCCTStandardVersion
    _cstCDISCCTPublishingSet
    ;

  %let _cstThisMacro=&sysmacroname;
  %let _cstSrcData=&sysmacroname;

  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstUseResultsDS=0;
  
  %let _cstXMLPath=;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then %do;
    %* We are not able to communicate other than to the LOG;
    %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG can not be missing.;
    %goto exit_error_nomsg;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;


  %cstutil_getRandomNumber(_cstVarname=_cstRandom);

  %if (%eval(not %symexist(_cstStandard))) or
      (%eval(not %symexist(_cstStandardVersion))) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstStandard and _cstStandardVersion must be specified as global macro variables.;
    %goto exit_error;
  %end;

  %* Rule: _cstStandard and _cstStandardVersion must be specified  *;
  %if %sysevalf(%superq(_cstStandard)=, boolean) or
      %sysevalf(%superq(_cstStandardVersion)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstStandard and _cstStandardVersion must be specified as global macro variables.;
    %goto exit_error;
  %end;

  %* retrieve static variables;
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_STUDYMETADATA,_cstVar=_cstTypeStudyMetadata);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_CLASSMETADATA,_cstVar=_cstTypeClassMetadata);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_REFERENCEMETADATA,_cstVar=_cstTypeReferenceMetadata);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_SOURCEDATA,_cstVar=_cstTypeSourceData);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_SOURCEMETADATA,_cstVar=_cstTypeSourceMetaData);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_REFERENCECTERM,_cstVar=_cstTypeReferenceCTerm);

  %* Reporting will be to the CST results data set if available, otherwise to the SAS log.  *;
  %if (%symexist(_cstResultsDS)=1) %then
  %do;
    %if (%sysfunc(exist(&_cstResultsDS))) %then
    %do;
      %let _cstUseResultsDS=1;
      %******************************************************;
      %*  Create a temporary messages data set if required  *;
      %******************************************************;
      %cstutil_createTempMessages(_cstCreationFlag=_cstNeedToDeleteMsgs);
    %end;
  %end;

  %* Write information to the results data set about this run. *;
  %if %symexist(_cstResultsDS) %then
  %do;
    %cstutilwriteresultsintro(_cstResultID=DEF0097, _cstProcessType=FILEIO);
  %end;

  %******************************************************************************;
  %* Parameter checks                                                           *;
  %******************************************************************************;

  %* Rule: _cstTrgStandard and _cstTrgStandardVersion must be specified  *;
  %if %sysevalf(%superq(_cstTrgStandard)=, boolean) or
      %sysevalf(%superq(_cstTrgStandardVersion)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameters _cstTrgStandard and _cstTrgStandardVersion must be specified.;
    %goto exit_error;
  %end;

  %* Rule: _cstSASDataLib must be specified  *;
  %if %sysevalf(%superq(_cstSASDataLib)=, boolean) %then %do;
    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the data location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstTrgStandard),
          _cstStandardVersion=&_cstTrgStandardVersion,
          _cstSASRefType=&_cstTypeSourceData,
          _cstSASRefsasref=_cstSASDataLib,
          _cstAllowZeroObs=1
          );
      %end;
  %end;
  %if %sysevalf(%superq(_cstSASDataLib)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstSASDataLib must be specified.;
    %goto exit_error;
  %end;


  %* Rule: Check that the Data libref is assigned  *;
  %if (%sysfunc(libref(&_cstSASDataLib))) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The Data libref(&_cstSASDataLib) is not assigned.;
    %goto exit_error;
  %end;

  %* START of _cstStudyMetadata validation;
  %* Rule: _cstStudyMetadata must be specified  *;
  %if %sysevalf(%superq(_cstStudyMetadata)=, boolean) %then
  %do;
    %if %symexist(_CSTSASRefs) %then
    %do;
      %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
          %* Try getting the target location from the SASReferences file;
          %cstUtil_getSASReference(
            _cstStandard=%upcase(&_cstTrgStandard),
            _cstStandardVersion=&_cstTrgStandardVersion,
            _cstSASRefType=&_cstTypeSourceMetaData,
            _cstSASRefSubType=Study,
            _cstSASRefsasref=_cstSrcLibrary,
            _cstSASRefmember=_cstStudyMetadata,
            _cstAllowZeroObs=1
            );
          %let _cstStudyMetadata = &_cstSrcLibrary..&_cstStudyMetadata;
          %if %sysevalf(%superq(_cstSrcLibrary)=, boolean) or
              %sysevalf(%superq(_cstStudyMetadata)=, boolean) %then
          %let &_cstReturn=1;
      %end;
      %else
      %do;
        %let &_cstReturn=1;
      %end;
    %end;
    %else
    %do;
      %let &_cstReturn=1;
    %end;
  %end;

  %if &&&_cstReturn %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter(s) must be specified: _cstStudyMetadata.;
    %goto exit_error;
  %end;

  %* Rule: _cstStudyMetadata must have one record *;
  %if %cstutilnobs(_cstDatasetName=&_cstStudyMetadata) ne 1 %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Data set &_cstStudyMetadata must have exactly one record.;
    %goto exit_error;
  %end;  

  %* Rule: _cstStudyMetadata must have certain columns: studyname studydescription protocolname studyversion *;
  %let _cstNotExistVar=;
  %if not %cstutilcheckvarsexist(
      _cstDataSetName=&_cstStudyMetadata,
      _cstVarList=studyname studydescription protocolname studyversion,
      _cstNotExistVarList=_cstNotExistVar) %then %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The following column(s) are missing in &_cstStudyMetadata: &_cstNotExistVar;
    %goto exit_error;
  %end;   

  proc sql noprint;
   select StudyVersion into :_cstStudyVersion
   from &_cstStudyMetadata
   ;
  quit;
  %let _cstStudyVersion=&_cstStudyVersion;

  %* Rule: _cstStudyMetadata columns StudyName, StudyDescription, ProtocolName and StudyVersion must not be empty *;
  data _null_;
    set &_cstStudyMetadata;
    length message $100;
    message="";
    if missing(StudyName) then message=catx(" ", message, "StudyName");
    if missing(StudyDescription) then message=catx(" ", message, "StudyDescription");
    if missing(ProtocolName) then message=catx(" ", message, "ProtocolName");
    if missing(StudyVersion) then message=catx(" ", message, "StudyVersion");
    if not missing(message) then call symputx("&_cstReturnMsg", message);
  run;
     
  %if not %sysevalf(%superq(&_cstReturnMsg)=, boolean) %then %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The following _cstStudyMetadata columns must not be empty: &&&_cstReturnMsg...;
    %goto exit_error;
  %end;   

  %* END of _cstStudyMetadata validation;

  %* START of _cstStandardMetadata validation;
  %* Rule: _cstStandardMetadata must be specified  *;
  %if %sysevalf(%superq(_cstStandardMetadata)=, boolean) %then
  %do;
    %if %symexist(_CSTSASRefs) %then
    %do;
      %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
          %* Try getting the target location from the SASReferences file;
          %cstUtil_getSASReference(
            _cstStandard=%upcase(&_cstTrgStandard),
            _cstStandardVersion=&_cstTrgStandardVersion,
            _cstSASRefType=&_cstTypeSourceMetaData,
            _cstSASRefSubType=Standard,
            _cstSASRefsasref=_cstSrcLibrary,
            _cstSASRefmember=_cstStandardMetadata,
            _cstAllowZeroObs=1
            );
          %let _cstStandardMetadata = &_cstSrcLibrary..&_cstStandardMetadata;
          %if %sysevalf(%superq(_cstSrcLibrary)=, boolean) or
              %sysevalf(%superq(_cstStandardMetadata)=, boolean) %then
          %let &_cstReturn=1;
      %end;
      %else
      %do;
        %let &_cstReturn=1;
      %end;
    %end;
    %else
    %do;
      %let &_cstReturn=1;
    %end;
  %end;

  %if &&&_cstReturn %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter(s) must be specified: _cstStandardMetadata.;
    %goto exit_error;
  %end;

  %* Rule: _cstStandardMetadata must have one record *;
  %if %cstutilnobs(_cstDatasetName=&_cstStandardMetadata) lt 1 %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Data set &_cstStandardMetadata must have exactly at least record.;
    %goto exit_error;
  %end;  

  %* Rule: _cstStandardMetadata must have certain columns: standard, standardversion, type, status *;
  %let _cstNotExistVar=;
  %if not %cstutilcheckvarsexist(
      _cstDataSetName=&_cstStandardMetadata,
      _cstVarList=standard standardversion type status,
      _cstNotExistVarList=_cstNotExistVar) %then %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The following column(s) are missing in &_cstStandardMetadata: &_cstNotExistVar;
    %goto exit_error;
  %end;   

  %* Rule: _cstStandardMetadata columns formalstandardname, formalstandardversion, type, status must not be empty *;
  data _null_;
    set &_cstStandardMetadata;
    length message $100;
    message="";
    if missing(CDISCStandard) then message=catx(" ", message, "Standard");
    if missing(CDISCStandardVersion) then message=catx(" ", message, "StandardVersion");
    if missing(Type) then message=catx(" ", message, "Type");
    if missing(Status) then message=catx(" ", message, "Status");
    if not missing(message) then call symputx("&_cstReturnMsg", message);
  run;
     
  %if not %sysevalf(%superq(&_cstReturnMsg)=, boolean) %then %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The following _cstStandardMetadata columns must not be empty: &&&_cstReturnMsg...;
    %goto exit_error;
  %end;   

  proc sql noprint;
   select StudyVersion into :_cstStudyVersion
   from &_cstStudyMetadata
   ;
  quit;
  %let _cstStudyVersion=&_cstStudyVersion;

  %* END of _cstStandardMetadata validation;

  %* Rule: Expected source tables to be created must be specified;
  %let _cstExpTables=Study Standard Table Column CodeList Value Document;

  %let _cstMissing=;
  %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables));
    %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
    %if %sysevalf(%superq(_cstTrg&_cstTable.DS)=, boolean) %then
    %do;
      %if %symexist(_CSTSASRefs) %then
      %do;
        %if %sysfunc(exist(&_CSTSASRefs)) %then
        %do;
          %* Try getting the target location from the SASReferences file;
          %cstUtil_getSASReference(
            _cstStandard=%upcase(&_cstStandard),
            _cstStandardVersion=&_cstStandardVersion,
            _cstSASRefType=&_cstTypeStudyMetadata,
            _cstSASRefSubType=&_cstTable,
            _cstSASRefsasref=_cstTrgMetaLibrary,
            _cstSASRefmember=_cstTrg&_cstTable.DS,
            _cstAllowZeroObs=1
            );
          %let _cstTrg&_cstTable.DS = &_cstTrgMetaLibrary..&&_cstTrg&_cstTable.DS;
          %if %sysevalf(%superq(_cstTrgMetaLibrary)=, boolean) or
              %sysevalf(%superq(_cstTrg&_cstTable.DS)=, boolean) %then
            %let _cstMissing = &_cstMissing _cstTrg&_cstTable.DS;
        %end;
        %else
        %do;
          %let _cstMissing = &_cstMissing _cstTrg&_cstTable.DS;
        %end;
      %end;
      %else
      %do;
        %let _cstMissing = &_cstMissing _cstTrg&_cstTable.DS;
      %end;
    %end;
  %end;

  %if %length(&_cstMissing) gt 0
    %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Required macro parameter(s) must be specified: &_cstMissing..;
      %goto exit_error;
    %end;


  %* Rule: Expected source table libraries to be created must be assigned;
  %let _cstExpTables=Study Standard Table Column CodeList Value Document;

  %let _cstNotAssigned=;
  %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables));
    %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
    %if %sysfunc(kindexc(&&_cstTrg&_cstTable.DS,.)) %then 
    %do;   
      %if (%sysfunc(libref(%sysfunc(scan(%trim(%left(&&_cstTrg&_cstTable.DS)),1,.))))) %then 
      %do;
          %let _cstNotAssigned = &_cstNotAssigned %scan(%trim(%left(&&_cstTrg&_cstTable.DS)),1,.);
      %end;
    %end;
  %end;

  %if %length(&_cstNotAssigned) gt 0
    %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Target libraries must be assigned: &_cstNotAssigned..;
      %goto exit_error;
    %end;

  %* Rule: _cstLang has to conform to the xs:lang regular expression  *;
  %let _cstRegex=/^([a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*)$/;
  %let _cstRegexID=%sysfunc(PRXPARSE(&_cstRegex)); 

  %if %sysevalf(%superq(_cstLang)=, boolean)=0 %then
  %do;
    %if %sysfunc(PRXMATCH(&_cstRegexID, &_cstLang))=0 %then
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=_cstLang=&_cstLang is an incorrect xs:lang value.;
      %goto exit_error;
    %end;
  %end;


  %* Rule: _cstUseRefLib has to be Y or N  *;
  %if %sysevalf(%superq(_cstUseRefLib)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstUseRefLib must be specified.;
    %goto exit_error;
  %end;
  %else %if "%substr(%upcase(&_cstUseRefLib),1,1)" ne "Y" and "%substr(%upcase(&_cstUseRefLib),1,1)" ne "N" %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstUseRefLib=&_cstUseRefLib must be Y or N.;
    %goto exit_error;
  %end;

  %if %substr(%upcase(&_cstUseRefLib),1,1) eq Y %then
  %do;

    %let _cstExpTables=Table Column;
    %let _cstMissing=;

    %* Rule: Reference data sets need to be defined *;
    %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables));
      %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
      %if %sysevalf(%superq(_cstRef&_cstTable.DS)=, boolean) %then
      %do;
        %if %symexist(_CSTSASRefs) %then
        %do;
          %if %sysfunc(exist(&_CSTSASRefs)) %then
          %do;
              %* Try getting the target location from the SASReferences file;
              %cstUtil_getSASReference(
                _cstStandard=%upcase(&_cstTrgStandard),
                _cstStandardVersion=&_cstTrgStandardVersion,
                _cstSASRefType=&_cstTypeReferenceMetadata,
                _cstSASRefSubType=&_cstTable,
                _cstSASRefsasref=_cstReflibrary,
                _cstSASRefmember=_cstRef&_cstTable.DS,
                _cstAllowZeroObs=1
                );
              %let _cstRef&_cstTable.DS = &_cstReflibrary..&&_cstRef&_cstTable.DS;
              %if %sysevalf(%superq(_cstReflibrary)=, boolean) or
                  %sysevalf(%superq(_cstRef&_cstTable.DS)=, boolean) %then
              %let _cstMissing = &_cstMissing _cstRef&_cstTable.DS;
          %end;
          %else
          %do;
            %let _cstMissing = &_cstMissing _cstRef&_cstTable.DS;
          %end;
        %end;
        %else
        %do;
          %let _cstMissing = &_cstMissing _cstRef&_cstTable.DS;
        %end;
      %end;
    %end;

    %* Rule: Class data sets need to be defined *;
    %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables));
      %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
      %if %sysevalf(%superq(_cstClass&_cstTable.DS)=, boolean) %then
      %do;
        %if %symexist(_CSTSASRefs) %then
        %do;
          %if %sysfunc(exist(&_CSTSASRefs)) %then
          %do;
              %* Try getting the target location from the SASReferences file;
              %cstUtil_getSASReference(
                _cstStandard=%upcase(&_cstTrgStandard),
                _cstStandardVersion=&_cstTrgStandardVersion,
                _cstSASRefType=&_cstTypeClassMetadata,
                _cstSASRefSubType=&_cstTable,
                _cstSASRefsasref=_cstReflibrary,
                _cstSASRefmember=_cstClass&_cstTable.DS,
                _cstAllowZeroObs=1
                );
                %let _cstClass&_cstTable.DS = &_cstReflibrary..&&_cstClass&_cstTable.DS;
                %if %sysevalf(%superq(_cstReflibrary)=, boolean) or
                    %sysevalf(%superq(_cstClass&_cstTable.DS)=, boolean) %then
                %let _cstMissing = &_cstMissing _cstClass&_cstTable.DS;
          %end;
          %else
          %do;
            %let _cstMissing = &_cstMissing _cstClass&_cstTable.DS;
          %end;
        %end;
        %else
        %do;
          %let _cstMissing = &_cstMissing _cstClass&_cstTable.DS;
        %end;
      %end;
    %end;

    %if %length(&_cstMissing) gt 0
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Required macro parameter(s) must be specified: &_cstMissing..;
        %goto exit_error;
      %end;


      %let _cstExpTables=Table Column;

      %let _cstMissing=;
      %* Rule: Expected Reference data sets must exist  *;
      %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables, %str( )));
        %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
        %if not %sysfunc(exist(&&_cstRef&_cstTable.DS)) %then
          %let _cstMissing = &_cstMissing _cstRef&_cstTable.DS=&&_cstRef&_cstTable.DS;
      %end;

      %if %length(&_cstMissing) gt 0
        %then %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected Reference data sets must exist: &_cstMissing..;
          %goto exit_error;
        %end;

      %let _cstMissing=;
      %* Rule: Expected Class data sets must exist  *;
      %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables, %str( )));
        %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
        %if not %sysfunc(exist(&&_cstClass&_cstTable.DS)) %then
          %let _cstMissing = &_cstMissing _cstClass&_cstTable.DS=&&_cstClass&_cstTable.DS;
      %end;

      %if %length(&_cstMissing) gt 0
        %then %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected Class data sets must exist: &_cstMissing..;
          %goto exit_error;
        %end;

  %end;  %* _cstUseRefLib=Y ;


  %* Rule: _cstKeepAllCodeLists has to be Y or N  *;
  %if %sysevalf(%superq(_cstKeepAllCodeLists)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstKeepAllCodeLists must be specified.;
    %goto exit_error;
  %end;
  %else %if "%substr(%upcase(&_cstKeepAllCodeLists),1,1)" ne "Y" and "%substr(%upcase(&_cstKeepAllCodeLists),1,1)" ne "N" %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstKeepAllCodeLists=&_cstKeepAllCodeLists must be Y or N.;
    %goto exit_error;
  %end;


  %* Check NCI data set;
  %if %sysevalf(%superq(_cstNCICTerms)=, boolean) %then 
  %do;
    %* Try getting _cstNCICTerms from the SASReferences file;
    %cstUtil_getSASReference(
      _cstStandard=CDISC-TERMINOLOGY,
      _cstStandardVersion=NCI_THESAURUS,
      _cstSASRefType=&_cstTypeReferenceCTerm,
      _cstSASRefsasref=_cstNCIlibrary,
      _cstSASRefmember=_cstNCIDS,
      _cstAllowZeroObs=1
      );

    %let _cstNCICTerms = &_cstNCIlibrary..&_cstNCIDS;
    %if %sysevalf(%superq(_cstNCIlibrary)=, boolean) or
        %sysevalf(%superq(_cstNCIDS)=, boolean) %then
    %let _cstNCICTerms=;

  %end;

  %if %sysevalf(%superq(_cstNCICTerms)=, boolean)=0 %then 
  %do;
    %if not %sysfunc(exist(&_cstNCICTerms)) %then 
    %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Data set &_cstNCICTerms does not exist.;
        %goto exit_error;
    %end;
    %else 
    %do;
      %let _notexistvar=;
      %if not %cstutilcheckvarsexist(
          _cstDataSetName=&_cstNCICTerms,
          _cstVarList=codelist codelist_name codelist_code fmtname cdisc_submission_value code,
          _cstNotExistVarList=_notexistvar) %then 
      %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=The following variables are missing in &_cstNCICTerms: &_notexistvar;
        %goto exit_error;
      %end;   
    %end;  
  %end; 

  %******************************************************************************;
  %* End of Parameter checks                                                    *;
  %******************************************************************************;


  * A single source data library serves as the input to this process.  *;
  proc contents data=&_cstSASDataLib.._all_ out=work.contents&_cstRandom
      (keep=libname memname memlabel name type length varnum label format formatl formatd sorted sortedby) noprint;
  run;
  %let _cstRecs_contents = %cstutilnobs(_cstDatasetName=work.contents&_cstRandom);

  %if %eval(&_cstRecs_contents) eq 0 %then
  %do;
    %* No have data;
    %if %symexist(_cstResultsDS) %then
    %do;
      %cstutil_writeresult(
        _cstResultID=DEF0097
        ,_cstResultParm1=Data library &_cstSASDataLib does not have any data
        ,_cstResultParm2=
        ,_cstResultSeqParm=1
        ,_cstSeqNoParm=1
        ,_cstSrcDataParm=&_cstThisMacro
        ,_cstResultFlagParm=0
        ,_cstRCParm=0
        ,_cstResultsDSParm=&_cstResultsDS
        );
    %end;
  %end;

  %*********************************************************************;
  %*  Create source_study metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=study,_cstOutputDS=&_cstTrgStudyDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS,_cstAttribute=LABEL);

  data &_cstTrgStudyDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    set &_cstTrgStudyDS 
        &_cstStudyMetadata;
    sasref= upcase("&_cstSASDataLib");
  run;

  proc sort data=&_cstTrgStudyDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef StudyVersion;
  run;

  %if %sysfunc(exist(&_cstTrgStudyDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgStudyDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgStudyDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgStudyDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgStudyDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgStudyDS (%nrbquote(&_cstDSLabel))
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

  %*********************************************************************;
  %*  Create source_standard metadata                                  *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=standard,_cstOutputDS=&_cstTrgStandardDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgStandardDS,_cstAttribute=LABEL);

  data &_cstTrgStandardDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    set &_cstTrgStandardDS 
        &_cstStandardMetadata;
    sasref= upcase("&_cstSASDataLib");
    studyversion="&_cstStudyVersion";
    standard = "&_cstTrgStandard";
    StandardVersion= "&_cstTrgStandardVersion";
  run;
  
  proc sort data=&_cstStandardMetadata;
    by order;
  run;
  
  data _null_;
    set &_cstStandardMetadata;
    by type order notsorted;
    if first.type then do;
      if type="IG" then do;
        call symputx('_cstCDISCIGStandard', kstrip(cdiscstandard));
        call symputx('_cstCDISCIGStandardVersion', kstrip(cdiscstandardversion));
      end;  
      if type="CT" then do;
        call symputx('_cstCDISCCTStandard', kstrip(cdiscstandard));
        call symputx('_cstCDISCCTStandardVersion', kstrip(cdiscstandardversion));
        call symputx('_cstCDISCCTPublishingSet', kstrip(publishingset));
      end;  
    end;  
  run;  
  
  proc sort data=&_cstTrgStandardDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef StudyVersion;
  run;

  %if %sysfunc(exist(&_cstTrgStandardDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgStandardDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgStandardDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgStandardDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgStandardDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgStandardDS (%nrbquote(&_cstDSLabel))
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

  %*********************************************************************;
  %*  Create source_table metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=table,_cstOutputDS=&_cstTrgTableDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS,_cstAttribute=LABEL);

  %if %eval(&_cstRecs_contents) ge 1 %then
  %do;
    %* We have data;
    
    proc sql;
      create table work.source_tables_&_cstRandom as
      select
        memname as table,
        memlabel as label length=200,
        name,
        sorted,
        sortedby
      from work.contents&_cstRandom
      order by memname, sortedby
      ;
    quit;        

    data work.source_tables_&_cstRandom(drop=name sorted sortedby);
      length xmltitle xmlpath keys $200 domain $32 class $40;
      set work.source_tables_&_cstRandom;  
      by table sortedby;
      retain keys domain class;
      if first.table then do;
        call missing(keys);
        call missing(domain);
        call missing(class);
        call missing(xmltitle);
        call missing(xmlpath);
      end;
      
        %if (%quote(&_cstTrgStandard) eq %quote(CDISC-SDTM)) or
            (%quote(&_cstTrgStandard) eq %quote(CDISC-SEND)) %then
        %do;
          %* Some rules to derive the DOMAIN;
          %* ADaM does not have a DOMAIN;
          if substr(name, 3) in ('TRT' 'TEST' 'TERM' 'SEQ') then
            domain=substr(name, 1, 2);
          if upcase(name)='COUNTRY' then domain='DM';
          if table in ('DM' 'SE' 'SV' 'TA' 'TE' 'TD' 'TV' 'TS' 'TI' 'DM') then domain=table;
          if table in ('RELREC') then domain="";
          if substr(table, 1, 4) = "SUPP" then domain = substr(table, 5); 
        %end;

      %* Some rules to derive the CLASS;
      if substr(name, 3) = ('TRT')  then class="INTERVENTIONS";
      if substr(name, 3) = ('TESTCD') then class="FINDINGS";
      if substr(name, 3) = ('TERM') then class="EVENTS";
      if name = 'PARAMCD' then class="BDS";
  
      sasref = upcase("&_cstSASDataLib");
      standard="&_cstTrgStandard";
      StandardVersion="&_cstTrgStandardVersion";
      StudyVersion="&_cstStudyVersion";
      if not missing(label) then xmltitle = catx(' ', label, 'transport file');
      date=put(today(), E8601DA.);
  
      if sortedby then keys = catx(' ', keys, name);
  
      if last.table then output;
    run;

    %if %upcase(&_cstUseRefLib) eq Y %then
    %do;
  
      data work.buildpath_&_cstRandom(keep=xmldir);
        length htaplmx xmldir $400;
        set &_cstRefTableDS;
        htaplmx=tranwrd(kreverse(xmlpath),'\','/');
        if kindex(htaplmx, '/') 
          then xmldir=kreverse(ksubstr(htaplmx,kindexc(htaplmx,'/')));
          else xmldir="";            
      run;

      proc freq data=work.buildpath_&_cstRandom;
        tables xmldir/out=work.xmlpath_&_cstRandom noprint;
      run;
    
      proc sort data=work.xmlpath_&_cstRandom;
        by descending count;
      run;
    
      data _null_;
        set work.xmlpath_&_cstRandom;
        by descending count;
        if _n_=1;
        call symputx('_cstXMLPath',xmldir);
      run;

      %cstutil_deleteDataSet(_cstDataSetName=work.buildpath_&_cstRandom); 
      %cstutil_deleteDataSet(_cstDataSetName=work.xmlpath_&_cstRandom); 

      data work.source_tables_define_&_cstRandom;
        set &_cstTrgTableDS 
            work.source_tables_&_cstRandom;
      run;
  
      %* Get SUPP column reference metadata; 
      proc sort data=&_cstRefTableDS 
        out=work.supp_ref_&_cstRandom(keep=Table Label Keys Class Purpose Structure State) nodupkey;
      by Table;
      where upcase(substr(table, 1, 4))="SUPP";
      run;
      data work.supp_ref_&_cstRandom;
        set work.supp_ref_&_cstRandom;
        if not missing(label) then label = tranwrd (label, substr(table, 5, 2), 'XX');
      run;
  
      proc sql;
      create table work.merge_tables_&_cstRandom as
      select
  
        src.table,
  
        reft.label as label_ref,
        reft.xmlpath as xmlpath_ref,
        reft.xmltitle as xmltitle_ref,
        reft.keys as keys_ref,
        reft.class as class_ref,
        reft.purpose as purpose_ref,
        reft.structure as structure_ref,
        reft.state as state_ref,
  
        reftd.label as label_refdom,
        reftd.keys as keys_refdom,
        reftd.class as class_refdom,
        reftd.purpose as purpose_refdom,
        reftd.structure as structure_refdom,
        reftd.state as state_refdom,
        
        supp.label as label_supp,
        supp.keys as keys_supp,
        supp.class as class_supp,
        supp.purpose as purpose_supp,
        supp.structure as structure_supp,
        supp.state as state_supp,
  
        classt.purpose as purpose_class
  
        from work.source_tables_define_&_cstRandom src
          left join &_cstRefTableDS reft
            on src.table=reft.table
          left join
          (
          select srct.table, srct.domain, ref.label, ref.keys, ref.class, ref.purpose, ref.structure, ref.state, ref.date
            from work.source_tables_&_cstRandom srct,
                 &_cstRefTableDS ref
            where (upcase(srct.domain)=upcase(ref.table) or upcase(srct.class)=upcase(ref.table))
          ) reftd
            on upcase(src.table)=upcase(reftd.table)
          left join work.supp_ref_&_cstRandom supp
            on upcase(substr(src.table, 1, 4))="SUPP"
          left join &_cstClassTableDS classt
            on ((upcase(reftd.class)=upcase(classt.table)) or (upcase(src.class)=upcase(classt.table)))
        order by table
        ;
      quit;
    
      data work.source_tables_&_cstRandom
        (drop=label_: keys_: class_: purpose_: structure_: xmlpath_: xmltitle_: state_:);
        merge work.source_tables_define_&_cstRandom work.merge_tables_&_cstRandom;
        format _character_ _numeric_;
        by table;
        if missing(date) then date=put(today(), E8601DA.);
  
        if missing(label) then label=label_ref;
        if missing(label) then label=label_refdom;
  
        if missing(keys) then keys=keys_ref;
        if missing(keys) then keys=keys_refdom;
  
        if missing(class) then class=upcase(class_ref);
        if missing(class) then class=upcase(class_refdom);
  
        if missing(purpose) then purpose=purpose_ref;
        if missing(purpose) then purpose=purpose_refdom;
        if missing(purpose) then purpose=purpose_class;
  
        if missing(structure) then structure=structure_ref;
        if missing(structure) then structure=structure_refdom;
  
        if missing(state) then state=state_ref;
        if missing(state) then state=state_refdom;
  
        if upcase(substr(table, 1, 4))="SUPP" then do;
          if missing(label) and (not missing(label_supp)) 
            then label=tranwrd (label_supp, 'XX', substr(table, 5, 2));
          if missing(keys) then keys=keys_supp;
          if missing(class) then class=upcase(class_supp);
          if missing(purpose) then purpose=purpose_supp;
          if missing(structure) then structure=structure_supp;
          if missing(state) then state=state_supp;
        end;  
        
        if (not missing(domain)) and (domain ne table) then domaindescription=label_refdom; 

        if missing(xmlpath) then xmlpath=xmlpath_ref;
        if missing(xmlpath) then xmlpath=cats("&_cstXMLPath", lowcase(table), ".xpt"); 
        if missing(xmltitle) then xmltitle=xmltitle_ref;
        if missing(xmltitle) and (not missing(label)) then xmltitle = catx(' ', label, 'transport file');
        
        order=_n_;
      run;
  
      %cstutil_deleteDataSet(_cstDataSetName=work.merge_tables_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work.source_tables_define_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work.supp_ref_&_cstRandom);
  
    %end;
  
  
    data &_cstTrgTableDS;
      set &_cstTrgTableDS 
          work.source_tables_&_cstRandom;
      if not missing(keys) then do;
        if indexw(upcase(strip(reverse(Keys))),"DIJBUSU")>1
          then Repeating = "Yes";
          else Repeating = "No";
        if indexw(upcase(Keys) ,"USUBJID")
          then IsReferenceData = "No";
          else IsReferenceData = "Yes";
      end;
      cdiscstandard="&_cstCDISCIGStandard";
      cdiscstandardversion="&_cstCDISCIGStandardVersion";
    run;

  %end; %* _cstRecs_contents gt 0 ; 
  
  proc sort data=&_cstTrgTableDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef Table;
  run;

  %if %sysfunc(exist(&_cstTrgTableDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgTableDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgTableDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgTableDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgTableDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgTableDS (%nrbquote(&_cstDSLabel))
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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_tables_&_cstRandom);

  %*********************************************************************;
  %*  Create source_column metadata                                    *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=column,_cstOutputDS=&_cstTrgColumnDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS,_cstAttribute=LABEL);

  %if %eval(&_cstRecs_contents) ge 1 %then
  %do;
    %* We have data;

    proc sql;
      create table work.source_columns_&_cstRandom as
      select
        memname as table,
        label length=200,
        name as column,
        varnum as order,
        type as ctype,
        length,
        format,
        formatl,
        formatd        
      from work.contents&_cstRandom
      order by memname, varnum
      ;
    quit;        
  
    
    data work.source_columns_&_cstRandom(drop=oneDigit twoDigit position lengthprx);
      set work.source_columns_&_cstRandom; 
      length type $1 displayformat $10 newcolumn1 newcolumn2 $8;
      retain oneDigit twoDigit;
  
      if _n_=1 then do;
        oneDigit=prxparse('(\d{1}?)');
        twoDigit=prxparse('(\d{2}?)');
      end;

      if anydigit(column) then
      do;
        call prxsubstr(twoDigit, column, position, lengthprx);
        if position ^= 0 then do;
          newcolumn1=column;
          substr(newcolumn1,position,lengthprx)='xx';
          newcolumn2=column;
          substr(newcolumn2,position,lengthprx)='zz';
        end;
        else newcolumn1=column;
        call prxsubstr(oneDigit, newcolumn1, position, lengthprx);
        if position ^= 0 then do;
          if newcolumn1 = '' then
            newcolumn1=column;
          substr(newcolumn1,position,lengthprx)='y';
          if newcolumn2 = '' then
            newcolumn2=column;
          substr(newcolumn2,position,lengthprx)='y';
          if newcolumn1=newcolumn2 then
            newcolumn2='';
        end;
      end;

      sasref = upcase("&_cstSASDataLib");
      StudyVersion="&_cstStudyVersion";
      /*
      standard="&_cstTrgStandard";
      StandardVersion="&_cstTrgStandardVersion";
      */
      type=ifc(ctype=1, "N", "C"); 
      if formatl>0 then do;
        if formatd>0 then displayformat = cats(formatl,'.',formatd);
                     else displayformat = cats(formatl,'.');
        if not missing(format) then displayformat = cats(format,displayformat);
        if formatd>0 then significantdigits = formatd;
      end;
    run;

    %*cstutiltrimcharvars(
      _cstDataSetName=work.source_columns_&_cstRandom,
      _cstDataSetOutName=work.source_columns_&_cstRandom
    );
  
    %if %upcase(&_cstUseRefLib) eq Y %then
    %do;
  
      data work.source_columns_define_&_cstRandom;
        set &_cstTrgColumnDS 
            work.source_columns_&_cstRandom;
      run;
  
      %* Get SUPP column reference metadata; 
      proc sort data=&_cstRefColumnDS 
        out=work.supp_ref_&_cstRandom(keep=Column label length core xmldatatype xmlcodelist algorithm displayformat) nodupkey;
      by Column;
      where upcase(substr(table, 1, 4))="SUPP";
      run;
  
      proc sql;
      create table work.merge_columns_&_cstRandom as
      select
        src.table,
        src.order,
  
        refc.label as label_ref,
        refc.xmldatatype as xmldatatype_ref,
        refc.xmlcodelist as xmlcodelist_ref,
        refc.core as core_ref,
        refc.displayformat as displayformat_ref,
        refc.algorithm as algorithm_ref,
  
        srct.domain,
        srct.class,
        srct.table as table_srct,
        reftd.xmldatatype as xmldatatype_reftd,
        reftd.xmlcodelist as xmlcodelist_reftd,
        reftd.core as core_reftd,
        reftd.displayformat as displayformat_reftd,
        reftd.algorithm as algorithm_reftd,
  
        supp.label as label_supp,
        supp.core as core_supp,
        supp.xmldatatype as xmldatatype_supp,
        supp.xmlcodelist as xmlcodelist_supp,
        supp.displayformat as displayformat_supp,
        supp.algorithm as algorithm_supp,
  
        classc.table as table_class,
        classc.label as label_class,
        classc.core as core_class,
        classc.xmldatatype as xmldatatype_class
  
        from work.source_columns_define_&_cstRandom src
          left join &_cstRefColumnDS refc
            on src.table=refc.table and src.column=refc.column
          left join &_cstTrgTableDS srct
            on (upcase(srct.table)=upcase(src.table))
          left join
          (
          select ref.table, ref.column, ref.label, ref.core, 
                 ref.xmldatatype, ref.xmlcodelist, ref.displayformat, ref.algorithm
            from &_cstRefColumnDS ref
          ) reftd
            on ((upcase(src.table)=upcase(reftd.table)) and 
                 (upcase(src.column)=upcase(reftd.column)) or (upcase(src.newcolumn1)=upcase(reftd.column)) or (upcase(src.newcolumn2)=upcase(reftd.column))) 
          left join work.supp_ref_&_cstRandom supp
            on (upcase(substr(src.table, 1, 4))="SUPP" and upcase(src.column)=upcase(supp.column))
          left join &_cstClassColumnDS classc
            on ((upcase(src.column)=upcase(classc.column)) or (substr(src.column,3) = substr(classc.column,3))) and
               ((upcase(srct.class)=upcase(classc.table)) or (upcase(classc.table) in ("TIMING", "IDENTIFIERS")))
  
        order by table, order
        ;
  
      quit;
  
      data work.source_columns_&_cstRandom(drop=domain class table_: label_: algorithm_: displayformat_: core_: xmldatatype_: xmlcodelist_:);
        merge work.source_columns_define_&_cstRandom work.merge_columns_&_cstRandom;
        format _character_ _numeric_;
        by table order;
  
        if missing(xmldatatype) then xmldatatype=xmldatatype_ref; 
        if missing(xmldatatype) then xmldatatype=xmldatatype_reftd;
        if missing(xmldatatype) then xmldatatype=xmldatatype_class;
        
        if missing(xmlcodelist) then xmlcodelist=xmlcodelist_ref; 
        if missing(xmlcodelist) then xmlcodelist=xmlcodelist_reftd; 
  
        if missing(algorithm) then algorithm=algorithm_ref; 
        if missing(algorithm) then algorithm=algorithm_reftd; 
  
        if missing(displayformat) then displayformat=displayformat_ref; 
        if missing(displayformat) then displayformat=displayformat_reftd; 
  
        %if (%quote(&_cstTrgStandard) eq %quote(CDISC-SDTM)) or
            (%quote(&_cstTrgStandard) eq %quote(CDISC-SEND)) %then
        %do;
          %* ADaM has a different definition for Core compared to SDTM and SEND;
          if missing(core) then core=core_ref;
          if missing(core) then core=core_reftd;
          * if missing(core) then core=core_refdom;
          if missing(core) then core=core_class;

          if core = "Req" then mandatory = "Yes";
          if core = "Exp" or core = "Perm" then mandatory = "No";
        %end;        
  
        if upcase(substr(table, 1, 4))="SUPP" then do;
          if missing(label) then label=label_supp;
          if missing(core) then core=core_supp;
          if missing(xmldatatype) then xmldatatype=xmldatatype_supp;
          if missing(xmlcodelist) then xmlcodelist=xmlcodelist_supp;
          if missing(algorithm) then algorithm=algorithm_supp; 
          if missing(displayformat) then displayformat=displayformat_supp; 
        end;  
      run;

      %cstutil_deleteDataSet(_cstDataSetName=work.merge_columns_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work.source_columns_define_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work.supp_ref_&_cstRandom);
  
    %end;
  
    data &_cstTrgColumnDS(drop=ctype formatl formatd format newcolumn1 newcolumn2);
      set &_cstTrgColumnDS 
          work.source_columns_&_cstRandom;
      if not missing(xmlcodelist) then
      do;
        xmlcodelist=compress(xmlcodelist, "$");
        if ksubstr(upcase(xmlcodelist),1,3) ne "CL." then xmlcodelist="CL."||kstrip(xmlcodelist);
      end;
      
      if missing(xmldatatype) then 
      do;
        if ctype=1 and formatd<1 then xmldatatype='integer';
          else if ctype=1 and formatd>0 then xmldatatype='float';
             else xmldatatype='text';
      end;  
    run;
  

  %end; %* _cstRecs_contents gt 0 ;

  proc sort data=&_cstTrgColumnDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef Table Order;
  run;

  %if %sysfunc(exist(&_cstTrgColumnDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgColumnDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgColumnDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgColumnDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgColumnDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgColumnDS (%nrbquote(&_cstDSLabel))
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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_columns_&_cstRandom);

  %*********************************************************************;
  %*  Create source_value metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=value,_cstOutputDS=&_cstTrgValueDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS,_cstAttribute=LABEL);

  proc sort data=&_cstTrgvalueDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef Table Column Order;
  run;

  %if %sysfunc(exist(&_cstTrgvalueDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgvalueDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgvalueDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgvalueDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgvalueDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgvalueDS (%nrbquote(&_cstDSLabel))
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


  %*********************************************************************;
  %*  Create source_codelist metadata                                  *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=codelist,_cstOutputDS=codelist_template_&_cstRandom
    );

  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=codelist_template_&_cstRandom,_cstAttribute=LABEL);

  %cstutilgetncimetadata(
    _cstFormatCatalogs=&_cstFormatCatalogs,
    _cstNCICTerms=&_cstNCICTerms,
    _cstLang=&_cstLang,
    _cstStudyVersion=&_cstStudyVersion, 
    _cstStandard=&_cstTrgStandard,
    _cstStandardVersion=&_cstTrgStandardVersion,
    _cstFmtDS=work.source_codelists_&_cstRandom,
    _cstSASRef=SRCDATA,
    _cstReturn=&_cstReturn,
    _cstReturnMsg=&_cstReturnMsg
    );

  %if &&&_cstReturn %then 
  %do;
    %goto exit_error;
  %end;

  data work.source_codelists_&_cstRandom;
    set work.source_codelists_&_cstRandom;
    /* standardoid="&_cstCTVersionOID"; */
    cdiscstandard="&_cstCDISCCTStandard";
    cdiscstandardversion="&_cstCDISCCTStandardVersion";
    publishingset="&_cstCDISCCTPublishingSet";
  run;

  %if %substr(%upcase(&_cstKeepAllCodeLists),1,1) eq N %then
  %do;

    %* Create a data set with all applicable formats. ;
    data work.cl_column_value_&_cstRandom(keep=xmlcodelist);
      set &_cstTrgColumnDS &_cstTrgValueDS;
        xmlcodelist=upcase(xmlcodelist);
        if xmlcodelist ne '';
    run;
      
    proc sort data=work.cl_column_value_&_cstRandom nodupkey;
      by xmlcodelist;
    run;
    
    %* Only keep applicable formats. ;
    proc sql;
      create table &_cstTrgCodeListDS
      as select
        cl.*
      from
        work.source_codelists_&_cstRandom cl, 
        work.cl_column_value_&_cstRandom cv
      where (upcase(compress(cl.codelist, '$')) = 
             upcase(compress(cv.xmlcodelist, '$')))
      ;
    quit;

    data &_cstTrgCodeListDS;
      set work.codelist_template_&_cstRandom &_cstTrgCodeListDS;
    run;   

    %cstutil_deleteDataSet(_cstDataSetName=work.cl_column_value_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.codelist_template_&_cstRandom);

    proc sort data=&_cstTrgCodeListDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
      by SASRef Codelist Rank OrderNumber CodedValueNum CodedValueChar;
    run;

  %end;
  %else %do;

    data work.source_codelists_&_cstRandom;
      set work.codelist_template_&_cstRandom work.source_codelists_&_cstRandom;
    run;   

    proc sort data=work.source_codelists_&_cstRandom out=&_cstTrgCodeListDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
      by SASRef Codelist Rank OrderNumber CodedValueNum CodedValueChar;
    run;

  %end;
  

  %if %sysfunc(exist(&_cstTrgCodeListDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgCodeListDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgCodeListDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgCodeListDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgCodeListDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgCodeListDS (%nrbquote(&_cstDSLabel))
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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_codelists_&_cstRandom);

  %***********************************************************************;
  %*  Create source_documents metadata                                   *;
  %*  Documents can be attached to Item Origins, Methods, Comments       *;
  %*  Comments can be attached to a WhereClause, ItemDef or ItemGroupDef *;
  %***********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=document,_cstOutputDS=&_cstTrgDocumentDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS,_cstAttribute=LABEL);

  proc sort data=&_cstTrgDocumentDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef DocType Table Column WhereClause href;
  run;

  %if %sysfunc(exist(&_cstTrgDocumentDS)) %then %do;
    %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDocumentDS);
    %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                              %else %let _cstRecs=&_cstRecs record;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
         ()&_cstTrgDocumentDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
  %end;

  %if %symexist(_cstResultsDS) %then
  %do;
    %if %sysfunc(exist(&_cstTrgDocumentDS)) %then %do;
       %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgDocumentDS);
       %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                 %else %let _cstRecs=&_cstRecs record;
       %cstutil_writeresult(
          _cstResultId=DEF0014
          ,_cstResultParm1=&_cstTrgDocumentDS (%nrbquote(&_cstDSLabel))
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


  %***********************************************************************;
  %*  Create source_analysisresults metadata                             *;
  %***********************************************************************;

  %if %sysevalf(%superq(_cstTrgAnalysisResultDS)=, boolean) %then
  %do;
    %if %symexist(_CSTSASRefs) %then
    %do;
      %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the target location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeStudyMetadata,
          _cstSASRefSubType=analysisresult,
          _cstSASRefsasref=_cstTrgMetaLibrary,
          _cstSASRefmember=_cstTrgAnalysisResultDS,
          _cstAllowZeroObs=1
          );
        
        %if %sysevalf(%superq(_cstTrgMetaLibrary)=, boolean) or
            %sysevalf(%superq(_cstTrgAnalysisResultDS)=, boolean) 
            %then %let _cstTrgAnalysisResultDS=;
            %else %let _cstTrgAnalysisResultDS = &_cstTrgMetaLibrary..&_cstTrgAnalysisResultDS; 
      %end;
    %end;
  %end;

  %if %sysevalf(%superq(_cstTrgAnalysisResultDS)=, boolean)=0 %then
  %do;

    %if (%sysfunc(libref(%sysfunc(scan(%trim(%left(&_cstTrgAnalysisResultDS)),1,.))))) %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Target libraries must be assigned: _cstTrgAnalysisResultDS.;
      %goto exit_error;
    %end;


    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=analysisresult,_cstOutputDS=&_cstTrgAnalysisResultDS
      );
    %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS,_cstAttribute=LABEL);
  
    proc sort data=&_cstTrgAnalysisResultDS
      %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
      by SASRef DisplayIdentifier ResultIdentifier table analysisvariables;
    run;
  
    %if %sysfunc(exist(&_cstTrgAnalysisResultDS)) %then %do;
      %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgAnalysisResultDS);
      %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                %else %let _cstRecs=&_cstRecs record;
      %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] %str
           ()&_cstTrgAnalysisResultDS (%nrbquote(&_cstDSLabel)) was created as requested (&_cstRecs).;
    %end;
  
    %if %symexist(_cstResultsDS) %then
    %do;
      %if %sysfunc(exist(&_cstTrgAnalysisResultDS)) %then %do;
         %let _cstRecs=%cstutilnobs(_cstDatasetName=&_cstTrgAnalysisResultDS);
         %if %eval(&_cstRecs) ne 1 %then %let _cstRecs=&_cstRecs records;
                                   %else %let _cstRecs=&_cstRecs record;
         %cstutil_writeresult(
            _cstResultId=DEF0014
            ,_cstResultParm1=&_cstTrgAnalysisResultDS (%nrbquote(&_cstDSLabel))
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

  %***********************************************************************;

  %* Clean-up  *;
  %cstutil_deleteDataSet(_cstDataSetName=work.contents&_cstRandom);

  %exit_error:
  %if &&&_cstReturn %then 
  %do;
    %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] &&&_cstReturnMsg;

    %if %symexist(_cstResultsDS) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DEF0099
                  ,_cstResultParm1=&&&_cstReturnMsg
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstThisMacro
                  ,_cstResultFlagParm=&&&_cstReturn
                  ,_cstRCParm=&&&_cstReturn
                  );

    %end;
  %end;
  
  %* Persist the results if specified in sasreferences  *;
  %cstutil_saveresults();

  %exit_error_nomsg:

%mend define_createsrcmetafromsaslib;
