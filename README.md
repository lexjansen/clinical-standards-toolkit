# SAS Clinical Standards Toolkit (openCST)

## Overview

The SAS Clinical Standards Toolkit (CST) is now offered as an open source solution.  Users can  contribute new standards and updates more frequently via GitHub.

### What's Changed

The open source release of SAS Clinical Standards Toolkit is a direct port of the last production release (1.7.2) with minor modifications to adapt to a new deployment architecture.

- CST Framework macros and jars are now external to SASHome and requires manual configuration post-install
- Scripts are provided to easily run installations or individual standard updates
- Manually loading the jar in code no longer uses the picklists method
- Manually modifying sasautos requires that you use insert or append operations
- All source code is included
- Deployment support Windows and Unix platforms

### Prerequisites

To deploy openCST, the following software is required:

- **Apache Ant 1.7** or higher is required in order to build and deploy.
- **JDK 8** or higher (only if you wish to modify and build the Java component)
- **SAS Version 9.4** (note: if the SAS Clinical Standards Toolkit was previously installed from a software depot, it must be removed before installing the open source version).  The installation scripts have NOT been validated on SAS Viya yet.

### Migration from previous SAS Clinical Standards Toolkit versions

The open source version of SAS Clinical Standards Toolkit does not assume any migration control.  If you are running a previous release, and especially if you made modifications or added standards, it is up to you to apply any modifications to newly deployed standards and macros, and copy and register any standards that you added.  The open source installer is non-destructive and will make a copy of the global, sample, and framework libraries if they already exist.  The open source programs are functionally identical to the last CST production release.  Changes to macros and programs are related to how the framework jar is loaded and how macros are added to sasautos.

The following migration steps are recommended:

1. Make backup copies of your cstGlobalLibrary, cstSampleLibrary, and any framework macros that you changed in your installation.
2. Completely uninstall SAS Clinical Standards Toolkit from your SAS installation.
3. Perform the open source installation as defined below.
4. Sync any changes\additions that you made.

## Installation

There are two options for installing openCST:

1. Build from source
2. Release package

If you intend to contribute back to the open source repository or want more control over installing standards, follow the build from source instructions.  If you only want to deploy the final product and start working with it, follow the release package instructions.

### Installing a Release Package

Each release of openCST contains compressed files for the distribution source or deployed instances.  The deployed instance compressed file contains the end result of building openCST using the default locations.

1. In GitHub, select the latest release for clinical-standards-toolkit.
1a. For a windows deployment, download cst-xxx-deployed.zip.
1b. For Linux, choose cst-xxx-deployed.tar.gz.
2. Expand the zip to the desired location.  The zip file contains the three deployed folders (cstGlobalLibrary, cstSampleLibrary, and cstFramework).
3. Add properties to the SAS installation configuration.  You will find a text file in the cstFrameworkLibrary that contains the information that needs to be added based on a default deployment.  You will likely need to change the paths for each property to reflect the location of the expanded files.

### Building from Source

The default locations for openCST are as follows:

```text
C:/cstFrameworkLibrary
C:/cstGlobalLibrary
C:/cstSampleLibrary
C:/Program Files/SASHome*
```

*SAS 9.4 is required to process transport files and register standards in the global library during installation.

If you need to change any of these (or you are running the install on Unix), the recommended approach is to create an override properties file in your user home folder.

1. If needed, create a properties override
 a. copy  **cstbuild.properties**  (found in templates folder) to your user home folder (i.e., c:\users\userid on Windows)
b. change the values to the required locations for your server configuration.
c. save changes.

2. From a command window, navigate to the clinicalstandardstoolkit folder cloned from GitHub, and type:
`ant install`
3. When the deployment finishes, review the deploy.log file created in the clinicalstandardstoolkit folder to verify that all processes ran successfully.
4. Add properties to the SAS installation configuration.  You will find a text file in the cstFrameworkLibrary that contains the information that needs to be added based on your deployment setup.

## Getting Started

After installation, you will have three managed folders on your system.

1. cstFrameworkLibrary (new)- contains the macros and jars previously installed in SASHome.
2. cstGlobalLibrary - the standards available  on your system.
3. cstSampleLibrary - sample programs that demonstrate how to perform common tasks with standards.

The previous Clinical Standards toolkit documents (see additional resources) are still valid references.  We typically recommend starting with the Operational Qualification Guide.

## Deploying Updates (only if you built openCST from source)

As new changes are contributed, you can periodically pull updated GIT files to your local repository and apply them to your installation.

### For changes to the cstFrameworkLibrary (macros or jar)

1. Open a command prompt and change to the clinicalstandardstoolkit folder in your local GIT repository.
2. Run `ant dist-framework`.  This will build only the cstFrameworkLibrary component in your distribution and unpack any SAS data files.
3. Run `ant deploy-framework`.  This will deploy updates to the cstFrameworkLibrary location.

### For changes individual standards or adding new standards

1. Open a command prompt and change to the updated or added standard in the clinicalstandardstoolkit/standards folder in your local GIT repository.
`
Example: if you want to run an update for SDTM 3.2, change to clinicalstandardstoolkit/standards/cstsdtm32 folder.
`
2. Run `ant dist`.  This will build the distribution for the standard and unpack any SAS data files.
3. Run `ant deploy`.  This will deploy updates to the cstGlobalLibrary and cstSampleLibrary location and register (or re-register) the standard.

Note: for updates to the framework or existing standards, a backup copy of the applicables framework, global, and sample folder will be created.  If you are adding a new standard, the new folders are simply added.

## Disabling or Uninstalling CST

Disabling CST only requires removing the settings from the SAS server configuration.  The cstFramework, cstGlobalLibrary, and cstSampleLibrary will remain intact in the event that you continue using it in the future.

Uninstalling CST completely removes the cstFramework, cstGlobalLibrary, and cstSampleLibrary.

1. Remove the statements added to the SAS Configuration file.
2. From the clinicalstandardstoolkit folder in your local GIT repository, run `ant uninstall`.  You will be asked to confirm that you want to completely remove the installation.  Responding with `yes` will completely remove the installation.

## Opening Issues

- Feel free to open an issue to discuss any questions you have or ask about ideas for contributions.  Others who monitor issues may pickup your ideas for implementation.
- If you have an idea but don't want to code it up yourself, feel free to run it by us. We can implement it for you as long as you help with the use cases and sample programs.

## Troubleshooting

Ensure that you have adminstrator privileges on Windows or are using the SAS Administrator account on Unix.

During installation, most issues are typically related to launching SAS.  This depends on setting your environment properties properly.  The script files use these to set CST environment properties (in lieu of SAS Configuration files) to launch SAS processes that perform tasks such as porting datasets and registering standards.

`sas.fulldirpath.sasrootdir.default` must point to your SASHOME location, typically C:/Progra~1/SASHome or /usr/local/SAS.  Within SASHOME, it's expected that the standard folder structure is present (in SAS 9.4, this is SASFoundation/9.4).  If this is not the case, you will need to add an additional property to your override:

`sas.dirpath.sasFoundation.94=path within SASHome to executable`

Post-Installation, the SAS configuration file must be updated to define the CST system values in accordance with SAS system configuration guidelines.

## Contributing

We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project.

Do you need help adding a new standard?  Open an issue in GitHub!

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

ant-contrib-1.0b3.jar is licensed under the [Apache 1.1 License](ANT-CONTRIB-LICENSE).
xercesImpl.jar is licensed under the [Apache 2.0 License](LICENSE).
xml-apis.jar is licensed under the [Apache 2.0 License](LICENSE).
define2-1.xsl is licensed under the [MIT License](define2-1.xsl.LICENSE).

## Additional Resources

Legacy Documentation is still applicable for the most part.  The most notable exception is the location of the autocall macros as described in the Getting Started section.

[Operational Qualification Guide](https://support.sas.com/documentation/cdl/en/clinstdtktiq/69402/PDF/default/clinstdtktiq.pdf)

[Getting Started Guide](https://support.sas.com/documentation/cdl/en/clinstdtktgs/69403/PDF/default/clinstdtktgs.pdf)

[User's Guilde](https://support.sas.com/documentation/cdl/en/clinstdtktug/69404/PDF/default/clinstdtktug.pdf)
