# openCST Define-XML 2.1 Metadata Structures (Define-XML 2.1.5 - NCI Controlled Terminology Package 52 - 2022-12-26)

| Dataset | Label | Order | Variable | Label | Datatype | Length | Allowed Values
|---|---|---|---|---|---|---|---|
|source_study |Source Study Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_study |Source Study Metadata |2 |fileoid |Unique identifier for the file |char|128 |  |
|source_study |Source Study Metadata |3 |originator |The organization that generated the Define-XML file |char|128 |  |
|source_study |Source Study Metadata |4 |studyoid |Unique identifier for the study |char|128 |  |
|source_study |Source Study Metadata |5 |context |Context in which the Define-XML document is used |char|2000 |NCIt: C170448 - [Submission, Other] |
|source_study |Source Study Metadata |6 |studyname |Short external name for the study |char|128 |  |
|source_study |Source Study Metadata |7 |studydescription |Description of the study |char|2000 |  |
|source_study |Source Study Metadata |8 |protocolname |Sponsors internal name for the protocol |char|128 |  |
|source_study |Source Study Metadata |9 |comment |MetadataVersion Comment |char|1000 |  |
|source_study |Source Study Metadata |10 |metadataversionname |MetadataVersion Name |char|1000 |  |
|source_study |Source Study Metadata |11 |metadataversiondescription |MetadataVersion Description |char|1000 |  |
|source_study |Source Study Metadata |12 |studyversion |Unique study version identifier |char|128 |  |
|source_study |Source Study Metadata |13 |standard |Name of Standard |char|20 |  |
|source_study |Source Study Metadata |14 |standardversion |Version of Standard |char|20 |  |
|source_standards |Source Standard Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_standards |Source Standard Metadata |2 |cdiscstandard |Name of Standard |char|40 |NCIt: C170452 - [ADaMIG, BIMO, CDISC/NCI, SDTMIG, SDTMIG-AP, SDTMIG-MD, SENDIG, SENDIG-AR, SENDIG-DART] |
|source_standards |Source Standard Metadata |3 |cdiscstandardversion |Version of Standard |char|20 |  |
|source_standards |Source Standard Metadata |4 |order |Standard order |num |8 |  |
|source_standards |Source Standard Metadata |5 |type |Type of Standard |char|20 |NCIt: C170451 - [CT, IG] |
|source_standards |Source Standard Metadata |6 |publishingset |Set of published files of Standard when Type='CT' |char|20 |NCIt: C172331 - [ADaM, CDASH, DEFINE-XML, SDTM, SEND] |
|source_standards |Source Standard Metadata |7 |status |Status of Standard |char|20 |NCIt: C172332- [Draft, Final, Provisional] - Extensible |
|source_standards |Source Standard Metadata |8 |comment |Comment |char|1000 |  |
|source_standards |Source Standard Metadata |9 |studyversion |Unique study version identifier |char|128 |  |
|source_standards |Source Standard Metadata |10 |standard |Name of Standard |char|20 |  |
|source_standards |Source Standard Metadata |11 |standardversion |Version of Standard |char|20 |  |
|source_tables |Source Table Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_tables |Source Table Metadata |2 |table |Table Name |char|32 |  |
|source_tables |Source Table Metadata |3 |label |Table Label |char|200 |  |
|source_tables |Source Table Metadata |4 |order |Table order |num |8 |  |
|source_tables |Source Table Metadata |5 |repeating |Can Itemgroup occur repeatedly within the containing Form? |char|3 |[Yes, No] |
|source_tables |Source Table Metadata |6 |isreferencedata |Can Itemgroup occur only within a ReferenceData element? |char|3 |[Yes, No] |
|source_tables |Source Table Metadata |7 |domain |Domain |char|32 |  |
|source_tables |Source Table Metadata |8 |domaindescription |Domain description |char|256 |  |
|source_tables |Source Table Metadata |9 |class |Observation Class within Standard |char|40 |NCIt: C103329 - [ADAM OTHER, C103375 BASIC DATA STRUCTURE, DEVICE LEVEL ANALYSIS DATASET, EVENTS, FINDINGS, FINDINGS ABOUT, INTERVENTIONS, MEDICAL DEVICE BASIC DATA STRUCTURE, MEDICAL DEVICE OCCURRENCE DATA STRUCTURE, OCCURRENCE DATA STRUCTURE, RELATIONSHIP, SPECIAL PURPOSE, STUDY REFERENCE, SUBJECT LEVEL ANALYSIS DATASET, TRIAL DESIGN] |
|source_tables |Source Table Metadata |10 |subclass |Observation SubClass within Standard |char|40 |NCIt: C165635, C177903, C176227 - [ADVERSE EVENT, MEDICAL DEVICE TIME-TO-EVENT, NON-COMPARTMENTAL ANALYSIS, POPULATION PHARMACOKINETIC ANALYSIS, TIME-TO-EVENT] |
|source_tables |Source Table Metadata |11 |xmlpath |(Relative) path to XPT file |char|200 |  |
|source_tables |Source Table Metadata |12 |xmltitle |Title for XPT file |char|200 |  |
|source_tables |Source Table Metadata |13 |structure |Table Structure |char|200 |  |
|source_tables |Source Table Metadata |14 |purpose |Purpose |char|10 |[Tabulation, Analysis] |
|source_tables |Source Table Metadata |15 |keys |Table Keys |char|200 |  |
|source_tables |Source Table Metadata |16 |state |Data Set State |char|20 |[Final, Draft] |
|source_tables |Source Table Metadata |17 |date |Release Date |char|20 |  |
|source_tables |Source Table Metadata |18 |comment |Comment |char|1000 |  |
|source_tables |Source Table Metadata |19 |cdiscstandard |Name of Standard |char|40 |NCIt: C170452 - [ADaMIG, BIMO, CDISC/NCI, SDTMIG, SDTMIG-AP, SDTMIG-MD, SENDIG, SENDIG-AR, SENDIG-DART] |
|source_tables |Source Table Metadata |20 |cdiscstandardversion |Version of Standard |char|20 |  |
|source_tables |Source Table Metadata |21 |isnonstandard |ItemGroup is non-standard? |char|3 |[Yes] |
|source_tables |Source Table Metadata |22 |hasnodata |ItemGroup has no data? |char|3 |[Yes] |
|source_tables |Source Table Metadata |23 |studyversion |Unique study version identifier |char|128 |  |
|source_tables |Source Table Metadata |24 |standard |Name of Standard |char|20 |  |
|source_tables |Source Table Metadata |25 |standardversion |Version of Standard |char|20 |  |
|source_columns |Source Column Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_columns |Source Column Metadata |2 |table |Table Name |char|32 |  |
|source_columns |Source Column Metadata |3 |column |Column Name |char|32 |  |
|source_columns |Source Column Metadata |4 |label |Column Description |char|200 |  |
|source_columns |Source Column Metadata |5 |order |Column Order |num |8 |  |
|source_columns |Source Column Metadata |6 |type |Column Type |char|1 |[N, C] |
|source_columns |Source Column Metadata |7 |length |Column Length |num |8 |  |
|source_columns |Source Column Metadata |8 |displayformat |Display Format |char|200 |  |
|source_columns |Source Column Metadata |9 |significantdigits |Significant Digits |num |8 |  |
|source_columns |Source Column Metadata |10 |xmldatatype |XML Data Type |char|18 |[text, integer, float, datetime, date, time, partialDate, partialTime, partialDatetime, incompleteDatetime, durationDatetime, intervalDatetime] |
|source_columns |Source Column Metadata |11 |xmlcodelist |SAS Format/XML Codelist |char|128 |  |
|source_columns |Source Column Metadata |12 |core |Column Required, Optional, or Expected |char|10 |[Req, Exp, Perm, Cond] |
|source_columns |Source Column Metadata |13 |mandatory |Column Mandatory |char|3 |[Yes, No] |
|source_columns |Source Column Metadata |14 |origintype |Column Origin Type |char|40 |NCIt: C170449 - [Assigned, Collected, Derived, Not Available, Other, Predecessor, Protocol] |
|source_columns |Source Column Metadata |15 |originsource |Column Origin Source |char|40 |NCIt: C170450 - [Investigator, Sponsor, Subject, Vendor] |
|source_columns |Source Column Metadata |16 |origindescription |Column Origin Description |char|1000 |  |
|source_columns |Source Column Metadata |17 |role |Column Role |char|200 |  |
|source_columns |Source Column Metadata |18 |algorithm |Computational Algorithm or Method |char|1000 |  |
|source_columns |Source Column Metadata |19 |algorithmname |Computational Algorithm or Method Name |char|200 |  |
|source_columns |Source Column Metadata |20 |algorithmtype |Type of Algorithm |char|11 |[Computation, Imputation] |
|source_columns |Source Column Metadata |21 |formalexpression |Formal Expression for Algorithm |char|1000 |  |
|source_columns |Source Column Metadata |22 |formalexpressioncontext |Context to be used when evaluating the FormalExpression content |char|1000 |  |
|source_columns |Source Column Metadata |23 |comment |Comment |char|1000 |  |
|source_columns |Source Column Metadata |24 |isnonstandard |Item is non-standard? |char|3 |[Yes] |
|source_columns |Source Column Metadata |25 |hasnodata |Item has no data? |char|3 |[Yes] |
|source_columns |Source Column Metadata |26 |studyversion |Unique study version identifier |char|128 |  |
|source_columns |Source Column Metadata |27 |standard |Name of Standard |char|20 |  |
|source_columns |Source Column Metadata |28 |standardversion |Version of Standard |char|20 |  |
|source_values |Source Value Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_values |Source Value Metadata |2 |table |Table Name |char|32 |  |
|source_values |Source Value Metadata |3 |column |Column Name |char|32 |  |
|source_values |Source Value Metadata |4 |name |Virtual Variable Name |char|32 |  |
|source_values |Source Value Metadata |5 |valuelistdescription |ValueList Description |char|2000 |  |
|source_values |Source Value Metadata |6 |whereclause |Where Clause |char|1000 |  |
|source_values |Source Value Metadata |7 |whereclausecomment |Where Clause comment |char|1000 |  |
|source_values |Source Value Metadata |8 |label |Column Description |char|200 |  |
|source_values |Source Value Metadata |9 |order |Column Order |num |8 |  |
|source_values |Source Value Metadata |10 |type |Column Type |char|1 |[N, C] |
|source_values |Source Value Metadata |11 |length |Column Length |num |8 |  |
|source_values |Source Value Metadata |12 |displayformat |Display Format |char|200 |  |
|source_values |Source Value Metadata |13 |significantdigits |Significant Digits |num |8 |  |
|source_values |Source Value Metadata |14 |xmldatatype |XML Data Type |char|18 |[text, integer, float, datetime, date, time, partialDate, partialTime, partialDatetime, incompleteDatetime, durationDatetime, intervalDatetime] |
|source_values |Source Value Metadata |15 |xmlcodelist |SAS Format/XML Codelist |char|128 |  |
|source_values |Source Value Metadata |16 |core |Column Required, Optional or Expected |char|10 |[Req, Exp, Perm, Cond] |
|source_values |Source Value Metadata |17 |mandatory |Column Mandatory |char|3 |[Yes, No] |
|source_values |Source Value Metadata |18 |origintype |Column Origin Type |char|40 |NCIt: C170449 - [Assigned, Collected, Derived, Not Available, Other, Predecessor, Protocol] |
|source_values |Source Value Metadata |19 |originsource |Column Origin Source |char|40 |NCIt: C170450 - [Investigator, Sponsor, Subject, Vendor] |
|source_values |Source Value Metadata |20 |origindescription |Column Origin Description |char|1000 |  |
|source_values |Source Value Metadata |21 |role |Column Role |char|200 |  |
|source_values |Source Value Metadata |22 |algorithm |Computational Algorithm or Method |char|1000 |  |
|source_values |Source Value Metadata |23 |algorithmname |Computational Algorithm or Method Name |char|200 |  |
|source_values |Source Value Metadata |24 |algorithmtype |Type of Algorithm |char|11 |[Computation, Imputation] |
|source_values |Source Value Metadata |25 |formalexpression |Formal Expression for Algorithm |char|1000 |  |
|source_values |Source Value Metadata |26 |formalexpressioncontext |Context to be used when evaluating the FormalExpression content |char|1000 |  |
|source_values |Source Value Metadata |27 |comment |Comment |char|1000 |  |
|source_values |Source Value Metadata |28 |hasnodata |Item has no data? |char|3 |[Yes] |
|source_values |Source Value Metadata |29 |studyversion |Unique study version identifier |char|128 |  |
|source_values |Source Value Metadata |30 |standard |Name of Standard |char|20 |  |
|source_values |Source Value Metadata |31 |standardversion |Version of Standard |char|20 |  |
|source_codelists |Source Codelist Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_codelists |Source Codelist Metadata |2 |codelist |Unique identifier for this CodeList |char|128 |  |
|source_codelists |Source Codelist Metadata |3 |codelistname |CodeList Name |char|128 |  |
|source_codelists |Source Codelist Metadata |4 |codelistdescription |CodeList Description |char|2000 |  |
|source_codelists |Source Codelist Metadata |5 |desclanguage |Language |char|17 |  |
|source_codelists |Source Codelist Metadata |6 |codelistncicode |Codelist NCI Code |char|10 |  |
|source_codelists |Source Codelist Metadata |7 |codelistdatatype |CodeList item value data type |char|7 |[text, float, integer] |
|source_codelists |Source Codelist Metadata |8 |sasformatname |SAS format name |char|32 |  |
|source_codelists |Source Codelist Metadata |9 |codedvaluechar |Value of the codelist item (character) |char|512 |  |
|source_codelists |Source Codelist Metadata |10 |codedvaluenum |Value of the codelist item (numeric) |num |8 |  |
|source_codelists |Source Codelist Metadata |11 |codelistitemdescription |CodeList item description |char|2000 |  |
|source_codelists |Source Codelist Metadata |12 |decodetext |Decode value of the codelist item |char|2000 |  |
|source_codelists |Source Codelist Metadata |13 |decodelanguage |Decode Language |char|17 |  |
|source_codelists |Source Codelist Metadata |14 |codedvaluencicode |Codelist Item NCI Code |char|10 |  |
|source_codelists |Source Codelist Metadata |15 |rank |CodedValue order relative to other item values |num |8 |  |
|source_codelists |Source Codelist Metadata |16 |ordernumber |Display order of the item within the CodeList. |num |8 |  |
|source_codelists |Source Codelist Metadata |17 |extendedvalue |Coded value that has been used to extend external controlled terminology |char|3 |[Yes] |
|source_codelists |Source Codelist Metadata |18 |dictionary |Name of the external codelist |char|200 |NCTt: C66788 - [CDISC CT, COSTART, CTCAE, D-U-N-S NUMBER, ICD, ICD-O, LOINC, MED-RT, MedDRA, SNOMED, UNII, WHO ATC CLASSIFICATION SYSTEM, WHOART, WHODD] |
|source_codelists |Source Codelist Metadata |19 |version |Version designator of the external codelist |char|200 |  |
|source_codelists |Source Codelist Metadata |20 |ref |Reference to a local instance of the dictionary |char|512 |  |
|source_codelists |Source Codelist Metadata |21 |href |URL of an external instance of the dictionary |char|512 |  |
|source_codelists |Source Codelist Metadata |22 |comment |Comment |char|1000 |  |
|source_codelists |Source Codelist Metadata |23 |cdiscstandard |Name of Standard |char|40 |NCIt: C170452 - [ADaMIG, BIMO, CDISC/NCI, SDTMIG, SDTMIG-AP, SDTMIG-MD, SENDIG, SENDIG-AR, SENDIG-DART] |
|source_codelists |Source Codelist Metadata |24 |cdiscstandardversion |Version of Standard |char|20 |  |
|source_codelists |Source Codelist Metadata |25 |publishingset |Set of published files of Standard when Type='CT' |char|20 |NCIt: C172331 - [ADaM, CDASH, DEFINE-XML, SDTM, SEND] |
|source_codelists |Source Codelist Metadata |26 |isnonstandard |CodeList is non-standard? |char|3 |[Yes] |
|source_codelists |Source Codelist Metadata |27 |studyversion |Unique study version identifier |char|128 |  |
|source_codelists |Source Codelist Metadata |28 |standard |Name of Standard |char|20 |  |
|source_codelists |Source Codelist Metadata |29 |standardversion |Version of Standard |char|20 |  |
|source_documents |Source Document Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_documents |Source Document Metadata |2 |doctype |Document Type (SUPPDOC, CRF, COMMENT, METHOD, DISPLAY, RESULTDOC, RESULTCODE) |char|32 |[SUPPDOC, CRF, COMMENT, METHOD, DISPLAY, RESULTDOC, RESULTCODE] |
|source_documents |Source Document Metadata |3 |docsubtype |Document Sub Type for doctytpe=COMMENT (MDV, TABLE, COLUMN, VCOLUMN, WHERECLAUSE, CODELIST) |char|32 |[MDV, STANDARD, TABLE, COLUMN, VCOLUMN, WHERECLAUSE, CODELIST] |
|source_documents |Source Document Metadata |4 |href |The pathname and filename of the target document relative to the define.xml |char|512 |  |
|source_documents |Source Document Metadata |5 |title |Meaningful description, label, or location of the document leaf |char|2000 |  |
|source_documents |Source Document Metadata |6 |pdfpagereftype |Type of Page Reference (PhysicalRef/NamedDestination) |char|32 |[PhysicalRef, NamedDestination] |
|source_documents |Source Document Metadata |7 |pdfpagerefs |Page Reference |char|200 |  |
|source_documents |Source Document Metadata |8 |pdfpagereftitle |Meaningful description of the specific document reference |char|2000 |  |
|source_documents |Source Document Metadata |9 |table |Table Name |char|32 |  |
|source_documents |Source Document Metadata |10 |column |Column Name |char|32 |  |
|source_documents |Source Document Metadata |11 |whereclause |Where Clause |char|1000 |  |
|source_documents |Source Document Metadata |12 |codelist |Unique identifier for the CodeList |char|128 |  |
|source_documents |Source Document Metadata |13 |displayidentifier |Analysis Display Identifier |char|128 |  |
|source_documents |Source Document Metadata |14 |resultidentifier |Analysis Display Result Identifier |char|128 |  |
|source_documents |Source Document Metadata |15 |cdiscstandard |Name of Standard |char|40 |NCIt: C170452 - [ADaMIG, BIMO, CDISC/NCI, SDTMIG, SDTMIG-AP, SDTMIG-MD, SENDIG, SENDIG-AR, SENDIG-DART] |
|source_documents |Source Document Metadata |16 |cdiscstandardversion |Version of Standard |char|20 |  |
|source_documents |Source Document Metadata |17 |publishingset |Set of published files of Standard when Type='CT' |char|20 |NCIt: C172331 - [ADaM, CDASH, DEFINE-XML, SDTM, SEND] |
|source_documents |Source Document Metadata |18 |studyversion |Unique study version identifier |char|128 |  |
|source_documents |Source Document Metadata |19 |standard |Name of Standard |char|20 |  |
|source_documents |Source Document Metadata |20 |standardversion |Version of Standard |char|20 |  |
|source_analysisresults |Source Analysis Results Metadata |1 |sasref |SASreferences sourcedata libref |char|8 |  |
|source_analysisresults |Source Analysis Results Metadata |2 |displayidentifier |Unique identifier for analysis display |char|128 |  |
|source_analysisresults |Source Analysis Results Metadata |3 |displayname |Title of display |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |4 |displaydescription |Description of display |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |5 |resultidentifier |Specific analysis result within display |char|128 |  |
|source_analysisresults |Source Analysis Results Metadata |6 |resultdescription |Description of analysis result within display |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |7 |parametercolumn |Name of the column that holds the parameter |char|8 |  |
|source_analysisresults |Source Analysis Results Metadata |8 |analysisreason |Reason for analysis |char|2000 |NCIt: C117744 - [EXPLORATORY OUTCOME MEASURE, PRIMARY OUTCOME MEASURE, SECONDARY OUTCOME MEASURE] - Extensible |
|source_analysisresults |Source Analysis Results Metadata |9 |analysispurpose |Purpose of analysis |char|2000 |NCIt: C117745 - [DATA DRIVEN, REQUESTED BY REGULATORY AGENCY, SPECIFIED IN PROTOCOL, SPECIFIED IN SAP] - Extensible |
|source_analysisresults |Source Analysis Results Metadata |10 |tablejoincomment |Comment describing how to join tables |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |11 |resultdocumentation |Documentation of analysis result within display |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |12 |codecontext |Name and version of computer language |char|128 |  |
|source_analysisresults |Source Analysis Results Metadata |13 |code |Programming statements |char|2000 |  |
|source_analysisresults |Source Analysis Results Metadata |14 |table |Table Name |char|32 |  |
|source_analysisresults |Source Analysis Results Metadata |15 |analysisvariables |Analysis Variable List |char|1024 |  |
|source_analysisresults |Source Analysis Results Metadata |16 |whereclause |Where Clause |char|1000 |  |
|source_analysisresults |Source Analysis Results Metadata |17 |studyversion |Unique Study Version Identifier |char|128 |  |
|source_analysisresults |Source Analysis Results Metadata |18 |standard |Name of Standard |char|20 |  |
|source_analysisresults |Source Analysis Results Metadata |19 |standardversion |Version of Standard |char|20 |  |
