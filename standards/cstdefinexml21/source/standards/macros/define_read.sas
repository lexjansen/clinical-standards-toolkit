%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_read                                                                    *;
%*                                                                                *;
%* Reads a Define-XML V2.1 file into the SAS representation of Define-XML.        *;
%*                                                                                *;
%* This macro uses the SAS representation of a CDISC Define-XML V2.1 file as      *;
%* source and converts it into SAS data sets. The inputs and outputs are          *;
%* specified in a SASReferences file.                                             *;
%*                                                                                *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cst_rc Task error status                                              *;
%* @macvar _cst_rcmsg Message associated with _cst_rc                             *;
%* @macvar _cstSASRefs Run-time SASReferences data set derived in process setup   *;
%* @macvar _cstResultFlag Results: Problem was detected                           *;
%* @macvar _cstResultsDS Results data set                                         *;
%* @macvar _cstResultSeq Results: Unique invocation of check                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%* @macvar _cstVersion Version of the SAS Clinical Standards Toolkit              *;
%* @macvar _cstStandard Name of a standard registered to the SAS Clinical         *;
%*             Standards Toolkit                                                  *;
%* @macvar _cstStandardVersion Version of the standard referenced in _cstStandard *;
%*                                                                                *;
%* @param _cstCallingPgm - optional - The name of the driver module calling       *;
%*            this macro.                                                         *;
%*                                                                                *;
%* @history 2022-02-07 Removed the use of picklists                               *;
%*          2023-03-12 Remove standard and standardversion from study metadata    *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_read(
    _cstCallingPgm=Unspecified
    ) / des='CST: Read CDISC Define-XML V2.1 file';

   %local
    _cstAbort
    _cstAction
    _cstAvailableTransformsPath
    _cstCubeXMLMapName
    _cstCubeXMLMapPath
    _cstCubeXMLName
    _cstCubeXMLPath
    _cstExternalXMLPath
    _cstGlobalMDLib
    _cstGlobalMDPath
    _cstGlobalTransformsXML
    _cstGlobalXSDPath
    _cstGlobalXSLPath
    _cstLogXMLName
    _cstLogXMLPath
    _cstLogXMLScope
    _cstMDPath
    _cstMsgDir
    _cstMsgMem
    _cstNextCode
    _cstParam1
    _cstParam2
    _cstParamsClass
    _cstRandom
    _cstRefColumnDS
    _cstRefLib
    _cstRefTableDS
    _cstrundt
    _cstrunstd
    _cstrunstdver
    _cstSaveSASRefs
    _cstSASRefsasref
    _cstSASRefmember
    _cstSavedOrigResultsName
    _cstSrcDataLibrary
    _cstSrcMetaLibrary
    _cstSrcStudyDS
    _cstSrcTableDS
    _cstSrcColumnDS
    _cstSubTypeXML
    _cstTempDS1
    _cstTempDS2
    _cstTempDS3
    _cstTempFilename1
    _cstTempFilename2
    _cstTempFilename3
    _cstTempFilename4
    _cstTempLib
    _cstTempResultsDS
    _cstThisMacro
    _cstThisMacroRC
    _cstThisMacroRCMsg
    _cstTransformsClass
    _cstTypeExtXML
    _cstTypeRefXML
    _cstTypeSourceData
    _cstWorkPath
    _cstXMLEngine
    _cstXMLLib
    _cstXMLMap
    _cstXMLMapFile
    _cstXsdReposPath
    _cstXslReposPath
    ;

  %let _cstrundt=%sysfunc(datetime(),is8601dt.);
  %let _cstrunstd=&_cstStandard;
  %let _cstrunstdver=&_cstStandardVersion;

  %let _cstAbort=0;
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcData=&sysmacroname;
  %let _cstSaveSASRefs=&_cstSASRefs;
  %let _cstThisMacroRC=0;
  %let _cstThisMacro=&sysmacroname;

  %* If we have a prior failure in the job stream (typically validating the SASReferences)  *;
  %*  bail out here and report what we are doing.                                           *;
  %if (&_cst_rc) %then %do;
    %let _cstAbort=1;
    %goto EXIT_ABORT;
  %end;


  %* retrieve static variables;
  %cst_getStatic(_cstName=CST_GLOBALMD_PATH,_cstVar=_cstGlobalMDPath);
  %cst_getStatic(_cstName=CST_GLOBALXSD_PATH,_cstVar=_cstGlobalXsdPath);
  %cst_getStatic(_cstName=CST_GLOBALXSL_PATH,_cstVar=_cstGlobalXSLPath);
  %cst_getStatic(_cstName=CST_GLOBALMD_TRANSFORMSXML,_cstVar=_cstGlobalTransformsXML);

  %cst_getStatic(_cstName=CST_SASREF_TYPE_SOURCEDATA,_cstVar=_cstTypeSourceData);

  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_REFXML,_cstVar=_cstTypeRefXML);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_EXTXML,_cstVar=_cstTypeExtXML);
  %define_getStatic(_cstName=DEFINE_SASREF_SUBTYPE_XML,_cstVar=_cstSubtypeXML);

  %define_getStatic(_cstName=DEFINE_JAVA_PARAMSCLASS,_cstVar=_cstParamsClass);
  %define_getStatic(_cstName=DEFINE_JAVA_IMPORTCLASS,_cstVar=_cstTransformsClass);

  %* Generate the random names used in the macro;
  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  %let _cstGlobalMDLib=_gmd&_cstRandom;
  %let _cstCubeXMLName=_cub&_cstRandom;
  %let _cstCubeXMLMapName=_map&_cstRandom;
  %let _cstTempFilename2=_t2&_cstRandom;
  %let _cstTempFilename3=_t3&_cstRandom;
  %let _cstTempFilename4=_t4t&_cstRandom;
  %let _cstLogXMLName=_log&_cstRandom;
  %let _cstTempRefMdTable=_tmd&_cstRandom;
  %let _cstNextCode=_cod&_cstRandom;

  %let _cstXMLEngine=xmlv2;

  %* Determine XML Log Scope;
  %if &_cstDebug %then %let _cstLogXMLScope=_ALL_;
                 %else %let _cstLogXMLScope=USER;

  %* Create a temporary messages data set if required;
  %local _cstNeedToDeleteMsgs;
  %cstutil_createTempMessages(_cstCreationFlag=_cstNeedToDeleteMsgs);

  %let _cstSeqCnt=0;

  * Assign the libname to the global metadata library;
  libname &_cstGlobalMDLib "%unquote(&_cstGlobalMDPath)" access=readonly;

  * assign a filename to the catalog that will hold the next code to run;
  data _null_;
    call symputx('_cstWorkPath',pathname('work'),'L');
  run;
  filename &_cstNextCode  "&_cstWorkPath/&_cstNextCode..sas";

  * The sasrefs data set must exist;
  %if (^(%sysfunc(exist(&_cstsasrefs)))) %then %do;
     %let _cstParam1=SASReferences;
     %let _cstParam2=&_cstsasrefs;
     %goto MISSING_DATASET;
  %end;

  %* Write information to the results data set about this run. *;
  %cstutilwriteresultsintro(_cstProcessType=FILEIO, _cstPgm=&_cstCallingPgm);

  %* set up static-final style variables;
  %let _cstAction=IMPORT;

  %* Get the fileref of the src data and the XML file and then the full path to it;
  %cstUtil_getSASReference(
    _cstStandard=%upcase(&_cstrunstd)
    ,_cstStandardVersion=&_cstrunstdver
    ,_cstSASRefType=&_cstTypeSourceData
    ,_cstSASRefsasref=_cstSrcDataLibrary
    );
  %if (&_cst_rc) %then %do;
     %let _cstParam1=&_cstTypeSourceData;
     %goto MISSING_SASREF;
  %end;
  %else %if (%sysfunc(libref(&_cstSrcDataLibrary))) %then %do;
     %let _cstParam1=&_cstSrcDataLibrary;
     %let _cstParam2=&_cstTypeSourceData;
     %goto MISSING_ASSIGNMENT;
  %end;
  %else %if (&_cstDebug=1) %then %do;
    %put Retrieved sourceData library from sasrefs file: &_cstSrcDataLibrary;
  %end;

  %* Get the fileref of the XML file;
  %cstUtil_getSASReference(
    _cstStandard=%upcase(&_cstrunstd)
    ,_cstStandardVersion=&_cstrunstdver
    ,_cstSASRefType=&_cstTypeExtXml
    ,_cstSASRefSubType=&_cstSubtypeXML
    ,_cstSASRefsasref=_cstTempFilename1
    );
  %if (&_cst_rc) %then %do;
     %let _cstParam1=&_cstTypeExtXml/&_cstSubtypeXML;
     %goto MISSING_SASREF;
  %end;
  %else %if (&_cstDebug=1) %then %do;
    %put XML file to read from sasrefs file: &_cstTempFilename1;
  %end;

  * Stop processing if the XML file does not exist ;
  %if (%length(&_cstTempFilename1)>0) %then %do;
    %if ((%sysfunc(fexist(&_cstTempFilename1)))=0) %then %do;
       %let _cstParam1=%sysfunc(pathname(&_cstTempFilename1));
       %goto MISSING_FILE;
    %end;
  %end;

  * Assign temporary filenames to the repository paths as the SAS !Var needs to be expanded;
  filename &_cstTempFilename2 "%unquote(&_cstGlobalXsdPath)";
  filename &_cstTempFilename3 "%unquote(&_cstGlobalXslPath)";
  filename &_cstTempFilename4 "%unquote(&_cstGlobalMDPath)";

  * Save the path to the XML file, xsd/xsl repos and work library for use later;
  data _null_;
    * call symputx('_cstWorkPath',pathname('work'),'L');
    call symputx('_cstExternalXMLPath',pathname("&_cstTempFilename1"),'L');
    call symputx('_cstXsdReposPath',pathname("&_cstTempFilename2"),'L');
    call symputx('_cstXslReposPath',pathname("&_cstTempFilename3"),'L');
    call symputx('_cstMDPath',pathname("&_cstTempFilename4"),'L');
  run;

* De-Allocate the temporary filename;
  filename &_cstTempFilename2;
  filename &_cstTempFilename3;
  filename &_cstTempFilename4;


  %* the location where the temporary cube XML will be stored;
  %let _cstCubeXMLPath=&_cstWorkPath./&_cstCubeXMLName._read.xml;
  %let _cstLogXMLPath=&_cstWorkPath./&_cstLogXMLName._read.xml;

  %let _cstAvailableTransformsPath=&_cstMDPath./&_cstGlobalTransformsXML;

  %* Print out debugging information;
  %if (&_cstDebug=1) %then %do;
    %put Note: Calling java with parameters:;
    %put       _cstParamsClass=&_cstParamsClass;
    %put       _cstTransformsClass=&_cstTransformsClass;
    %put       _cstAction=&_cstAction;
    %put       _cstStandard=&_cstrunstd;
    %put       _cstStandardVersion=&_cstrunstdver ;
    %put       _cstXslReposPath=&_cstXslReposPath;
    %put       _cstXsdReposPath=&_cstXsdReposPath;
    %put       _cstCubeXMLPath=&_cstCubeXMLPath;
    %put       _cstExternalXMLPath=&_cstExternalXMLPath;
    %put       _cstAvailableTransformsPath=&_cstAvailableTransformsPath;
    %put       _cstLogXMLPath=&_cstLogXMLPath;
  %end;

  %********************;
  %*  Call javaobj    *;
  %********************;

  %* In the following, the logging level is set to info ;
  data _null_;
  
    dcl javaobj prefs("&_cstParamsClass");
    prefs.callvoidmethod('setImportOrExport',"&_cstAction");
    prefs.callvoidmethod('setStandardName',"&_cstrunstd");
    prefs.callvoidmethod('setStandardVersion',"&_cstrunstdver");

    prefs.callvoidmethod('setXslBasePath',tranwrd("&_cstXslReposPath",'\','/'));
    prefs.callvoidmethod('setSchemaBasePath',tranwrd("&_cstXsdReposPath",'\','/'));

    prefs.callvoidmethod('setSasXMLPath',tranwrd("&_cstCubeXMLPath",'\','/'));
    prefs.callvoidmethod('setStandardXMLPath',tranwrd("&_cstExternalXMLPath",'\','/'));

    prefs.callvoidmethod('setAvailableTransformsFilePath',tranwrd("&_cstAvailableTransformsPath",'\','/'));
    prefs.callvoidmethod('setLogFilePath',tranwrd("&_cstLogXMLPath",'\','/'));

    * set logging to INFO;
    prefs.callvoidmethod('setLogLevelString','INFO');

    dcl javaobj transformer("&_cstTransformsClass", prefs);
    transformer.exceptiondescribe(1);
    transformer.callvoidmethod('exec');

    * check the return values here and get results path;
    transformer.delete();
    prefs.delete();
  run;

  * check to see if there are any Java issues;
  %cstutilcheckjava;
  %if (&_cstResultFlag) %then %do;
    %goto JAVA_ERRORS;
  %end;

  %* Process the XML LOG File;
  %cstutilprocessxmllog(
    _cstReturn=_cstThisMacroRC,
    _cstReturnMsg=_cstThisMacroRCMsg,
    _cstLogXMLPath=&_cstLogXMLPath,
    _cstScope=&_cstLogXMLScope
   ); 

  %* Cleanup XML Log File;
  %if &_cstDebug=0 %then %do;
    data _null_;
      rc=filename("&_cstLogXMLName","&_cstLogXMLPath");
      rc=fdelete("&_cstLogXMLName");
      rc=filename("&_cstLogXMLName");
    run;
  %end;
  

  %********************************************************;
  %* Check for existence of pre-defined XML Map file      *;
  %********************************************************;
  %let _cstSASRefsasref=;
  %let _cstSASRefmember=;
  %let _cstXMLMapFile=;
  %cstutil_getsasreference(_cstSASRefType=referencexml,_cstSASRefSubtype=map,
                           _cstSASRefsasref=_cstXMLLib,_cstSASRefmember=_cstXMLMap,
                           _cstAllowZeroObs=1);

  %if (&_cst_rc) %then %goto CLEANUP;

  %if &_cstXMLLib ne %then
  %do;
    %let _cstXMLMapFile=%sysfunc(pathname(&_cstXMLLib));
  %end;
  %else
  %do;
    %************************************************************;
    %*  Set empty file name to a random value since fileexist() *;
    %*  returns value of 1 if value for file is missing.        *;
    %************************************************************;
    %cstutil_getRandomNumber(_cstVarname=_cstRandom);
    %let _cstXMLMapFile=&_cstRandom;
  %end;

  %if %sysfunc(fileexist("&_cstXMLMapFile"))%then
  %do;
    %**********************************************;
    %* MAP File EXISTS                            *;
    %*  Setup filename statement for XMLMap file  *;
    %**********************************************;
    %cstutil_getRandomNumber(_cstVarname=_cstTempFileName1);
    filename _cst&_cstTempFileName1 "&_cstXMLMapFile";
    %let _cstThisMacroRC=0;
    %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
    %cstutil_writeresult(
           _cstResultId=DEF0013
          ,_cstResultParm1=read from
          ,_cstResultParm2=&_cstXMLMapFile
          ,_cstResultSeqParm=1
          ,_cstSeqNoParm=&_cstSeqCnt
          ,_cstSrcDataParm=&_cstThisMacro
          ,_cstResultFlagParm=&_cstThisMacroRC
          );
  %end;
  %else
  %do;
    %if "&_cstXMLMapFile"="&_cstRandom" %then
    %do;
      %******************************************************************;
      %*  The location where the temporary cube XML Map will be stored  *;
      %******************************************************************;
      %let _cstCubeXMLMapPath=&_cstWorkPath./&_cstCubeXMLMapName..map;
      %**********************************************;
      %* MAP File is not specified, create in WORK  *;
      %*  Setup filename statement for XMLMap file  *;
      %**********************************************;
      %cstutil_getRandomNumber(_cstVarname=_cstTempFileName1);
      filename _cst&_cstTempFileName1 "&_cstCubeXMLMapPath";
      %let _cstThisMacroRC=0;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
             _cstResultId=DEF0013
            ,_cstResultParm1=written to
            ,_cstResultParm2=&_cstCubeXMLMapPath
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=&_cstSeqCnt
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=&_cstThisMacroRC
            );
    %end;
    %else
    %do;
      %************************************************************************;
      %* MAP File is specified in SASREFERENCES, create it in specified area  *;
      %*  Setup filename statement for XMLMap file                            *;
      %************************************************************************;
      %cstutil_getRandomNumber(_cstVarname=_cstTempFileName1);
      filename _cst&_cstTempFileName1 "&_cstXMLMapFile";
      %let _cstThisMacroRC=0;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
             _cstResultId=DEF0013
            ,_cstResultParm1=automatically generated and written to
            ,_cstResultParm2=&_cstXMLMapFile
            ,_cstResultSeqParm=1
            ,_cstSeqNoParm=&_cstSeqCnt
            ,_cstSrcDataParm=&_cstThisMacro
            ,_cstResultFlagParm=&_cstThisMacroRC
            );
    %end;

    %****************************************************************************************;
    %* Generate dynamic XML map file for DEFINE using Reference Columns and Tables Metadata *;
    %****************************************************************************************;

    %*************************************************************************;
    %* Get reference metadata librefs and data set names from sasreferences  *;
    %*************************************************************************;
    %cstutil_getsasreference(_cstSASRefType=referencemetadata,_cstSASRefSubtype=table,_cstSASRefsasref=_cstRefLib,
            _cstSASRefmember=_cstRefTableDS);
    %cstutil_getsasreference(_cstSASRefType=referencemetadata,_cstSASRefSubtype=column,_cstSASRefsasref=_cstRefLib,
            _cstSASRefmember=_cstRefColumnDS);

    %**********************************;
    %*  Get reference_table metadata  *;
    %**********************************;
    %cstutil_getRandomNumber(_cstVarname=_cstTempDS1);
    proc sort data=&_cstRefLib..&_cstRefTableDS out=work._cst&_cstTempDS1 (rename=(label=tlabel) keep=table label  xmlelementname);
      by table;
    run;

    %***********************************;
    %*  Get reference_column metadata  *;
    %***********************************;
    %cstutil_getRandomNumber(_cstVarname=_cstTempDS2);
    proc sort data=&_cstRefLib..&_cstRefColumnDS out=work._cst&_cstTempDS2;
      by table;
    run;

    %**********************************************************************;
    %*  Combine the metadata from reference_columns and reference_tables  *;
    %*  so that table label is available to the XMLMap                    *;
    %**********************************************************************;
    %cstutil_getRandomNumber(_cstVarname=_cstTempDS3);
    data work._cst&_cstTempDS3;
      merge work._cst&_cstTempDS2 work._cst&_cstTempDS1;
      by table;
    run;

    %***************************************************************;
    %*  Build the XMLMap file dynamically from reference metadata  *;
    %***************************************************************;
    data _null_;
      file _cst&_cstTempFileName1;
      set work._cst&_cstTempDS3 END=eof;
      by table;

      length codeline $400 numval dtype ddtype $10;

      if _n_ = 1 then
      do;
        put '<?xml version="1.0" encoding="windows-1252"?>';
        put '<SXLEMAP version="1.2">';
        put ;
      end;

      if upcase(type)="C" then
      do;
        dtype="character";
        ddtype="string";
      end;
      else
      do;
        dtype="numeric";
        ddtype="integer";
      end;

      numval=input(length, best12.);

      if first.table then
      do;
         codeline='<TABLE name="'||strip(xmlelementname)||'">';
         put codeline;
         codeline='<TABLE-PATH syntax="XPath">/LIBRARY/'||strip(xmlelementname)||'</TABLE-PATH>';
         put @4 codeline;
         codeline='<TABLE-DESCRIPTION>'||strip(tlabel)||'</TABLE-DESCRIPTION>';
         put @4 codeline;
         put;
      end;

      codeline='<COLUMN name="'||strip(xmlattributename)||'">';
      put @4 codeline;
      codeline='<PATH syntax="Xpath">/LIBRARY/'||strip(xmlelementname)||'/'||strip(xmlattributename)||'</PATH>';
      put @6 codeline;
      codeline='<TYPE>'||strip(dtype)||'</TYPE>';
      put @6 codeline;
      codeline='<DATATYPE>'||strip(dtype)||'</DATATYPE>';
      put @6 codeline;
      codeline='<DESCRIPTION>'||strip(label)||'</DESCRIPTION>';
      put @6 codeline;
      codeline='<LENGTH>'||strip(numval)||'</LENGTH>';
      put @6 codeline;
      codeline='</COLUMN>';
      put @4 codeline;

      if last.table then
      do;
        put ;
        put "</TABLE>";
        put ;
        put ;
      end;

      if eof then put "</SXLEMAP>";
    run;

    %**********************************;
    %*  Clean up temporary data sets  *;
    %**********************************;
    %cstutil_deleteDataSet(_cstDataSetName=work._cst&_cstTempDS1);
    %cstutil_deleteDataSet(_cstDataSetName=work._cst&_cstTempDS2);
    %cstutil_deleteDataSet(_cstDataSetName=work._cst&_cstTempDS3);

  %end;

  %****************************************************************************;
  %* Read the cubexml created by the javaobj call via the xml libname engine  *;
  %****************************************************************************;

  filename XMLIN "&_cstCubeXMLPath";
  libname XMLIN &_cstXMLEngine XMLMAP=_cst&_cstTempFileName1 access=READONLY;

  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  %let _cstNextCode=_cod&_cstRandom;

  filename &_cstNextCode CATALOG "work.&_cstNextCode..SAScode.source";

  proc sql;
    create table work._cstsrctables as
    select libname as sasref length=8,
           memname as table length=32,
           "&_cstrunstd" as standard length=20,
           "&_cstrunstdver" as standardversion length=20,
           memname as xmlelementname length=200
      from dictionary.tables
      where libname='XMLIN';

    create table work._cstsrccolumns as
    select libname as sasref length=8,
           memname as table length=32,
           name as column length=32,
           label length=200,
           varnum as order,
           upcase(substr(type,1,1)) as type length=1,
           length,
           format as displayformat length=32,
           "&_cstrunstd" as standard length=20,
           "&_cstrunstdver" as standardversion length=20
      from dictionary.columns
      where libname='XMLIN';
  quit;

  %cstutil_getsasreference(_cstSASRefType=sourcedata,_cstSASRefsasref=_cstSrcDataLibrary);

  data _null_;
    file &_cstNextCode;
    set work._cstsrctables;

    if _n_=1 then
      put @1 "* Copy work data sets built by xml engine to the sourcedata library  *;";

    put @1 "data &_cstSrcDataLibrary.." table +(-1) "; set xmlin." table +(-1) "; run;";
  run;

  %include &_cstNextCode;

  filename _cst&_cstTempFileName1;

  * Cleanup cube file;
  %if (&_cstDebug=0) %then %do;
    data _null_;
      rc=filename("&_cstCubeXMLName","&_cstcubeXMLPath");
      rc=fdelete("&_cstCubeXMLName");
      rc=filename("&_cstCubeXMLName");
    run;
  %end;

  %**********************************************************************;
  %* Get source metadata librefs and data set names from sasreferences  *;
  %* The assumption is that if SASReferences contains records for       *;
  %*  sourcemetadata, the user wants to build sourcemetadata as an      *;
  %*  action of this macro.                                             *;
  %**********************************************************************;

  %cstutil_getsasreference(_cstSASRefType=sourcemetadata,_cstSASRefsasref=_cstSrcMetaLibrary,_cstAllowZeroObs=1,_cstConcatenate=1);
  %if %length(&_cstSrcMetaLibrary)>0 %then
  %do;

    %cstutil_getsasreference(_cstSASRefType=sourcemetadata,_cstSASRefSubtype=table,_cstSASRefsasref=_cstSrcMetaLibrary,
            _cstSASRefmember=_cstSrcTableDS);
    %if (&_cst_rc) %then %do;
       %let _cstParam1=sourcemetadata/table;
       %goto MISSING_SASREF;
    %end;

    %cstutil_getsasreference(_cstSASRefType=sourcemetadata,_cstSASRefSubtype=column,_cstSASRefsasref=_cstSrcMetaLibrary,
            _cstSASRefmember=_cstSrcColumnDS);
    %if (&_cst_rc) %then %do;
       %let _cstParam1=sourcemetadata/column;
       %goto MISSING_SASREF;
    %end;

    %cstutil_getsasreference(_cstSASRefType=referencemetadata,_cstSASRefSubtype=table,_cstSASRefsasref=_cstRefLib,
            _cstSASRefmember=_cstRefTableDS);
    %if (&_cst_rc) %then %do;
       %let _cstParam1=referencemetadata/table;
       %goto MISSING_SASREF;
    %end;

    %cstutil_getsasreference(_cstSASRefType=referencemetadata,_cstSASRefSubtype=column,_cstSASRefsasref=_cstRefLib,
            _cstSASRefmember=_cstRefColumnDS);
    %if (&_cst_rc) %then %do;
       %let _cstParam1=referencemetadata/column;
       %goto MISSING_SASREF;
    %end;


    %cstutil_getsasreference(_cstSASRefType=sourcemetadata,_cstSASRefSubtype=study,_cstSASRefsasref=_cstSrcMetaLibrary,
            _cstSASRefmember=_cstSrcStudyDS);
    %if (&_cst_rc) %then %do;
       %let _cstParam1=sourcemetadata/study;
       %goto MISSING_SASREF;
    %end;

    proc sql;
      create table &_cstSrcMetaLibrary..&_cstSrcTableDS
        like &_cstRefLib..&_cstRefTableDS;
      create table &_cstSrcMetaLibrary..&_cstSrcColumnDS
        like &_cstRefLib..&_cstRefColumnDS;
    quit;
    data &_cstSrcMetaLibrary..&_cstSrcTableDS;
      set &_cstSrcMetaLibrary..&_cstSrcTableDS work._cstsrctables;
      sasref=upcase("&_cstSrcDataLibrary");
    run;

    data &_cstSrcMetaLibrary..&_cstSrcColumnDS;
      set &_cstSrcMetaLibrary..&_cstSrcColumnDS work._cstsrccolumns;
      sasref=upcase("&_cstSrcDataLibrary");
    run;

    %********************************************************;
    %* Build a metadata record describing the source study  *;
    %********************************************************;


    %if (%sysfunc(exist(&_cstSrcDataLibrary..metadataversion))) %then
    %do;
      data work.&_cstSrcStudyDS (keep=derivationdate);
        attrib
          derivationdate format=$20.  label="Date Study Derived"
        ;
        set &_cstSrcDataLibrary..metadataversion (obs=1);

        derivationdate=put(datetime(),is8601dt.);
      run;
    %end;
    %else
    %do;
      data work.&_cstSrcStudyDS;
        attrib
          derivationdate format=$20.  label="Date Study Derived"
        ;
        retain derivationdate;
        output;
      run;
    %end;

    data &_cstSrcMetaLibrary..&_cstSrcStudyDS;
      set work.&_cstSrcStudyDS;
    run;

  %end;
  %else
  %do;
    %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
    %cstutil_writeresult(
                _cstResultID=CST0200
                ,_cstResultParm1=%str(No attempt was made to derive sourcemetadata because no type=sourcemetadata record was found in SASReferences)
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro);
  %end;

  %************************************;
  %*  Everything was OK so report it  *;
  %************************************;

  %let _cstParam1=&_cstExternalXMLPath;
  %let _cstThisMacroRC=0;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0012
                ,_cstResultParm1=&_cstParam1
                ,_cstResultSeqParm=1
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );

  %goto CLEANUP;

%MISSING_DATASET:
  %if (&_cstDebug) %then %do;
     %put In MISSING_DATASET;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0008
                ,_cstResultParm1=&_cstParam1
                ,_cstResultParm2=&_cstParam2
                ,_cstResultSeqParm=1
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %goto CLEANUP;

%MISSING_FILE:
  %if (&_cstDebug) %then %do;
     %put In MISSING_FILE;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0009
                ,_cstResultParm1=&_cstParam1
                ,_cstResultSeqParm=1
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %goto CLEANUP;

%MISSING_SASREF:
  %if (&_cstDebug) %then %do;
     %put In MISSING_SASREF;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0004
                ,_cstResultParm1=&_cstParam1
                ,_cstResultSeqParm=1
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %goto CLEANUP;

%MISSING_ASSIGNMENT:
  %if (&_cstDebug) %then %do;
     %put In MISSING_ASSIGNMENT;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0005
                ,_cstResultParm1=&_cstParam1
                ,_cstResultParm2=&_cstParam2
                ,_cstResultSeqParm=1
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %goto CLEANUP;



%JAVA_ERRORS:
  %if (&_cstDebug) %then %do;
     %put In JAVA_ERRORS;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0099
                ,_cstResultParm1=PROCESS HALTED
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %goto CLEANUP;

%CLEANUP:
  %if (&_cstDebug) %then %do;
     %put In CLEANUP;
  %end;

  %* Persist the results if specified in sasreferences  *;
  %cstutil_saveresults();

  %* reset the resultSequence/SeqCnt variables;
  %*****cstutil_internalManageResults(_cstAction=RESTORE);

  * Clear any libnames;
  libname &_cstGlobalMDLib;
  %if %sysfunc(libref(xmlin)) EQ 0 %then libname xmlin;;

  * Clean up temporary data sets if they exist;

  %if %sysfunc(cexist(work.&_cstNextCode)) %then %do;
    proc datasets nolist lib=work;
      delete &_cstNextCode / memtype=catalog;
    quit;
  %end;
  %cstutil_deleteDataSet(_cstDataSetName=work._cstsrctables);
  %cstutil_deleteDataSet(_cstDataSetName=work._cstsrccolumns);

  * Clear the temporary filename into the work catalog;
  filename &_cstNextCode;

  %* Delete the temporary messages data set if it was created here;
  %if (&_cstNeedToDeleteMsgs=1) %then
  %do;
    %local _cstMsgDir _cstMsgMem;
    %if %eval(%index(&_cstMessages,.)>0) %then
    %do;
      %let _cstMsgDir=%scan(&_cstMessages,1,.);
      %let _cstMsgMem=%scan(&_cstMessages,2,.);
    %end;
    %else
    %do;
      %let _cstMsgDir=work;
      %let _cstMsgMem=&_cstMessages;
    %end;
    %cstutil_deleteDataSet(_cstDataSetName=&_cstMsgDir..&_cstMsgMem);
  %end;

%EXIT_ABORT:

  %if (&_cstAbort) %then %do;
    %let _cstThisMacroRC=1;
    %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
    %cstutil_writeresult(
                _cstResultId=CST0190
                ,_cstResultParm1=a predecessor method - processing was aborted
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                );
  %end;

  %let _cst_rc=&_cstThisMacroRC;
  %let _cstSASRefs=&_cstSaveSASRefs;


%mend define_read;
