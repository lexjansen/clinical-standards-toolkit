%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* cstutilcomparemetasasdefine21                                                  *;
%*                                                                                *;
%* Compares XPT/SAS data set metadata with the SAS representation of Define-XML.  *;
%*                                                                                *;
%* The macro compares XPT/SAS data set metadata with the metadata in the SAS of   *;
%* representation CRT-DDS v1.0 or Define-XML 2.0.                                 *;
%*                                                                                *;
%* The results of the comparison will be presented in a SAS data set with the     *;
%* following columns:                                                             *;
%*                                                                                *;
%*   StandardName       - Standard Name                                           *;
%*   StandardVersion    - Standard Version                                        *;
%*   MetadataLib        - Metadata Library                                        *;
%*   DataLib            - DataLibrary                                             *;
%*   XPTFolder          - XPT Folder                                              *;
%*   table              - Table                                                   *;
%*   column             - Column                                                  *;
%*   issue              - Issue                                                   *;
%*   define_value       - Define Value                                            *;
%*   data_value         - SAS Value                                               *;
%*   Comment            - Comment                                                 *;
%*                                                                                *;
%* The ISSUE column summarizes the issue with a short keyword:                    *;
%*                                                                                *;
%*   DSLABEL        - The data set label does not match the data set description  *;
%*                    in the Define-XML metadata                                  *;
%*   LABEL          - The variable label does not match the variable description  *;
%*                    in the Define-XML metadata                                  *;
%*   DEFINE_COLUMN  - The Define-XML metadata defines a variable that is not      *;
%*                    in the data set                                             *;
%*   DATA_COLUMN    - There is a data set column that does not have a             *;
%*                    definition in the Define-XML metadata                       *;
%*   LENGTH         - There are inconsistencies between the length of the SAS     *;
%*                    variable and the length as defined in the Define-XML        *;
%*                    metadata. This check will only be performed for SAS         *;
%*                    character variables, since the definition of length of      *;
%*                    numerical variables is not compatible between SAS and       *;
%*                    Define-XML.                                                 *;
%*   TYPE           - There are inconsistencies between the type of the SAS       *;
%*                    variable and the DataType as defined in the Define-XML      *;
%*                    metadata.                                                   *;
%*                                                                                *;
%* Notes and Assumptions:                                                         *;
%*  (1) The SAS representation of Define-XML represents a valid CRT-DDS 1.0 or    *;
%*      Define-XML 2.0 file.                                                      *;
%*  (2) Any librefs referenced in macro parameters must be pre-allocated.         *;
%*  (3) Either _cstSourceDataLibrary or _cstSourceXPTFolder must be specified.    *;
%*  (4) The _cstSourceMetadataLibrary parameter points to the library with        *;
%*      the SAS representation of CRT-DDS v1.0 or Define-XML v2.0.                *;
%*      The following data sets are expected to exist in this library:            *;
%*                                                                                *;
%*        definedocument                                                          *;
%*        study                                                                   *;
%*        metadataversion                                                         *;
%*        itemgroupdefs                                                           *;
%*        itemgroupdefitemrefs (CRT-DDS 1.0)                                      *;
%*        itemgroupitemrefs (Define-XML 2.0)                                      *;
%*        itemdefs                                                                *;
%*        translatedtext (Define-XML 2.0)                                         *;
%*                                                                                *;
%*                                                                                *;
%* @param _cstSourceDataLibrary - conditional - The libref of that points to the  *;
%*            source data library with the SAS data sets.                         *;
%* @param _cstSourceXPTFolder - conditional - The folder where the SAS Version 5  *;
%*            XPORT (XPT) files are located.                                      *;
%* @param _cstSourceMetadataLibrary - required - The libref of the source         *;
%*            metadata folder/library.                                            *;
%* @param _cstRptDS - required - The data set in which to save the detailed       *;
%*            results.                                                            *;
%*            Default: work._cstCompareMetadata.                                  *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2022-08-31 Added support for Define-XML v2.1                          *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure external                                                             *;

%macro cstutilcomparemetasasdefine21(
  _cstSourceDataLibrary=,
  _cstSourceXPTFolder=,
  _cstSourceMetadataLibrary=,
  _cstRptDS=work._cstCompareMetadata,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des='CST: Compare DS metadata with define.xml';

  %local 
    _cstSrcMacro
    _cstRandom
    _cstItemGroupItemRef
    _cstDataLibrary
    _cstMetadataVersions
    _cstDefineVersion
    _cstDataCleanup
    ;

  %let _cstSrcMacro=&SYSMACRONAME;
  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  %let _cstDataCleanup=0;
  %let _cstDefineVersion=;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then
  %do;
    %* We are not able to communicate other than to the LOG;
    %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG can not be missing.;
    %goto exit_macro;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;

  %*************************************************;
  %*  Check for existence of _cstDebug             *;
  %*************************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;

  %************************;
  %* Parameter checking   *;
  %************************;

  %* _cstSourceDataLibrary and _cstSourceXPTFolder --------------------------*;
  %if %sysevalf(%superq(_cstSourceDataLibrary)=, boolean) and
      %sysevalf(%superq(_cstSourceXPTFolder)=, boolean) %then
  %do;
    %* Rule: Either _cstSourceDataLibrary or _cstSourceXPTFolder must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Either _cstSourceDataLibrary or _cstSourceXPTFolder must be specified.;
    %goto exit_error;
  %end;

  %if ((not %sysevalf(%superq(_cstSourceDataLibrary)=, boolean)) and
       (not %sysevalf(%superq(_cstSourceXPTFolder)=, boolean))) %then
  %do;
    %* Rule: _cstSourceDataLibrary and _cstSourceXPTFolder must not be specified both *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstSourceDataLibrary and _cstSourceXPTFolder must not be specified both.;
    %goto exit_error;
  %end;

  %if not %sysevalf(%superq(_cstSourceDataLibrary)=, boolean) %then
  %do;
    %if %sysfunc(libref(&_cstSourceDataLibrary)) %then
    %do;
      %* Rule: If _cstSourceDataLibrary is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The libref _cstSourceDataLibrary=&_cstSourceDataLibrary has not been pre-allocated.;
      %goto exit_error;
    %end;
  %end;

  %if not %sysevalf(%superq(_cstSourceXPTFolder)=, boolean) %then
  %do;
    %if %sysfunc(filename(_cstDir,&_cstSourceXPTFolder)) ne 0
      %then %put %sysfunc(sysmsg());
    %if %sysfunc(fexist(&_cstDir)) ne 1 %then
    %do;
      %* Rule: If _cstSourceXPTFolder is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The folder _cstSourceXPTFolder=&_cstSourceXPTFolder does not exist.;
      %goto exit_error;
    %end;
  %end;

  %* _cstSourceMetadataLibrary   ----------------------------------------------*;
  %if %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) %then
  %do;
    %* Rule: _cstSourceMetadataLibrary must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstSourceMetadataLibrary must be specified.;
    %goto exit_error;
  %end;

  %if %sysfunc(libref(&_cstSourceMetadataLibrary)) %then
  %do;
    %* Rule: If _cstSourceMetadataLibrary is specified, it must exist  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=The libref _cstSourceMetadataLibrary=&_cstSourceMetadataLibrary has not been pre-allocated.;
    %goto exit_error;
  %end;

  %* Rule: _cstSourceMetadataLibrary exists, so certain data sets must exist  *;
  %let _cstExpSrcTables=definedocument study metadataversion itemgroupdefs itemdefs;
  %let _cstMissing=;
  %do _cstCounter=1 %to %sysfunc(countw(&_cstExpSrcTables, %str( )));
    %let _cstTable=%scan(&_cstExpSrcTables, &_cstCounter);
    %if not %sysfunc(exist(&_cstSourceMetadataLibrary..&_cstTable)) %then
      %let _cstMissing = &_cstMissing &_cstTable;
  %end;

  %if %length(&_cstMissing) gt 0
    %then 
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Expected source metadata data set(s) not existing in library &_cstSourceMetadataLibrary: &_cstMissing;
      %goto exit_error;
    %end;

  %* Check other data sets   --------------------------------------------------*;
  %if (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))) and
      (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupitemrefs))) %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Expected source data set(s) not existing in library &_cstSourceMetadataLibrary: itemgroupdefitemrefs or itemgroupitemrefs;
    %goto exit_error;
  %end;
  %if (%sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupitemrefs))) and
      (not %sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext))) %then 
  %do;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Expected source data set not existing in library &_cstSourceMetadataLibrary: translatedtext;
    %goto exit_error;
  %end;

  %* Get the Define-XML metadataversions  ----------------------------------------------*;
  proc sql noprint;
   select distinct count(*) into :_cstMetadataVersions
   from &_cstSourceMetadataLibrary..metadataversion
   ;
  quit;
  %let _cstMetadataVersions=&_cstMetadataVersions;
  %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] _cstMetadataVersions = &_cstMetadataVersions;
  %if %eval(&_cstMetadataVersions) ne 1 %then
  %do;
    %* Rule: Exactly one MetadataVersion expected *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Exactly one MetadataVersion expected: &_cstMetadataVersions.;
    %goto exit_error;
  %end;

  %* Get the Define-XML version  ----------------------------------------------*;
  %let _cstDefineVersion=;
  proc sql noprint;
    select scan(DefineVersion, 1, ".") into :_cstDefineVersion
    from &_cstSourceMetadataLibrary..metadataversion
    ;
  quit;

  %let _cstDefineVersion=&_cstDefineVersion;
  %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] _cstDefineVersion = &_cstDefineVersion;
  
  %if %sysevalf(%superq(_cstDefineVersion)=, boolean) %then
  %do;
    %* Rule: _cstDefineVersion=1 or _cstDefineVersion=2 is expected  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=metadataversion.DefineVersion can not be missing.;
    %goto exit_error;
  %end;

  %if not (%eval(&_cstDefineVersion)=1 or %eval(&_cstDefineVersion)=2) %then
  %do;
    %* Rule: _cstDefineVersion=1 or _cstDefineVersion=2 is expected  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=metadataversion.DefineVersion=1.* or metadataversion.DefineVersion=2.* is expected.;
    %goto exit_error;
  %end;

  %* _cstRptDS   -------------------------------------------------------------*;
  %if %sysevalf(%superq(_cstRptDS)=, boolean) %then
  %do;
    %* Rule: _cstRptDS must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstRptDS must be specified.;
    %goto exit_error;
  %end;

  %************************;
  %* Begin macro logic    *;
  %************************;

  %****************************************************************************;
  %* This section gets the metadata from the SAS representation of Define-XML *;
  %****************************************************************************;

  %if %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))
    %then %let _cstItemGroupItemRef = itemgroupdefitemrefs;
    %else %let _cstItemGroupItemRef = itemgroupitemrefs;

  *** Combine Metadata;
  proc sql;
    create table work._cst_metadata_&_cstRandom
    as select
      case
        when not missing (igd.SASDatasetName) 
        then igd.SASDatasetName
        else igd.Name
      end as Table,
      case
        when not missing (itd.SASFieldName) 
        then itd.SASFieldName
        else itd.Name
      end as Column,
      %if %eval(&_cstDefineVersion)=1 %then
      %do;
        igd.Label      as ItemGroupLabel,
        itd.Label      as ItemLabel,
      %end;
      %if %eval(&_cstDefineVersion)=2 %then
      %do;
        %if (%sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext))) and
            (%eval(&_cstDefineVersion)=2) %then
        %do;
          tt_igd.TranslatedText as ItemGroupLabel,
          tt_id.TranslatedText as ItemLabel,
        %end;
      %end;      
      igd.IsReferenceData,
      igd.HasNoData as IgdHasNoData,
      stnd.Name,
      stnd.Version,
      igdir.OrderNumber,
      igdir.HasNoData,
      itd.DataType as ItemDataType,
      itd.Length as ItemLength,
      itd.DisplayFormat,
      itd.SignificantDigits

    from &_cstSourceMetadataLibrary..metadataversion mdv
       inner join &_cstSourceMetadataLibrary..itemgroupdefs igd
     on igd.FK_MetaDataVersion = mdv.OID
       inner join &_cstSourceMetadataLibrary..&_cstItemGroupItemRef igdir
     on igdir.FK_ItemGroupDefs = igd.OID
       inner join &_cstSourceMetadataLibrary..itemdefs itd
     on (itd.OID = igdir.ItemOID and itd.FK_MetaDataVersion = mdv.OID)
       left join &_cstSourceMetadataLibrary..standards stnd
     on (stnd.OID = igd.StandardOID and stnd.FK_MetaDataVersion = mdv.OID)

     %if %eval(&_cstDefineVersion)=2 %then
     %do;
       %if %sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext)) %then 
       %do;
           left join &_cstSourceMetadataLibrary..translatedtext tt_igd
         on (igd.OID = tt_igd.parentKey and upcase(tt_igd.parent)="ITEMGROUPDEFS")  
           left join &_cstSourceMetadataLibrary..translatedtext tt_id
         on (itd.OID = tt_id.parentKey and upcase(tt_id.parent)="ITEMDEFS")  
       %end;     
     %end;
     order by Table, Column
     ;
  quit;

  %****************************************************************************;
  %* This section gets the metadata from the SAS Data sets or the XPT files   *;
  %****************************************************************************;

  %if (not %sysevalf(%superq(_cstSourceXPTFolder)=, boolean)) %then
  %do;
    %* We need to unpack XPT files *;

    %let rc=%sysfunc(dcreate(data&_cstRandom, %sysfunc(pathname(work))));
    libname dt&_cstRandom "%sysfunc(pathname(work))/data&_cstRandom";
    %let _cstDataCleanup=1;
    %let _cstDataLibrary=dt&_cstRandom;

    %cstutilxptread(
      _cstSourceFolder=&_cstSourceXPTFolder, 
      _cstOutputLibrary=dt&_cstRandom,
      _cstExtension=xpt
      );
    
  %end;
  %else %do;
    %let _cstDataLibrary=&_cstSourceDataLibrary;
  %end;  


  %* A single source data library serves as the input to this process.  *;
  proc contents data=&_cstDataLibrary.._all_ 
                out=work.contents&_cstRandom
                (keep=memname memlabel name type length label varnum formatl formatd varnum
                 rename=(memname=table name=column))  noprint;
  run;
  proc sort data=work.contents&_cstRandom;
    by table column;
  run;  

  data work.define_data_&_cstRandom(drop=type);
      attrib 
        SASDataType length=$4 label="SAS DataType"
        ;
    merge work._cst_metadata_&_cstRandom(in=indef)
          work.contents&_cstRandom(in=indata);
    by table column;
    source=indef + (2*indata);
    if type=1 then SASDataType="Num";
    if type=2 then SASDataType="Char";
  run;

       
  data work.define_data_&_cstRandom(keep=StandardName StandardVersion MetadataLib DataLib XPTFolder
                                         table column IgdHasNoData HasNoData issue define_value data_value comment);
    attrib 
      StandardName length=$20 label="Standard Name"
      StandardVersion length=$20 label="Standard Version"
      MetadataLib length=$8 label="Metadata Library"
      DataLib length=$8 label="DataLibrary"
      XPTFolder length=$2000 label="XPT Folder"

      table label="Table"
      column label="Column"
      issue length=$20 label="Issue"
      define_value length=$200 label="Define Value"
      data_value length=$200 label="SAS Value"
      Comment length=$200 label="Comment"
      ;
    set work.define_data_&_cstRandom;
    by table column;

    StandardName=Name;
    StandardVersion=Version;
    comment="";
    
    if not missing("&_cstSourceMetadataLibrary") then MetadataLib="&_cstSourceMetadataLibrary";    
    if not missing("&_cstSourceDataLibrary") then DataLib="&_cstSourceDataLibrary";  
    if not missing("&_cstSourceXPTFolder") then XPTFolder="%nrbquote(&_cstSourceXPTFolder)";  
    
    if (source=1) and (IgdHasNoData ne "Yes") and (HasNoData ne "Yes") then do;
      define_value=column;
      data_value="";
      issue="DEFINE_COLUMN";
      output;
    end;

    if source=2 then do;
      define_value="";
      data_value=column;
      issue="DATA_COLUMN";
      output;
    end;

    if (source=3) and (HasNoData ne "Yes") then do;
      if ItemLabel ne label then do;
        define_value=ItemLabel;
        data_value=label;
        issue="LABEL";
        output;
      end;

      if (ItemLength ne length) and 
         (
          (ItemDataType in ('date' 'time' 'datetime' 'partialDate' 'partialTime' 'partialDatetime' 'incompleteDatetime' 'durationDatetime') 
           and (not missing(ItemLength)) and SASDataType="Char") or
          ((ItemDataType in ('string' 'text')) and (SASDataType="Char")) 
         ) 
         then do;
        define_value=kleft(put(ItemLength, best.));
        data_value=kleft(put(length, best.));
        issue="LENGTH";
        comment=cats("SAS DataType=", SASDataType, ", Define DataType=", ItemDataType); 
        output;
      end;

      if SASDataType="Num" and (not (ItemDataType in ('float' 'integer'))) then do;
        define_value=ItemDataType;
        data_value=SASDataType;
        issue="TYPE";
        output;
      end;

      if SASDataType="Char" and (ItemDataType in ('float' 'integer')) then do;
        define_value=ItemDataType;
        data_value=SASDataType;
        issue="TYPE";
        output;
      end;

    end;

    if first.table then do;
      if (ItemGroupLabel ne memlabel) and (IgdHasNoData ne "Yes") then do;
        define_value=ItemGroupLabel;
        data_value=memlabel;
        issue="DSLABEL";
        column="";
        output;
      end;
    end;

  run;

  %if %cstutilnobs(_cstDatasetName=work.define_data_&_cstRandom) eq 0 %then %do;
    %* No issues;

    data &_cstRptDS(keep=StandardName StandardVersion MetadataLib DataLib XPTFolder
                         table column issue define_value data_value comment);
      attrib 
        StandardName length=$20 label="Standard Name"
        StandardVersion length=$20 label="Standard Version"
        MetadataLib length=$8 label="Metadata Library"
        DataLib length=$8 label="DataLibrary"
        XPTFolder length=$2000 label="XPT Folder"
  
        table length=$128 label="Table"
        column length=$128 label="Column"
        issue length=$20 label="Issue"
        define_value length=$200 label="Define Value"
        data_value length=$200 label="SAS Value"
        Comment length=$200 label="Comment"
        ;

      call missing (of _all_);
      StandardName="";
      StandardVersion="";

      if not missing("&_cstSourceMetadataLibrary") then MetadataLib="&_cstSourceMetadataLibrary";    
      if not missing("&_cstSourceDataLibrary") then DataLib="&_cstSourceDataLibrary";  
      if not missing("&_cstSourceXPTFolder") then XPTFolder="%nrbquote(&_cstSourceXPTFolder)";  
      
      Comment="No issues";
      output;
    run;
    
  %end; 
  %else %do;
    data &_cstRptDS;
      set work.define_data_&_cstRandom;
  %end;   

  %**************************;
  %*  Cleanup               *;
  %**************************;

  %cstutil_deleteDataSet(_cstDataSetName=work.define_data_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work._cst_metadata_&_cstRandom);
  %cstutil_deleteDataSet(_cstDataSetName=work.contents&_cstRandom);

  %if &_cstDataCleanup %then %do;
  
    proc datasets lib=dt&_cstRandom kill memtype=data nolist;
    run; quit;
    filename dt&_cstRandom "%sysfunc(pathname(dt&_cstRandom))";
    %let rc=%sysfunc(fdelete(dt&_cstRandom));
    libname dt&_cstRandom;

  %end;  

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
%exit_error:

  %if %length(&&&_cstReturnMsg)>0 %then
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&_cstSrcMacro] &&&_cstReturnMsg;

%exit_macro:

%mend cstutilcomparemetasasdefine21;
