local longdan = fk.CreateSkill {
  name = "yi__longdan",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["yi__longdan"] = "龙胆",
  [":yi__longdan"] = "转换技，当你需要使用基本牌时，阴：你可弃一张牌并视为使用之；阳：你可摸一张牌并令你本回合不能使用此牌名的牌。",
  ["#yi__longdan_choose-yang"] = "龙胆：选择一种基本牌，弃一张牌并视为使用之。",
  ["#yi__longdan_choose-yin"] = "龙胆：选择一种基本牌，摸一张牌并令你本回合不能使用之。",
  ["#yi__longdan-yin"] = "弃置一张牌并视为使用%arg",
  ["#yi__longdan_prohibit"] = "龙胆",
  ["@yi__longdan-turn"] = "龙胆",

  ["$yi__longdan1"] = "保驾扶危主，冲阵透重围！",
  ["$yi__longdan2"] = "银枪映豪胆，赤血鉴忠心！",
}

longdan:addEffect("viewas", {
  anim_type = "switch",
  pattern = ".|.|.|.|.|basic",
  prompt = function(self, player)
    return "#yi__longdan_choose-" .. player:getSwitchSkillState(longdan.name, false, true)
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b", true)
    local names = player:getViewAsCardNames(longdan.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = longdan.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    if player:getSwitchSkillState(longdan.name, false) == fk.SwitchYin then
      local cards = room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = longdan.name,
        cancelable = false,
        pattern = ".",
        prompt = "#yi__longdan-yin:::" .. use.card:toLogString(),
      })
      if #cards > 0 then return end
    elseif player:getSwitchSkillState(longdan.name, false) == fk.SwitchYang then
      room:addTableMark(player, "@yi__longdan-turn", use.card.trueName)
      player:drawCards(1, longdan.name)
    end
    return longdan.name
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
})

longdan:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return table.contains(player:getTableMark("@yi__longdan-turn"), card.trueName)
  end,
})


return longdan

-- -- 赵云
-- local zhaoyun = General(extension, "yi__zhaoyun", "shu", 4)
-- local longdan = fk.CreateViewAsSkill{
--   name = "yi__longdan",
--   anim_type = "switch",
--   switch_skill_name = "yi__longdan",
--   prompt = function(self)
--     return "#yi__longdan_choose-"..Self:getSwitchSkillState(self.name, false, true)
--   end,
--   pattern = ".|.|.|.|.|basic",
--   interaction = function()
--     local all_names = U.getAllCardNames("b", true)
--     local names = U.getViewAsCardNames(Self, "shizong", all_names)
--     if #names == 0 then return false end
--     return UI.ComboBox { choices = names, all_choices = all_names }
--   end,
--   card_filter = Util.FalseFunc,
--   view_as = function(self)
--     if not self.interaction.data then return end
--     local card = Fk:cloneCard(self.interaction.data)
--     card.skillName = self.name
--     return card
--   end,
--   before_use = function(self, player, use)
--     local room = player.room
--     if player:getSwitchSkillState(self.name, false) == fk.SwitchYin then
--       local card = room:askForDiscard(player, 1, 1, true, self.name,
--        false, ".", "#yi__longdan-yin:::"..use.card.name, false)
--       if #card > 0 then return end
--     elseif player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
--       room:addTableMark(player, "@yi__longdan-turn", use.card.name)
--       room:drawCards(player, 1, self.name)
--     end
--     return self.name
--   end,
--   enabled_at_play = function(self, player)
--     return true
--   end,
--   enabled_at_response = function(self, player, response)
--     return not response
--   end,
-- }
-- local longdan_prohibit = fk.CreateProhibitSkill{
--   name = "#yi__longdan_prohibit",
--   prohibit_use = function(self, player, card)
--     return table.contains(player:getTableMark("@yi__longdan-turn"), card.trueName)
--   end,
-- }
-- longdan:addRelatedSkill(longdan_prohibit)
-- zhaoyun:addSkill(longdan)
-- Fk:loadTranslationTable{
--   ["yi__zhaoyun"] = "异赵云",
--   ["#yi__zhaoyun"] = "虎将龙胆",
--   ["designer:yi__zhaoyun"] = "KidUnion",
--   ["yi__longdan"] = "龙胆",
--   [":yi__longdan"] = "转换技，当你需要使用基本牌时，阴：你可弃一张牌并视为使用之；阳：你可摸一张牌并令你本回合不能使用此牌名的牌。",
--   ["#yi__longdan_choose-yang"] = "龙胆：选择一种基本牌，弃一张牌并视为使用之。",
--   ["#yi__longdan_choose-yin"] = "龙胆：选择一种基本牌，摸一张牌并令你本回合不能使用之。",
--   ["#yi__longdan-yin"] = "弃置一张牌并视为使用%arg",
--   ["#yi__longdan_prohibit"] = "龙胆",
--   ["@yi__longdan-turn"] = "龙胆",
  
--   ["$yi__longdan1"] = "保驾扶危主，冲阵透重围！",
--   ["$yi__longdan2"] = "银枪映豪胆，赤血鉴忠心！",

--   ["~yi__zhaoyun"] = "生驱单骑摧敌锐，死作忠魂佑主周！",
-- }
