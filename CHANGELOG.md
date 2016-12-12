# EPS Release History

## 0.3.0 (2016-12-09)

 * Ensure compatibility with PS 2.0 [Dominique Broeglin]
 * Alternative way to inject variables without changing current scope [Dominique Broeglin]
 * Refactored template engine to add multiline tags and trimming [Dominique Broeglin]
 * Added test for multiline expression tag [Dominique Broeglin]

Note: This release breaks backward compatibility to behave more like ERB:

 * No more output from a <% ... %> tags
 * No more line breaks added at the end of the template output
 * Refactored the cmdlet name to : Invoke-EpsTemplate

## 0.2.0 (2016-08-29)

 * Update README.md [Dave Wu]
 * Added proper escaping for ` and $ [Dominique Broeglin]
 * Fixed test suite when $A is defined [Dominique Broeglin]
 * Corrected style issues to satisfy Visual Studio Code [Dominique Broeglin]
 * Added PrivateData (re-encoded in UTF8) [Dominique Broeglin]
 * Changing base box name to eval-win2012r2-standard-nocm-1.0.4 [Dominique Broeglin]
 * Test various PowerShell versions with Appveyor. [Dominique Broeglin]
 * Added appveyor CI and corrected error on RootModule [Dominique Broeglin]
 * Update README.md [Dave Wu]
 * Aligning version number with upstream [Dominique Broeglin]
 * Reorganized the code in a more module like layout [Dominique Broeglin]
 * Update README.md [Dave Wu]
 * Cleaned up Vagrantfile and added provisioning [Dominique Broeglin]
 * Replaced EPS.ps1 by module EPS.psm1 [Dominique Broeglin]
 * Added a Vagrantfile to help developing on non Windows environment [Dominique Broeglin]

## 0.1.0 (2016-10-02)

 * First functional version
