
local widget = require( "widget" )
local json = require("json")

local currentLatitude = 0
local currentLongitude = 0

local testMode = true

display.setStatusBar( display.HiddenStatusBar )

display.setDefault( "anchorX", 0.0 )	-- default to Left anchor point


local latitude = display.newText( "--", 0, 0, native.systemFont, 26 )

latitude.anchorX = 0
latitude.x, latitude.y = 135, 64
latitude:setFillColor( 1, 85/255, 85/255 )

local longitude = display.newText( "--", 0, 0, native.systemFont, 26 )
longitude.x, longitude.y = 135, latitude.y + 50
longitude:setFillColor( 1, 85/255, 85/255 )

display.setDefault( "anchorX", 0.5 )	-- default to Center anchor point


local locationHandler = function( event )

	-- Check for error (user may have turned off Location Services)
	if event.errorCode then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
		print( "Location error: " .. tostring( event.errorMessage ) )
	else
	
		local latitudeText = string.format( '%.3f', event.latitude )
		currentLatitude = latitudeText
		latitude.text = latitudeText
		
		local longitudeText = string.format( '%.3f', event.longitude )
		currentLongitude = longitudeText
		longitude.text = longitudeText
		
	end
end

local jsonFile = function( filename, base )

	-- set default base dir if none specified
	if not base then base = system.ResourceDirectory; end

	-- create a file path for corona i/o
		local path = system.pathForFile( filename, base )

	-- will hold contents of file
		local contents

	-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "r" )
		if file then
		-- read all contents of file into a string
		contents = file:read( "*a" )
		io.close( file ) -- close the file after using it
	end

	return contents
end

function print_r(arr, indentLevel)
    local str = {}

    for index,value in pairs(arr) do
            str[index] = value
    end
    return str
end

local function networkListener( event )
	if ( event.isError ) then
		print( "Network error!")
	else
		--print ( "RESPONSE: " .. event.response )
		local t = json.decode( event.response )
		
	
		
		
		-- Status with capital S is checked for cases where no data is returned at all
		if t.Status == nil then
			--if this table does not exist, then data should exist
			
			if testMode == true then
				print(t.geoLocation)
				print(t.stations)
				print(t.status)
				print("--------------------")
			end
			
			-- Go through the array in a loop
			for key, value in pairs(t.stations) do
				-- Here you can do whatever you like with the values
				local temp_table = t.stations[key]
				local station_info
				
				if type(value) == "table" then
					--grabs the next station value
					station_info = print_r(temp_table)
					
					--currently this is string data, but should be a table of the relevant information instead
					print(station_info.reg_price)
					
					
					
					
				else
					print("not a table")
				end
				
			end
			
		else
			--case where no data is returned at all for some reason
			print_r(t)
		end
		
		
		
		
		

	end
end

	
-- Activate location listener
Runtime:addEventListener( "location", locationHandler )


local gas_call = "http://api.mygasfeed.com/stations/radius/" .. latitude.text .. "/" .. longitude.text .. "/2" .. "/reg/price/ik3c9jau1p.json?"


local json_file_get = jsonFile( network.request( gas_call, "GET", networkListener ) )


