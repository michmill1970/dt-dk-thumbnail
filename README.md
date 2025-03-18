# dt-dk-thumbnail
### A small Darktable Lua script to save the edited thumbnail to the .xmp sidecar

## Overview
The dt-dk-thumbnail Lua script solves a long standing challenge for people who love the digital asset management capabilities of [digiKam](https://www.digikam.org), but want to use [Darktable](https://www.darktable.org) for image editing.

The script writes a thumbnail image of the edited Darktable image to the .xmp sidecar. digiKam will use the thumbnail in the .xmp sidecar instead of generating a thumbnail from the embedded preview in the image file.

The thumbnail is used for all thumbnail/icon views in digiKam. Larger images used for full-screen display and for editing do not use the Darktable thumbmail.

## Application Configuration

There are a few settings in digiKam and Darktable that must be configured correctly for the script to work. These settings are different from the default settings.

##### Darktable - Darktable Preferences

- Storage - store XMP Tags in compressed format: never
- Storage - look for updated XMP files on startup: checked

##### Darktable - darktablerc (optional)

- database=:memory:
**Note:** This will disable the Darktable database.  All edits and changes will be stored in the .xmp sidecar.  The Darktable database will be empty each time you start Darktable.

##### digiKam - Settings

- Metadata->Behavior - Rescan file when files are modified
- Metadata->Sidecars - Read from sidecar files: checked
- Metadata->Sidecars - Write to sidecar files: checked (optional)
- Metadata->Sidecars - Write to XMP sidecar only (optional)

## Installation

### Dependencies

##### Luarocks and LuaSocket

The dt-dk-thumbnail Lua script requires the [Luarocks](https://luarocks.org/) Lua package manager and the [LuaSocket](https://luarocks.org/modules/lunarmodules/luasocket) package.

Please follow the directions for your platform for installing Luarocks and LuaSocket.

**Note:** After installing Luarocks and the LuaSocket package, please make sure the proper Lua environment variables are exported on your computer. Because Darktable is typically launched from digiKam, adding the environment variable exports in the .bash_profile or .zshrc typically doesn't work. Please see the documentation for your platform to ensure the environment variables are accessible by applications launched by your desktop.

##### Darktable - Lua

Please see the [Darktable Lua documentation](https://docs.darktable.org/lua/stable/lua.scripts.manual/installation/) to ensure Lua is installed and working in your Darktable install.

##### Darktable - Installing the script

Installing a Lua script for Darktable requires the user to copy the script to a directory under Darktable's Lua directory. While the script in in development, it is strongly recommended you create a subdirectory called "experimental" in the Darktable Lua directory, and copy the write_thumbnail_xmp.lua script into the "experimental" directory.

##### Darktable - Activating the script

Start Darktable after the script is installed. You should see a new Lua script called "Create XMP Thumbnail" in the Experimental directory. Watch the center of the Darktable window carefully when enabling the script for any error messages.

##### Darktable - Assigning a keyboard shortcut

To export thumbnails to digiKam, you need to assign a keyboard shortcut to run the "Create XMP Thumbnail" Lua script. Please see the [Darktable documentation](https://docs.darktable.org/usermanual/development/en/preferences-settings/shortcuts/) for how to assign a keyboard shortcut. I like to use Ctrl+Shift+0 because it is not presently assigned to any functions in Darktable.

## Exporting Thumbnails

Exporting thumbnails to the XMP file is done in Darktable's lighttable view.  Select the image(s) you want to view the thumbnails for in digiKam, and then press the keyboard shortcut combination you configured in the previous step.  If the script and dependencies were installed correctly, the thumbnail is written to the .xmp sidecar.

## Viewing the thumbnails in digiKam

To view the thumbnails in digiKam, in the main menu navigate to Album->Reread metadata from files.  After a few seconds, the thumbnails in the center view should show the edited Darktable image.

## Known issues

- Thumbnail rotation is incorrect for portrait orientation images in digiKam version 8.6.0 and earlier.  Fixed in digiKam 8.7.0.