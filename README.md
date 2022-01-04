# scaffold-spm-proj

`scaffold-spm-proj` is a command-line tool that helps you create the [SwiftPMProjectExample](https://github.com/d-date/SwiftPMProjectExample) like directory structures.

## Usage

When you want to create a new project using [SwiftPMProjectExample](https://github.com/d-date/SwiftPMProjectExample) like directory structures. Run this

```sh
scaffold-spm-proj scaffold --repository-name "MyNewProject" --module-name AppFeature --module-name Home
```

You need to setup little more by hand even you ran the command but much better than nothing.

### help

```sh
❯ scaffold-spm-proj --help
OVERVIEW: Supports to setup the hyper-modularized style by Point-Free using SwiftPM.

USAGE: scaffold-spm-proj <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  scaffold                Scaffold the hyper-modularized style directories and files structure.

  See 'scaffold-spm-proj help <subcommand>' for detailed help.
```

```sh
❯ scaffold-spm-proj scaffold --help
OVERVIEW: Scaffold the hyper-modularized style directories and files structure.

USAGE: scaffold-spm-proj scaffold [--output-dir <destination_dir>] --repository-name <repository-name> [--xcworkspace-name <xcworkspace-name>] [--xcode-project-name <xcode-project-name>] [--into <dir_name>] [--module-name <name> ...]

OPTIONS:
  --output-dir <destination_dir>
                          where to generate (default: current directory)
  --repository-name <repository-name>
  --xcworkspace-name <xcworkspace-name>
  --xcode-project-name <xcode-project-name>
  --into <dir_name>       Directory for source code nested into 
  --module-name <name>    module name 
  --version               Show the version.
  -h, --help              Show help information.
```

## Not supported

- xcodeproj related operations (ex: createing, adding module to xcodeproj and rearrange directory structure in your xcodeproj)
    - Here is how you add xcodeproj file manually
        1. open xcworkspace file by Xcode
        1. Click "File" -> "New" -> "Project..." 
        1. Select a template you want and click "Next"
        1. Put some extra information and click "Next"
        1. Select "App" directory, turn off "Source Control", select workspace you open in "Add to", select workspace you open in "Group" and click "Next"
    - Here is how you add your module in your xcodeproj
        1. open xcworkspace file by Xcode
        1. Select your project file in the Navigator Pane
        1. Select your app target in Targets Pane
        1. Select General tab
        1. Scroll down to the bottom, Click "+" button in "Frameworks, Libraries, and Embedded Content"
        1. Select your module under your "Wrokspace" in modal window
    - Here is how you rearrange directory structure in your xcodeproj
        1. Rearrange directory in Finder
        1. Open your workspace and fix a red xcodeproj location in right pane
        1. Delete references of red items under xcodeproj first, then D&D them from Finder into xcworkspace.
        1. Fix "Development Assets" location in your build settings