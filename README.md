CKEditor 4 Presets Builder
==========================

This builder is a tool that creates CKEditor release files for the main "preset" configurations officially distributed at <https://ckeditor.com/>. It is targeted to the CKEditor core team, to test the preset builds, to update the ckeditor.com website on new releases and to generate the [nightly builds](https://nightly.ckeditor.com/).

A preset is a CKEditor configuration for building that includes a specific set of plugins. Currently, there are 3 presets defined: **standard**, **basic** and **full**.

The original source code from the official CKEditor repositories is used for the build.

## Cloning this Code

To clone this code:

	> git clone https://github.com/ckeditor/ckeditor4-presets.git

Then, the registered submodules need to be updated:

	> git submodule update --init

## Running the Builder

The `build.sh` is the only file you should care about. It downloads CKBuilder, if necessary, and execute the building process.

This is the command syntax:

	> build.sh standard|basic|full [all]

The optional "all" argument tells the builder to include all plugins available in the `ckeditor4` repository, even if they're not included in the preset.

The build will be then created in the `build/[preset name]` folder.

Examples:

	> # Build a "standard" release.
	> build.sh standard

	> # Build a "basic" release, including all plugins available.
	> build.sh basic all

## Creating custom Presets

Apart from using predefined presets, you can create a custom preset manually and use it with the `build.sh` script. As an example, let's create a preset including basic configuration with the [Editor Placeholder](https://ckeditor.com/cke4/addon/editorplaceholder) plugin.

### 1. Adding the build configuration file

Create a builder configuration file at `presets/custom-build-config.js`:

```js
var CKBUILDER_CONFIG = {
	skin: 'moono-lisa',
	ignore: [
		'bender.js',
		'bender.ci.js',
		'.bender',
		'bender-err.log',
		'bender-out.log',
		'.travis.yml',
		'dev',
		'.DS_Store',
		'.editorconfig',
		'.github',
		'.gitignore',
		'.gitattributes',
		'gruntfile.js',
		'.idea',
		'.jscsrc',
		'.jshintignore',
		'.jshintrc',
		'less',
		'.mailmap',
		'node_modules',
		'.npm',
		'.nvmrc',
		'package.json',
		'package-lock.json',
		'README.md',
		'tests'
	],
	plugins: {
		about: 1,
		basicstyles: 1,
		clipboard: 1,
		floatingspace: 1,
		list: 1,
		indentlist: 1,
		enterkey: 1,
		entities: 1,
		link: 1,
		editorplaceholder: 1,
		toolbar: 1,
		undo: 1,
		wysiwygarea: 1
	}
};
```

### 2. Adding the editor configuration file

Create an editor configuration file at `presets/custom-ckeditor-config.js`:

```js
CKEDITOR.editorConfig = function( config ) {
	// The toolbar groups arrangement, optimized for a single toolbar row.
	config.toolbarGroups = [
		{ name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ] },
		{ name: 'forms' },
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ] },
		{ name: 'links' },
		{ name: 'insert' },
		{ name: 'styles' },
		{ name: 'colors' },
		{ name: 'tools' },
		{ name: 'others' },
		{ name: 'about' }
	];

	// The default plugins included in the basic setup define some toolbar buttons that
	// are not needed in a basic editor. These are removed here.
	config.removeButtons = 'Cut,Copy,Paste,Undo,Redo,Anchor,Underline,Strike,Subscript,Superscript';

	// Dialog windows are also simplified.
	config.removeDialogTabs = 'link:advanced';

	// Finally, configure editor placeholder text.
	config.editorplaceholder = 'Type something here...';
};
```

### 3. Building a custom preset

Run `build.sh` file:

	> # Build a custom "custom" preset.
	> build.sh custom
