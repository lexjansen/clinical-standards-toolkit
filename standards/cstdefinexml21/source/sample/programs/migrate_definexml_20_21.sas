**********************************************************************************;
* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
* SPDX-License-Identifier: Apache-2.0                                            *;
* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
* SPDX-License-Identifier: Apache-2.0                                            *;
*                                                                                *;
* migrate_definexml_20_21_sdtm.sas                                               *;
*                                                                                *;
* Sample driver program to migrate Define-XML v2.0 SDTM or ADaM metadata source  *;
* datasets to Define-XML v2.1 metadata source data sets.                         *;
*                                                                                *;
* Caveat: As with many automated conversion tools, this should be used with      *;
* caution. The source metadata files resulting from this conversion provide a    *;
* starting point for Define-XML 2.1 metadata and a decent way to get a jump      *;
* start on  exploring 2.1 features but they should not be considered ideal       *;
* Define 2.1 implementations suitable for production use.                        *;
*                                                                                *;
* CSTversion  1.7                                                                *;
*                                                                                *;
* The following statements may require information from the user                 *;
**********************************************************************************;

%let _cstStandard=CDISC-DEFINE-XML;
%let _cstStandardVersion=2.1;   * <----- User sets the Define-XML version *;

%let _cstTrgStandard=CDISC-SDTM;    * <----- User sets to standard of the source study *;
%*let _cstTrgStandard=CDISC-ADAM;    * <----- User sets to standard of the source study *;
%if %SYMEXIST(sysparm) and %sysevalf(%superq(sysparm)=, boolean)=0 %then %do;
  * <----- Standard to use can be set from the command line *;
  %let _cstTrgStandard=&sysparm;
%end;



%if ("&_cstTrgStandard"="CDISC-SDTM") %then %do;
  %let _cstTrgStandardVersion=3.1.2;   * <----- User sets to standard version of the source study  *;
%end;

%if ("&_cstTrgStandard"="CDISC-ADAM") %then %do;
  %let _cstTrgStandardVersion=2.1;     * <----- User sets to standard version of the source study  *;
%end;



*****************************************************************************************************;
* The following data step sets (at a minimum) the studyrootpath and studyoutputpath.  These are     *;
* used to make the driver programs portable across platforms and allow the code to be run with      *;
* minimal modification. These macro variables by default point to locations within the              *;
* cstSampleLibrary, set during install but modifiable thereafter.  The cstSampleLibrary is assumed  *;
* to allow write operations by this driver module.                                                  *;
*****************************************************************************************************;

%cst_setStandardProperties(_cstStandard=CST-FRAMEWORK,_cstSubType=initialize);
%cstutil_setcstsroot;
data _null_;
  call symput('studyRootPath',cats("&_cstSRoot","/cdisc-definexml-2.0.0-&_cstVersion"));
  call symput('studyOutputPath',cats("&_cstSRoot","/cdisc-definexml-&_cstStandardVersion.-&_cstVersion"));
run;
%let workPath=%sysfunc(pathname(work));
%let define20_metadata=&studyRootPath/sascstdemodata/%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion/metadata;
%let define21_metadata=&studyOutputPath/derivedstudymetadata_define-2.0/%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;


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
  values ("CST-FRAMEWORK" "1.2"                   "messages"          ""             "messages" "libref"  "input"  "dataset"  "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard" "&_cstStandardVersion"  "autocall"          ""             "defauto"  "fileref" "input"  "folder"   "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard" "&_cstStandardVersion"  "messages"          ""             "defmsg"   "libref"  "input"  "dataset"  "N"  "" ""                                   2 ""                                  "")
  values ("&_cstStandard" "&_cstStandardVersion"  "properties"        "initialize"   "inprop"   "fileref" "input"  "file"     "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard" "&_cstStandardVersion"  "results"           "results"      "results"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/results"           . "migrate_20_21_results.sas7bdat"   "")

  values ("&_cstStandard" "&_cstStandardVersion"  "sourcemetadata"    ""  "defv20"  "libref"  "input"  "folder"   "N"  "" "&define20_metadata" . "" "")
  values ("&_cstStandard" "&_cstStandardVersion"  "targetmetadata"    ""  "defv21"  "libref"  "output" "folder"   "Y"  "" "&define21_metadata" . "" "")
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

%**************************************************************************************;
%* Create some formats for mapping (used in the cstutilmigrate_define20_21.sas macro) *;
%**************************************************************************************;
proc format;
  value $_cstorg
   /* Maps from Define-XML v22 values to Define-XML v21 values */
   "CRF"="Collected"
   "eDT"="Collected"
   "COLLECTED" = "Collected"
   "DERIVED" = "Derived"
   "OTHER" = "Other"
   "NOT AVAILABLE" = "Not Available"
  ;
run;  

%********************************************************;
%*  Define Standards Metadata                           *;
%*  Since the SAS datasets have no version information, *;
%*  only specify one record per type (IG or CT)         *;
%********************************************************;
%cst_createdsfromtemplate(
  _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=&_cstStandardVersion,
  _cstType=studymetadata,_cstSubType=standard,_cstOutputDS=work.source_standards
  );
  
proc sql;
  insert into work.source_standards(cdiscstandard, cdiscstandardversion, type, publishingset, order, status, comment)
%if "&_cstTrgStandard" eq "CDISC-SDTM" %then %do;
    values("SDTMIG", "&_cstTrgStandardVersion", "IG", "", 1, "Final", "")
    values("CDISC/NCI", "2014-06-27", "CT", "SDTM", 2, "Final", "")
    values("CDISC/NCI", "2020-12-18", "CT", "DEFINE-XML", 3, "Final", "")
%end;
%if "&_cstTrgStandard" eq "CDISC-ADAM" %then %do;
    values("ADaMIG", "&_cstTrgStandardVersion", "IG", "", 1, "Final", "")
    values("CDISC/NCI", "2014-09-26", "CT", "ADaM", 2, "Final", "")
    values("CDISC/NCI", "2014-06-27", "CT", "SDTM", 3, "Final", "")
    values("CDISC/NCI", "2020-12-18", "CT", "DEFINE-XML", 4, "Final", "")
%end;
  ;
  quit;
run;

%**********************************************************************************;
%* Define the studyversion macro variable.                                        *;
%* This will become the MetaDataVersion/@OID attribute                            *;
%* Also define the SASRef macro variable to use for the SASRef column in the      *;
%* source_xxx data sets.                                                          *;
%**********************************************************************************;
proc sql noprint;
 select studyversion, SASRef into :studyversion, :SASRef
 from defv20.source_study;
quit;

%**********************************************************************************;
%* Migrate source tables                                                          *;
%**********************************************************************************;
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_study, _cstSrcType=study, 
  _cstTrgDS=defv21.source_study, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=work, _cstSrcDS=source_standards, _cstSrcType=standard, 
  _cstTrgDS=defv21.source_standards, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_tables, _cstSrcType=table,
  _cstTrgDS=defv21.source_tables, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_columns, _cstSrcType=column,
  _cstTrgDS=defv21.source_columns, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_values, _cstSrcType=value,
  _cstTrgDS=defv21.source_values, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_codelists, _cstSrcType=codelist,
  _cstTrgDS=defv21.source_codelists, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
  
%cstutilmigrate_define20_21(
  _cstSrcLib=defv20, _cstSrcDS=source_documents, _cstSrcType=document,
  _cstTrgDS=defv21.source_documents, _cstStudyVersion=&studyversion, 
  _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);

%if ("&_cstTrgStandard"="CDISC-ADAM") %then %do;
  %cstutilmigrate_define20_21(
    _cstSrcLib=defv20, _cstSrcDS=source_analysisresults, _cstSrcType=analysisresult,
    _cstTrgDS=defv21.source_analysisresults, _cstStudyVersion=&studyversion, 
    _cstTrgStandard=&_cstTrgStandard, _cstTrgStandardVersion=&_cstTrgStandardVersion);
%end;

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

%* Clean-up;
proc catalog cat=work.formats et=formatc;
  delete _cstorg;
quit;

proc datasets lib=work nolist;
  delete source_standards / memtype=data;
quit;
