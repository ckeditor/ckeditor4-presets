Forked from https://github.com/ckeditor/ckeditor-presets

Coatue CKEditor Builder
========================

### Get latest ckeditor core:

> git submodule update --init

---

### Create a new Plugin

1. Add your plugin to `/plugins` (see `/plugins/timestamp` for a basic example plugin).
2. Update `/presets/coatue-build-config.js` to include your fresh plugin.
3. Build using `./build.sh coatue`. The finished build will be in `/dist`

---

### Create a new Skin

1. Add your skin to `/skins` (see `/skins/coatue` for a basic skin example).
2. Update `/presets/coatue-build-config.js` to include your fresh skin.
3. Build using `./build.sh coatue`. The finished build will be in `/dist`
