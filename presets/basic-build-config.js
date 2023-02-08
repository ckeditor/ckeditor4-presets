/**
 * @license Copyright (c) 2003-2023, CKSource Holding sp. z o.o. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

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
		toolbar: 1,
		undo: 1,
		wysiwygarea: 1
	}
};
