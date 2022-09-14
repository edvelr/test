
if not myConfig then myConfig = {} end

myConfig.minNameLength = 3
myConfig.maxNameLength = 15
myConfig.minAddressLength = 5
myConfig.maxAddressLength = 80

function checkValidName(str)
	local len = utfLen(str)
	if len < myConfig.minNameLength then
		return false, "Имя/Фамилия слишком короткая, минимум " .. myConfig.minNameLength .. " символа"
	elseif len > myConfig.maxNameLength then
		return false, "Имя/Фамилия слишком короткая, максимум " .. myConfig.maxNameLength .. " символов"
	end

	return true
end
function checkValidAddress(str)
	local len = utfLen(str)
	if len < myConfig.minAddressLength then
		return false, "Адрес слишком короткий, минимум " .. myConfig.minAddressLength .. " символов"
	elseif len > myConfig.maxAddressLength then
		return false, "Адрес слишком длинный, максимум " .. myConfig.maxAddressLength .. " символов"
	end

	return true
end