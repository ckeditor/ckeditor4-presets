/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	config.height = '100%'

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
    { name: 'basic', groups: ['basicstyles', 'cleanup', 'list', 'indent', 'undo', 'insert'] }
  ]

	config.extraAllowedContent = 'title'

	// sharedspace  -- allows multiple editor instances to share the same toolbar
  // indentblock  -- enables indent/outdent feature
  config.extraPlugins = 'divarea,sharedspace,indentblock'

		// Remove some buttons provided by the standard plugins, which are
		// not needed in the Standard(s) toolbar.
	config.removeButtons = 'Strike,Subscript,Superscript'

		// Set the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre'

	// Simplify the dialog windows.
  config.removeDialogTabs = 'image:advanced;link:advanced'

	// see http://docs.ckeditor.com/#!/api/CKEDITOR.config-cfg-sharedSpaces
	config.sharedSpaces = {
    top: 'text-editor-toolbar'
  }

};
