local extension = Package:new("yi")
extension.extensionName = "DIY"

extension:loadSkillSkelsByPath("./packages/DIY/pkg/yi/skills")

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

-- General:new(extension, "yi__yuanshu", "qun", 3):addSkills { "yi__wangzun", "yi__tongji" }
-- Fk:loadTranslationTable{
--   ["yi__yuanshu"] = "异袁术",
--   ["#yi__yuanshu"] = "冢中枯骨",
--   ["designer:yi__yuanshu"] = "KidUnion",

--   ["~yi__yuanshu"] = "蜜水……蜜水……",
-- }



return extension

-- local extension = Package:new("yi")
-- extension.extensionName = "DIY"

-- local U = require "packages/utility/utility"

-- Fk:loadTranslationTable{
--   ["yi"] = "异包",
-- }

-- -- 陆逊
-- local luxun = General(extension, "yi__luxun", "wu", 3)
-- local qianxun = fk.CreateTriggerSkill{
--   name = "yi__qianxun",
--   anim_type = "defensive",
--   events = {fk.TargetConfirming},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player and #table.filter(player:getCardIds("h"), function(id) 
--       return Fk:getCardById(id).color == data.card.color and id ~= data.card.id
--     end) ~= 0 and data.card.type == Card.TypeTrick and player:getMark("yi__qianxun-turn") == 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local colors = {"黑", "红", "无"}
--     if room:askForSkillInvoke(player, self.name, nil, "#yi__qianxun-invoke:::"..colors[data.card.color]) then
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local cards = table.filter(player:getCardIds("h"), function(id) return Fk:getCardById(id).color == data.card.color end)
--     if #cards > 0 then
--       room:throwCard(cards, self.name, player, player)
--       AimGroup:cancelTarget(data, player.id)
--       room:setPlayerMark(player, "yi__qianxun-turn", 1)
--     end
--   end,
-- }
-- local lianying = fk.CreateTriggerSkill{
--   name = "yi__lianying",
--   anim_type = "special",
--   prompt = "#yi__lianying-other",
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) then
--       for _, move in ipairs(data) do
--         if move.from == player.id and move.moveReason ~= fk.ReasonUse then
--           for _, info in ipairs(move.moveInfo) do
--             local suit = Fk:getCardById(info.cardId).suit
--             local cards = table.filter(player:getCardIds("h"), function(id) return Fk:getCardById(id).suit == suit end)
--             return info.fromArea == Card.PlayerHand and #cards == 0
--           end
--         end
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local card = room:getNCards(1)
--     room:askForYiji(player, card, room:getAlivePlayers(), self.name, 1, 1, "#yi__lianying-give", card)
--   end,
-- }
-- local lianyin_use = fk.CreateTriggerSkill{
--   name = "#yi__lianyin_use",
--   anim_type = "offensive",
--   events = {fk.TargetSpecified},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player and data.card.type ~= Card.TypeEquip and data.card.suit ~= Card.NoSuit and
--     table.every(player.player_cards[Player.Hand], function (id) return Fk:getCardById(id).suit ~= data.card.suit end)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local choices = {"不计次数", "额外结算"}
--     local choice = room:askForChoice(player, choices, self.name, "#yi__lianying-choose")
--     if choice == "不计次数" then
--       player:addCardUseHistory(data.card.trueName, -1)
--     elseif choice == "额外结算" then
--       data.additionalEffect = (data.additionalEffect or 0) + 1
--     end
--   end,
-- }
-- lianying:addRelatedSkill(lianyin_use)
-- luxun:addSkill(qianxun)
-- luxun:addSkill(lianying)
-- Fk:loadTranslationTable{
--   ["yi__luxun"] = "异陆逊",
--   ["#yi__luxun"] = "儒生雄才",
--   ["designer:yi__luxun"] = "KidUnion",
--   ["yi__qianxun"] = "谦逊",
--   [":yi__qianxun"] = "每回合限一次，当你成为锦囊牌的目标时，你可弃置与之颜色相同的所有手牌并取消你为目标。",
--   ["#yi__qianxun-invoke"] = "发动【谦逊】，弃置所有%arg色的手牌，取消你为目标",
--   ["yi__lianying"] = "连营",
--   [":yi__lianying"] = "当你使用一种花色的最后一张手牌时，你可令此牌不计次数或额外结算一次；",
--   "当你非因使用失去一种花色的最后一张手牌时，你可观看牌堆顶一张牌并将之交给一名角色。",
--   ["#yi__lianying-other"] = "发动【连营】，观看牌堆顶一张牌并分配",
--   ["#yi__lianying-give"] = "连营：将此牌交给一名角色",
--   ["#yi__lianyin_use"] = "连营",
--   ["#yi__lianying-choose"] = "连营：选择令此牌不计次数或额外结算一次",

--   ["yi__qianxun-turn"] = "谦逊",

--   ["$yi__qianxun1"] = "满招损，谦受益。",
--   ["$yi__qianxun2"] = "谦谦君子，温润如玉。",
--   ["$yi__lianying1"] = "生生不息，源源不绝。",
--   ["$yi__lianying2"] = "失之淡然，得之坦然。",
--   ["~yi__luxun"] = "我的未竟之业……",
-- }

-- -- 关羽
-- local guanyu = General(extension, "yi__guanyu", "shu", 4)
-- local wusheng = fk.CreateActiveSkill{
--   name = "yi__wusheng",
--   anim_type = "offensive",
--   card_num = function(self)
--     return math.max(0, Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn"))
--   end,
--   prompt = function()
--     local num = Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn")
--     if num < 0 then
--       return "#yi__wusheng-draw:::"..-num
--     else
--       return "#yi__wusheng-discard:::"..num
--     end
--   end,
--   card_filter = function(self, to_select, selected)
--     return #selected < Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn") and
--     Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and
--     not Self:prohibitDiscard(Fk:getCardById(to_select))
--   end,
--   can_use = function(self, player)
--     return (player:getHandcardNum() < #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_draw-phase") == 0) or
--       (player:getHandcardNum() > #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_discard-phase") == 0)
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     if #effect.cards > 0 then
--       room:addPlayerMark(player, "yi__wusheng_discard-phase", 1)
--       room:throwCard(effect.cards, self.name, player, player)
--       U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#yi__wusheng_slash", 
--       false, true, true)
--     else
--       local num = #player:getTableMark("@yi__wusheng-turn") - player:getHandcardNum()
--       room:addPlayerMark(player, "yi__wusheng_draw-phase", 1)
--       if num > 0 then
--         room:drawCards(player, num, self.name)
--         U.askForUseVirtualCard(room, player, "duel", nil, self.name, "#yi__wusheng_duel", 
--         false, true, true, false)
--       end 
--     end
--   end,
-- }
-- local wusheng_trigger = fk.CreateTriggerSkill{
--   name = "#yi__wusheng_trigger",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true)
--     and not table.contains(player:getTableMark("@yi__wusheng-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@yi__wusheng-turn", data.card:getSuitString(true))
--   end,

--   on_acquire = function (self, player, is_start)
--     local room = player.room
--     if player ~= player.room.current then return end
--     local mark = {}
--     room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
--       local use = e.data[1]
--       if use.from == player.id then
--         table.insertIfNeed(mark, use.card:getSuitString(true))
--       end
--     end, Player.HistoryTurn)
--     room:setPlayerMark(player, "@yi__wusheng-turn", #mark > 0 and mark or 0)
--   end,
--   on_lose = function (self, player, is_start)
--     player.room:setPlayerMark(player, "@yi__wusheng-turn", 0)
--   end,
-- }
-- local yijue = fk.CreateTriggerSkill{
--   name = "yi__yijue",
--   anim_type = "defensive",
--   frequency = Skill.Compulsory,
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and data.damage >= player.hp and data.from and
--       data.from:getMark("@@yi__yi") ~= player.id and data.from:getMark("@@yi__yijue") ~= player.id
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player.room:doIndicate(player.id, {data.from.id})
--     room:setPlayerMark(data.from, "@@yi__yi", player.id)
--     return true
--   end,
-- }
-- local yijue_delay = fk.CreateTriggerSkill{
--   name = "#yi__yijue_delay",
--   anim_type = "defensive",
--   frequency = Skill.Compulsory,
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     return data.from and data.from == player and player:hasSkill(self) and data.damage >= target.hp and
--     target:getMark("@@yi__yi") == player.id
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player.room:doIndicate(player.id, {target.id})
--     room:setPlayerMark(target, "@@yi__yi", 0)
--     room:setPlayerMark(target, "@@yi__yijue", player.id)
--     return true
--   end,
-- }
-- wusheng:addRelatedSkill(wusheng_trigger)
-- yijue:addRelatedSkill(yijue_delay)
-- guanyu:addSkill(wusheng)
-- guanyu:addSkill(yijue)
-- Fk:loadTranslationTable{
--   ["yi__guanyu"] = "异关羽",
--   ["#yi__guanyu"] = "美髯公",
--   ["designer:yi__guanyu"] = "KidUnion",

--   ["yi__wusheng"] = "武圣",
--   [":yi__wusheng"] = "出牌阶段各限一次，你可将手牌弃至/摸至X张，视为使用一张无距离次数限制的【杀】/【决斗】。（X为你本回合使用牌的花色数且包含无色）",
--   ["#yi__wusheng-draw"] = "发动【武圣】，摸%arg张牌并视为使用一张【决斗】",
--   ["#yi__wusheng-discard"] = "发动【武圣】，弃置%arg张手牌并视为使用一张【杀】",
--   ["@yi__wusheng-turn"] = "武圣",
--   ["#yi__wusheng_slash"] = "武圣：视为使用一张无距离次数限制的【杀】",
--   ["#yi__wusheng_duel"] = "武圣：视为使用一张【决斗】",
--   ["yi__yijue"] = "义绝",
--   [":yi__yijue"] = "锁定技，防止一名角色对你造成的首次致命伤害，若如此做，防止你对其造成的下一次致命伤害。",
--   ["#yi__yijue_delay"] = "义绝",
--   ["@@yi__yi"] = "义",
--   ["@@yi__yijue"] = "义绝",

--   ["$yi__wusheng1"] = "刀锋所向，战无不克！",
--   ["$yi__wusheng2"] = "逆贼，哪里走！",
--   ["$yi__yijue1"] = "关某，向来恩怨分明！",
--   ["$yi__yijue2"] = "恩已断，义当绝！",
--   ["~yi__guanyu"] = "桃园一拜，恩义常在……",
-- }

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

-- -- 黄盖
-- local huanggai = General(extension, "yi__huanggai", "wu", 4)
-- local zhaxiang = fk.CreateTriggerSkill{
--   name = "yi__zhaxiang",
--   anim_type = "drawcard",
--   prompt = "#yi__zhaxiang",
--   events = {fk.HpLost},
--   on_trigger = function(self, event, target, player, data)
--     for i = 1, data.num do
--       if i > 1 and not player:hasSkill(self) then break end
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local cards = player:drawCards(3, self.name)
--     local visible = {}
--     for _, id in ipairs(cards) do
--       local card = Fk:getCardById(id)
--       if(not card.is_damage_card) then
--         room:setCardMark(card, "@@visible", 1)
--         table.insert(visible, id)
--       else 
--         room:setCardMark(card, "@@yi__zhaxiang_damage", 1)
--       end
--     end
--     player:showCards(visible)
--   end,
-- }
-- local zhaxiang_delay = fk.CreateTriggerSkill{
--   name = "#yi__zhaxiang_delay",
--   refresh_events = {fk.PreCardUse},
--   can_refresh = function(self, event, target, player, data)
--     return player == target and data.card:getMark("@@yi__zhaxiang_damage") > 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
--   end,
-- }
-- local zhaxiang_trigger = fk.CreateTriggerSkill{
--   name = "#yi__zhaxiang_trigger",
--   mute = true,
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player.dead or not player:hasSkill("yi__zhaxiang") then return false end
--     local suits = player:getTableMark("@yi__zhaxiang-round")
--     if #suits == 4 then return false end
--     local suit, can_use = nil, false
--     for _, move in ipairs(data) do
--       if move.from == player.id then
--         for _, info in ipairs(move.moveInfo) do
--           local card = Fk:getCardById(info.cardId)
--           suit = card:getSuitString(true)
--           if card:getMark("@@visible") > 0 or info.fromArea == Card.PlayerEquip then
--             card:setMark("@@visible", 0)
--             if not table.contains(suits, suit) and suit ~= Card.NoSuit then
--               player.room:addTableMark(player, "@yi__zhaxiang-round", suit)
--               can_use = true
--             end
--           end
--         end
--       end
--       return can_use
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     U.askForUseVirtualCard(room, player, "fire__slash", nil, self.name, "#yi__zhaxiang_slash", 
--     true, true, true)
--   end,
-- }
-- zhaxiang:addRelatedSkill(zhaxiang_trigger)
-- zhaxiang:addRelatedSkill(zhaxiang_delay)
-- huanggai:addSkill("ex__kurou")
-- huanggai:addSkill(zhaxiang)
-- Fk:loadTranslationTable{
--   ["yi__huanggai"] = "异黄盖",
--   ["#yi__huanggai"] = "轻身焚舰",
--   ["designer:yi__yuanshu"] = "KidUnion",
--   ["ex__kurou"] = "苦肉",
--   [":ex__kurou"] = "出牌阶段限一次，你可以弃置一张牌并失去1点体力。",
--   ["yi__zhaxiang"] = "诈降",
--   [":yi__zhaxiang"] = "当你失去体力后，你可摸三张牌并明置其中的非伤害牌，其余牌不可被响应；"..
--   "你每轮首次失去一种花色的明置牌后可视为使用一张无距离限制的火【杀】。",
--   ["@@visible"] = "明置",
--   ["@@yi__zhaxiang_damage"] = "不可被响应",
--   ["@yi__zhaxiang-round"] = "诈降",
--   ["#ex__kurou"] = "苦肉：你可以弃置一张牌并失去1点体力",
--   ["#yi__zhaxiang"] = "诈降：你可以摸三张牌并明置其中的非伤害牌",
--   ["#yi__zhaxiang_delay"] = "诈降",
--   ["#yi__zhaxiang_trigger"] = "诈降",
--   ["#yi__zhaxiang_slash"] = "诈降：你可视为使用一张无距离限制的火【杀】",

--   ["$ex__kurou1"] = "我这把老骨头，不算什么！",
--   ["$ex__kurou2"] = "为成大业，死不足惜！",
--   ["$yi__zhaxiang1"] = "铁锁连舟而行，东吴水师可破！",
--   ["$yi__zhaxiang2"] = "两军阵前，不斩降将！",
--   ["~yi__huanggai"] = "盖，有负公瑾重托……",
-- }

-- -- return extension
