**********************************************************************************;
* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
* SPDX-License-Identifier: Apache-2.0                                            *;
* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
* SPDX-License-Identifier: Apache-2.0                                            *;
*                                                                                *;
* create_sourcemetadata_fromsaslib.sas                                           *;
*                                                                                *;
* This sample driver module performs the setup steps to derive source metadata   *;
* files from a library of SAS data sets for a CDISC study.                       *;
*                                                                                *;
* The following source metadata files are used by Clinical Standards Toolkit to  *;
* support CDISC validation and derivation of define.xml files:                   *;
*          source_study                                                          *;
*          source_tables                                                         *;
*          source_standards                                                      *;
*          source_columns                                                        *;
*          source_codelists                                                      *;
*          source_documents                                                      *;
*          source_values                                                         *;
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
%let _cstStandardVersion=2.1;   * <----- User sets the Define-XML version *;

%let _cstTrgStandard=CDISC-SDTM;   * <----- User sets to standard of the source study *;
%*let _cstTrgStandard=CDISC-ADAM;   * <----- User sets to standard of the source study *;
%if %SYMEXIST(sysparm) and %sysevalf(%superq(sysparm)=, boolean)=0 %then %do;
  * <----- Standard to use can be set from the command line *;
  %let _cstTrgStandard=&sysparm;
%end;



%if ("&_cstTrgStandard"="CDISC-SDTM") %then %do;
  %let _cstTrgStandardVersion=3.2;
  %* Subfolder with the SAS Source Metadata data sets;
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;
  %let _cstStudyCatalog=formats;
  %let _cstUseARM=0;
%end;

%if ("&_cstTrgStandard"="CDISC-ADAM") %then %do;
  %let _cstTrgStandardVersion=2.1;
  %* Subfolder with the SAS Source Metadata data sets;
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;
  %let _cstStudyCatalog=cterms;
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
  call symput('studyRootPath',cats("&_cstSRoot","/&_cstStandardSubFolder.-&_cstVersion"));
  call symput('studyOutputPath',cats("&_cstSRoot","/cdisc-definexml-&_cstStandardVersion.-&_cstVersion"));
run;
%let workPath=%sysfunc(pathname(work));

**********************************************;
*  Define Study Metadata - only 1 record     *;
**********************************************;
%cst_createdsfromtemplate(
  _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=&_cstStandardVersion,
  _cstType=studymetadata,_cstSubType=study,_cstOutputDS=work.studymetadata
  );
proc sql;
  insert into work.studymetadata(fileoid, studyoid, originator, context,
                                 studyname, studydescription, protocolname, comment,
                                 metadataversionname, metadataversiondescription,
                                 studyversion, standard, standardversion)
%if "&_cstTrgStandard"="CDISC-SDTM" %then %do;
    values("www.cdisc.org/StudyCDISC01_1/1/Define-XML_2.1.0", "STDY.www.cdisc.org.CDISC01_1", "", "Submission",
           "CDISC01", "CDISC Test Study", "CDISC01", "",
           "Study CDISC01_1, Data Definitions V-1", "Data Definitions for CDISC01-01 SDTM datasets",
           "MDV.CDISC01.SDTMIG.3.2.SDTM.1.4", "&_cstTrgStandard", "&_cstTrgStandardVersion")
%end;
%if "&_cstTrgStandard"="CDISC-ADAM" %then %do;
    values("www.cdisc.org/StudyCDISC01_1/1/Define-XML_2.1.0", "STDY.www.cdisc.org.CDISC01_1", "", "Submission",
           "CDISC01", "CDISC Test Study", "CDISC01", "",
           "Study CDISC01_1, Data Definitions V-1", "Data Definitions for CDISC01-01 ADaM datasets",
           "MDV.CDISC01.ADaMIG.1.2", "&_cstTrgStandard", "&_cstTrgStandardVersion")
%end;
  ;
  quit;
run;

********************************************************;
*  Define Standards Metadata                           *;
*  Since the SAS datasets have no version information, *;
*  only specify one record per type (IG or CT)         *;
********************************************************;
%cst_createdsfromtemplate(
  _cstStandard=CDISC-DEFINE-XML,_cstStandardVersion=&_cstStandardVersion,
  _cstType=studymetadata,_cstSubType=standard,_cstOutputDS=work.standardsmetadata
  );

proc sql;
  insert into work.standardsmetadata(cdiscstandard, cdiscstandardversion, type, publishingset, order, status, comment)
%if "&_cstTrgStandard"="CDISC-SDTM" %then %do;
    values("SDTMIG", "&_cstTrgStandardVersion", "IG", "", 1, "Final", "")
    values("CDISC/NCI", "2014-06-27", "CT", "SDTM", 2, "Final", "")
    values("CDISC/NCI", "2020-12-18", "CT", "DEFINE-XML", 3, "Final", "")
%end;
%if "&_cstTrgStandard"="CDISC-ADAM" %then %do;
    values("ADaMIG", "&_cstTrgStandardVersion", "IG", "", 1, "Final", "")
    values("CDISC/NCI", "2014-09-26", "CT", "ADaM", 2, "Final", "")
    values("CDISC/NCI", "2014-06-27", "CT", "SDTM", 3, "Final", "")
    values("CDISC/NCI", "2020-12-18", "CT", "DEFINE-XML", 4, "Final", "")
%end;
  ;
  quit;
run;

*********************************************************************;
* Set CDISC NCI Controlled Terminology version for this process.    *;
*********************************************************************;
%cst_getstandardsubtypes(_cstStandard=CDISC-TERMINOLOGY,_cstOutputDS=work._cstStdSubTypes);
data _null_;
  set work._cstStdSubTypes (where=(standardversion="&_cstTrgStandard" and isstandarddefault='Y'));
  %* User can override CT version of interest by specifying a different where clause:            *;
  %* Example: (where=(standardversion="&_cstTrgStandard" and standardsubtypeversion='201406'))   *;
  call symputx('_cstCTPath',path);
  call symputx('_cstCTMemname',memname);
run;

proc datasets lib=work nolist;
  delete _cstStdSubTypes;
quit;
run;

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
  values ("CST-FRAMEWORK"    "1.2"                      "messages"          ""               "messages" "libref"  "input"  "dataset"  "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "autocall"          ""               "defauto"  "fileref" "input"  "folder"   "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "messages"          ""               "defmsg"   "libref"  "input"  "dataset"  "N"  "" ""                                   2 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "properties"        "initialize"     "inprop"   "fileref" "input"  "file"     "N"  "" ""                                   1 ""                                  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "results"           "results"        "results"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/results"           . "srcmeta_saslib_results.sas7bdat"   "")

  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "classmetadata"     "column"         "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                                  "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "classmetadata"     "table"          "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                                  "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "referencemetadata" "column"         "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                                  "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "referencemetadata" "table"          "refmeta"  "libref"  "input"  "dataset"  "N"  "" ""                                   . ""                                  "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "sourcedata"        ""               "srcdata"  "libref"  "input"  "folder"   "N"  "" "&_cstSRoot/&_cstStandardSubFolder-1.7/sascstdemodata/data"            . ""                           "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "sourcemetadata"    "study"          "srcmeta"  "libref"  "input"  "dataset"  "Y"  "" "&workPath"                                                            . "studymetadata.sas7bdat"     "")
  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "sourcemetadata"    "standard"       "srcmeta"  "libref"  "input"  "dataset"  "Y"  "" "&workPath"                                                            . "standardsmetadata.sas7bdat" "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "study"          "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_study.sas7bdat"      "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "standard"       "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_standards.sas7bdat"  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "table"          "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_tables.sas7bdat"     "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "column"         "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_columns.sas7bdat"    "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "codelist"       "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_codelists.sas7bdat"  "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "value"          "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_values.sas7bdat"     "")
  values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "document"       "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_documents.sas7bdat"  "")
  %if &_cstUseARM %then %do;
    values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "analysisresult" "trgmeta"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder"  . "source_analysisresults.sas7bdat"    "")
  %end;

  values ("&_cstTrgStandard" "&_cstTrgStandardVersion"  "fmtsearch"         ""               "cstfmt"   "libref"  "input"  "catalog"  "N"  "" "&studyRootPath/sascstdemodata/terminology/formats"                    1  "&_cstStudyCatalog"                   "")
  values ("CDISC-TERMINOLOGY" "NCI_THESAURUS"           "fmtsearch"         ""               "ncifmt"   "libref"  "input"  "catalog"  "N"  "" "&_cstCTPath"               2  "&_cstCTMemname"        "")
  values ("CDISC-TERMINOLOGY" "NCI_THESAURUS"           "referencecterm"    ""               "ncifmt"   "libref"  "input"  "dataset"  "N"  "" "&_cstCTPath"               1  "&_cstCTMemname"        "")

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

*******************************************************************************;
* Run the standard-specific Define-XML macros.                                *;
*******************************************************************************;

%define_createsrcmetafromsaslib(
  _cstTrgStandard=&_cstTrgStandard,
  _cstTrgStandardVersion=&_cstTrgStandardVersion,
  _cstLang=en,
  _cstUseRefLib=Y,
  _cstKeepAllCodeLists=N
);

/*
%* Study formats in CST 1.7;
libname studyfmt "&studyRootPath/sascstdemodata/terminology/formats";

%* CDISC-NCI Terminology to be used in CST 1.7;
libname ncifmt "&_cstCTPath";

%* Formats to be used for SDTM;
options fmtsearch = (studyfmt.formats ncisdtm.&_cstCTMemname);

libname srcdata "&_cstSRoot/&_cstStandardSubFolder-&_cstVersion/sascstdemodata/data";
libname trgmeta "&studyOutputPath/derivedstudymetadata_saslib/&_cstStandardSubFolder";
libname refmeta "&_cstGRoot/standards/&_cstStandardSubFolder.-&_cstVersion/metadata";

%define_createsrcmetafromsaslib(
  _cstSASDataLib=srcdata,
  _cstStudyMetadata=work.studymetadata,
  _cstStandardMetadata=work.standardsmetadata,
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
  _cstUseRefLib=Y,
  _cstRefTableDS=refmeta.reference_tables,
  _cstRefColumnDS=refmeta.reference_columns,
  _cstClassTableDS=refmeta.class_tables,
  _cstClassColumnDS=refmeta.class_columns,
  _cstKeepAllCodeLists=N,
  _cstFormatCatalogs=cstfmt.formats ncifmt.cterms,
  _cstNCICTerms=ncifmt.cterms,
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

%* Clean-up;
proc datasets lib=work nolist;
  delete studymetadata standardsmetadata / memtype=data;
quit;
