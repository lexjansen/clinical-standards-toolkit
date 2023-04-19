# readme.md

## Example Define-XML documents

The example Define-XML documents in the **sourcexml** folder that are used to import in this module are based on the following sources:

- **define_msg_sdtm.xml**: SDTM Metadata Submission Guidelines v2.0, published 30 March 2021
  source: <https://www.cdisc.org/standards/foundational/sdtm/sdtm-metadata-submission-guidelines-v2-0>

- **define_msg_adam.xml**: ADaM Metadata Submission Guidelines v1.0, 18 April 18 2023
  source: <https://wiki.cdisc.org/display/ADAMMSG/ADaM+MSG+examples>

- **define_sdtm_full_example.xml**: adapted from **define_msg_sdtm.xml** to add more metadata in order to fully demonstrate Define-XML 2.1 capabilities:
  - Add a description to a ValueList definition
  - Add a WhereClause comment with a document reference
  - Add descriptions to a CodeList, a CodelistItem and an EnumeratedItime
  - Add a CodeList comment with a document reference
  - Add a External CodeList comment with a document reference
  - Add a Method document reference
  - Add a Formal Expression to a Method
  - Add document references to variable and VLM variables comments with a title that is different from the document title
  - Add multiple HTTP references to a comment.

## Sample Programs

| Sample program | Description | Input | Intermediate | output |
| ----------- | ----------- |----------- |----------- |----------- |
| create_sourcemetadata_fromsaslib.sas | Create study source metadata from SAS datasets|\<standard\>-1.7/sascstdemodata/data| work library |derivedstudymetadata_saslib/\<standard\>|
| migrate_definexml_20_21.sas | Convert Define-XML 2.0 study source metadata to Define-XML 2.1 study source metadata |cdisc-definexml-2.0.0-1.7/sascstdemodata/\<standard\>/metadata| work library |derivedstudymetadata_define-2.0/\<standard\> |
| create_sourcemetadata_from_definexml.sas | Create study source metadata from Define-XML 2.1|sourcexml/define_msg_\<standard\>.xml | deriveddata/\<standard\>|derivedstudymetadata_define/\<standard\>|derivedstudymetadata_define/\<standard\>|
| create_definexml_from_source.sas | Create Define-XML 2.1 from study source metadata |sascstdemodata/\<standard\>/metadata| data/\<standard\>|targetxml/define_msg_\<standard\>.* |
| compare_metadata_sasdefine_xpt.sas | Compare Define-XML 2.1 metadata against SAS XPT metadata| /transport/\<standard\> and /deriveddata/\<standard\> | |results/compare_metadata_results.sas7bdat
| definexml_roundtrip_full_example.sas | Import a Define-XML 2.1 file to study source metadata and then export it to a Define-XML 2.1 file|sourcexml/define_sdtm_full_example.* | sascstdemodata/roundtrip_full_example/metadata | targetxml/define_sdtm_full_example.*
