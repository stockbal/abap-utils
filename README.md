# abap-utils

Utilities for ABAP Development

## Package overview
- **/src**  
  Miscellaneous objects
- **/src/ci**  
  Contains Classes/interfaces for Code Inspector Handling
- **/src/envanalysis (WIP)**  
  Contains Classes/interfaces for Object Environment Analysis  
  
  Important Objects in package  
  Object Name               | Purpose
  --------------------------|------------------------------------
  ZCL_DUTILS_OEA_ANALYZER   | Central class which handles object environment analysis. Can be created via ZCL_DUTILS_OEA_FACTORY=>CREATE_ANALYZER

## Installation

Install this repository using [abapGit](https://github.com/abapGit/abapGit#abapgit).

### SAP NetWeaver compatibility

This repository is compatible with NW 7.40 SP08 and greater
