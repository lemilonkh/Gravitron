local util = {}
local startTime = love.timer.getTime()

function util.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

-- rounds num towards 0 (to nearest integer)
function util.round(num)
	if num >= 0 then return math.floor(num + .5)
	else return math.ceil(num - .5) end
end

function util.random(min, max, precision)
	local range = max - min
	local offset = range * math.random()
	local unrounded = min + offset

	if not precision then
		return unrounded
	end

	local powerOfTen = 10 ^ precision
	return math.floor(unrounded * powerOfTen + 0.5) / powerOfTen
end

-- returns 2D simplex noise in range [min, max]
-- one dimension is time (measured since the start of the program), the other is the given seed
function util.timeNoise(min, max, seed)
	seed = seed or 0
	local time = love.timer.getTime() - startTime
	local scaledNoise = love.math.noise(seed, time) * (max - min) + min
	return scaledNoise
end

function util.rotateVector(x, y, angle)
  xRot = math.cos(angle) * x + math.sin(angle) * y
  yRot = math.sin(angle) * x + math.cos(angle) * y
  return xRot, yRot
end

-- returns a table containing all arguments
function util.pack(...)
	return { n = select("#", ...), ... }
end

-- get all keys contained in table (useful for non-contiguous tables, i.e. dictionaries)
function util.keys(tab)
    local keys, i = {}, 0
    for key, value in pairs(tab) do
        i = i + 1
        keys[i] = key
    end
    return keys
end

-- get all values contained in table (useful for non-contiguous tables, i.e. dictionaries)
function util.values(tab)
    local values, i = {}, 0
    for key, value in pairs(tab) do
        i = i + 1
        values[i] = value
    end
    return values
end

function util.removeValue(tab, value)
	local n = #tab

	-- remove all occurrences of value in tab
	for i = 1, n do
		if tab[i] == value then
			tab[i] = nil
		end
	end

    -- compact tab by filling up empty indices
	local j = 0
	for i = 1, n do
		if tab[i] ~= nil then
			j = j + 1
			tab[j] = tab[i]
		end
	end

    -- remove excess elements at end of tab
	for i = j + 1, n do
		tab[i] = nil
	end
end

return util