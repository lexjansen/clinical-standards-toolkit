# SAS Clinical Standards Toolkit (openCST)

## General Assumptions

- SAS 9.4 has been installed and is functioning correctly.
- openCST has been installed, including the sample study libraries.
- The installation of openCST has not been modified from the default installation. If the sample studies have been modified before running these tests, your results data sets can vary from what is described in this document.

**Note**: With a default installation, the results data sets must not contain errors or warnings. With a modified installation, errors or warnings might be normal, but they must be resolved by you.

### File Path Separator

This document is used for both UNIX and Microsoft Windows environments. The forward slash character ( / ) is used in file paths as the separator between path components, which works in both operating system environments.

### Sample study library directory within This Document

*sample study library directory* is used to denote the sample study libraries available with openCST.

### Variables Referred to by the Tests

- CST_DEFINEXML
\<sample study library directory\>/cdisc-definexml-2.0.0-1.7

## Define-XML v2.1 - Operational Qualification (OQ)

### Introduction

If this program runs successfully and produces the expected results, openCST performed the following tasks:

- derived Define-XML 2.0 source metadata by importing a Define-XML v2.1 file.
- validated a Define-XML v2.1 file against the XML schema
- created a Define-XML v2.1 file from source metadata

### Steps

1. Start a new SAS session
2. In the SAS Program Editor, select **File > Open Program**, and then select **CST_DEFINEXML/programs/definexml_roundtrip_full_example.sas**.
3. Select **Run > Submit**
   This program writes to the SAS log file, creates study source metadata in the **CST_DEFINEXML/sascstdemodata/roundtrip_full_example/metadata** directory from the **CST_DEFINEXML/sourcexml/define_sdtm_full_example.xml** file. It creates a Results data set in the **CST_DEFINEXML/results** directory.
   It also creates a Define-XML v2.1 file: **CST_DEFINEXML/targetxml/define_sdtm_full_example.xml**.
4. Review the log to ensure that there are no errors or warnings.
5. Review the **CST_DEFINEXML/sascstdemodata/roundtrip_full_example/metadata** directory to ensure that these conditions are met:
   1. the **source_study** dataset contains 1 record
   2. the **source_standards** dataset contains 4 records
   3. the **source_tables** dataset contains 31 records
   4. the **source_columns** dataset contains 439 records
   5. the **source_values** dataset contains 212 records
   6. the **source_codelists** dataset contains 802 records
   7. the **source_documents** dataset contains 171 records
6. Review the roundtrip_full_example_results dataset in the **CST_DEFINEXML/results** directory to ensure that these conditions are met:
   1. The column labeled **Process status** (named _cst_rc) is **0** for all records.
   2. The column named **resultflag** is **0** for all records.
   3. The data set contains 263 records.
   4. There is a record where **Source data** is **DEFINE_READ** that reports that the XML file was read successfully.
   5. There is a record where **Source data** is **XML TRANSFORMER** that reports **The document validated successfully**.
   6. There is a record where **Source data** is **DEFINE_WRITE** that reports that the XML file was created.
7. Check that **define_sdtm_full_example.xml**, **define_sdtm_full_example.html** and **define2-1.xsl** have been created in the **CST_DEFINEXML/targetxml** directory.
8. Close the SAS session.
