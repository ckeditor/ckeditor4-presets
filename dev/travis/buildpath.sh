#!/bin/bash
# Copyright (c) 2003-2023, CKSource Holding sp. z o.o. All rights reserved.
# For licensing, see https://ckeditor.com/legal/ckeditor-oss-license

# Return CKEditor build path.

echo "./build/$(ls -1t ./build/ | head -n 1)/full-all/ckeditor/"
