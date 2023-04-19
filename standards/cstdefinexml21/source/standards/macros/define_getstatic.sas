%* Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.   *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%* Copyright (c) 2023, Lex Jansen.  All Rights Reserved.                          *;
%* SPDX-License-Identifier: Apache-2.0                                            *;
%*                                                                                *;
%* define_getStatic                                                               *;
%*                                                                                *;
%* Returns constant values that are used by other macros.                         *;
%*                                                                                *;
%* @param _cstName The name of the value to retrieve.                             *;
%*      Values: DEFINE_SASREF_TYPE_REFXML | DEFINE_SASREF_TYPE_EXTXML |           *;
%*        DEFINE_SASREF_TYPE_STUDYMETADATA | DEFINE_SASREF_TYPE_CLASSMETADATA |   *;
%*        DEFINE_SASREF_TYPE_REFERENCEMETADATA | DEFINE_SASREF_TYPE_SOURCEDATA |  *;
%*        DEFINE_SASREF_TYPE_SOURCEMETADATA | DEFINE_SASREF_TYPE_REFERENCECTERM | *;
%*        DEFINE_SASREF_SUBTYPE_XML | DEFINE_SASREF_SUBTYPE_STYLESHEET |          *;
%*        DEFINE_JAVA_PARAMSCLASS | DEFINE_JAVA_IMPORTCLASS |                     *;
%*        DEFINE_JAVA_EXPORTCLASS                                                 *;
%* @param _cstVar  The macro variable to populate with the value.                 *;
%*                                                                                *;
%* @history 2022-03-12 Removed the use of picklists                               *;
%*                                                                                *;
%* @since 1.6                                                                     *;
%* @exposure internal                                                             *;

%macro define_getStatic(
    _cstName=,
    _cstVar=
    ) / des="CST: CDISC-DEFINE-XML static variables";

  %*
  DEFINE - sasreferences values.
  ;
  %if (&_cstName=DEFINE_SASREF_TYPE_REFXML) %then %let &_cstVar=referencexml;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_EXTXML) %then %let &_cstVar=externalxml;
  %else %if (&_cstName=DEFINE_SASREF_SUBTYPE_XML) %then %let &_cstVar=xml;
  %else %if (&_cstName=DEFINE_SASREF_SUBTYPE_STYLESHEET) %then %let &_cstVar=stylesheet;

  %else %if (&_cstName=DEFINE_SASREF_TYPE_STUDYMETADATA) %then %let &_cstVar=studymetadata;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_CLASSMETADATA) %then %let &_cstVar=classmetadata;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_REFERENCEMETADATA) %then %let &_cstVar=referencemetadata;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_SOURCEDATA) %then %let &_cstVar=sourcedata;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_SOURCEMETADATA) %then %let &_cstVar=sourcemetadata;
  %else %if (&_cstName=DEFINE_SASREF_TYPE_REFERENCECTERM) %then %let &_cstVar=referencecterm;

  %*
  DEFINE JAVA Information
  ;
  %else %if (&_cstName=DEFINE_JAVA_PARAMSCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLTransformerParams;
  %else %if (&_cstName=DEFINE_JAVA_IMPORTCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLImporter;
  %else %if (&_cstName=DEFINE_JAVA_EXPORTCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLExporter;

%mend define_getStatic;
