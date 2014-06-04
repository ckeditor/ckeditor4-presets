/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

var CKBUILDER_CONFIG = {
	skin: 'moono',
	ignore: [
		'dev',
		'.gitignore',
		'.gitattributes',
		'README.md',
		'.mailmap',
		'.idea',
		'.DS_Store',
		'tests',
		'package.json',
		'bender.js',
		'.bender',
		'bender-err.log',
		'bender-out.log',
		'node_modules'
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
