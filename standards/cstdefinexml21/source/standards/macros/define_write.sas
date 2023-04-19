%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_write                                                                   *;
%*                                                                                *;
%* Writes a CDISC Define-XML V2.1 file.                                           *;
%*                                                                                *;
%* This macro uses the SAS representation of a Define-XML V2.1 file as source     *;
%* data and converts it into the required XML structure. The inputs and outputs   *;
%* are specified in a SASReferences file.                                         *;
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
%*                                                                                *;
%* @param _cstCreateDisplayStyleSheet - optional - Create a style sheet in the    *;
%*            same directory as the output XML file.                              *;
%*            1: This macro looks in the specified SASReferences file for a       *;
%*            record with a type and subtype of referencexml and stylesheet, and  *;
%*            uses that file.                                                     *;
%*            0: This macro does not create the XSL stylesheet, even if one is    *;
%*            specified in the SASReferences file.                                *;
%*            Values: 0 | 1                                                       *;
%*            Default: 1                                                          *;
%* @param _cstOutputEncoding - optional - The XML encoding to use for the         *;
%*            Define-XML file that is created.                                    *;
%*            Default: UTF-8                                                      *;
%* @param _cstHeaderComment - optional - The short comment that is added to the   *;
%*            top of the Define-XML file that is produced. If this parameter is   *;
%*            not specified, a default is used.                                   *;
%* @param _cstResultsOverrideDS - optional - The (libname.)member that refers to  *;
%*            the Results data set to create. If omitted, the Results data set    *;
%*            that is specified by &_cstResultsDS is used.                        *;
%* @param _cstLogLevel - required - The level of error reporting.                 *;
%*            Values: info | warning | error | fatal error                        *;
%*            Default: info                                                       *;
%* @param _cstCallingPgm - optional - The name of the driver module calling       *;
%*            this macro.                                                         *;
%*                                                                                *;
%* @history 2022-02-07 Removed the use of picklists                               *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure external                                                             *;

%macro define_write(
    _cstCreateDisplayStyleSheet=1,
    _cstOutputEncoding=UTF-8,
    _cstHeaderComment=,
    _cstResultsOverrideDS=,
    _cstLogLevel=info,
    _cstCallingPgm=Unspecified
    ) / des='CST: Write CDISC Define-XML V2.1 file';


  %* declare local variables used in the macro;
  %local
    _cstRandom
    _cstGlobalMDPath
    _cstGlobalXSLPath
    _cstGlobalXSDPath
    _cstGlobalTransformsXML
    _cstGlobalStdDS
    _cstGlobalStdSASRefsDS
    _cstGlobalMDLib

    _cstThisMacro
    _cstThisMacroRC
    _cstThisMacroRCMsg

    _cstError
    _cstParm1
    _cstParm2
    _cstNextCode

    _cstTypeRefXML
    _cstTypeExtXML
    _cstTypeSourceData
    _cstTypeRefMD
    _cstSubTypeTable
    _cstSubtypeXML
    _cstSubtypeStylesheet
    _cstSubtypeXsdRepos
    _cstSubtypeXslRepos

    _cstStandard
    _cstStandardVersion
    _cstAction

    _cstXsdReposPath
    _cstXslReposPath
    _cstParamsClass
    _cstTransformsClass
    _cstWorkPath
    _cstAvailableTransformsPath
    _cstExternalXMLPath
    _cstStyleSheetPath
    _cstOutputStyleSheetName
    _cstCubeXMLName
    _cstCubeXMLPath
    _cstLogXMLName
    _cstLogXMLPath
    _cstLogXMLScope

    _cstXMLEngine

    _cstSrcDataLibrary
    _cstResultsDSLib

    _cstTempFilename1
    _cstTempFilename2
    _cstTempFilename3
    _cstTempFilename4
    _cstTempFilename5
    _cstTempDirLib1
    _cstTempDirLib1FullPath
    _cstNextCode

    _cstTempRefMdTable
    _cstTempRefMdTableObs

    _cstSavedOrigResultsName

    _cstrundt
    _cstrunstd
    _cstrunstdver
    ;

  %let _cstrundt=;
  %let _cstrunstd=;
  %let _cstrunstdver=;

  %let _cstSrcData=&sysmacroname;
  %let _cstThisMacroRC=0;
  %let _cstThisMacro=&sysmacroname;
  %****if %symexist(_cstResultsOverrideDS) %then %let _cstresultsds=&_cstResultsOverrideds;
  %if %length(&_cstResultsOverrideDS)>0 %then
    %let _cstresultsds=&_cstResultsOverrideds;

  %* retrieve static variables;
  %cst_getStatic(_cstName=CST_GLOBALMD_PATH,_cstVar=_cstGlobalMDPath);
  %cst_getStatic(_cstName=CST_GLOBALMD_REGSTANDARD,_cstVar=_cstGlobalStdDS);
  %cst_getStatic(_cstName=CST_GLOBALMD_SASREFS,_cstVar=_cstGlobalStdSASRefsDS);
  %cst_getStatic(_cstName=CST_GLOBALXSD_PATH,_cstVar=_cstGlobalXsdPath);
  %cst_getStatic(_cstName=CST_GLOBALXSL_PATH,_cstVar=_cstGlobalXSLPath);
  %cst_getStatic(_cstName=CST_GLOBALMD_TRANSFORMSXML,_cstVar=_cstGlobalTransformsXML);

  %cst_getStatic(_cstName=CST_SASREF_TYPE_REFMD,_cstVar=_cstTypeRefMD);
  %cst_getStatic(_cstName=CST_SASREF_TYPE_SOURCEDATA,_cstVar=_cstTypeSourceData);
  %cst_getStatic(_cstName=CST_SASREF_SUBTYPE_TABLE,_cstVar=_cstSubTypeTable);

  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_REFXML,_cstVar=_cstTypeRefXML);
  %define_getStatic(_cstName=DEFINE_SASREF_TYPE_EXTXML,_cstVar=_cstTypeExtXML);
  %define_getStatic(_cstName=DEFINE_SASREF_SUBTYPE_XML,_cstVar=_cstSubtypeXML);
  %define_getStatic(_cstName=DEFINE_SASREF_SUBTYPE_STYLESHEET,_cstVar=_cstSubtypeStylesheet);

  %define_getStatic(_cstName=DEFINE_JAVA_PARAMSCLASS,_cstVar=_cstParamsClass);
  %define_getStatic(_cstName=DEFINE_JAVA_EXPORTCLASS,_cstVar=_cstTransformsClass);


  %* Generate the random names used in the macro;
  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  %let _cstGlobalMDLib=_gmd&_cstRandom;
  %let _cstCubeXMLName=_cub&_cstRandom;
  %let _cstTempFilename2=_t2&_cstRandom;
  %let _cstTempFilename3=_t3&_cstRandom;
  %let _cstTempFilename4=_t4t&_cstRandom;
  %let _cstLogXMLName=_log&_cstRandom;
  %let _cstTempRefMdTable=_tmd&_cstRandom;
  %let _cstNextCode=_cod&_cstRandom;
  %let _cstTempDirLib1=_tl&_cstRandom;

  %let _cstXMLEngine=xmlv2;

  %* Determine XML Log Scope;
  %if &_cstDebug %then %let _cstLogXMLScope=_ALL_;
                 %else %let _cstLogXMLScope=USER;

  data _null_;
   if upcase("&_cstLogLevel") in ("INFO", "ERROR" , "WARNING", "FATAL ERROR")
      then call symput('loglev',"&_cstLogLevel");
   else call symput('loglev',"INFO");
  run;


  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  %let _cstTempDirLib1=_cst&_cstRandom;


  %* Create a temporary messages data set if required;
  %local _cstNeedToDeleteMsgs;
  %cstutil_createTempMessages(_cstCreationFlag=_cstNeedToDeleteMsgs);

  %* Set up the location of the results data set to write to;
  %local
    _cstThisResultsDS
    _cstThisResultsDSLib
    _cstThisResultsDSMem
    _cstUsingResultsOverride
    _cstSaveResultSeq
    _cstSaveSeqCnt
    ;
  %cstutil_internalManageResults(_cstAction=SAVE);
  %let _cstResultSeq=1;
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


  data _null_;
    set &_cstSASrefs (where=(upcase(standard)="CDISC-DEFINE-XML"));
    if _n_=1 then do;
      call symputx('_cstrundt',put(datetime(),is8601dt.));
      call symputx('_cstrunstd',standard);
      call symputx('_cstrunstdver',standardversion);
    end;
  run;

  %* Write information to the results data set about this run. *;
  %cstutilwriteresultsintro(_cstProcessType=FILEIO, _cstPgm=&_cstCallingPgm);

  %* check that the sas references table is correct;
  %* need to redirect the results because there is no override in checkDS;
  %let _cstSavedOrigResultsName=&_cstResultsDS;
  %let _cstResultsDS=&_cstThisResultsDS;

  %if (&_cstDebug) %then %do;
    %put before the call to cst_checkDS;
    %put _cstSavedOrigResultsName=&_cstSavedOrigResultsName;
    %put _cstResultsDS=&_cstResultsDS;
  %end;

  * The library for the results must exist;
  %if ((%sysfunc(libref(&_cstThisResultsDSLib)))) %then %do;
     %let _cstParam1=&_cstThisResultsDSLib;
     %goto RESULTSLIB_NOT_ASSIGNED;
  %end;

  * _cstCreateDisplayStyleSheet must be 0 or 1;
  %if (^((&_cstCreateDisplayStyleSheet=0) OR (&_cstCreateDisplayStyleSheet=1))) %then %do;
     %let _cstParam1=_cstCreateDisplayStyleSheet;
     %let _cstParam2=&_cstCreateDisplayStyleSheet;
     %goto INVALID_PARAM_VALUE;
  %end;


  %* set up static-final style variables;
  %let _cstStandard=&_cstrunstd;
  %let _cstStandardVersion=&_cstrunstdver;
  %let _cstAction=EXPORT;

  %* Get the fileref of the src data and the XML file and then the full path to it;
  %cstUtil_getSASReference(
    _cstStandard=%upcase(&_cstStandard)
    ,_cstStandardVersion=&_cstStandardVersion
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
    _cstStandard=%upcase(&_cstStandard)
    ,_cstStandardVersion=&_cstStandardVersion
    ,_cstSASRefType=&_cstTypeExtXml
    ,_cstSASRefSubType=&_cstSubtypeXML
    ,_cstSASRefsasref=_cstTempFilename1
    );
  %if (&_cst_rc) %then %do;
     %let _cstParam1=&_cstTypeExtXml/&_cstSubtypeXML;
     %goto MISSING_SASREF;
  %end;
  %else %if (&_cstDebug=1) %then %do;
    %put XML file to create from sasrefs file: &_cstTempFilename1;
  %end;

  %* Get the fileref of the stylesheet to use file - if the user is asking to use one;
  %if (&_cstCreateDisplayStyleSheet=1) %then %do;
    %cstUtil_getSASReference(
      _cstStandard=%upcase(&_cstStandard)
      ,_cstStandardVersion=&_cstStandardVersion
      ,_cstSASRefType=&_cstTypeRefXML
      ,_cstSASRefSubType=&_cstSubtypeStylesheet
      ,_cstSASRefsasref=_cstTempFilename5
      ,_cstSASRefMember=_cstOutputStyleSheetName
      ,_cstAllowZeroObs=1
      );
    %if (%length(&_cstTempFilename5)>0) %then %do;
      %* if provided, it must exist;
      %if ((%sysfunc(fexist(&_cstTempFilename5)))=0) %then %do;
         %let _cstParam1=%sysfunc(pathname(&_cstTempFilename5));
         %goto MISSING_FILE;
      %end;
    %end;
  %end;
  %if (&_cstDebug=1) %then %do;
    %put Stylesheet reference: &_cstTempFilename5;
    %put _cstCreateDisplayStyleSheet=&_cstCreateDisplayStyleSheet;
    %put _cstStandard=%upcase(&_cstStandard);
    %put _cstStandardVersion=&_cstStandardVersion;
    %put _cstSASRefType=&_cstTypeRefXML;
    %put _cstSASRefSubType=&_cstSubtypeStylesheet;
  %end;

  %* This next section ensures that the dataset and column names have the correct
     capitalization as SAS does not care but Java and XML do.  This will be done
     by creating a temporary lib under the work directory and creating the
     correct data sets under there.
     These will be used in the Define-XML creation and then deleted later.;

  * Get the path to the work library, create the temp dir under it and
    assign a library to it;
  data _null_;
    length
      workPath $500
      tempDirPath $500
      ;

    workPath=pathname('work');
    call symputx('_cstWorkPath',workPath,'L');
    tempDirPath=dcreate("&_cstTempDirLib1","&&_cstWorkPath");
    call symputx('_cstTempDirLib1FullPath',tempDirPath,'L');
  run;

  libname &_cstTempDirLib1 "&_cstTempDirLib1FullPath";

  * Create the standard metadata files in the new directory;
  %cst_createTablesForDataStandard(
     _cstStandard=&_cstStandard
    ,_cstStandardVersion=&_cstStandardVersion
    ,_cstOutputLibrary=&_cstTempDirLib1
    );


  * Get the library information for the table metadata for this standard-version;
  * and create a working copy if it;
  %* NOTE: this uses the same variable name for 2 purposes: the libname and the work data;
  %* set name.  Do not confuse the two things;
  data _null_;
    file &_cstNextCode;
    set &_cstGlobalMDLib..&_cstGlobalStdSASRefsDS (where=(
      (standard="&_cstStandard") AND
      (standardVersion="&_cstStandardVersion") AND
      (upcase(type)="%upcase(&_cstTypeRefMD)") AND
      (upcase(subType)="%upcase(&_cstSubTypeTable)")
    ));
    memname = scan(memname,1,'.');

    put @1 "* Assign the library to the standard's metadata;";
    put @1 'libname &_cstTempRefMdTable "' %unquote(path) +(-1) '" access=readonly;';

    put @1 "* Create the MDP data set that be used to create the XML;";
    put @1 "* This also contains the srcMemname that is the data set the user has provided;";
    put @1 "data work.&_cstTempRefMdTable(keep=srcMemname mdpMemname mdpName);";
    put @3   "length srcMemname $65 mdpMemname $65 mdpName $200;";
    put @3   "set &_cstTempRefMdTable.." memname +(-1) ";";
    put @3   "srcMemname='" "&_cstSrcDataLibrary" "' || '.' || table;";
    put @3   "mdpMemname='" "&_cstTempDirLib1" "' || '.' || table;";
    put @3   "if exist(srcMemname) then do;";
    put @5     "mdpName=xmlElementName;";
    put @5     "output;";
    put @3   "end;";
    put @1 "run;";

    put @1 "* De-assign the libname;";
    put @1 "libname &_cstTempRefMdTable;";
  run;

  * Include the code just created to create the mdp table;
  * Note: there may be issues if this is buried in multiple macro calls;
  %include &_cstNextCode;


  data _null_;
    if 0 then set work.&_cstTempRefMdTable nobs=_numobs;
    call symputx('_cstTempRefMdTableObs',_numobs);
    stop;
  run;
   * The source data sets must exist;
   %if (&_cstTempRefMdTableObs = 0) %then %do;
      %let _cstParam1=No SAS data sets to transform to Define-XML in library &_cstSrcDataLibrary..;
      %let _cstParam2=;
      %goto MISSING_SOURCE_DATASETS;
   %end;


  %**********************************************************************;
  %* Internal helper macro                                              *;
  %**********************************************************************;
  %macro _cstutil_checktranscoding(_cstTable);
    %local sess_enc dset_enc dsid rc _cstSaveOptions;
    %let sess_enc = %sysfunc(getoption(encoding));
  
    %* Determine Encoding of SAS Dataset;
    %let dset_enc=%str();
    %let dsid = %sysfunc(open(&_cstTable));
    %if %eval(&dsid>0) %then %do;
      %let dset_enc = %sysfunc(trim(%scan(%sysfunc(attrc(&dsid,ENCODING)),1,%str( ))));
      %let rc = %sysfunc(close(&dsid));
    %end;
    
    %let _cstSaveOptions=%sysfunc(getoption(errorabend)) %sysfunc(getoption(syntaxcheck))
    options noerrorabend nosyntaxcheck;
    %let syscc=0;
    data work._cstTranscoding_&_cstRandom(encoding="&_cstOutputEncoding");
      set &_cstTable;
    run;
    options &_cstSaveOptions;
  
    %if %eval(&syscc>4) %then %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Data &_cstTable can not be transcoded correctly to &_cstOutputEncoding..;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Check %nrbquote(%sysfunc(pathname(&_cstTempFilename1))).;
      
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DEF0098
                    ,_cstResultParm1=Data &_cstTable can not be transcoded correctly to &_cstOutputEncoding.. Check %sysfunc(pathname(&_cstTempFilename1))
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstThisMacro
                    ,_cstResultFlagParm=1
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;
    %let syscc=0;
    
    %cstutil_deleteDataSet(_cstDataSetName=work._cstTranscoding_&_cstRandom);
      
  %exitmac:
  %mend _cstutil_checktranscoding;
  
  %* End of internal macro specification  *;


  * Check transcoding;
  data _null_;
    length code $200;
    set work.&_cstTempRefMdTable;
    code = cats('%_cstutil_checktranscoding(', srcMemname,');');
    code = catt('%nrstr(', code, ")");
    call execute(code);
  run;  
  %let syscc=0;

  * use the data set just created (work.&_cstTempRefMdTable) to write the
    code to copy the data sets;
  data _null_;
    file &_cstNextCode;
    set work.&_cstTempRefMdTable;

    if _n_=1 then do;
      put @1 "* This section copies the source data into the temporary library;";
    end;
    put @1 "data " mdpMemname ";";
    put @3   "if (0) then set " mdpMemname ";";
    put @3   "set " srcMemname ";";
    put @1 "run;"/ /;
  run;


  * Include the code just created to fill the correctly capitalizaed tables/columns;
  * Note: there may be issues if this is buried in multiple macro calls;
  %include &_cstNextCode;


  %* At this point the data prep is complete, so need to create the XML;

  * Assign temporary filenames to the repository paths as the SAS !Var needs to be expanded;
  %* _cstTempFilename1,5 was assigned already so leave it;
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
    %if (%length(&_cstTempFilename5)>0) %then %do;
      call symputx('_cstStyleSheetPath',pathname("&_cstTempFilename5"),'L');
    %end;
  run;


* De-Allocate the temporary filename;
  filename &_cstTempFilename2;
  filename &_cstTempFilename3;
  filename &_cstTempFilename4;

  %* the location where the temporary cube XML will be stored;
  %let _cstCubeXMLPath=&_cstWorkPath./&_cstCubeXMLName._write.xml;
  %let _cstLogXMLPath=&_cstWorkPath./&_cstLogXMLName._write.xml;

  %let _cstAvailableTransformsPath=&_cstMDPath./&_cstGlobalTransformsXML;

  %* Print out debuggin information;
  %if (&_cstDebug=1) %then %do;
    %put Note: Calling java with parameters:;
    %put       _cstParamsClass=&_cstParamsClass;
    %put       _cstTransformsClass=&_cstTransformsClass;
    %put       _cstAction=&_cstAction;
    %put       _cstStandard=&_cstStandard;
    %put       _cstStandardVersion=&_cstStandardVersion ;
    %put       _cstXslReposPath=&_cstXslReposPath;
    %put       _cstXsdReposPath=&_cstXsdReposPath;
    %put       _cstCubeXMLPath=&_cstCubeXMLPath;
    %put       _cstExternalXMLPath=&_cstExternalXMLPath;
    %put       _cstStyleSheetPath=&_cstStyleSheetPath;
    %put       _cstAvailableTransformsPath=&_cstAvailableTransformsPath;
    %put       _cstLogXMLPath=&_cstLogXMLPath;
    %put       _cstCreateDisplayStyleSheet=&_cstCreateDisplayStyleSheet;
    %put       _cstOutputStyleSheetName=&_cstOutputStyleSheetName;
  %end;


  %* write the intermediate XML file out;
  %cstutil_writecubexml(_cstXMLOut=&_cstCubeXMLPath,
                        _cstEncoding=&_cstOutputEncoding,
                        _cstMDPFile=work.&_cstTempRefMdTable);


  %* The temporary data sets are no longer needed so they can be cleaned up,
    the directory deleted and the libname deassigned;
  proc datasets nolist kill lib=&_cstTempDirLib1;
  quit;

  libname &_cstTempDirLib1;

  data _null_;
    rc=filename("&_cstTempDirLib1","&_cstTempDirLib1FullPath");
    rc=fdelete("&_cstTempDirLib1");
    rc=filename("&_cstTempDirLib1");
  run;
  %* end of cleanup;


  %* In the following, the logging level is set to info as the transform creates
     an empty XML doc if nothing is reported, which causes an error in the SAS libname;
  * Create the external XML file from intermediate xml;
  data _null_;
  
    dcl javaobj prefs("&_cstParamsClass");
    prefs.callvoidmethod('setImportOrExport',"&_cstAction");
    prefs.callvoidmethod('setStandardName',"&_cstStandard");
    prefs.callvoidmethod('setStandardVersion',"&_cstStandardVersion");

    prefs.callvoidmethod('setXslBasePath',tranwrd("&_cstXslReposPath",'\','/'));
    prefs.callvoidmethod('setSchemaBasePath',tranwrd("&_cstXsdReposPath",'\','/'));

    prefs.callvoidmethod('setSasXMLPath',tranwrd("&_cstCubeXMLPath",'\','/'));
    prefs.callvoidmethod('setStandardXMLPath',tranwrd("&_cstExternalXMLPath",'\','/'));

    prefs.callvoidmethod('setAvailableTransformsFilePath',tranwrd("&_cstAvailableTransformsPath",'\','/'));
    prefs.callvoidmethod('setLogFilePath',tranwrd("&_cstLogXMLPath",'\','/'));

    if ("&_cstOutputEncoding" ne '') then do;
      prefs.callvoidmethod('setOutputEncoding',"&_cstOutputEncoding");
    end;

    %if %sysevalf(%superq(_cstHeaderComment)=, boolean)=0 %then %do;
      prefs.callvoidmethod('setHeaderCommentText',tranwrd("&_cstHeaderComment",'\','/'));
    %end;


    if (&_cstCreateDisplayStyleSheet=1) then do;
      if ("&_cstStyleSheetPath" ne '') then do;
        prefs.callvoidmethod('setCustomStylesheetPath', tranwrd("&_cstStyleSheetPath",'\','/'));
        prefs.callvoidMethod('setOutputStylesheetName', tranwrd("&_cstOutputStyleSheetName..xsl",'\','/'));
      end;
      prefs.callvoidmethod('createDisplayStylesheet');
    end;

    * set logging to INFO;
    prefs.callvoidmethod('setLogLevelString',"&loglev");

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

  * Cleanup the log and cube file;
  %if (&_cstDebug=0) %then %do;
    data _null_;
      rc=filename("&_cstLogXMLName","&_cstLogXMLPath");
      rc=fdelete("&_cstLogXMLName");
      rc=filename("&_cstLogXMLName");
      rc=filename("&_cstCubeXMLName","&_cstcubeXMLPath");
      rc=fdelete("&_cstCubeXMLName");
      rc=filename("&_cstCubeXMLName");
    run;
  %end;

  %* Handle any errors generated during the java code;
  %if (&_cstThisMacroRC) %then %do;
    %goto GENERATION_ERRORS;
  %end;

  %* Everything was OK so  report it;
  %let _cstParam1=&_cstExternalXMLPath;
  %let _cstThisMacroRC=0;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0010
                ,_cstResultParm1=&_cstParam1
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
                );

  %goto CLEANUP;


%RESULTSLIB_NOT_ASSIGNED:
  %if (&_cstDebug) %then %do;
     %put In RESULTSLIB_NOT_ASSIGNED;
  %end;

  %local _cstTempResultsDS;

  %cstutil_getRandomNumber(_cstVarname=_cstRandom);
  %let _cstTempResultsDS=_cst&_cstRandom;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0007
                ,_cstResultParm1=&_cstParam1
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstTempResultsDS
                );

  %* print the temp results to the log as the resutls file cannot exist;
  data _null_;
    file &_cstNextCode;
    set &_cstTempResultsDS;
    resultSeverity=upcase(resultSeverity);
    put %nrstr("%put ") resultSeverity ": "  message ";";
  run;

  %cstutil_deleteDataSet(_cstDataSetName=work.&_cstTempResultsDS);

  %include &_cstNextCode;

  %let rc=delete("&_cstNextCode");

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
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
                );
  %goto CLEANUP;

%MISSING_SOURCE_DATASETS:
  %if (&_cstDebug) %then %do;
     %put In MISSING_SOURCE_DATASETS;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0099
                ,_cstResultParm1=&_cstParam1
                ,_cstResultParm2=&_cstParam2
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
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
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
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
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
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
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
                );
  %goto CLEANUP;

%INVALID_PARAM_VALUE:
  %if (&_cstDebug) %then %do;
     %put In INVALID_PARAM_VALUE;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0006
                ,_cstResultParm1=&_cstParam1
                ,_cstResultParm2=&_cstParam2
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
                );
  %goto CLEANUP;

%GENERATION_ERRORS:
  %if (&_cstDebug) %then %do;
     %put In GENERATION_ERRORS;
  %end;

  %let _cstThisMacroRC=1;
  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
  %cstutil_writeresult(
                _cstResultId=DEF0011
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstThisMacro
                ,_cstResultFlagParm=&_cstThisMacroRC
                ,_cstRCParm=&_cstThisMacroRC
                ,_cstResultsDSParm=&_cstThisResultsDS
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
                ,_cstResultsDSParm=&_cstThisResultsDS
                );
  %goto CLEANUP;


%CLEANUP:
  %if (&_cstDebug) %then %do;
     %put In CLEANUP;
  %end;

  %* Persist the results if specified in sasreferences  *;
  %cstutil_saveresults();

  %* reset the resultSequence/SeqCnt variables;
  %cstutil_internalManageResults(_cstAction=RESTORE);

  * Clear the libname;
  libname &_cstGlobalMDLib;

  * Clear the temporary filename into the work catalog;
  filename &_cstNextCode;

  * Clean up temporary data sets if they exist;
  %cstutil_deleteDataSet(_cstDataSetName=work.&_cstTempRefMdTable);

  %* Delete the temporary messages data set if it was created here;
  %if (&_cstNeedToDeleteMsgs=1) %then %do;
    %local _cstMsgDir _cstMsgMem;
    %if %eval(%index(&_cstMessages,.)>0) %then %do;
      %let _cstMsgDir=%scan(&_cstMessages,1,.);
      %let _cstMsgMem=%scan(&_cstMessages,2,.);
    %end;
    %else %do;
      %let _cstMsgDir=work;
      %let _cstMsgMem=&_cstMessages;
    %end;
    %cstutil_deleteDataSet(_cstDataSetName=&_cstMsgDir..&_cstMsgMem);
  %end;

  %let _cst_rc=&_cstThisMacroRC;

%mend define_write;
