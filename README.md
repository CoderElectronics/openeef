# OpenEEF v1.1
OpenEEF (Open Enhanced Executable Format) is a new format of executable that packages traditional code, project resources, and metadata into a single binary file. This enables you to package your entire project into a single file, and automatically install dependencies while tracking code updates at a lower level. V1.1 includes built-in APT, Snapcraft, and Optware backends for dependency management, a simple versioning tool to track changes to packaged code (using md5sum), a metadata interface, and a simple packager tool. 

## Included SDK
There are three main tools included with the OpenEEF SDK:
 - eefget (Metadata interface script)
 - eefmake (The packaging tool for creating special binaries)
 - eefrt (The main runtime interpreter)

### eefget
This tool makes it easier to get metadata variables from the final binary file. There are two main modes, the first is text mode, and the second is file mode.
\
Text mode allows you to retrieve a text variable from the metadata configuration file inside the binary. When running the command, it will output the variable's text content to stdout.

    eefget -t <package file name> <variable name>

\
File mode allows you to retrieve a filename variable from the metadata configuration file inside the binary, and read the contents of that file to stdout. When running the command, it will output the file's contents to stdout.

    eefget -f <package file name> <variable name>
 
### eefmake
This is the packager tool for the OpenEEF format. This format is a cpio-compressed folder with a signature added, and a shebang to run the interpreter program (eefrt). 
\
There is a basic file tree that makes up an app, centered around the `init` configuration file:

    .
    ├── data 
    │   ├── icon.png 		(icon file, specified in init)
    │   ├── inits-ni.sh     (init script, non interactive mode, specified in init)
    │   └── inits.sh		(init script, specified in init)
    └── init
\
The init file contains all of the metadata and names of the scripts that are run. Every file referenced in init must be inside of the `data` folder. Some standard metadata variables are `name`, `author`, `version`, `builddate`, and `icon`. The init file must be in the Yaml format, with 3 sections.

    global:
	  icon: "icon.png"
	  name: "Test App"
	  author: "Ari Stehney"

	dependencies:
	  apt: "python3 bash"

	init:
	  default: "inits.sh"
	  noninteractive: "inits-ni.sh"

"global" is the metadata location, and the only place that `eefget` reads from. You can put any variable names in the global section, but your should include some of the recommended variables from above. "dependencies" is used by the dependency manager on the first run (and if the file md5sum changes), and three variables are supported. For automated install, set the package manager name variable to a string of space separated package names (apt, snap, and opkg are supported). "init" is the last, and maybe the most important section. This section consists of runtime targets, although only "default" is required. Any target names can be used to select a different script, and the target can be set using the `EEF_TARGET=<target name>` bash variable when running the package. 
\
\
Once you have your app's file tree made according to the previous instructions, it is time to package the app. Here is a simple command to build the example app:

    eefmake example/ example.eef
	
	or:
	
	eefmake <your app root folder> <output package filename>
This should give you a fully finished binary, and it should be executable like a normal binary as long as OpenEEF is installed on your system.

### eefrt
This is the most important script, the entire interpreter/runtime for OpenEEF. Once the SDK is installed, this interpreter should be executed automatically when running an OpenEEF binary, but it can also be run manually. To run a binary manually, here is the usage for eefrt:

    eefrt <package filename> <script arguments>
Whenever the interpreter is run, any arguments added to the script are directly passed to the script being run. The one bash variable that is read is named "EEF_TARGET," and this sets the active script target to run (this also works without using the interpreter manually).

    EEF_TARGET=noninteractive eefrt <package filename> <script arguments>
    
    or:
	
	EEF_TARGET=noninteractive ./<package filename> <script arguments>

\
The last important feature of eefrt is dependency management. The interpreter has a package tracking system using md5sum to check if this package has been run before, and if not, trigger the package manager to install everything needed.

## Installing the SDK
Included with the repo is an installer for the SDK. The installer makes everything executable, and moves the scripts to the right location. This requires sudo privileges and a bash installation. To install, just clone this repo, and run install.sh.

    ./install.sh

