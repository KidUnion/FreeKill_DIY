local extension = Package:new("yi")
extension.extensionName = "FreeKill_DIY"

extension:loadSkillSkelsByPath("./packages/FreeKill_DIY/pkg/yi/skills")

Fk:loadTranslationTable{
  ["yi"] = "异包",
}

General:new(extension, "yi__huanggai", "wu", 4):addSkills { "ex__kurou", "yi__zhaxiang" }
Fk:loadTranslationTable{
  ["yi__huanggai"] = "异黄盖",
  ["#yi__huanggai"] = "轻身焚舰",
  ["designer:yi__huanggai"] = "KidUnion",

  ["$ex__kurou_yi__huanggai1"] = "我这把老骨头，不算什么！",
  ["$ex__kurou_yi__huanggai2"] = "为成大业，死不足惜！",
  ["~yi__huanggai"] = "盖，有负公瑾重托……",
}

General:new(extension, "yi__diaochan", "qun", 3, 3, General.Female):addSkills { "yi__lijian", "yi__biyue" }
Fk:loadTranslationTable{
  ["yi__diaochan"] = "异貂蝉",
  ["#yi__diaochan"] = "乱世舞姬",
  ["designer:yi__diaochan"] = "KidUnion",

  ["~yi__diaochan"] = "舞罢人散，独留孤影……",
}

General:new(extension, "yi__luxun", "wu", 3):addSkills { "yi__qianxun", "yi__lianying" }
Fk:loadTranslationTable{
  ["yi__luxun"] = "异陆逊",
  ["#yi__luxun"] = "儒生雄才",
  ["designer:yi__luxun"] = "KidUnion",

  ["~yi__luxun"] = "我的未竟之业……",
}

General:new(extension, "yi__zhugeliang", "shu", 3):addSkills { "yi__guanxing", "yi__kongcheng" }
Fk:loadTranslationTable{
  ["yi__zhugeliang"] = "异诸葛亮",
  ["#yi__zhugeliang"] = "忠武智绝",
  ["designer:yi__zhugeliang"] = "KidUnion",

  ["~yi__zhugeliang"] = "将星陨落，天命难违……",
}

General:new(extension, "yi__guanyu", "shu", 4):addSkills { "yi__wusheng", "yi__yijue" }
Fk:loadTranslationTable{
  ["yi__guanyu"] = "异关羽",
  ["#yi__guanyu"] = "美髯公",
  ["designer:yi__guanyu"] = "KidUnion",

  ["~yi__guanyu"] = "桃园一拜，恩义常在……",
}

General:new(extension, "yi__zhangliao", "wei", 4):addSkills { "yi__tuxi" }
Fk:loadTranslationTable{
  ["yi__zhangliao"] = "异张辽",
  ["#yi__zhangliao"] = "震津止啼",
  ["designer:yi__zhangliao"] = "KidUnion",

  ["~yi__zhangliao"] = "被敌人占了先机啊……",
}

-- General:new(extension, "yi__wangping", "shu", 4):addSkills { "yi__feijun", "yi__binglue" }
-- Fk:loadTranslationTable{
--   ["yi__wangping"] = "异王平",
--   ["#yi__wangping"] = "兵谋以致用",
--   ["designer:yi__wangping"] = "KidUnion",

--   ["$yi__feijun1"] = "无当飞军，伐叛乱，镇蛮夷！",
--   ["$yi__feijun2"] = "山地崎岖，也挡不住飞军破势！",
--   ["$yi__binglue1"] = "奇略兵速，敌未能料之。",
--   ["$yi__binglue2"] = "兵略者，明战胜攻取之数，形机之势，诈谲之变。",
--   ["~yi__wangping"] = "无当飞军，也有困于深林之时……",
-- }

-- General:new(extension, "yi__zhaoyun", "shu", 4):addSkills { "yi__longdan" }
-- Fk:loadTranslationTable{
--   ["yi__zhaoyun"] = "异赵云",
--   ["#yi__zhaoyun"] = "虎将龙胆",
--   ["designer:yi__zhaoyun"] = "KidUnion",
  
--   ["$yi__longdan1"] = "保驾扶危主，冲阵透重围！",
--   ["$yi__longdan2"] = "银枪映豪胆，赤血鉴忠心！",
--   ["~yi__zhaoyun"] = "生驱单骑摧敌锐，死作忠魂佑主周！",
-- }

General:new(extension, "yi__yuanshu", "qun", 3):addSkills { "yi__wangzun", "yi__tongji" }
Fk:loadTranslationTable{
  ["yi__yuanshu"] = "异袁术",
  ["#yi__yuanshu"] = "冢中枯骨",
  ["designer:yi__yuanshu"] = "KidUnion",

  ["~yi__yuanshu"] = "蜜水……蜜水……",
}

General:new(extension, "yi__zhenji", "wei", 3, 3, General.Female):addSkills { "yi__luoshen", "yi__qingguo" }
Fk:loadTranslationTable{
  ["yi__zhenji"] = "异甄姬",
  ["#yi__zhenji"] = "洛水神女",
  ["designer:yi__zhenji"] = "KidUnion",

  ["~yi__zhenji"] = "悼良会之永绝兮，哀一逝而异乡。",
}

General:new(extension, "yi__zhouyu", "wu", 3):addSkills { "yi__fanjian", "yi__yingzi" }
Fk:loadTranslationTable{
  ["yi__zhouyu"] = "异周瑜",
  ["#yi__zhouyu"] = "雄姿英发",
  ["designer:yi__zhouyu"] = "KidUnion",

  ["~yi__zhouyu"] = "既生瑜，何生……",
}

return extension

-- -- 王平
-- local wangping = General(extension, "yi__wangping", "shu", 4)
-- Fk:addQmlMark{
--   name = "yi__feijun",
--   qml_path = "",
--   how_to_show = function(name, value, p)
--     local x = p:getMark("#yi__feijun") + 1
--     if x > 1 then
--       return Fk:translate(Util.PhaseStrMapper(x))
--     end
--     return " "
--   end,
-- }
-- local feijun = fk.CreateTriggerSkill{
--   name = "yi__feijun",
--   anim_type = "special",
--   events = {fk.EventPhaseEnd},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.phase == player:getMark("#yi__feijun") + 1
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local cards = {}
--     local _, ret = room:askForUseActiveSkill(player, "yi__feijun_active", "#yi__feijun-invoke", false)
--     if ret then
--       cards = ret.cards
--     end
--     if #cards == 0 then return end
--     room:throwCard(cards, self.name, player, player)
--     player.room:addTableMark(player, "@yi__feijun-turn", Fk:getCardById(cards[1]):getSuitString(true))
--     if player.dead then return end
--     if room:askForChoice(player, {"#yi__feijun_draw", "#yi__feijun_slash"}, self.name, "#yi__feijun_choose") == "#yi__feijun_draw" then
--       local num = player.maxHp - player:getHandcardNum()
--       if num > 0 then
--         room:drawCards(player, num, self.name)
--       end
--       local phase = math.min(player:getMark("#yi__feijun") + #cards, 6)
--       room:setPlayerMark(player, "#yi__feijun", phase)
--     else
--       U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#yi__feijun-slash", 
--       false, true, true)
--       local phase = math.max(player:getMark("#yi__feijun") - #cards, 1)
--       room:setPlayerMark(player, "#yi__feijun", phase)
--     end
--   end,

--   on_acquire = function (self, player)
--     player.room:setPlayerMark(player, "@[yi__feijun]", 1)
--     player.room:setPlayerMark(player, "#yi__feijun", 1)
--   end,
--   on_lose = function (self, player)
--     player.room:setPlayerMark(player, "@[yi__feijun]", 0)
--     player.room:setPlayerMark(player, "#yi__feijun", 0)
--   end,
-- }
-- local feijun_active = fk.CreateActiveSkill{
--   name = "yi__feijun_active",
--   mute = true,
--   card_filter = function(self, to_select, selected)
--     if Self:prohibitDiscard(Fk:getCardById(to_select)) then return false end
--     if #selected == 0 then
--       return not table.contains(Self:getTableMark("@yi__feijun-turn"), 
--       Fk:getCardById(to_select):getSuitString(true))
--     else
--       return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
--     end
--   end,
-- }
-- Fk:addSkill(feijun_active)
-- local binglue = fk.CreateTriggerSkill{
--   name = "yi__binglue",
--   anim_type = "special",
--   events = {fk.TurnEnd},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and #player:getTableMark("@yi__binglue-turn") > 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     self.cost_data = #player:getTableMark("@yi__binglue-turn") + 1
--     if room:askForSkillInvoke(player, self.name, nil, "#yi__binglue-invoke:::"..Util.PhaseStrMapper(self.cost_data)) then
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     player:gainAnExtraPhase(self.cost_data)
--   end,
  
--   refresh_events = {fk.TurnStart, fk.AfterCardsMove},
--   can_refresh = function(self, event, target, player, data)
--     if event == fk.TurnStart then
--       return player == target
--     elseif player.room.current == player then
--       local mark = player:getMark("@yi__binglue-turn")
--       if type(mark) == "table" then
--         return #mark < 4
--       else
--         return player:hasSkill(self, true)
--       end
--     end
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.TurnStart then
--       if player:hasSkill(self, true) then
--         player.room:setPlayerMark(player, "@yi__binglue-turn", {})
--       elseif player:usedSkillTimes(self.name, Player.HistoryRound) > 0 then
--         player:setSkillUseHistory(self.name, 0, Player.HistoryRound)
--       end
--     else
--       for _, move in ipairs(data) do
--         if move.toArea == Card.DiscardPile then
--           for _, info in ipairs(move.moveInfo) do
--             local suit = Fk:getCardById(info.cardId):getSuitString(true)
--             if not table.contains(player:getTableMark("@yi__binglue-turn"), suit) then
--               room:addTableMark(player, "@yi__binglue-turn", suit)
--             end
--           end
--         end
--       end
--     end
--   end,

--   on_acquire = function (self, player, is_start)
--     local room = player.room
--     if player ~= player.room.current then return end
--     local mark = {}
--     room.logic:getEventsOfScope(GameEvent.MoveCards, 999, function(e)
--       for _, move in ipairs(e.data) do
--         if move.toArea == Card.DiscardPile then
--           for _, info in ipairs(move.moveInfo) do
--             local card = Fk:getCardById(info.cardId)
--             if card and card.suit ~= Card.NoSuit then
--               table.insertIfNeed(mark, card:getSuitString(true))
--             end
--           end
--         end
--       end
--     end, Player.HistoryTurn)
--     room:setPlayerMark(player, "@yi__binglue-turn", #mark > 0 and mark or 0)
--   end,
--   on_lose = function (self, player, is_start)
--     player.room:setPlayerMark(player, "@yi__binglue-turn", 0)
--   end,
-- }
-- wangping:addSkill(feijun)
-- wangping:addSkill(binglue)
-- Fk:loadTranslationTable{
--   ["yi__wangping"] = "异王平",
--   ["#yi__wangping"] = "兵谋以致用",
--   ["designer:yi__wangping"] = "KidUnion",
--   ["yi__feijun"] = "飞军",
--   [":yi__feijun"] = "每回合每种花色限一次，准备阶段结束时，你可弃置任意张花色相同的牌并视为使用一张无距离限制的【杀】/将手牌摸至体力上限，"..
--   "然后此技能的发动时机提前/延后至多等量个阶段。",
--   ["yi__binglue"] = "兵略",
--   [":yi__binglue"] = "你的回合结束时，你可执行本回合的第X个阶段。（X为本回合进入弃牌堆的花色数）",
--   ["@[yi__feijun]"] = "飞军",
--   ["yi__feijun_active"] = "飞军",
--   ["@yi__feijun-turn"] = "飞军",
--   ["#yi__feijun"] = "飞军",
--   ["#yi__feijun-invoke"] = "发动【飞军】，弃置相同花色的任意张牌",
--   ["#yi__feijun_choose"] = "飞军：选择摸牌至体力上限或视为使用【杀】",
--   ["#yi__feijun_draw"] = "将手牌摸至体力上限",
--   ["#yi__feijun_slash"] = "视为使用【杀】",
--   ["#yi__feijun-slash"] = "飞军：视为使用一张无距离限制的【杀】",
--   ["@yi__binglue-turn"] = "兵略",
--   ["#yi__binglue-invoke"] = "发动【兵略】，执行一个%arg",

--   ["$yi__feijun1"] = "无当飞军，伐叛乱，镇蛮夷！",
--   ["$yi__feijun2"] = "山地崎岖，也挡不住飞军破势！",
--   ["$yi__binglue1"] = "奇略兵速，敌未能料之。",
--   ["$yi__binglue2"] = "兵略者，明战胜攻取之数，形机之势，诈谲之变。",
--   ["~yi__wangping"] = "无当飞军，也有困于深林之时……",
-- }

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

-- -- 袁术
-- local yuanshu = General(extension, "yi__yuanshu", "qun", 3)
-- local wangzun = fk.CreateTriggerSkill{
--   name = "yi__wangzun",
--   anim_type = "special",
--   events = {fk.TurnStart},
--   can_trigger = function(self, event, target, player, data)
--     return target.seat == 1 and player:hasSkill(self) and #target:getCardIds("he") > 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     if room:askForSkillInvoke(player, self.name, nil, "#yi__wangzun-invoke::"..target.id) then
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local card1 = room:askForCardChosen(player, target, "he", self.name)
--     if not card1 then return false end
--     room:obtainCard(player, card1, false, fk.ReasonPrey, player.id, self.name)
--     local card2 = room:askForCard(player, 1, 1, true, self.name, true, ".", "#yi__wangzun-give::"..target.id)
--     if #card2 == 0 then return false end
--     room:obtainCard(target, card2, false, fk.ReasonPrey, player.id, self.name)
--     player:gainAnExtraPhase(Player.Play)
--   end,
-- }
-- local tongji = fk.CreateViewAsSkill{
--   name = "yi__tongji",
--   prompt = "#yi__tongji",
--   anim_type = "offensive",
--   interaction = function(self)
--     local all_names = U.getAllCardNames("bt")
--     local names = table.filter(all_names, function (name)
--       local card = Fk:cloneCard(name)
--       card.skillName = self.name
--       return Self:canUse(card) and not Self:prohibitUse(card) and card.is_damage_card and not table.contains(
--       Self:getTableMark("yi__tongji_used"), name)
--     end)
--     if #names == 0 then return end
--     return UI.ComboBox {choices = names}
--   end,
--   card_num = 0,
--   view_as = function(self)
--     if not self.interaction.data then return end
--     local card = Fk:cloneCard(self.interaction.data)
--     card.skillName = self.name
--     return card
--   end,
--   enabled_at_play = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
--   end,
--   after_use = function(self, player, use)
--     if not use.card then return end
--     player.room:addTableMark(player, "yi__tongji_used", use.card.name)
--   end,
-- }
-- local tongji_trigger = fk.CreateTriggerSkill{
--   name = "#yi__tongji_trigger",
--   refresh_events = {fk.PreCardEffect},
--   can_refresh = function(self, event, target, player, data)
--     return player:hasSkill("yi__tongji") and table.contains(player:getTableMark("yi__tongji_used"), data.card.name)
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, "yi__tongji", "negative")
--     data.disresponsiveList = data.disresponsiveList or {}
--     table.insertIfNeed(data.disresponsiveList, player.id)
--   end,
-- }
-- wangzun:addRelatedSkill(tongji_trigger)
-- yuanshu:addSkill(wangzun)
-- yuanshu:addSkill(tongji)
-- Fk:loadTranslationTable{
--   ["yi__yuanshu"] = "异袁术",
--   ["#yi__yuanshu"] = "冢中枯骨",
--   ["designer:yi__yuanshu"] = "KidUnion",
--   ["yi__wangzun"] = "妄尊",
--   [":yi__wangzun"] = "一号位的回合开始前，你可获得其一张牌，然后你可交给其一张牌并执行一个出牌阶段。",
--   ["#yi__wangzun-invoke"] = "发动【妄尊】，获得%dest一张牌",
--   ["#yi__wangzun-give"] = "妄尊：你可交给%dest一张牌并执行一个出牌阶段",
--   ["yi__tongji"] = "同疾",
--   [":yi__tongji"] = "出牌阶段限一次，你可视为使用一张未以此法使用过的伤害牌，然后本局游戏你不能响应此牌名的牌。",
--   ["#yi__tongji"] = "发动【同疾】，视为使用一张未以此法使用过的伤害牌",
--   ["#yi__tongji_trigger"] = "同疾",

--   ["~yi__yuanshu"] = "蜜水……蜜水……",
-- }
