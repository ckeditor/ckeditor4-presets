CKEditor 4 Presets Builder
==========================

This builder is a tool that creates CKEditor release files for the main "preset" configurations officially distributed at <http://ckeditor.com>. It is targeted to the CKEditor core team, to test the preset builds, to update the ckeditor.com website on new releases and to generate the [nightly builds](http://nightly.ckeditor.com/).

A preset is a CKEditor configuration for building that includes a specific set of plugins. Currently, there are 3 presets defined: **standard**, **basic** and **full**.

The original source code from the official CKEditor repositories is used for the build.

## Cloning this Code

To clone this code:

	> git clone https://github.com/ckeditor/ckeditor-presets.git

Then, the registered submodules need to be updated:

	> git submodule update --init

## Running the Builder

The `build.sh` is the only file you should care about. It downloads CKBuilder, if necessary, and execute the building process.

This is the command syntax:

	> build.sh standard|basic|full [all]

The optional "all" argument tells the builder to include all plugins available in the ckeditor-dev repository, even if they're not included in the preset.

The build will be then created in the `build/[preset name]` folder.

Examples:

	> # Build a "standard" release.
	> build.sh standard

	> # Build a "basic" release, including all plugins available.
	> build.sh standard
