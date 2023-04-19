%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* defineutil_splitwhereclause                                                    *;
%*                                                                                *;
%* Splits multiple WHERE clause conditions into one condition per record.         *;
%*                                                                                *;
%* @macvar &_cstReturn Task error status                                          *;
%* @macvar &_cstReturnMsg Message associated with _cst_rc                         *;
%* @macvar _cstDebug Turns debugging on or off for the session                    *;
%* @macvar _cstResultSeq Results: Unique invocation of the macro                  *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%*                                                                                *;
%* @param _cstDSIn - required - The input data set.                               *;
%* @param _cstDSOut - required - The output data set.                             *;
%* @param _cstOutputLibrary - required - The library to write the Define-XML data *;
%*            sets.                                                               *;
%*            Default: srcdata                                                    *;
%* @param _cstType - required - The input data set type.                          *;
%*            Used in WhereClauseRangeChecks/@OID                                 *;
%*      Values: VAL | ARM                                                         *;
%*                                                                                *;
%* @history 2023-03-12 Support "" as CheckValue                                   *;
%*                                                                                *;
%* @since 1.7.1                                                                   *;
%* @exposure internal                                                             *;

%macro defineutil_splitwhereclause(
  _cstDSIn=, 
  _cstDSOut=, 
  _cstOutputLibrary=srcdata,
  _cstType=
  );
    
    %local
     _cstRandom
     _cstThisMacro
     _cstSaveOptions
     _cstMessageColumns
     _cstColumn
     _cstCounter
     ;

    %let _cstThisMacro=&sysmacroname;

    %cstutil_getRandomNumber(_cstVarname=_cstRandom);
    
    data &_cstDSOut(drop=i whereclause2);
      length single_condition $1000 whereclause2 $1000;
      set &_cstDSIn;

      %* Replace multiple blanks with a single blank;
      whereclause2 = compbl(whereclause);

      %* Remove unnecessary blanks;
      whereclause2 = tranwrd(whereclause2, '", "', '","');
      whereclause2 = tranwrd(whereclause2, '" ,"', '","');

      %* Fix incorrect case of AND - be careful as AND can be part of the text;
      if kindex(whereclause2, '" and ') then whereclause2 = tranwrd(whereclause2, '" and ', '" AND ');
      if kindex(whereclause2, '") and ') then whereclause2 = tranwrd(whereclause2, '") and ', '") AND ');

      %* Try fixing missing parentheses;
      if kindex(whereclause2, '" AND ') and kindex(whereclause2, '" AND (')=0 
       then do;
         whereclause2 = tranwrd(whereclause2, '" AND ', '" AND (');
         whereclause2 = strip(whereclause2)||")"; 
       end;
    
      if kindex(whereclause2, '") AND ') and kindex(whereclause2, '") AND (')=0 
       then do;
         whereclause2 = tranwrd(whereclause2, '") AND ', '") AND (');
         whereclause2 = strip(whereclause2)||")"; 
       end;
    
      if index(whereclause2, '" AND ') 
       then do;
         whereclause2 = tranwrd(whereclause2, '" AND ', '") AND ');
         whereclause2 = "("||strip(whereclause2); 
       end;


      whereclause2 = tranwrd(whereclause2, ") AND (", ")|(");

      i = 1;
      single_condition = kscan(whereclause2, i, '|');
      output;
      i = i + 1;
      single_condition = kscan(whereclause2, i, '|');
      do while (not missing(single_condition));
        output;
        i = i + 1;
        single_condition = kscan(whereclause2, i, '|');
      end;
    run;

    data &_cstDSOut;
      length FK_WhereClauseRangeChecks $20;
      set &_cstDSOut;
      FK_WhereClauseRangeChecks="WCRC."||"&_cstType.."||strip(put(_N_, z5.));
    run;

    %if %upcase(&_cstType) eq VAL 
      %then %let _cstMessageColumns=Column;
      %else %let _cstMessageColumns=DisplayIdentifier ResultIdentifier;                             

    %* split into item, operator and checkvalues;
    data &_cstDSOut(keep=WhereClauseOID ItemOID Comparator CheckValue FK_WhereClauseRangeChecks table &_cstMessageColumns whereclause);
      length ItemOID $&_cstOIDLength
             Comparator $%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..WhereClauseRangeChecks, _cstVarName=Comparator, _cstAttribute=VARLEN)
             CheckValue $%cstutilgetattribute(_cstDataSetName=&_cstOutputLibrary..WhereClauseRangeCheckValues, _cstVarName=checkvalue, _cstAttribute=VARLEN)
             CheckValueList $1000
             ;
      set &_cstDSOut;

      %* remove outer round brackets fromn single condition;
      if ksubstr(single_condition, 1, 1)="(" and ksubstr(single_condition, length(single_condition), 1)=")"
        then single_condition=ksubstr(single_condition, 2, length(single_condition)-2);

      ItemOID = kscan(single_condition, 1, ' ');
      ItemOID = "IT."||kstrip(table)||"."||kstrip(ItemOID);
      Comparator = kupcase(kscan(single_condition, 2, ' '));
      CheckValueList = kstrip(ksubstr(single_condition, kindex(upcase(single_condition), kstrip(Comparator))+klength(Comparator)));
      if ksubstr(CheckValueList, 1, 1)="(" and ksubstr(CheckValueList, length(CheckValueList), 1)=")"
        then CheckValueList=ksubstr(CheckValueList, 2, length(CheckValueList)-2);

      %* split checkvaluelist;
      select(upcase(Comparator));
        when('EQ', 'NE', 'LT', 'LE', 'GT', 'GE') do; CheckValue = CheckValueList; output; end;
        when('IN', 'NOTIN') do;
          %* Change delimeter to |, so that a "," in the data gives no problems when scanning;
          CheckValueList = tranwrd(CheckValueList, '","', '"|"');
          CheckValueList = tranwrd(CheckValueList, '" ,"', '"|"');
          CheckValueList = tranwrd(CheckValueList, '", "', '"|"');
          CheckValueList = tranwrd(CheckValueList, '" , "', '"|"');
          i = 1;
          CheckValue = kscan(CheckValueList, i, '|');
          output;
          i = i + 1;
          CheckValue = kscan(CheckValueList, i, '|');
          do while (not missing(CheckValue));
            output;
            i = i + 1;
            CheckValue = kscan(CheckValueList, i, '|');
          end;
        end;
        otherwise put "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname]: Unsupported " Comparator=;
      end;
    run;

    %if %sysfunc(exist(&_cstOutputLibrary..ItemDefs)) %then %do;
    
      proc sql;
        create table work._cst_wcc_&_cstRandom as
        select dso.*,
        id.Name
        from &_cstDSOut dso
        left join &_cstOutputLibrary..ItemDefs id
        on id.OID = dso.ItemOID
        ;
      run;
      
      %cst_createdsfromtemplate(_cstStandard=CST-FRAMEWORK,_cstType=results,_cstSubType=results,_cstOutputDS=work._cstIssues_&_cstRandom);

      %* The message variable might get very long, but it is ok if it gets truncated;
      %let _cstSaveOptions = %sysfunc(getoption(varlenchk, keyword));
      options varlenchk=nowarn;

      data work._cstIssues_&_cstRandom(keep=resultid checkid resultseq seqno srcdata message resultseverity resultflag _cst_rc actual keyvalues resultdetails);
        set work._cstIssues_&_cstRandom
           work._cst_wcc_&_cstRandom(where=(missing(name)) keep=table &_cstMessageColumns whereclause Name Comparator CheckValue);
        resultid="DEF0098";
        srcdata="&_cstThisMacro";
        resultseq=1;
        seqno=_n_;
        resultseverity="Warning";
        resultflag=1;
        _cst_rc=0;
        message="Column in WhereClause not found:";
        message=catt(message, " Table=", table);
        %do _cstCounter=1 %to %sysfunc(countw(&_cstMessageColumns));
          %let _cstColumn=%scan(&_cstMessageColumns, &_cstCounter);
          message=catt(message, ", &_cstColumn.=", &_cstColumn);
        %end;  
        message=catt(message, ", WhereClause=", whereclause, ", Comparator=", comparator, ", CheckValue=", checkvalue);
        putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Column in WhereClause not found: " Table= @;
        %do _cstCounter=1 %to %sysfunc(countw(&_cstMessageColumns));
          %let _cstColumn=%scan(&_cstMessageColumns, &_cstCounter);
          putlog &_cstColumn= @;
        %end;  
        putlog WhereClause= Comparator= CheckValue=;
      run;

      options &_cstSaveOptions;    

      %if %symexist(_cstResultsDS) %then
      %do;
        %if %klength(&_cstResultsDS) > 0 and %sysfunc(exist(&_cstResultsDS)) %then
        %do;
           proc append base=&_cstResultsDS data=work._cstIssues_&_cstRandom force;
           run;
        %end;
      %end;

      * Cleanup;
      %if not &_cstDebug %then %do;
         %cstutil_deleteDataSet(_cstDataSetName=work._cstIssues_&_cstRandom);
         %cstutil_deleteDataSet(_cstDataSetName=work._cst_wcc_&_cstRandom);
      %end;
      
  %end;    

    %* remove quotes;
    data &_cstDSOut(drop=table &_cstMessageColumns whereclause);
     set &_cstDSOut;
      if CheckValue='""' or  CheckValue="''" 
        then CheckValue="";
        else do;
          if ksubstr(CheckValue, 1, 1)="'" and ksubstr(CheckValue, length(CheckValue), 1)="'"
            then CheckValue=ksubstr(CheckValue, 2, length(CheckValue)-2);
          if ksubstr(CheckValue, 1, 1)='"' and ksubstr(CheckValue, length(CheckValue), 1)='"'
            then CheckValue=ksubstr(CheckValue, 2, length(CheckValue)-2);
        end;
    run;

%mend defineutil_splitwhereclause;
