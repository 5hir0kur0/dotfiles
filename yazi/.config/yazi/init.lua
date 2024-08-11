function Entity:icon()
	local icon = self._file:icon()
	if not icon then
		return ui.Line("")
	elseif self._file:is_hovered() then
		return ui.Line(" " .. icon.text .. "  ")
	else
		return ui.Line(" " .. icon.text .. "  "):style(icon.style)
	end
end

require("full-border"):setup()
