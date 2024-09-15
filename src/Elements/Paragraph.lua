local Root = script.Parent.Parent
local Components = Root.Components
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph:New(Config)
	assert(Config.Title, "Paragraph - Missing Title")
	Config.Content = Config.Content or ""

	local Paragraph = require(Components.Element)(Config.Title, Config.Content, Paragraph.Container, false)
	Paragraph.Frame.BackgroundTransparency = 0.92
	Paragraph.Border.Transparency = 0.6

	return Paragraph
end

function Paragraph:Update(OldParagraph, Title, Content)
	if OldParagraph.Title ~= Title then
	OldParagraph.Title = Title
	end
	
	if OldParagraph.Content ~= Content then
	OldParagraph.Content = Content
	end
	
	return Paragraph
end

return Paragraph
