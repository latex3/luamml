# Changelog
All notable changes to the `luamml` package since the
2025-02-17 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
this project uses date-based 'snapshot' version identifiers.

## [Unreleased]

- Ulrike Fischer, 2025-02-21
  * change intent :equationlabel to :equation-label and 
  :noequationlabel to :no-equation-label
  

## 2025-02-17

### Changed
- Ulrike Fischer, 2025-02-17
  * moved all patches into latex-lab
  * added sockets to luamml.dtx
  * changed handling of tags/labels: empty tags produces a row too and have an intent
  * corrected small bugs 

- Ulrike Fischer, 2024-11-29
  luamml-structelemwriter.lua: moved the actualtext for e.g. stretched braces from the structure element to the mc-chunk.

- Ulrike Fischer, 2024-03-03
  luamml.dtx: add plug for mbox socket to correctly annotate them in math.

- Ulrike Fischer, 2024-11-29
  luamml-structelemwriter.lua: use structnum instead of label when stashing. 
