%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_createsrcmetafromdefine                                                 *;
%*                                                                                *;
%* Derives source study metadata files from a Define-XML v2.1 data library.       *;
%*                                                                                *;
%* This macro derives source metadata files from a data library that contains     *;
%* the SAS representation of a Define-XML V2.1 define.xml file for a study.       *;
%*                                                                                *;
%* These SAS data sets must exist in this Define-XML V2.1 SAS data set library:   *;
%*      aliases                                                                   *;
%*      codelistitems                                                             *;
%*      codelists                                                                 *;
%*      definedocument                                                            *;
%*      documentrefs                                                              *;
%*      enumerateditems                                                           *;
%*      externalcodelists                                                         *;
%*      formalexpressions                                                         *;
%*      itemdefs                                                                  *;
%*      itemgroupdefs                                                             *;
%*      itemgroupclass                                                            *;
%*      itemgroupclasssubclass                                                    *;
%*      itemgroupitemrefs                                                         *;
%*      itemgroupleaf                                                             *;
%*      itemgroupleaftitles                                                       *;
%*      itemorigin                                                                *;
%*      itemrefwhereclauserefs                                                    *;
%*      itemvaluelistrefs                                                         *;
%*      mdvleaf                                                                   *;
%*      mdvleaftitles                                                             *;
%*      metadataversion                                                           *;
%*      methoddefs                                                                *;
%*      pdfpagerefs                                                               *;
%*      standards                                                                 *;
%*      study                                                                     *;
%*      translatedtext                                                            *;
%*      valuelistitemrefs                                                         *;
%*      valuelists                                                                *;
%*      whereclausedefs                                                           *;
%*      whereclauserangechecks                                                    *;
%*      whereclauserangecheckvalues                                               *;
%*                                                                                *;
%* When creating the source_analysisresults data set, the following SAS data sets *;
%* must exist in this Define-XML V2.1 SAS data set library:                       *;
%*                                                                                *;
%*      analysisdataset                                                           *;
%*      analysisdatasets                                                          *;
%*      analysisdocumentation                                                     *;
%*      analysisprogrammingcode                                                   *;
%*      analysisresultdisplays                                                    *;
%*      analysisresults                                                           *;
%*      analysisvariables                                                         *;
%*      analysiswhereclauserefs                                                   *;
%*                                                                                *;
%* These source metadata files are used by the SAS Clinical Standards Toolkit to  *;
%* support CDISC model validation and to derive CDISC Define-XML v2 (define.xml)  *;
%* files:                                                                         *;
%*          source_study                                                          *;
%*          source_standards                                                         *;
%*          source_tables                                                         *;
%*          source_columns                                                        *;
%*          source_codelists                                                      *;
%*          source_values                                                         *;
%*          source_documents                                                      *;
%*          source_analysisresults                                                *;
%*                                                                                *;
%* This is the general strategy:                                                  *;
%*    1. Use the SAS representation of a Define-XML V2.1 define.xml file as the   *;
%*       primary source of the information.                                       *;
%*    2. Use reference_tables, reference_columns, class_tables, and class_columns *;
%*       for matching the columns to impute missing metadata by specifying        *;
%*       _cstUseRefLib=Y.                                                         *;
%*                                                                                *;
%* Notes:                                                                         *;
%*   1. This is ONLY an attempted approximation of source metadata. No            *;
%*      assumptions should be made that the result accurately represents the      *;
%*      study data. Incomplete reference metadata might not enable imputation of  *;
%*      missing metadata.                                                         *;
%*   2. _cstDefineDataLib must be specified. If this parameter is not specified,  *;
%*      the macro attempts to get _cstDefineDataLib from the SASReferences data   *;
%*      set that is specified by the macro variable _cstSASRefs                   *;
%*      (type=sourcedata, subtype=, reftype=libref, filetype=folder).             *;
%*   3. _cstTrg<table>DS must be specified (table=Study|Standard|Table|Column|    *;
%*      CodeList|Value|Document|AnalysisResults). If this parameter is not        *;
%*      specified, the macro attempts to get _cstSAS<table>Lib from the           *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=studymetadata, subtype=<table>, reftype=libref,         *;
%*      filetype=dataset).                                                        *;
%*   4. _cstUseRefLib=Y _cstRefTableDS must be specified. If this parameter is    *;
%*      not specified, the macro attempts to get _cstRefTableDS from the          *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencemetadata, subtype=table, reftype=libref,       *;
%*      filetype=dataset).                                                        *;
%*   5. _cstUseRefLib=Y _cstRefColumnDS must be specified. If this parameter is   *;
%*      not specified, the macro attempts to get _cstRefColumnDS from the         *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencemetadata, subtype=column, reftype=libref,      *;
%*      filetype=dataset).                                                        *;
%*   6. _cstUseRefLib=Y _cstClassTableDS must be specified. If this parameter is  *;
%*      not specified, the macro attempts to get _cstClassTableDS from the        *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=classmetadata, subtype=table, reftype=libref,           *;
%*      filetype=dataset).                                                        *;
%*   7. _cstUseRefLib=Y _cstClassColumnDS must be specified. If this parameter is *;
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
%* @param  _cstDefineDataLib - required - The library where the SAS               *;
%*             representation of a Define-XML V2.1 file is located.               *;
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
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2017-03-10 Added support for AlgorithmType and FormalExpressions.     *;
%* @history 2017-08-25 Added support for table Repeating and IsReferenceData.     *;
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                     Added _cstTrgStandardDS parameter                          *;
%* @history 2022-08-31 Added support for AlgorithmName.                           *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro define_createsrcmetafromdefine(
    _cstDefineDataLib=,
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
    _cstReturn=_cst_rc,
    _cstReturnMsg=_cst_rcmsg
    ) / des='CST: Create source metadata from Define';


  %local
    _cstRandom
    _cstRegex
    _cstRegexID
    _cstRecs
    _cstExpTables
    _cstCounter
    _cstTable
    _cstMissing
    _cstNotAssigned

    _cstResultSeq
    _cstSeqCnt
    _cstUseResultsDS

    _cstThisMacro

    _cstTrgMetaLibrary
    _cstReflibrary

    _cstTypeStudyMetadata
    _cstTypeClassMetadata
    _cstTypeReferenceMetadata
    _cstTypeSourceData
    _cstDSLabel
    _cstLanguageCondition
    _cstAnalysisResultsMetadata
    ;

  %let _cstThisMacro=&sysmacroname;
  %let _cstSrcData=&sysmacroname;

  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstUseResultsDS=0;

  %let _cstAnalysisResultsMetadata=1;  
  
  %* Without a lang attribute "en" is assumed;
  %if &_cstLang=en or %sysevalf(%superq(_cstLang)=, boolean) 
  %then
    %let _cstLanguageCondition=%str((lang="en" or lang=""));
  %else  
    %let _cstLanguageCondition=%str(lang="&_cstLang");

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

  %* Rule: _cstDefineDataLib must be specified  *;
  %if %sysevalf(%superq(_cstDefineDataLib)=, boolean) %then %do;
    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the target location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeSourceData,
          _cstSASRefsasref=_cstDefineDataLib,
          _cstAllowZeroObs=1
          );
      %end;
  %end;
  %if %sysevalf(%superq(_cstDefineDataLib)=, boolean) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Required macro parameter _cstDefineDataLib must be specified.;
    %goto exit_error;
  %end;


  %* Rule: Check that the Define libref is assigned  *;
  %if (%sysfunc(libref(&_cstDefineDataLib))) %then
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The Define libref(&_cstDefineDataLib) is not assigned.;
    %goto exit_error;
  %end;


  %* Rule: If _cstDefineDataLib exists, so certain data sets must exist  *;
  %let _cstExpTables=definedocument study metadataversion standards supplementaldocs itemgroupdefs itemgroupclass itemgroupclasssubclass %str
                     ()itemgroupitemrefs itemdefs translatedtext itemgroupleaf itemgroupleaftitles aliases codelists itemorigin methoddefs %str
                     ()codelistitems enumerateditems whereclausedefs whereclauserangechecks whereclauserangecheckvalues %str
                     ()formalexpressions externalcodelists valuelists valuelistitemrefs itemvaluelistrefs itemrefwhereclauserefs %str
                     ()mdvleaf mdvleaftitles documentrefs pdfpagerefs;
  %let _cstMissing=;
  %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables, %str( )));
    %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
    %if not %sysfunc(exist(&_cstDefineDataLib..&_cstTable)) %then
      %let _cstMissing = &_cstMissing &_cstTable;
  %end;

  %if %length(&_cstMissing) gt 0
    %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Expected Define-XML metadata data set(s) not existing in library &_cstDefineDataLib: &_cstMissing..;
      %goto exit_error;
    %end;

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


  %* Special case: Analysis Results Metadata. It does not have to be specified;
  %let _cstMissing=;
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
          _cstSASRefSubType=AnalysisResult,
          _cstSASRefsasref=_cstTrgMetaLibrary,
          _cstSASRefmember=_cstTrgAnalysisResultDS,
          _cstAllowZeroObs=1
          );

        %if %sysevalf(%superq(_cstTrgAnalysisResultDS)=, boolean) %then
          %let _cstAnalysisResultsMetadata=0;

        %let _cstTrgAnalysisResultDS = &_cstTrgMetaLibrary..&_cstTrgAnalysisResultDS;
       
        %if %sysevalf(%superq(_cstTrgMetaLibrary)=, boolean) or
            %sysevalf(%superq(_cstTrgAnalysisResultDS)=, boolean) %then %do;
          %let _cstMissing = _cstTrg&_cstTable.DS;
          %let _cstAnalysisResultsMetadata=0;
        %end;
      %end;
      %else
      %do;
        %let _cstMissing = _cstTrg&_cstTable.DS;
        %let _cstAnalysisResultsMetadata=0;
      %end;
    %end;
    %else
    %do;
      %let _cstMissing = _cstTrg&_cstTable.DS;
      %let _cstAnalysisResultsMetadata=0;
    %end;
  %end;
  
  %* Rule: Expected Analysis Results Metadata library to be created must be assigned;
  %let _cstExpTables=Study Standard Table Column CodeList Value Document;

  %let _cstNotAssigned=;
  %if %sysfunc(kindexc(&_cstTrgAnalysisResultDS,.)) %then 
  %do;   
    %if (%sysfunc(libref(%sysfunc(scan(%trim(%left(&_cstTrgAnalysisResultDS)),1,.))))) %then 
    %do;
        %let _cstNotAssigned = %scan(%trim(%left(&_cstTrgAnalysisResultDS)),1,.);
        %let _cstAnalysisResultsMetadata=0;
    %end;

  %if %length(&_cstNotAssigned) gt 0
    %then %do;
      %let _cstAnalysisResultsMetadata=0;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Target libraries must be assigned: &_cstNotAssigned..;
      %goto exit_error;
    %end;
  %end;

  %if &_cstAnalysisResultsMetadata=0 %then 
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Analysis Results Metadata will not be created;

  %if &_cstAnalysisResultsMetadata %then
  %do;
    %* Rule: If _cstDefineDataLib exists, so certain data sets must exist  *;
    %let _cstExpTables=analysisdataset analysisdatasets analysisdocumentation analysisprogrammingcode %str
                     ()analysisresultdisplays analysisresults analysisvariables analysiswhereclauserefs;
    %let _cstMissing=;
    %do _cstCounter=1 %to %sysfunc(countw(&_cstExpTables, %str( )));
      %let _cstTable=%scan(&_cstExpTables, &_cstCounter);
      %if not %sysfunc(exist(&_cstDefineDataLib..&_cstTable)) %then
        %let _cstMissing = &_cstMissing &_cstTable;
    %end;
  
    %if %length(&_cstMissing) gt 0
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Expected Define-XML metadata data set(s) not existing in library &_cstDefineDataLib: &_cstMissing..;
        %goto exit_error;
      %end;
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

  %******************************************************************************;
  %* End of Parameter checks                                                    *;
  %******************************************************************************;

  %*********************************************************************;
  %*  Create source_study metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=study,_cstOutputDS=&_cstTrgStudyDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS,_cstAttribute=LABEL);

  proc sql;
    create table work.source_study_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      odm.FileOID,
      odm.Originator length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=Originator, _cstAttribute=VARLEN),
      odm.Context,
      std.OID as StudyOID,
      std.StudyName length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=StudyName, _cstAttribute=VARLEN),
      std.StudyDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=StudyDescription, _cstAttribute=VARLEN),
      std.ProtocolName length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=ProtocolName, _cstAttribute=VARLEN),
      comtt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      mdv.name as MetadataVersionName  length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=metadataversionname, _cstAttribute=VARLEN),
      mdv.description as MetadataVersionDescription  length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStudyDS, _cstVarName=metadataversiondescription, _cstAttribute=VARLEN),
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

    from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comtt
     on comtt.parentkey = mdv.commentoid
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_study_&_cstRandom);
  %if %eval(&_cstRecs) gt 0 %then %do;
    data &_cstTrgStudyDS;
      set &_cstTrgStudyDS 
          work.source_study_&_cstRandom;
    run;
  %end;

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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_study_&_cstRandom);

  %*********************************************************************;
  %*  Create source_standards metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=standard,_cstOutputDS=&_cstTrgStandardDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgStandardDS,_cstAttribute=LABEL);


  data work.source_standards0_&_cstRandom;
   set &_cstDefineDataLib..standards;
   Order=_n_;
  run;

  proc sql;
    create table work.source_standards_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      stnd.Name as CDISCStandard length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStandardDS, _cstVarName=CDISCStandard, _cstAttribute=VARLEN),
      stnd.Version as CDISCStandardVersion length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStandardDS, _cstVarName=CDISCStandardVersion, _cstAttribute=VARLEN),
      stnd.Order,
      stnd.Type,
      stnd.PublishingSet,
      stnd.Status,
      comtt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgStandardDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

    from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join work.source_standards0_&_cstRandom stnd
     on stnd.fk_metadataversion = mdv.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comtt
     on comtt.parentkey = stnd.commentoid
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_standards_&_cstRandom);
  %if %eval(&_cstRecs) gt 0 %then %do;
    data &_cstTrgStandardDS;
      set &_cstTrgStandardDS 
          work.source_standards_&_cstRandom;
    run;
  %end;

  proc sort data=&_cstTrgStandardDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef Order;
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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_standards0_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work.source_standards_&_cstRandom);

  %*********************************************************************;
  %*  Create source_table metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=table,_cstOutputDS=&_cstTrgTableDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS,_cstAttribute=LABEL);

  proc sql;
    create table ItemGroupKeys_&_cstRandom
    as select
      igdir.fk_ItemGroupDefs as ItemGroupOID,
      itd.Name as column,
      igdir.KeySequence

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..itemgroupdefs igd
     on igd.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..itemgroupitemrefs igdir
     on igdir.fk_itemgroupdefs = igd.oid
       inner join &_cstDefineDataLib..itemdefs itd
     on (itd.oid = igdir.itemoid and itd.fk_metadataversion = mdv.oid and not missing(igdir.KeySequence))
     order by ItemGroupOID, KeySequence
     ;
  quit;

  data ItemGroupKeys_&_cstRandom;
    retain ItemGroupOID keys;
    length keys $200;
    set ItemGroupKeys_&_cstRandom;
    by ItemGroupOID KeySequence;
    if first.ItemGroupOID then keys=column;
                          else keys=catx(' ', keys,column);
    if last.ItemGroupOID;
  run ;

  data work.itemgroupdefs_&_cstRandom;
   set &_cstDefineDataLib..itemgroupdefs;
   TableOrder=_n_;
  run;

  proc sql;
    create table work.source_tables_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      igd.Name as Table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Table, _cstAttribute=VARLEN),
      igdtt.TranslatedText as Label length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Label, _cstAttribute=VARLEN),
      igd.TableOrder as Order,
      igd.Domain,
      igd.Repeating,
      igd.IsReferenceData,
      al.Name as DomainDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=DomainDescription, _cstAttribute=VARLEN),
      igc.Name length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Class, _cstAttribute=VARLEN) as Class,
      igsc.Name length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=SubClass, _cstAttribute=VARLEN) as SubClass,
      igdl.href as xmlpath length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=xmlpath, _cstAttribute=VARLEN),
      igdlt.title as xmltitle length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=xmltitle, _cstAttribute=VARLEN),
      igd.Structure length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Structure, _cstAttribute=VARLEN),
      igd.Purpose length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Purpose, _cstAttribute=VARLEN),
      igdk.Keys,
      scan(odm.creationdatetime, 1, 'T') as date length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Date, _cstAttribute=VARLEN),
      comtt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      stnd.name length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=CDISCStandard, _cstAttribute=VARLEN) as CDISCStandard,
      stnd.Version length=%cstutilgetattribute(_cstDataSetName=&_cstTrgTableDS, _cstVarName=CDISCStandardVersion, _cstAttribute=VARLEN) as CDISCStandardVersion,
      igd.IsNonStandard,
      igd.HasNoData,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join work.itemgroupdefs_&_cstRandom igd
     on igd.fk_metadataversion = mdv.oid
       left join &_cstDefineDataLib..standards stnd
     on stnd.fk_metadataversion = mdv.oid and stnd.oid = igd.StandardOID
     
       left join &_cstDefineDataLib..itemgroupclass igc
     on igc.FK_ItemGroupDefs = igd.oid
       left join &_cstDefineDataLib..itemgroupclasssubclass igsc
     on igsc.FK_ItemGroupClass = igc.oid

       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ItemGroupDefs')) igdtt
     on igdtt.parentkey = igd.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comtt
     on comtt.parentkey = igd.commentoid
       left join &_cstDefineDataLib..aliases(where=(Context="DomainDescription" and parent='ItemGroupDefs')) al
     on al.parentkey = igd.oid
       left join &_cstDefineDataLib..itemgroupleaf igdl
     on igdl.fk_itemgroupdefs = igd.oid
       left join &_cstDefineDataLib..itemgroupleaftitles igdlt
     on igdlt.fk_itemgroupleaf = igdl.id
       left join work.ItemGroupKeys_&_cstRandom igdk
     on igdk.ItemGroupOID = igd.oid
     order by table
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_tables_&_cstRandom);

  %if %upcase(&_cstUseRefLib) eq Y %then
  %do;

    data work.source_tables_define_&_cstRandom;
      set &_cstTrgTableDS 
          work.source_tables_&_cstRandom;
    run;

    %* Get SUPP column reference metadata; 
    proc sort data=&_cstRefTableDS 
      out=work.supp_ref_&_cstRandom(keep=Table Label Class Keys Purpose Structure State) nodupkey;
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
        select srct.table, srct.class, srct.domain, ref.label, ref.keys, ref.purpose, ref.structure, ref.state, ref.date
          from work.source_tables_&_cstRandom srct,
               &_cstRefTableDS ref
          where upcase(srct.domain)=upcase(ref.table)
        ) reftd
          on upcase(src.table)=upcase(reftd.table)
        left join work.supp_ref_&_cstRandom supp
          on upcase(substr(src.table, 1, 4))="SUPP"
        left join &_cstClassTableDS classt
          on (upcase(reftd.class)=upcase(classt.table))
      order by table
      ;
    quit;

    data work.source_tables_&_cstRandom(drop=label_: keys_: class_: purpose_: structure_: state_:);
      merge work.source_tables_define_&_cstRandom work.merge_tables_&_cstRandom;
      format _character_ _numeric_;
      by table;
      if missing(date) then date=put(today(), E8601DA.);

      if missing(label) then label=label_ref;
      if missing(label) then label=label_refdom;

      if missing(keys) then keys=keys_ref;
      if missing(keys) then keys=keys_refdom;

      if missing(class) then class=class_ref;
      if missing(class) then class=class_refdom;

      if missing(structure) then structure=structure_ref;
      if missing(structure) then structure=structure_refdom;

      if missing(purpose) then purpose=purpose_ref;
      if missing(purpose) then purpose=purpose_refdom;
      if missing(purpose) then purpose=purpose_class;

      if missing(state) then state=state_ref;
      if missing(state) then state=state_refdom;

      if upcase(substr(table, 1, 4))="SUPP" then do;
        if missing(label) and (not missing(label_supp)) 
          then label=tranwrd (label_supp, 'XX', substr(table, 5, 2));
        if missing(keys) then keys=keys_supp;
        if missing(class) then class=class_supp;
        if missing(structure) then structure=structure_supp;
        if missing(state) then state=state_supp;
      end;  
    run;

    %cstutil_deleteDataSet(_cstDataSetName=work.merge_tables_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.source_tables_define_&_cstRandom);

  %end;

  data &_cstTrgTableDS;
    set &_cstTrgTableDS 
        work.source_tables_&_cstRandom;
  run;

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
  %cstutil_deleteDataSet(_cstDataSetName=work.itemgroupdefs_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work.ItemGroupKeys_&_cstRandom);

  %*********************************************************************;
  %*  Create source_column metadata                                    *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=column,_cstOutputDS=&_cstTrgColumnDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS,_cstAttribute=LABEL);

  proc sql;
    create table work.source_columns_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      igd.Name as Table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=Table, _cstAttribute=VARLEN),
      itd.Name as column length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=Column, _cstAttribute=VARLEN),
      idtt.TranslatedText as Label length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=Label, _cstAttribute=VARLEN),
      igdir.OrderNumber as order,
      igdir.Mandatory as mandatory,
      case when upcase(itd.DataType) in ("INTEGER","FLOAT")
        then 'N'
        else 'C'
      end as type,
      itd.Length,
      itd.DisplayFormat length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=DisplayFormat, _cstAttribute=VARLEN),
      itd.SignificantDigits,
      itd.DataType as xmldatatype,
      cl.OID as xmlcodelist,
      itor.type as origintype,
      itor.source as originsource,
      itortt.TranslatedText as origindescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=origindescription, _cstAttribute=VARLEN),
      igdir.Role,
      mettt.TranslatedText as algorithm length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=algorithm, _cstAttribute=VARLEN),
      metd.Name as algorithmname length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=algorithmname, _cstAttribute=VARLEN),
      metd.Type as algorithmtype length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=algorithmtype, _cstAttribute=VARLEN),
      metfe.Expression as formalexpression length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=formalexpression, _cstAttribute=VARLEN),
      metfe.Context as formalexpressioncontext length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=formalexpressioncontext, _cstAttribute=VARLEN),
      comitt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgColumnDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      igdir.IsNonStandard,
      igdir.HasNoData,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion      
      
     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..itemgroupdefs igd
     on igd.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..itemgroupitemrefs igdir
     on igdir.fk_itemgroupdefs = igd.oid
       inner join &_cstDefineDataLib..itemdefs itd
     on (itd.oid = igdir.itemoid and itd.fk_metadataversion = mdv.oid)
       left join &_cstDefineDataLib..codelists cl
     on (cl.fk_metadataversion = mdv.oid and itd.codelistref = cl.oid)
       left join &_cstDefineDataLib..itemorigin itor
     on itor.fk_itemdefs = itd.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ItemDefs')) idtt
     on idtt.parentkey = itd.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comitt
     on comitt.parentkey = itd.commentoid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='MethodDefs')) mettt
     on mettt.parentkey = igdir.methodoid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ItemOrigin')) itortt
     on itortt.parentkey = itor.oid
       left join &_cstDefineDataLib..methoddefs metd
     on metd.oid = igdir.methodoid
       left join &_cstDefineDataLib..formalexpressions(where=(parent='MethodDefs')) metfe
     on metfe.parentkey = metd.oid

     order by table, order;
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_columns_&_cstRandom);

  %if %upcase(&_cstUseRefLib) eq Y %then
  %do;

    data work.source_columns_define_&_cstRandom;
      set &_cstTrgColumnDS 
          work.source_columns_&_cstRandom;
    run;


    %* Get SUPP column reference metadata; 
    proc sort data=&_cstRefColumnDS 
      out=work.supp_ref_&_cstRandom(keep=Column label length core) nodupkey;
    by Column;
    where upcase(substr(table, 1, 4))="SUPP";
    run;
    
    proc sql;
    create table work.merge_columns_&_cstRandom as
    select
      src.table,
      src.order,
      reftd.domain,
      reftd.class,
      classc.table as table_class,
      classc.column as column_class,

      refc.label as label_ref,
      refc.length as length_ref,
      refc.core as core_ref,

      reftd.label as label_refdom,
      reftd.length as length_refdom,
      reftd.core as core_refdom,

      supp.label as label_supp,
      supp.length as length_supp,
      supp.core as core_supp,

      classc.label as label_class,
      classc.length as length_class,
      classc.core as core_class

      from work.source_columns_define_&_cstRandom src
        left join &_cstRefColumnDS refc
          on src.table=refc.table and src.column=refc.column
        left join
        (
        select srct.table, srct.class, ref.column, srct.domain, ref.label, ref.core, ref.length
          from &_cstTrgTableDS srct,
               &_cstRefColumnDS ref
          where upcase(srct.domain)=upcase(ref.table)
        ) reftd
          on (upcase(src.table)=upcase(reftd.table) and upcase(src.column)=upcase(reftd.column)) 
        left join work.supp_ref_&_cstRandom supp
          on (upcase(substr(src.table, 1, 4))="SUPP" and upcase(src.column)=upcase(supp.column))
        left join &_cstClassColumnDS classc
          on ((upcase(src.column)=upcase(classc.column)) or (substr(src.column,3) = substr(classc.column,3))) and
             ((upcase(reftd.class)=upcase(classc.table)) or (upcase(classc.table) in ("TIMING", "IDENTIFIERS")))

      order by table, order
      ;
    quit;

    data work.source_columns_&_cstRandom(drop=domain class table_class column_class label_: length_: core_:);
      merge work.source_columns_define_&_cstRandom work.merge_columns_&_cstRandom;
      format _character_ _numeric_;
      by table order;

      if missing(label) then label=label_ref;
      if missing(label) then label=label_refdom;
      if missing(label) then label=label_class;

      if length le 0 then length=length_ref;
      if length le 0 then length=length_refdom;
      if length le 0 then length=length_class;

      %if (%quote(&_cstTrgStandard) eq %quote(CDISC-SDTM)) or
          (%quote(&_cstTrgStandard) eq %quote(CDISC-SEND)) %then
      %do;
        %* ADaM has a different definition for Core compared to SDTM and SEND;
        if missing(core) then core=core_ref;
        if missing(core) then core=core_refdom;
        if missing(core) then core=core_class;
      %end;

      if upcase(substr(table, 1, 4))="SUPP" then do;
        if missing(label) then label=label_supp;
        if length le 0 then length=length_supp;
        if missing(core) then core=core_supp;
      end;  

    run;

    %cstutil_deleteDataSet(_cstDataSetName=work.merge_columns_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.source_columns_define_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.supp_ref_&_cstRandom);

  %end;

  data &_cstTrgColumnDS;
    set &_cstTrgColumnDS 
        work.source_columns_&_cstRandom;
  run;

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
  %*  Create source_codelist metadata                                  *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=codelist,_cstOutputDS=&_cstTrgCodeListDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS,_cstAttribute=LABEL);

  proc sql;
    create table work.source_codelists_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      cl.OID as CodeList,
      cl.Name as CodeListName,
      cltt.TranslatedText as CodeListDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CodeListDescription, _cstAttribute=VARLEN),
      cli.CodelistItemDescription as CodeListItemDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CodeListItemDescription, _cstAttribute=VARLEN),
      clal.Name as CodeListNCICode length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CodeListNCICode, _cstAttribute=VARLEN),
      cl.DataType as CodeListDataType,
      cl.SASFormatName as SasFormatName,
      case when not (upcase(cl.DataType) in ("INTEGER","FLOAT"))
        then cli.CodedValue
        else ""
      end as CodedValueChar,
      case when upcase(cl.DataType) in ("INTEGER","FLOAT")
        then input(cli.CodedValue, ? best.)
        else .
      end as CodedValueNum,
      cli.TranslatedText as DecodeText length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=DecodeText, _cstAttribute=VARLEN),
      cli.Lang as DecodeLanguage,
      cli.Name as CodedValueNCICode length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CodedValueNCICode, _cstAttribute=VARLEN),
      cli.Rank as Rank,
      cli.OrderNumber as OrderNumber,
      cli.ExtendedValue as ExtendedValue,
      extcl.dictionary length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=Dictionary, _cstAttribute=VARLEN),
      extcl.version length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=Version, _cstAttribute=VARLEN),
      extcl.ref,
      extcl.href,
      comtt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      stnd.name length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CDISCStandard, _cstAttribute=VARLEN) as CDISCStandard,
      stnd.Version length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=CDISCStandardVersion, _cstAttribute=VARLEN) as CDISCStandardVersion,
      stnd.PublishingSet length=%cstutilgetattribute(_cstDataSetName=&_cstTrgCodeListDS, _cstVarName=PublishingSet, _cstAttribute=VARLEN) as PublishingSet,
      cl.IsNonStandard,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid

       inner join &_cstDefineDataLib..codelists cl
     on cl.fk_metadataversion = mdv.oid
       left join &_cstDefineDataLib..standards stnd
     on stnd.fk_metadataversion = mdv.oid and stnd.oid = cl.StandardOID
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CodeLists')) cltt
     on cltt.parentkey = cl.oid
       left join &_cstDefineDataLib..aliases(where=(Context="nci:ExtCodeID" and parent='CodeLists')) clal
     on clal.parentkey = cl.oid
       left join &_cstDefineDataLib..externalcodelists extcl
     on extcl.fk_CodeLists = cl.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comtt
     on comtt.parentkey = cl.commentoid

       left join (

       (select cli.*, clitt.lang, clitt.TranslatedText, clial.Name, clittdes.TranslatedText as CodelistItemDescription from
         &_cstDefineDataLib..codelistitems cli
           left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CodeListItems')) clitt
         on clitt.parentkey = cli.oid
           left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CodeListItemDescription')) clittdes
         on clittdes.parentkey = cli.oid
           left join &_cstDefineDataLib..aliases(where=(Context="nci:ExtCodeID" and parent='CodeListItems')) clial
         on clial.parentkey = cli.oid)

       outer union corresponding

       (select encli.*, enclial.Name, enclittdes.TranslatedText as CodelistItemDescription from
         &_cstDefineDataLib..enumerateditems encli
           left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='EnumeratedItemDescription')) enclittdes
         on enclittdes.parentkey = encli.oid
           left join &_cstDefineDataLib..aliases(where=(Context="nci:ExtCodeID" and parent='EnumeratedItems')) enclial
         on enclial.parentkey = encli.oid)

         ) cli

     on cli.fk_CodeLists = cl.oid
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_codelists_&_cstRandom);
  %if %eval(&_cstRecs) gt 0 %then %do;

    data &_cstTrgCodeListDS;
      set &_cstTrgCodeListDS 
          work.source_codelists_&_cstRandom;
    run;
    
  %end;

  proc sort data=&_cstTrgCodeListDS
    %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
    by SASRef Codelist Rank OrderNumber CodedValueNum CodedValueChar;
  run;

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


  %*********************************************************************;
  %*  Create source_value metadata                                     *;
  %*********************************************************************;

  %cst_createdsfromtemplate(
  _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
  _cstType=studymetadata,_cstSubType=value,_cstOutputDS=&_cstTrgValueDS
  );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS,_cstAttribute=LABEL);

  proc sql;
    create table work._whereclauses_&_cstRandom
    as select
      mdv.OID as StudyVersion,
      wcld.oid as whereclauseoid,
      wclrc.oid as checkoid,
      wclrc.softhard,
      wclrc.itemoid,
      itd.name as column,
      wclrc.comparator,
      wclrcv.checkvalue,
      wcld.commentoid,
      comtt.TranslatedText as WhereClauseComment

    from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       left join &_cstDefineDataLib..whereclausedefs wcld
     on wcld.fk_metadataversion = mdv.oid
       left join &_cstDefineDataLib..whereclauserangechecks wclrc
     on wclrc.fk_whereclausedefs = wcld.oid
       left join &_cstDefineDataLib..whereclauserangecheckvalues wclrcv
     on wclrcv.FK_WhereClauseRangeChecks = wclrc.oid
       left join &_cstDefineDataLib..itemdefs itd
     on itd.oid = wclrc.itemoid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comtt
     on comtt.parentkey = wcld.commentoid

     order by whereclauseoid, checkoid
     ;
  quit;

  data _whereclauses_&_cstRandom(keep=whereclauseoid whereclause whereclausecomment commentoid);
    length single_condition $1000 whereclause $1000;
    retain single_condition whereclause;
    set work._whereclauses_&_cstRandom;
    by whereclauseoid checkoid;

    if first.checkoid
      then single_condition=quote(strip(checkvalue));
      else single_condition=cats(single_condition, ",", quote(strip(checkvalue)));
      if last.checkoid then do;
        select(comparator);
          when("EQ") single_condition = cat(strip(column), ' EQ ', strip(single_condition));
          when("IN") single_condition = cat(strip(column), ' IN ', "(", strip(single_condition), ")");
          when("NOTIN") single_condition = cat(strip(column), ' NOTIN ', "(", strip(single_condition), ")");
          when("NE") single_condition = cat(strip(column), ' NE ', strip(single_condition));
          when("GE") single_condition = cat(strip(column), ' GE ', strip(single_condition));
          when("LE") single_condition = cat(strip(column), ' LE ', strip(single_condition));
          when("GT") single_condition = cat(strip(column), ' GT ', strip(single_condition));
          when("LT") single_condition = cat(strip(column), ' LT ', strip(single_condition));
          otherwise;
        end;
      end;

      if first.whereclauseoid then call missing (whereclause);
      if last.checkoid then do;
        if missing(whereclause) then whereclause=cat("(", strip(single_condition), ")");
                                else whereclause=cat(strip(whereclause), ' AND ', "(", strip(single_condition), ")");
      end;
      if last.whereclauseoid then do;
        if findw(whereclause, 'AND')=0 and
           (substr(whereclause, 1, 1)="(" and substr(whereclause, length(whereclause), 1)=")")
         then whereclause=substr(whereclause, 2, length(whereclause)-2);
        output;
      end;
  run;


  proc sql;
    create table work.source_values_&_cstRandom
    as select

      upcase("&_cstDefineDataLib") as sasref,
      igd.Name as table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=Table, _cstAttribute=VARLEN),
      itd2.Name as column length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=Column, _cstAttribute=VARLEN),
      itd.Name as name length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=Name, _cstAttribute=VARLEN),
      vltt.TranslatedText as valuelistdescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=valuelistdescription, _cstAttribute=VARLEN),
      wc.whereclause,
      wc.whereclausecomment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=whereclausecomment, _cstAttribute=VARLEN),
      idtt.TranslatedText as Label length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=Label, _cstAttribute=VARLEN),
      vlir.OrderNumber as order,
      vlir.Mandatory as mandatory,      
      case when upcase(itd.DataType) in ("INTEGER","FLOAT")
        then 'N'
        else 'C'
      end as type,
      itd.Length,
      itd.DisplayFormat length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=DisplayFormat, _cstAttribute=VARLEN),
      itd.SignificantDigits,
      itd.DataType as xmldatatype,
      cl.OID as xmlcodelist,
      itor.type as origintype,
      itor.source as originsource,
      itortt.TranslatedText as origindescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=origindescription, _cstAttribute=VARLEN),
      vlir.Role,
      mettt.TranslatedText as algorithm length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=algorithm, _cstAttribute=VARLEN),
      metd.Name as algorithmname length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=algorithmname, _cstAttribute=VARLEN),
      metd.Type as algorithmtype length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=algorithmtype, _cstAttribute=VARLEN),
      metfe.Expression as formalexpression length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=formalexpression, _cstAttribute=VARLEN),
      metfe.Context as formalexpressioncontext length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=formalexpressioncontext, _cstAttribute=VARLEN),
      comitt.TranslatedText as Comment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgValueDS, _cstVarName=Comment, _cstAttribute=VARLEN),
      vlir.HasNoData,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..valuelists vld
     on vld.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..valuelistitemrefs vlir
     on vlir.fk_valuelists = vld.oid
       inner join &_cstDefineDataLib..itemdefs itd
     on (itd.oid = vlir.itemoid and itd.fk_metadataversion = mdv.oid)
       left join &_cstDefineDataLib..codelists cl
     on (cl.fk_metadataversion = mdv.oid and itd.codelistref = cl.oid)
       left join &_cstDefineDataLib..itemorigin itor
     on itor.fk_itemdefs = itd.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ValueLists')) vltt
     on vltt.parentkey = vld.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ItemDefs')) idtt
     on idtt.parentkey = itd.oid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='CommentDefs')) comitt
     on comitt.parentkey = itd.commentoid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='MethodDefs')) mettt
     on mettt.parentkey = vlir.methodoid
       left join &_cstDefineDataLib..translatedtext(where=(&_cstLanguageCondition and parent='ItemOrigin')) itortt
     on itortt.parentkey = itor.oid
       left join &_cstDefineDataLib..itemvaluelistrefs ivlr
     on ivlr.valuelistoid = vlir.fk_valuelists
       left join &_cstDefineDataLib..itemgroupitemrefs igdir
     on ivlr.fk_itemdefs = igdir.itemoid
       left join &_cstDefineDataLib..itemgroupdefs igd
     on igd.oid = igdir.fk_itemgroupdefs
       left join &_cstDefineDataLib..itemdefs itd2
     on itd2.oid = ivlr.fk_itemdefs
       left join &_cstDefineDataLib..methoddefs metd
     on metd.oid = vlir.methodoid
       left join &_cstDefineDataLib..formalexpressions(where=(parent='MethodDefs')) metfe
     on metfe.parentkey = metd.oid
       left join &_cstDefineDataLib..itemrefwhereclauserefs irwcr
     on irwcr.valuelistitemrefsoid = vlir.oid
       left join work._whereclauses_&_cstRandom wc
     on wc.whereclauseoid = irwcr.fk_whereclausedefs
     ;
  quit;

  %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_values_&_cstRandom);
  %if %eval(&_cstRecs) gt 0 %then %do;
    
    data &_cstTrgValueDS;
      set &_cstTrgValueDS 
          work.source_values_&_cstRandom;
    run;
    
  %end;

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

  %cstutil_deleteDataSet(_cstDataSetName=work.source_values_&_cstRandom);


  %***********************************************************************;
  %*  Create source_documents metadata                                   *;
  %*  Documents can be attached to Item Origins, Methods, and Comments.  *;
  %*  Comments can be attached to a MetaDataVersion, Standard,           *;
  %*  WhereClause, ItemDef, ItemGroupDef, or CodeList.                   *;
  %***********************************************************************;

  %cst_createdsfromtemplate(
    _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
    _cstType=studymetadata,_cstSubType=document,_cstOutputDS=&_cstTrgDocumentDS
    );
  %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS,_cstAttribute=LABEL);

  proc sql;
    %* Get all items and add a value to docsubtype1 when there is a comment;
    create table work._items_tabcolwhere_mt_cm_&_cstRandom
    as select 
    *,
    case
      when (not missing(itd.commentoid)) then "COLUMN"
      else ""
    end as docsubtype1
    from
    (select
    itd.oid as itemoid,
    igd.Name as table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Table, _cstAttribute=VARLEN),
    itd.Name as column length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Column, _cstAttribute=VARLEN),
    "" as whereclause,
    igdir.methodoid,
    itd.commentoid

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..itemgroupdefs igd
     on igd.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..itemgroupitemrefs igdir
     on igdir.fk_itemgroupdefs = igd.oid
       inner join &_cstDefineDataLib..itemdefs itd
     on (itd.oid = igdir.itemoid and itd.fk_metadataversion = mdv.oid)
     )
    outer union corresponding
    (select
    case
      when (not missing(itdv.commentoid)) then "VCOLUMN"
      when (not missing(wc.commentoid)) then "WHERECLAUSE"
      else ""
    end as docsubtype1,
    vlir.itemoid,
    itd.name as column length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Column, _cstAttribute=VARLEN),
    igd.name as table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Table, _cstAttribute=VARLEN),
    wc.whereclause,
    wc.commentoid as commentoid_wc,
    vlir.methodoid,
    itdv.commentoid

     from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..valuelists vld
     on vld.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..valuelistitemrefs vlir
     on vlir.fk_valuelists = vld.oid
       inner join &_cstDefineDataLib..itemrefwhereclauserefs irwcr
     on irwcr.valuelistitemrefsoid = vlir.oid
       inner join &_cstDefineDataLib..itemvaluelistrefs ivlr
     on (ivlr.valuelistoid=vld.oid)
       inner join &_cstDefineDataLib..itemdefs itd
     on (itd.oid = ivlr.fk_itemdefs and itd.fk_metadataversion = mdv.oid)
       inner join &_cstDefineDataLib..itemdefs itdv
     on (itdv.oid = vlir.itemoid and itdv.fk_metadataversion = mdv.oid)
       inner join &_cstDefineDataLib..itemgroupitemrefs igdir
     on igdir.itemoid = itd.oid
       inner join &_cstDefineDataLib..itemgroupdefs igd
     on igd.oid = igdir.fk_itemgroupdefs
       inner join work._whereclauses_&_cstRandom wc
     on wc.whereclauseoid = irwcr.fk_whereclausedefs
     )
     ;
  quit;

  proc sql;
    %* Supplemental Documents - doctype="SUPPDOC"*;
    create table work._source_suppdocuments_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
      "SUPPDOC" as doctype,
      mdvlf.href,
      mdvlft.title,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

    from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..mdvleaf mdvlf
     on mdvlf.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..mdvleaftitles mdvlft
     on mdvlft.fk_mdvleaf = mdvlf.id
       inner join &_cstDefineDataLib..supplementaldocs sd
     on sd.leafid = mdvlf.id
     ;

    %* Document references - doctype="CRF/COMMENT/DOCTYPE"*;
    create table work._source_documents0_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
      case
        when (parent="ItemOrigin") then "CRF"
        when (parent="CommentDefs") then "COMMENT"
        when (parent="MethodDefs") then "METHOD"
        else ""
      end as doctype,
      mdvlf.href,
      mdvlft.title,
      pdfpr.type as pdfpagereftype,
      pdfpr.title as pdfpagereftitle length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagereftitle, _cstAttribute=VARLEN),
      case
        when (not missing(pdfpr.pagerefs))
          then pdfpr.pagerefs
        when ((not missing(pdfpr.firstpage)) and (not missing (pdfpr.lastpage)))
          then catx('-', pdfpr.firstpage, pdfpr.lastpage)
        when (not missing(pdfpr.firstpage))
          then put(pdfpr.firstpage, best.)
        when (not missing(pdfpr.lastpage))
          then put(pdfpr.lastpage, best.)
        else ""
      end as pdfpagerefs length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagerefs, _cstAttribute=VARLEN),
      dr.parent,
      dr.parentkey,
      itor.fk_ItemDefs as originItem,
      mdv.OID as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

    from &_cstDefineDataLib..definedocument odm
       inner join &_cstDefineDataLib..study std
     on std.fk_definedocument = odm.fileoid
       inner join &_cstDefineDataLib..metadataversion mdv
     on mdv.fk_study = std.oid
       inner join &_cstDefineDataLib..mdvleaf mdvlf
     on mdvlf.fk_metadataversion = mdv.oid
       inner join &_cstDefineDataLib..mdvleaftitles mdvlft
     on mdvlft.fk_mdvleaf = mdvlf.id
       inner join &_cstDefineDataLib..documentrefs dr
     on dr.leafid = mdvlf.id
       left join &_cstDefineDataLib..pdfpagerefs pdfpr
     on (pdfpr.fk_documentrefs = dr.oid)
       left join &_cstDefineDataLib..itemorigin itor
     on (itor.oid = dr.parentkey)
     ;

    %* Documents attached to items;
    create table work._source_documents_&_cstRandom(drop=parent parentkey originitem)
    as select * from
    (select
      sd0.*,
      DocSubType1,
      tcwmc.table as Table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Table, _cstAttribute=VARLEN),
      tcwmc.column as Column length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Column, _cstAttribute=VARLEN),
      tcwmc.whereclause as Whereclause

    from work._source_documents0_&_cstRandom sd0
       inner join work._items_tabcolwhere_mt_cm_&_cstRandom tcwmc
     on (tcwmc.methodoid = sd0.parentkey or
         tcwmc.commentoid = sd0.parentkey or
         tcwmc.commentoid_wc = sd0.parentkey or
         tcwmc.itemoid = sd0.originItem)
     )

    outer union corresponding
    %* Documents attached to tables;
    (select
      sd0.*,
      "TABLE" as DocSubType2,
      itgd.Name as Table length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=Table, _cstAttribute=VARLEN)
    from work._source_documents0_&_cstRandom sd0
       inner join &_cstDefineDataLib..itemgroupdefs itgd
     on (itgd.commentoid = sd0.parentkey)
     )

    outer union corresponding
    %* Documents attached to codelists;
    (select
      sd0.*,
      "CODELIST" as DocSubType3,
      ct.OID as CodeList length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=CodeList, _cstAttribute=VARLEN)
    from work._source_documents0_&_cstRandom sd0
       inner join &_cstDefineDataLib..codelists ct
     on (ct.commentoid = sd0.parentkey)
     )
     
    outer union corresponding
    %* Documents attached to MDV;
    (select
      sd0.*,
      "MDV" as DocSubType4
    from work._source_documents0_&_cstRandom sd0
       inner join &_cstDefineDataLib..metadataversion mdv
     on (mdv.commentoid = sd0.parentkey)
     )

    outer union corresponding
    %* Documents attached to standards;
    (select
      sd0.*,
      "STANDARD" as DocSubType5,
      stnd.name as CDISCStandard length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=CDISCStandard, _cstAttribute=VARLEN),
      stnd.Version as CDISCStandardVersion length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=CDISCStandardVersion, _cstAttribute=VARLEN),
      stnd.PublishingSet as PublishingSet length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=PublishingSet, _cstAttribute=VARLEN)
    from work._source_documents0_&_cstRandom sd0
       inner join &_cstDefineDataLib..standards stnd
     on (stnd.commentoid = sd0.parentkey)
     )
     
     order by table, column, whereclause
     ;
  quit;


  %let _cstRecs=%cstutilnobs(_cstDatasetName=work._source_documents_&_cstRandom);
  %if %eval(&_cstRecs) gt 0 %then %do;

    data &_cstTrgDocumentDS(drop=DocSubType1 DocSubType2 DocSubType3 DocSubType4 DocSubType5);
      set &_cstTrgDocumentDS 
          work._source_suppdocuments_&_cstRandom
          work._source_documents_&_cstRandom;
      DocSubType="";
      if DocType="COMMENT" then do;
        %* We only need DocSubType for comments;
        if DocSubType1 ne "" then DocSubType=DocSubType1;    
        if DocSubType2 ne "" then DocSubType=DocSubType2;    
        if DocSubType3 ne "" then DocSubType=DocSubType3;    
        if DocSubType4 ne "" then DocSubType=DocSubType4;    
        if DocSubType5 ne "" then DocSubType=DocSubType5;    
      end;
    run;
    
  %end;

  %if &_cstAnalysisResultsMetadata %then %do;

    %*********************************************************************;
    %*  Create source_documents metadata for source_analysisresults      *;
    %*********************************************************************;
    proc sql;
    create table work._source_documents_displays_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
    
      case
        when (parent="AnalysisResultDisplays") then "DISPLAY"
        when (parent="AnalysisDocumentation") then "RESULTDOC"
        when (parent="AnalysisProgrammingCode") then "RESULTCODE"
        else ""
      end as doctype,
    
      mdvlf.href,
      mdvlft.title,
      pdfpr.title as pdfpagereftitle length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagereftitle, _cstAttribute=VARLEN),
      pdfpr.type as pdfpagereftype,
      case
        when (not missing(pdfpr.pagerefs))
          then pdfpr.pagerefs
        when ((not missing(pdfpr.firstpage)) and (not missing (pdfpr.lastpage)))
          then catx('-', pdfpr.firstpage, pdfpr.lastpage)
    
        when (not missing(pdfpr.firstpage))
          then put(pdfpr.firstpage, best.)
        when (not missing(pdfpr.lastpage))
          then put(pdfpr.lastpage, best.)
        else ""
      end as pdfpagerefs length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagerefs, _cstAttribute=VARLEN),
    
    
      ad.OID as DisplayIdentifier,
    
      ad.FK_MetaDataVersion as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

     from &_cstDefineDataLib..DocumentRefs dr
       inner join &_cstDefineDataLib..AnalysisResultDisplays ad
     on (dr.parentKey = ad.OID and dr.parent="AnalysisResultDisplays")
       left join &_cstDefineDataLib..pdfpagerefs pdfpr
     on (pdfpr.fk_documentrefs = dr.oid)
         left join &_cstDefineDataLib..mdvleaf mdvlf
       on mdvlf.id = dr.leafID
         left join &_cstDefineDataLib..mdvleaftitles mdvlft
       on mdvlft.fk_mdvleaf = mdvlf.id
     ;
    quit;


    proc sql;
    create table work._source_documents_results_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
    
      case
        when (parent="AnalysisResultDisplays") then "DISPLAY"
        when (parent="AnalysisDocumentation") then "RESULTDOC"
        when (parent="AnalysisProgrammingCode") then "RESULTCODE"
        else ""
      end as doctype,
    
      mdvlf.href,
      mdvlft.title,
      pdfpr.title as pdfpagereftitle length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagereftitle, _cstAttribute=VARLEN),
      pdfpr.type as pdfpagereftype,
      case
        when (not missing(pdfpr.pagerefs))
          then pdfpr.pagerefs
        when ((not missing(pdfpr.firstpage)) and (not missing (pdfpr.lastpage)))
          then catx('-', pdfpr.firstpage, pdfpr.lastpage)
        when (not missing(pdfpr.firstpage))
          then put(pdfpr.firstpage, best.)
        when (not missing(pdfpr.lastpage))
          then put(pdfpr.lastpage, best.)
        else ""
      end as pdfpagerefs length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagerefs, _cstAttribute=VARLEN),
    
      ad.OID as DisplayIdentifier,
      adr.OID as ResultIdentifier,
    
      ad.FK_MetaDataVersion as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion
    
     from &_cstDefineDataLib..DocumentRefs dr
    
        inner join 
        ((select OID, FK_AnalysisResults from
         &_cstDefineDataLib..AnalysisDocumentation adoc)
         union
         (select OID, FK_AnalysisResults from
         &_cstDefineDataLib..AnalysisProgrammingCode apc)) adoc_apc
           on adoc_apc.OID = dr.ParentKey and (dr.parent="AnalysisDocumentation" or dr.parent="AnalysisProgrammingCode")
    
       inner join &_cstDefineDataLib..AnalysisResults adr
     on adoc_apc.FK_AnalysisResults = adr.OID
       inner join &_cstDefineDataLib..AnalysisResultDisplays ad
     on (adr.FK_AnalysisResultDisplays = ad.OID)
    
    
       left join &_cstDefineDataLib..pdfpagerefs pdfpr
     on pdfpr.fk_documentrefs = dr.oid
       left join &_cstDefineDataLib..mdvleaf mdvlf
     on mdvlf.id = dr.leafID
       left join &_cstDefineDataLib..mdvleaftitles mdvlft
     on mdvlft.fk_mdvleaf = mdvlf.id
    
    ;
    quit;   

    proc sql;
    %* Get documents attached to analysis datasets comment;
    create table work._source_documents_ard_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
    
      "COMMENT" as DocType,
      "ARDS" as DocSubType,
    
      mdvlf.href,
      mdvlft.title,
      pdfpr.title as pdfpagereftitle length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagereftitle, _cstAttribute=VARLEN),
      pdfpr.type as pdfpagereftype,
      case
        when (not missing(pdfpr.pagerefs))
          then pdfpr.pagerefs
        when ((not missing(pdfpr.firstpage)) and (not missing (pdfpr.lastpage)))
          then catx('-', pdfpr.firstpage, pdfpr.lastpage)
        when (not missing(pdfpr.firstpage))
          then put(pdfpr.firstpage, best.)
        when (not missing(pdfpr.lastpage))
          then put(pdfpr.lastpage, best.)
        else ""
      end as pdfpagerefs length=%cstutilgetattribute(_cstDataSetName=&_cstTrgDocumentDS, _cstVarName=pdfpagerefs, _cstAttribute=VARLEN),
    
      ad.OID as DisplayIdentifier,
      adr.OID as ResultIdentifier,
    
      ad.FK_MetaDataVersion as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion

     from &_cstDefineDataLib..DocumentRefs dr
    
      inner join 
        ((select OID, CommentOID, FK_AnalysisResults from
         &_cstDefineDataLib..AnalysisDatasets)
         ) anda
     on anda.CommentOID = dr.ParentKey and dr.parent="CommentDefs"
    
       inner join &_cstDefineDataLib..AnalysisResults adr
     on anda.FK_AnalysisResults = adr.OID
       inner join &_cstDefineDataLib..AnalysisResultDisplays ad
     on (adr.FK_AnalysisResultDisplays = ad.OID)
    
    
       left join &_cstDefineDataLib..pdfpagerefs pdfpr
     on pdfpr.fk_documentrefs = dr.oid
       left join &_cstDefineDataLib..mdvleaf mdvlf
     on mdvlf.id = dr.leafID
       left join &_cstDefineDataLib..mdvleaftitles mdvlft
     on mdvlft.fk_mdvleaf = mdvlf.id
    
    ;
    quit;   


    data &_cstTrgDocumentDS;
      set &_cstTrgDocumentDS 
          %if %cstutilnobs(_cstDatasetName=work._source_documents_displays_&_cstRandom) gt 0 %then work._source_documents_displays_&_cstRandom;
          %if %cstutilnobs(_cstDatasetName=work._source_documents_results_&_cstRandom) gt 0 %then work._source_documents_results_&_cstRandom;
          %if %cstutilnobs(_cstDatasetName=work._source_documents_ard_&_cstRandom) gt 0 %then work._source_documents_ard_&_cstRandom;;
      format _character_ _numeric_;
      informat _character_ _numeric_;
    run;  

    %if &_cstDebug=0 %then %do;
      %cstutil_deleteDataSet(_cstDataSetName=work._source_documents_displays_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._source_documents_results_&_cstRandom);
      %cstutil_deleteDataSet(_cstDataSetName=work._source_documents_ard_&_cstRandom);
    %end;
    
  %end; %* _cstAnalysisResultsMetadata=1 ;

  
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

  %if &_cstDebug=0 %then %do;
    %cstutil_deleteDataSet(_cstDataSetName= work._source_suppdocuments_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work._source_documents0_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work._source_documents_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work._items_tabcolwhere_mt_cm_&_cstRandom);
  %end; 


  %*********************************************************************;
  %*  Create source_analysisresults metadata                           *;
  %*********************************************************************;

  
  %if &_cstAnalysisResultsMetadata %then %do;
     
    %cst_createdsfromtemplate(
      _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=2.1,
      _cstType=studymetadata,_cstSubType=analysisresult,_cstOutputDS=&_cstTrgAnalysisResultDS
      );
    %let _cstDSLabel=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS,_cstAttribute=LABEL);


    %*********************************************************************;
    %*  Create source_displays                                           *;
    %*********************************************************************;
    proc sql;
      create table work.source_displays_&_cstRandom
      as select
        upcase("&_cstDefineDataLib") as sasref,
        ard.OID as DisplayOID as DisplayIdentifier,
        ard.Name as DisplayName,
        ttard.TranslatedText as DisplayDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=DisplayDescription, _cstAttribute=VARLEN),
    
        mdv.OID as StudyVersion,
        "&_cstTrgStandard" as Standard,
        "&_cstTrgStandardVersion" as StandardVersion

        from &_cstDefineDataLib..definedocument odm
          inner join &_cstDefineDataLib..study std
        on std.fk_definedocument = odm.fileoid
          inner join &_cstDefineDataLib..metadataversion mdv
        on mdv.fk_study = std.oid
          inner join &_cstDefineDataLib..AnalysisResultDisplays ard
        on ard.fk_metadataversion = mdv.oid
          left join &_cstDefineDataLib..translatedtext(where=(parent='AnalysisResultDisplays')) ttard
        on ttard.parentkey = ard.oid
      ;
    quit;

    %*********************************************************************;
    %*  Create source_displayresults                                     *;
    %*********************************************************************;
    
    proc sql;
    create table work.source_displayresults_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
      ar.OID as ResultIdentifier,
      idp.Name as ParameterColumn length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=ParameterColumn, _cstAttribute=VARLEN),
      ar.AnalysisReason as AnalysisReason,
      ar.AnalysisPurpose as AnalysisPurpose,
      ttar.TranslatedText as ResultDescription length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=ResultDescription, _cstAttribute=VARLEN),
      ttcd.TranslatedText as TableJoinComment length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=TableJoinComment, _cstAttribute=VARLEN),
      ttadoc.TranslatedText as ResultDocumentation length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=ResultDocumentation, _cstAttribute=VARLEN),
      apc.context as CodeContext length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=CodeContext, _cstAttribute=VARLEN),
      apc.Code,
      ar.FK_AnalysisResultDisplays,
    
      ard.FK_MetaDataVersion as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion
      
     from &_cstDefineDataLib..AnalysisResultDisplays ard
       inner join &_cstDefineDataLib..AnalysisResults ar
     on ard.oid = ar.FK_AnalysisResultDisplays
       left join &_cstDefineDataLib..ItemDefs idp
     on ar.ParameterOID = idp.OID
       left join &_cstDefineDataLib..translatedtext(where=(parent='AnalysisResults')) ttar
     on ttar.parentkey = ar.oid
       left join &_cstDefineDataLib..AnalysisDatasets ads
     on ads.FK_AnalysisResults = ar.oid
       left join &_cstDefineDataLib..translatedtext(where=(parent='CommentDefs')) ttcd
     on ttcd.parentkey = ads.CommentOID
    
       left join &_cstDefineDataLib..AnalysisDocumentation adoc
     on adoc.FK_AnalysisResults = ar.oid
       left join &_cstDefineDataLib..translatedtext(where=(parent='AnalysisDocumentation')) ttadoc
     on ttadoc.parentkey = adoc.oid
    
       left join &_cstDefineDataLib..AnalysisProgrammingCode apc
     on apc.FK_AnalysisResults = ar.oid
     ;
    quit;

    %*********************************************************************;
    %*  Create source_displayresultdatasets                              *;
    %*********************************************************************;
    
    proc sql;
    create table work.source_displayresultds_&_cstRandom
    as select
      upcase("&_cstDefineDataLib") as sasref,
      igd.Name as TABLE length=%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=Table, _cstAttribute=VARLEN),
      id.Name as COLUMN,
      wc.whereclause,
      ads.FK_AnalysisResults,
    
      ard.FK_MetaDataVersion as StudyVersion,
      "&_cstTrgStandard" as Standard,
      "&_cstTrgStandardVersion" as StandardVersion
    
     from &_cstDefineDataLib..AnalysisResultDisplays ard
       inner join &_cstDefineDataLib..AnalysisResults ar
     on ard.oid = ar.FK_AnalysisResultDisplays
       left join &_cstDefineDataLib..AnalysisDatasets ads
     on ads.FK_AnalysisResults = ar.oid
    
       left join &_cstDefineDataLib..AnalysisDataset ad
     on ad.FK_AnalysisDatasets  = ads.OID
       left join &_cstDefineDataLib..ItemGroupDefs igd
     on ad.ItemGroupOID  = igd.OID
    
       left join &_cstDefineDataLib..AnalysisWhereClauseRefs awcr
     on awcr.FK_AnalysisDataset  = ad.OID
       left join &_cstDefineDataLib..WhereClauseDefs wcd
     on wcd.OID = awcr.WhereClauseOID
       left join &_cstDefineDataLib..translatedtext(where=(parent='CommentDefs')) ttcd2
     on ttcd2.parentkey = awcr.WhereClauseOID
    
       left join work._whereclauses_&_cstRandom wc
     on wc.whereclauseoid = awcr.WhereClauseOID
    
       left join &_cstDefineDataLib..AnalysisVariables av
     on av.FK_AnalysisDataset = ad.OID
       left join &_cstDefineDataLib..ItemDefs id
     on av.ItemOID = id.OID
     ;
    quit;

    %*********************************************************************;
    %*  Create source_displayresultdatasets                              *;
    %*********************************************************************;
    
    proc sql;
    create table source_results_&_cstRandom(drop=FK_AnalysisResultDisplays FK_AnalysisResults)
    as select 
      ad.*,
      adr.*,
      adrd.*
     from work.source_displays_&_cstRandom ad
       inner join work.source_displayresults_&_cstRandom(drop=sasref StudyVersion Standard StandardVersion) adr
     on adr.FK_AnalysisResultDisplays = ad.DisplayIdentifier
       inner join work.source_displayresultds_&_cstRandom(drop=sasref StudyVersion Standard StandardVersion) adrd
     on adrd.FK_AnalysisResults = adr.ResultIdentifier
     order by DisplayIdentifier, ResultIdentifier, table, column
     ;
    quit;

    %let _cstRecs=%cstutilnobs(_cstDatasetName=work.source_results_&_cstRandom);
    
    
    %if %eval(&_cstRecs) gt 0 %then %do;
      
      data &_cstTrgAnalysisResultDS(drop=column);
        retain sasref DisplayIdentifier DisplayName DisplayDescription 
               ResultIdentifier ParameterColumn AnalysisReason AnalysisPurpose ResultDescription TableJoinComment ResultDocumentation 
               CodeContext Code Table Column AnalysisVariables WhereClause StudyVersion Standard StandardVersion;
        length AnalysisVariables $%cstutilgetattribute(_cstDataSetName=&_cstTrgAnalysisResultDS, _cstVarName=AnalysisVariables, _cstAttribute=VARLEN);
        format _character_ _numeric_;
        set &_cstTrgAnalysisResultDS source_results_&_cstRandom;
        by sasref DisplayIdentifier ResultIdentifier Table;  
        if first.table then call missing(AnalysisVariables);
        AnalysisVariables = catx(' ', AnalysisVariables, column);
        if last.table;
      run;  

      proc sort data=&_cstTrgAnalysisResultDS
        %if %length(&_cstDSLabel)>0 %then (label="%nrbquote(&_cstDSLabel)");;
        by sasref DisplayIdentifier ResultIdentifier Table AnalysisVariables;
      run;
    %end;
  
    
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
  
    %cstutil_deleteDataSet(_cstDataSetName=work.source_displays_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.source_displayresults_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.source_displayresultds_&_cstRandom);
    %cstutil_deleteDataSet(_cstDataSetName=work.source_results_&_cstRandom);

  %end; %* _cstAnalysisResultsMetadata=1 ;

  %*********************************************************************;
  %*********************************************************************;

  %cstutil_deleteDataSet(_cstDataSetName=work._whereclauses_&_cstRandom);

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

%mend define_createsrcmetafromdefine;
