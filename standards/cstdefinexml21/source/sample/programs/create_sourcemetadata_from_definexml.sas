**********************************************************************************;
* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
* SPDX-License-Identifier: Apache-2.0                                            *;
*                                                                                *;
* create_sourcemetadata_from_definexml.sas                                       *;
*                                                                                *;
* This sample driver module performs the setup steps to derive source metadata   *;
* files for a CDISC study from a Define-XML v2.1 file.                           *;
*                                                                                *;
* The following source metadata files are used by Clinical Standards Toolkit to  *;
* support CDISC validation and derivation of define.xml files:                   *;
*          source_study                                                          *;
*          source_standards                                                      *;
*          source_tables                                                         *;
*          source_columns                                                        *;
*          source_values                                                         *;
*          source_codelists                                                      *;
*          source_documents                                                      *;
*          source_analysisresults                                                *;
*                                                                                *;
* Assumptions:                                                                   *;
*         The SASReferences file must exist, and must be identified in the       *;
*         call to cstutil_processsetup if it is not work.sasreferences.          *;
*         Alternatively macro parameters can be specified                        *;
*                                                                                *;
* CSTversion  1.7                                                                *;
*                                                                                *;
*  The following statements may require information from the user                *;
**********************************************************************************;

%let _cstStandard=CDISC-DEFINE-XML;
%let _cstStandardVersion=2.1;

%let _cstTrgStandard=CDISC-SDTM;   * <----- User sets to standard of the source study          *;
%*let _cstTrgStandard=CDISC-SEND-DART;   * <----- User sets to standard of the source study          *;
%*let _cstTrgStandard=CDISC-ADAM;   * <----- User sets to standard of the source study          *;



%if ("&_cstTrgStandard"="CDISC-SDTM") %then %do;
  %let _cstTrgStandardVersion=3.3;
  %* Subfolder with the SAS Source Metadata data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;
  %let _cstDefineFile=define_msg_sdtm.xml;
  %let _cstUseARM=0;
%end;

%if ("&_cstTrgStandard"="CDISC-SEND-DART") %then %do;
  %let _cstTrgStandardVersion=1.2;
  %* Subfolder with the SAS Source Metadata data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;
  %let _cstDefineFile=define_send_dart_1.2_define21.xml;
  %let _cstUseARM=0;
%end;

%if ("&_cstTrgStandard"="CDISC-ADAM") %then %do;
  %let _cstTrgStandardVersion=1.1;
  %* Subfolder with the SAS Source Metadata data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;
  %let _cstDefineFile=define_msg_adam.xml;
  %let _cstUseARM=1;
%end;


*****************************************************************************************************;
* The following code sets (at a minimum) the studyrootpath and studyoutputpath.  These are          *;
* used to make the driver programs portable across platforms and allow the code to be run with      *;
* minimal modification. These macro variables by default point to locations within the              *;
* cstSampleLibrary, set during install but modifiable thereafter.  The cstSampleLibrary is assumed  *;
* to allow write operations by this driver module.                                                  *;
*****************************************************************************************************;

%cst_setStandardProperties(_cstStandard=CST-FRAMEWORK,_cstSubType=initialize);

%cstutil_setcstsroot;
data _null_;
  call symput('studyRootPath',cats("&_cstSRoot","/cdisc-definexml-2.1-&_cstVersion"));
  call symput('studyOutputPath',cats("&_cstSRoot","/cdisc-definexml-2.1-&_cstVersion"));
run;
%let workPath=%sysfunc(pathname(work));

*****************************************************************************************;
* One strategy to defining the required library and file metadata for a CST process     *;
*  is to optionally build SASReferences in the WORK library.  An example of how to do   *;
*  this follows.                                                                        *;
*                                                                                       *;
* The call to cstutil_processsetup below tells CST how SASReferences will be provided   *;
*  and referenced.  If SASReferences is built in work, the call to cstutil_processsetup *;
*  may, assuming all defaults, be as simple as:                                         *;
*        %cstutil_processsetup(_cstStandard=CDISC-SDTM)                                 *;
*****************************************************************************************;

%let _cstSetupSrc=SASREFERENCES;

%cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK, _cstType=control,_cstSubType=reference, _cstOutputDS=work.sasreferences);

proc sql;
  insert into work.sasreferences
  values ("CST-FRAMEWORK"    "1.2"                      "messages"          ""           "messages" "libref"  "input"  "dataset"  "N"  "" ""                                   1 ""                           "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "messages"          ""           "defmsg"   "libref"  "input"  "dataset"  "N"  "" ""                                   2 ""                           "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "autocall"          ""           "defauto"  "fileref" "input"  "folder"   "N"  "" ""                                   1 ""                           "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "properties"        "initialize" "inprop"   "fileref" "input"  "file"     "N"  "" ""                                   1 ""                           "")

  values ("&_cstStandard"    "&_cstStandardVersion"     "results"           "results"    "results"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/results"           . "srcmeta_define_results.sas7bdat"   "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "externalxml"       "xml"        "crtxml"   "fileref" "input"  "file"     "N"  "" "&studyRootPath/sourcexml"           . "&_cstDefineFile"            "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "referencexml"      "map"        "crtmap"   "fileref" "input"  "file"     "N"  "" "&studyRootPath/referencexml"        . "define.map"                 "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "sourcedata"        ""           "srcdata"  "libref"  "output" "folder"   "N"  "" "&studyOutputPath/deriveddata/&_cstStandardSubFolder"  . ""         "")

  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "study"      "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_study.sas7bdat"      "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "standard"   "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_standards.sas7bdat"  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "table"      "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_tables.sas7bdat"     "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "column"     "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_columns.sas7bdat"    "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "codelist"   "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_codelists.sas7bdat"  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "value"      "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_values.sas7bdat"     "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "document"   "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_documents.sas7bdat"  "")
  %if &_cstUseARM %then %do;
    values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "analysisresult" "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder"  . "source_analysisresults.sas7bdat"    "")
  %end;
/*
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "classmetadata"     "column"     "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                           "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "classmetadata"     "table"      "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                           "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "referencemetadata" "column"     "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                           "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "referencemetadata" "table"      "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                           "")
*/
  ;
quit;

************************************************************;
* Debugging aid:  set _cstDebug=1                          *;
* Note value may be reset in call to cstutil_processsetup  *;
*  based on property settings.  It can be reset at any     *;
*  point in the process.                                   *;
************************************************************;
%let _cstDebug=0;

**********************************************
*  Check debug option and set cleanup macro  *
*  cleanup macro for SASReferences run.      *
**********************************************;
data _null_;
  _cstDebug = input(symget('_cstDebug'),8.);
  if _cstDebug then
    call execute("options &_cstDebugOptions;");
  else
    call execute(("%sysfunc(tranwrd(options %cmpres(&_cstDebugOptions), %str( ), %str( no)));"));
run;

*****************************************************************************************;
* Clinical Standards Toolkit utilizes autocall macro libraries to contain and           *;
*  reference standard-specific code libraries.  Once the autocall path is set and one   *;
*  or more macros have been used within any given autocall library, deallocation or     *;
*  reallocation of the autocall fileref cannot occur unless the autocall path is first  *;
*  reset to exclude the specific fileref.                                               *;
*                                                                                       *;
* This becomes a problem only with repeated calls to %cstutil_processsetup() or         *;
*  %cstutil_allocatesasreferences within the same sas session.  Doing so, without       *;
*  submitting code similar to the code below may produce SAS errors such as:            *;
*     ERROR - At least one file associated with fileref AUTO1 is still in use.          *;
*     ERROR - Error in the FILENAME statement.                                          *;
*                                                                                       *;
* If you call %cstutil_processsetup() or %cstutil_allocatesasreferences more than once  *;
*  within the same sas session, typically using %let _cstReallocateSASRefs=1 to tell    *;
*  CST to attempt reallocation, use of the following code is recommended between each   *;
*  code submission.                                                                     *;
*                                                                                       *;
* Use of the following code is NOT needed to run this driver module initially.          *;
*****************************************************************************************;

%*let _cstReallocateSASRefs=1;
%*include "&_cstGRoot/standards/cst-framework-&_cstVersion/programs/resetautocallpath.sas";


*****************************************************************************************;
* The following macro (cstutil_processsetup) utilizes the following parameters:         *;
*                                                                                       *;
* _cstSASReferencesSource - Setup should be based upon what initial source?             *;
*   Values: SASREFERENCES (default) or RESULTS data set. If RESULTS:                    *;
*     (1) no other parameters are required and setup responsibility is passed to the    *;
*                 cstutil_reportsetup macro                                             *;
*     (2) the results data set name must be passed to cstutil_reportsetup as            *;
*                 libref.memname                                                        *;
*                                                                                       *;
* _cstSASReferencesLocation - The path (folder location) of the sasreferences data set  *;
*                              (default is the path to the WORK library)                *;
*                                                                                       *;
* _cstSASReferencesName - The name of the sasreferences data set                        *;
*                              (default is sasreferences)                               *;
*****************************************************************************************;

%cstutil_processsetup();


***************************************************************************;
* Run the schema validation macro.                                        *;
***************************************************************************;
%cstutilxmlvalidate();

*******************************************************************************;
* Run the standard-specific Define-XML macros.                                *;
*******************************************************************************;
%define_read();

*******************************************************************************;
* Run the standard-specific Define-XML macros.                                *;
*******************************************************************************;

%define_createsrcmetafromdefine(
  _cstTrgStandard=&_cstTrgStandard,
  _cstTrgStandardVersion=&_cstTrgStandardVersion,
  _cstLang=en,
  _cstUseRefLib=N
);
 

/*

libname srcdata "&studyRootPath/deriveddata/&_cstStandardSubFolder";
libname trgmeta "&studyOutputPath/derivedstudymetadata_define/&_cstStandardSubFolder";
*/
/*
%define_createsrcmetafromdefine(
  _cstDefineDataLib=srcdata,
  _cstTrgStandard=&_cstTrgStandard,
  _cstTrgStandardVersion=&_cstTrgStandardVersion,
  _cstTrgStudyDS=trgmeta.source_study,
  _cstTrgStandardDS=trgmeta.source_standards,
  _cstTrgTableDS=trgmeta.source_tables,
  _cstTrgColumnDS=trgmeta.source_columns,
  _cstTrgCodeListDS=trgmeta.source_codelists,
  _cstTrgValueDS=trgmeta.source_values,
  _cstTrgDocumentDS=trgmeta.source_documents,
  %if &_cstUseARM %then %do;
    _cstTrgAnalysisResultDS=trgmeta.source_analysisresults,
  %end;
  _cstLang=en,
  _cstUseRefLib=N,
  _cstRefTableDS=refmeta.reference_tables,
  _cstRefColumnDS=refmeta.reference_columns,
  _cstClassTableDS=refmeta.class_tables,
  _cstClassColumnDS=refmeta.class_columns,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  );
*/

**********************************************************************************;
* Clean-up the CST process files, macro variables and macros.                    *;
**********************************************************************************;
* Delete sasreferences if created above  *;
proc datasets lib=work nolist;
  delete sasreferences / memtype=data;
quit;

%*cstutil_cleanupcstsession(
     _cstClearCompiledMacros=0
    ,_cstClearLibRefs=1
    ,_cstResetSASAutos=1
    ,_cstResetFmtSearch=0
    ,_cstResetSASOptions=0
    ,_cstDeleteFiles=1
    ,_cstDeleteGlobalMacroVars=0);
