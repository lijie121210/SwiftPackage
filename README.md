# SwiftPackage

The original executable swift initial package structure is
---
 ProjectName	-- Package.swift
 				-- Sources		-- main.swift
 				-- Tests
 				-- .gitignore
---
creating by command:
`$ swift package init --type executable`

it can't be tested because there is main.swift.

SwiftPackage relayout files and directories 

---
 ProjectName	-- Package.swift
 				-- Sources -- ProjectNameLib.  -- ProjectNameError.swift
 							 -- ProjectNameApp   -- main.swift
 				-- Tests	 -- ProjectNameTests -- ProjectNameTestCase.swift
 				-- .gitignore
---

Then, ProjectNameLib module is testable.

## Usage

1. Build package and archive a binary file: SwiftPackage
2. Copy SwiftPackage to /usr/local/bin or anywhere in $PATH
3. Create Folder and run.

For Example: 
```
$ mv path/to/SwiftPackage /usr/local/bin/swiftp
$ mkdir hello
$ cd hello
$ swiftp xcode-open
```

Currently, there are three commands:

> swiftp init or -i
> swiftp xcode or -x
> swiftp xcode-open or -xo

Todo
- [ ]  help message 