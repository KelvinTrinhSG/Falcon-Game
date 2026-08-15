--!strict

local NumberFormatter = {}

local suffixes: {string} = {"", "K", "M", "B", "T", "Q"}

-- ## MODIFIED ## Changed to a more generic function that accepts an optional prefix.
function NumberFormatter.formatNumber(number: number, prefix: string?): string
	-- Use the provided prefix, or an empty string if none is given.
	local formattedString: string = prefix or ""
	local i: number = 1

	while number >= 1000 and i < #suffixes do
		number /= 1000
		i += 1
	end

	local suffix: string = suffixes[i]
	if suffix == "" then
		formattedString ..= tostring(math.floor(number))
	else
		formattedString ..= string.format("%.2f", number) .. suffix
	end

	return formattedString
end

return NumberFormatter