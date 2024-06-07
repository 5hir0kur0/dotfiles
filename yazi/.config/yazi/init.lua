function File:icon(file)
	local icon = file:icon()
	if not icon then
		return {}
	elseif file:is_hovered() then
		return { ui.Span(" " .. icon.text .. "  ") }
	else
		return { ui.Span(" " .. icon.text .. "  "):style(icon.style) }
	end
end
