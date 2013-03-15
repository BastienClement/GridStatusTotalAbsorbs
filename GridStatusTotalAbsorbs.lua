--[[
	Copyright (c) 2013 Bastien Clément

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local GridRoster = Grid:GetModule("GridRoster")
local GridStatus = Grid:GetModule("GridStatus")

local GridStatusTotalAbsorbs = GridStatus:NewModule("GridStatusTotalAbsorbs")

GridStatusTotalAbsorbs.defaultDB = {
	unit_total_absorbs = {
		color = { r = 0.7, g = 0.7, b = 1.0, a = 1.0 },
		text = "Total Absorbs",
		enable = true,
		priority = 30,
		range = false
	}
}

GridStatusTotalAbsorbs.menuName = "Total Absorbs"
GridStatusTotalAbsorbs.options = false

local settings

function GridStatusTotalAbsorbs:OnInitialize()
	self.super.OnInitialize(self)
	self:RegisterStatus("unit_total_absorbs", "Total Absorbs", nil, true)
	settings = self.db.profile.unit_total_absorbs
end

function GridStatusTotalAbsorbs:OnStatusEnable(status)
	if status == "unit_total_absorbs" then
		self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
		self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
		self:UpdateAllUnits()
	end
end

function GridStatusTotalAbsorbs:OnStatusDisable(status)
	if status == "unit_total_absorbs" then
		for guid, unitid in GridRoster:IterateRoster() do
			self.core:SendStatusLost(guid, "unit_total_absorbs")
		end
		self:UnregisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
		self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
	end
end

function GridStatusTotalAbsorbs:Reset()
	self.super.Reset(self)
	self:UpdateAllUnits()
end

function GridStatusTotalAbsorbs:UpdateAllUnits()
	for guid, unitid in GridRoster:IterateRoster() do
		self:UpdateUnitAbsorbs(unitid)
	end
end

function GridStatusTotalAbsorbs:UpdateUnit(_, unitid)
	self:UpdateUnitAbsorbs(unitid)
end

function GridStatusTotalAbsorbs:UpdateUnitAbsorbs(unitid)
	local abs, max = UnitGetTotalAbsorbs(unitid), UnitHealthMax(unitid)
	local guid = UnitGUID(unitid)

	if abs == 0 then
		self.core:SendStatusLost(guid, "unit_total_absorbs")
	else
		self.core:SendStatusGained(
			guid,
			"unit_total_absorbs",
			settings.priority,
			nil,
			settings.color,
			(abs > 0 and tostring(abs) or nil),
			abs,
			max,
			nil
		)
	end
end
