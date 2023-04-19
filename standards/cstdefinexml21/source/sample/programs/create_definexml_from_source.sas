**********************************************************************************;
* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
* SPDX-License-Identifier: Apache-2.0                                            *;
* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
* SPDX-License-Identifier: Apache-2.0                                            *;
*                                                                                *;
* create_definexml_from_source.sas                                               *;
*                                                                                *;
* Sample driver program to perform a primary Toolkit action, in this case,       *;
* creating the Define-XML data sets from the CDISC standard model (SDTM, ADaM or *;
* SEND source metadata) in the WORK library, and then create a CDISC-DEFINE-XML  *;
* V2.1 define.xml file.                                                          *;
* A call to a standard-specific Define-XML macro is required later in this code. *;
*                                                                                *;
* Assumptions:                                                                   *;
*         The SASReferences file must exist, and must be identified in the       *;
*         call to cstutil_processsetup if it is not work.sasreferences.          *;
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
  %let _cstTrgStandardVersion=3.3;
  %* Subfolder with the SAS Source Metadata data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;  
  %let _cstDefineFile=define_sdtm_3.3;
  %let _cstUseARM=0;
%end;

%if ("&_cstTrgStandard"="CDISC-ADAM") %then %do;
  %let _cstTrgStandardVersion=1.1;
  %* Subfolder with the SAS Source Metadata data sets; 
  %let _cstStandardSubFolder=%lowcase(&_cstTrgStandard)-&_cstTrgStandardVersion;  
  %let _cstDefineFile=define_adam_1.1;
  %let _cstUseARM=1;
%end;



*****************************************************************************************************;
* The following code sets (at a minimum) the studyrootpath and studyoutputpath.  These are          *;
* used to make the driver programs portable across platforms and allow the code to be run with      *;
* minimal modification. These nacro variables by default point to locations within the              *;
* cstSampleLibrary, set during install but modifiable thereafter.  The cstSampleLibrary is assumed  *;
* to allow write operations by this driver module.                                                  *;
*****************************************************************************************************;

%cst_setStandardProperties(_cstStandard=CST-FRAMEWORK,_cstSubType=initialize);
%cstutil_setcstsroot;
data _null_;
  call symput('studyRootPath',cats("&_cstSRoot","/cdisc-definexml-&_cstStandardVersion.-&_cstVersion"));
  call symput('studyOutputPath',cats("&_cstSRoot","/cdisc-definexml-&_cstStandardVersion.-&_cstVersion"));
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
*        %cstutil_processsetup()                                                        *;
*****************************************************************************************;

%let _cstSetupSrc=SASREFERENCES;

%cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK, _cstType=control,_cstSubType=reference, _cstOutputDS=work.sasreferences);

proc sql;
  insert into work.sasreferences
  values ("CST-FRAMEWORK"     "1.2"                     "messages"        ""            "messages" "libref"  "input"  "dataset"  "N"  "" ""                          1  ""                         "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "messages"        ""            "crtmsg"   "libref"  "input"  "dataset"  "N"  "" ""                          2  ""                         "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "autocall"        ""            "auto1"    "fileref" "input"  "folder"   "N"  "" ""                          1  ""                         "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "control"         "reference"   "control"  "libref"  "both"   "dataset"  "Y"  "" "&workpath"                .  "sasreferences"             "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "properties"      "initialize"  "inprop"   "fileref" "input"  "file"     "N"  "" ""                          1  ""                         "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "results"         "results"     "results"  "libref"  "output" "dataset"  "Y"  "" "&studyOutputPath/results"  .  "sourcetodefinexml_results.sas7bdat"     "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "sourcedata"      ""            "srcdata"  "libref"  "output" "folder"   "Y"  "" "&studyRootPath/data/&_cstStandardSubFolder"    .  ""             "")

  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "study"       "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_study"     "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "standard"    "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_standards" "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "table"       "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_tables"    "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "column"      "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_columns"   "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "codelist"    "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_codelists" "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "value"       "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_values"    "")
  values ("&_cstStandard"  "&_cstStandardVersion" "studymetadata"   "document"    "sampdata" "libref"  "input"  "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  .  "source_documents" "")
  %if &_cstUseARM %then %do;
    values ("&_cstStandard"    "&_cstStandardVersion"     "studymetadata"     "analysisresult" "sampdata"  "libref"  "input" "dataset"  "N"  "" "&studyRootPath/sascstdemodata/&_cstStandardSubFolder/metadata"  . "source_analysisresults"    "")
  %end;
  values ("&_cstStandard"     "&_cstStandardVersion"    "externalxml"     "xml"         "extxml"   "fileref" "output" "file"     "Y"  ""  "&studyOutputPath/targetxml"            .  "&_cstDefineFile..xml"     "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "report"          "outputfile"  "html"     "fileref" "output" "file"     "Y"  ""  "&studyOutputPath/targetxml"            .  "&_cstDefineFile..html"    "")
  values ("&_cstStandard"     "&_cstStandardVersion"    "referencexml"    "stylesheet"  "xslt01"   "fileref" "input"  "file"     "Y"  ""  ""                                      .  "define2-1.xsl"            "")
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

%define_sourcetodefine(
  _cstOutLib=srcdata,
  _cstSourceStudy=sampdata.source_study,
  _cstSourceStandards=sampdata.source_standards,
  _cstSourceTables=sampdata.source_tables,
  _cstSourceColumns=sampdata.source_columns,
  _cstSourceCodeLists=sampdata.source_codelists,
  _cstSourceValues=sampdata.source_values,
  _cstSourceDocuments=sampdata.source_documents,
  %if &_cstUseARM %then %do;
    _cstSourceAnalysisResults=sampdata.source_analysisresults,
  %end;  
  _cstFullModel=N,
  _cstCheckLengths=Y,
  _cstLang=en
  );

%define_write(
  _cstCreateDisplayStyleSheet=1,
  _cstHeaderComment=%str( Produced with SAS &sysver )
  );

***************************************************************************;
* Run the cross-standard schema validation macro.                         *;
* Running cstutilxmlvalidate is not required.  The define_read macro will *;
* attempt to import an invalid define xml file. However, importing an     *;
* invalid define xml file may result in an incomplete import.             *;
*                                                                         *;
* cstutilxmlvalidate parameters (all optional):                           *;
*  _cstSASReferences:  The SASReferences data set provides the location   *:
*          of the to-be-validate XML file associated with a registered    *;
*          standard and standardversion (default:  &_cstSASRefs).         *;
*  _cstLogLevel:  Identifies the level of error reporting.                *;
*          Valid values: Info (default) Warning, Error, Fatal Error       *;
*  _cstCallingPgm:  The name of the driver module calling this macro      *;
***************************************************************************;

%cstutilxmlvalidate();

*******************************************************************************************;
* Create HTML rendition for browsers that do not allow local rendition of XSLT stylesheet *;
*******************************************************************************************;
proc xsl 
  in=extxml 
  xsl=xslt01 
  out=html; 
  parameter 'nCodeListItemDisplay'=5 'displayMethodsTable'=1 'displayCommentsTable'=0;
run; 

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
