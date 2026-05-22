-- Add more spacing after icons
function Entity:icon()
	local icon = self._file:icon()
	if not icon then
		return ""
	elseif self._file.is_hovered then
		return icon.text .. "  "
	else
		return ui.Line(icon.text .. "  "):style(icon.style)
	end
end

require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}
require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}
