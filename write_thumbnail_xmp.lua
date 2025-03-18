-- Darktable Lua script to write a thumbnail to the related XMP metadata file
-- so digiKam can display the thumbnail in the digiKam Light Table view.
-- 
-- Copyright (C) 2025  Michael Miller <michael underscore miller at msn dot com>
--
-- MIT License
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
-- documentation files (the “Software”), to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
-- to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions
-- of the Software.
--   
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


-- Uncomment the following 2 lines and replace with your values if the Lua library environment variables are not set
-- package.path = package.path .. ";/opt/hb-digikam.org.arm64/Cellar/luarocks/3.11.1/share/lua/5.4/?.lua"
-- package.cpath = package.cpath .. ";/opt/hb-digikam.org.arm64/lib/lua/5.4/?.so;/opt/hb-digikam.org.arm64/lib/lua/5.4/mime/?.so"

local dt = require "darktable"
local mime = require "mime"
local gettext = dt.gettext.gettext

local function _(msgid)
  return gettext(msgid)
end

-- Function to be called when Darktable exits
local function on_exit()
  dt.print("Darktable is exiting...")
  -- Add any additional cleanup or actions here
end

-- Function to create a thumbnail of the current image and get its base64 encoding
local function create_thumbnail()
  local selectedImages = dt.gui.selection()
  
  for _, image in ipairs(selectedImages) do

    dt.print(dt.configuration.cache_dir)
    image:generate_cache(true, 1, 2)

    -- Create the thumbnail image
    local temp_path = dt.configuration.tmp_dir .. "/thumbnail.jpg"  -- Use Darktable cache directory for the temporary path
    local exporter = dt.new_format("jpeg")
    exporter.quality = 85
    exporter.max_height = 200
    exporter.max_width = 200
    exporter:write_image(image, temp_path, false)
  
    -- Read the thumbnail and encode it in base64
    local file_content = nil
    local base64_content = nil
    local file = io.open(temp_path, "rb")
    if file then
      file_content = file:read("*all")
      file:close()
      base64_content = mime.b64(file_content)
    else
      dt.print("Failed to open thumbnail file: " .. temp_path)
      return
    end

    -- Delete the temporary thumbnail
    os.remove(temp_path)

    -- Check if the base64 encoding was successful
    if base64_content then
      local xmp_path = image.path .. "/" .. image.filename .. ".xmp"
      local xmp_file = io.open(xmp_path, "r")
      local xmp_temp_file = io.open(xmp_path .. ".tmp", "w")

      -- Copy the XMP file by reading it line by line and writing it to a new file
      if xmp_file and xmp_temp_file then
        local preview_written = false
        local previewsource_written = false
        for line in xmp_file:lines() do

          -- Skip the existing digiKam:PreviewSource property
          if not string.find(line, 'digiKam:PreviewSource=') then

            -- Write the new base64 encoded thumbnail to the digiKam:Preview property of the XMP file
            if string.find(line, 'digiKam:Preview=') and not preview_written then
              xmp_temp_file:write('   digiKam:Preview="' .. base64_content .. '"\n')
              preview_written = true
              if not previewsource_written then
                xmp_temp_file:write('   digiKam:PreviewSource="dkdtLuaThumbnail"\n')
                previewsource_written = true
              end
            else
              -- Write the line as is
              xmp_temp_file:write(line .. "\n")
              -- If the digiKam:Preview property is not present, add it after the xmp:Rating property
              if string.find(line, 'xmp:Rating=') and not preview_written then
                xmp_temp_file:write('   digiKam:Preview="' .. base64_content .. '"\n')
                preview_written = true
                if not previewsource_written then
                  xmp_temp_file:write('   digiKam:PreviewSource="dkdtLuaThumbnail"\n')
                  previewsource_written = true
                end
              end
            end
          end
        end
        xmp_file:close()
        xmp_temp_file:close()
        os.remove(xmp_path)
        os.rename(xmp_path .. ".tmp", xmp_path)
      else
        dt.print("Failed to open XMP file: " .. xmp_path)
      end        
    end

    -- Print a confirmation message
    dt.print("Thumbnail written to XMP metadata")
  
  end
end

-- -- Register the on_exit function to be called when Darktable exits
-- dt.register_event("shutdown", on_exit)

-- Register the create_thumbnail function to be called when a shortcut is pressed
dt.register_event("Create XMP Thumbnail", "shortcut", 
    function(event, shortcut)
      create_thumbnail()
    end, _("Create XMP Thumbnail")
  )
