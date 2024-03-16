local numberUtil = {}

-- lol
function numberUtil.simplifyNumber(n)
	if n >= 10 ^ 45 then
		return string.format("%.2fQdc", n / 10 ^ 45)
	elseif n >= 10 ^ 42 then
		return string.format("%.2fTdc", n / 10 ^ 42)
	elseif n >= 10 ^ 39 then
		return string.format("%.2fDdc", n / 10 ^ 39)
	elseif n >= 10 ^ 36 then
		return string.format("%.2fUd", n / 10 ^ 36)
	elseif n >= 10 ^ 33 then
		return string.format("%.2fDc", n / 10 ^ 33)
	elseif n >= 10 ^ 30 then
		return string.format("%.2fNo", n / 10 ^ 30)
	elseif n >= 10 ^ 27 then
		return string.format("%.2fOc", n / 10 ^ 27)
	elseif n >= 10 ^ 24 then
		return string.format("%.2fSp", n / 10 ^ 24)
	elseif n >= 10 ^ 21 then
		return string.format("%.2fSx", n / 10 ^ 21)
	elseif n >= 10 ^ 18 then
		return string.format("%.2fQn", n / 10 ^ 18)
	elseif n >= 10 ^ 15 then
		return string.format("%.2fQd", n / 10 ^ 15)
	elseif n >= 10 ^ 12 then
		return string.format("%.2fT", n / 10 ^ 12)
	elseif n >= 10 ^ 9 then
		return string.format("%.2fB", n / 10 ^ 9)
	elseif n >= 10 ^ 6 then
		return string.format("%.2fM", n / 10 ^ 6)
	elseif n >= 10 ^ 3 then
		return string.format("%.2fK", n / 10 ^ 3)
	else
		return string.format("%.2f", n)
	end
end

return numberUtil
