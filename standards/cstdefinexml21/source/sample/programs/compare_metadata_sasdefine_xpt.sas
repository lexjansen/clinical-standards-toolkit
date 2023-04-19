**********************************************************************************;
* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
* SPDX-License-Identifier: Apache-2.0                                            *;
* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
* SPDX-License-Identifier: Apache-2.0                                            *;
*                                                                                *;
* compare_metadata_sasdefine_xpt.sas                                             *;
*                                                                                *;
* Sample driver program to compare the metadata in the SAS representation of a   *;
* CDISC-DEFINE-XML V2.1 (define.xml) file with the metadata in the SAS Version   *;
* 5 (XPT) transport files described by the Define-XML V2.1 file.                 *;
*                                                                                *;
* Assumptions:                                                                   *;
*         The SASReferences file must exist, and must be identified in the       *;
*         call to cstutil_processsetup if it is not work.sasreferences.          *;
*                                                                                *;
* CSTversion  1.7                                                                *;
*                                                                                *;
* The following statements may require information from the user                 *;
**********************************************************************************;

%let _cstStandard=CDISC-DEFINE-XML;
%let _cstStandardVersion=2.1;   * <----- User sets the Define-XML version *;

%let _cstSrcStandard=CDISC-SDTM;   * <----- User sets to standard of the source study *;
%*let _cstSrcStandard=CDISC-ADAM;   * <----- User sets to standard of the source study *;
%if %SYMEXIST(sysparm) and %sysevalf(%superq(sysparm)=, boolean)=0 %then %do;
  * <----- Standard to use can be set from the command line *;
  %let _cstSrcStandard=&sysparm;
%end;



%if ("%upcase(&_cstSrcStandard)"="CDISC-SDTM") %then %do;
  %let _cstSrcStandardVersion=3.3;   * <----- User sets to standard version of the source study  *;
  %* Standard Subfolder with the SAS Version 5 transport files or the derived SAS Define-XML data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstSrcStandard)-&_cstSrcStandardVersion;
%end;

%if ("%upcase(&_cstSrcStandard)"="CDISC-ADAM") %then %do;
  %let _cstSrcStandardVersion=1.1;   * <----- User sets to standard version of the source study  *;
  %* Standard Subfolder with the SAS Version 5 transport files or the derived SAS Define-XML data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstSrcStandard)-&_cstSrcStandardVersion;
%end;



*****************************************************************************************************;
* The following data step sets (at a minimum) the studyrootpath and studyoutputpath.  These are     *;
* used to make the driver programs portable across platforms and allow the code to be run with      *;
* minimal modification. These nacro variables by default point to locations within the              *;
* cstSampleLibrary, set during install but modifiable thereafter.  The cstSampleLibrary is assumed  *;
* to allow write operations by this driver module.                                                  *;
*****************************************************************************************************;

%cst_setStandardProperties(_cstStandard=CST-FRAMEWORK,_cstSubType=initialize);
%cstutil_setcstsroot;

%let studyRootPath=&_cstSRoot/cdisc-definexml-&_cstStandardVersion.-&_cstVersion;
%let studyOutputPath=&_cstSRoot/cdisc-definexml-&_cstStandardVersion.-&_cstVersion;
%let workPath=%sysfunc(pathname(work));

%let _cstSetupSrc=SASREFERENCES;

%cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK, _cstType=control,_cstSubType=reference, _cstOutputDS=work.sasreferences);

proc sql;
  insert into work.sasreferences
  values ("CST-FRAMEWORK"    "1.2"                      "messages"          ""               "messages" "libref"  "input"  "dataset"  "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "autocall"          ""               "defauto"  "fileref" "input"  "folder"   "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "messages"          ""               "defmsg"   "libref"  "input"  "dataset"  "N"  "" ""                                   2 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "properties"        "initialize"     "inprop"   "fileref" "input"  "file"     "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "sourcedata"        ""               "srcdata"  "libref"  "input"  "file"     "N"  "" "&studyRootPath/transport/&_cstStandardSubFolder"    .  ""             "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "sourcemetadata"    ""               "srcmeta"  "libref"  "input"  "folder"   "N"  "" "&studyRootPath/deriveddata/&_cstStandardSubFolder"         .  ""             "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "results"           "results"        "results"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/results"           . "srcmeta_saslib_results.sas7bdat"   "")
  ;
quit;

************************************************************;
* Debugging aid:  set _cstDebug=1                          *;
* Note value may be reset in call to cstutil_processsetup  *;
*  based on property settings.  It can be reset at any     *;
*  point in the process.                                   *;
************************************************************;
%let _cstDebug=0;
data _null_;
  _cstDebug = input(symget('_cstDebug'),8.);
  if _cstDebug then
    call execute("options &_cstDebugOptions;");
  else
    call execute(("%sysfunc(tranwrd(options %cmpres(&_cstDebugOptions), %str( ), %str( no)));"));
run;

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

*******************************************************************************;
* Run the Framework macro.                                                    *;
*******************************************************************************;

%cstutilcomparemetasasdefine21(
  _cstSourceXPTFolder=%sysfunc(pathname(srcdata)),
  _cstSourceMetadataLibrary=srcmeta,
  _cstRptDS=results.compare_metadata_results
  );

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
