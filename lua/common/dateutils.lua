-- 
-- lua/common/dateutils.lua
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 

local date_fmt = "%Y-%m-%dT%T"

local function addMinutes(min,d)
	d = d or os.date()
	local t=os.time()
	t = t + min * 60
	return os.date(date_fmt,t)
end

local function addHours(hour,d)
	d = d or os.date()
	local t=os.time()
	t = t + hour * 60 * 60
	return os.date(date_fmt,t)
end

local function addDays(day,d)
	d = d or os.date()
	local t=os.time()
	t = t + day * 24 * 60 * 60
	return os.date(date_fmt,t)
end

local function getDate()
	return os.date(date_fmt)
end

local function setFormat(fmt)
	date_fmt = fmt or "%c"
end

return {
	addMinutes = addMinutes,
	addHours = addHours,
	addDays = addDays,
	getDate = getDate,
	setFormat = setFormat
}