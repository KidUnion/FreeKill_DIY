local extension = Package:new("yi")
extension.extensionName = "DIY"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["yi"] = "异包",
}

-- 陆逊
local luxun = General(extension, "yi__luxun", "wu", 3)
local yi__qianxun = fk.CreateTriggerSkill{
  name = "yi__qianxun",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and #table.filter(player:getCardIds("h"), function(id) 
      return Fk:getCardById(id).color == data.card.color and id ~= data.card.id
    end) ~= 0 and data.card.type == Card.TypeTrick and player:getMark("yi__qianxun-turn") == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local colors = {"黑", "红", "无"}
    if room:askForSkillInvoke(player, self.name, nil, "#yi__qianxun-invoke:::"..colors[data.card.color]) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id) return Fk:getCardById(id).color == data.card.color end)
    if #cards > 0 then
      room:throwCard(cards, self.name, player, player)
      AimGroup:cancelTarget(data, player.id)
      room:setPlayerMark(player, "yi__qianxun-turn", 1)
    end
  end,
}
local yi__lianying = fk.CreateTriggerSkill{
  name = "yi__lianying",
  anim_type = "special",
  prompt = "#yi__lianying-other",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason ~= fk.ReasonUse then
          for _, info in ipairs(move.moveInfo) do
            local suit = Fk:getCardById(info.cardId).suit
            local cards = table.filter(player:getCardIds("h"), function(id) return Fk:getCardById(id).suit == suit end)
            return info.fromArea == Card.PlayerHand and #cards == 0
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:getNCards(1)
    room:askForYiji(player, card, room:getAlivePlayers(), self.name, 1, 1, "#yi__lianying-give", card)
  end,
}
local yi__lianyin_use = fk.CreateTriggerSkill{
  name = "#yi__lianyin_use",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card.type ~= Card.TypeEquip and data.card.suit ~= Card.NoSuit and
    table.every(player.player_cards[Player.Hand], function (id) return Fk:getCardById(id).suit ~= data.card.suit end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"不计次数", "额外结算"}
    local choice = room:askForChoice(player, choices, self.name, "#yi__lianying-choose")
    if choice == "不计次数" then
      player:addCardUseHistory(data.card.trueName, -1)
    elseif choice == "额外结算" then
      data.additionalEffect = (data.additionalEffect or 0) + 1
    end
  end,
}
yi__lianying:addRelatedSkill(yi__lianyin_use)
luxun:addSkill(yi__qianxun)
luxun:addSkill(yi__lianying)
Fk:loadTranslationTable{
  ["yi__luxun"] = "异陆逊",
  ["#yi__luxun"] = "儒生雄才",
  ["designer:yi__luxun"] = "KidUnion",
  ["yi__qianxun"] = "谦逊",
  [":yi__qianxun"] = "每回合限一次，当你成为锦囊牌的目标时，你可弃置与之颜色相同的所有手牌并取消你为目标。",
  ["#yi__qianxun-invoke"] = "发动【谦逊】，弃置所有%arg色的手牌，取消你为目标",
  ["yi__lianying"] = "连营",
  [":yi__lianying"] = "当你使用一种花色的最后一张手牌时，你可令此牌不计次数或额外结算一次；",
  "当你非因使用失去一种花色的最后一张手牌时，你可观看牌堆顶一张牌并将之交给一名角色。",
  ["#yi__lianying-other"] = "发动【连营】，观看牌堆顶一张牌并分配",
  ["#yi__lianying-give"] = "连营：将此牌交给一名角色",
  ["#yi__lianyin_use"] = "连营",
  ["#yi__lianying-choose"] = "连营：选择令此牌不计次数或额外结算一次",

  ["yi__qianxun-turn"] = "谦逊",

  ["$yi__qianxun1"] = "满招损，谦受益。",
  ["$yi__qianxun2"] = "谦谦君子，温润如玉。",
  ["$yi__lianying1"] = "生生不息，源源不绝。",
  ["$yi__lianying2"] = "失之淡然，得之坦然。",
  ["~yi__luxun"] = "我的未竟之业……",
}

-- 关羽
local guanyu = General(extension, "yi__guanyu", "shu", 4)
local yi__wusheng = fk.CreateActiveSkill{
  name = "yi__wusheng",
  anim_type = "offensive",
  card_num = function(self)
    return math.max(0, Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn"))
  end,
  prompt = function()
    local num = Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn")
    if num < 0 then
      return "#yi__wusheng-draw:::"..-num
    else
      return "#yi__wusheng-discard:::"..num
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:getHandcardNum() - #Self:getTableMark("@yi__wusheng-turn") and
    Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and
    not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  can_use = function(self, player)
    return (player:getHandcardNum() < #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_draw-phase") == 0) or
      (player:getHandcardNum() > #player:getTableMark("@yi__wusheng-turn") and player:getMark("yi__wusheng_discard-phase") == 0)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if #effect.cards > 0 then
      room:addPlayerMark(player, "yi__wusheng_discard-phase", 1)
      room:throwCard(effect.cards, self.name, player, player)
      U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#yi__wusheng_slash", 
      false, true, true)
    else
      local num = #player:getTableMark("@yi__wusheng-turn") - player:getHandcardNum()
      room:addPlayerMark(player, "yi__wusheng_draw-phase", 1)
      if num > 0 then
        room:drawCards(player, num, self.name)
        U.askForUseVirtualCard(room, player, "duel", nil, self.name, "#yi__wusheng_duel", 
        false, true, true, false)
      end 
    end
  end,
}
local yi__wusheng_trigger = fk.CreateTriggerSkill{
  name = "#yi__wusheng_trigger",
  mute = true,
  events = {},

  refresh_events = {fk.CardUsing},
  can_refresh = function (self, event, target, player, data)
    return player == target and player:hasSkill(self, true)
    and not table.contains(player:getTableMark("@yi__wusheng-turn"), data.card:getSuitString(true))
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, "@yi__wusheng-turn", data.card:getSuitString(true))
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if player ~= player.room.current then return end
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
      local use = e.data[1]
      if use.from == player.id then
        table.insertIfNeed(mark, use.card:getSuitString(true))
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "@yi__wusheng-turn", #mark > 0 and mark or 0)
  end,
  on_lose = function (self, player, is_start)
    player.room:setPlayerMark(player, "@yi__wusheng-turn", 0)
  end,
}
local yi__yijue = fk.CreateTriggerSkill{
  name = "yi__yijue",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage >= player.hp and data.from and
      data.from:getMark("@@yi__yi") ~= player.id and data.from:getMark("@@yi__yijue") ~= player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.room:doIndicate(player.id, {data.from.id})
    room:setPlayerMark(data.from, "@@yi__yi", player.id)
    return true
  end,
}
local yi__yijue_delay = fk.CreateTriggerSkill{
  name = "#yi__yijue_delay",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(self) and data.damage >= target.hp and
    target:getMark("@@yi__yi") == player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.room:doIndicate(player.id, {target.id})
    room:setPlayerMark(target, "@@yi__yi", 0)
    room:setPlayerMark(target, "@@yi__yijue", player.id)
    return true
  end,
}
yi__wusheng:addRelatedSkill(yi__wusheng_trigger)
yi__yijue:addRelatedSkill(yi__yijue_delay)
guanyu:addSkill(yi__wusheng)
guanyu:addSkill(yi__yijue)
Fk:loadTranslationTable{
  ["yi__guanyu"] = "异关羽",
  ["#yi__guanyu"] = "美髯公",
  ["designer:yi__guanyu"] = "KidUnion",

  ["yi__wusheng"] = "武圣",
  [":yi__wusheng"] = "出牌阶段各限一次，你可将手牌弃至/摸至X张，视为使用一张无距离次数限制的【杀】/【决斗】。（X为你本回合使用牌的花色数且包含无色）",
  ["#yi__wusheng-draw"] = "发动【武圣】，摸%arg张牌并视为使用一张【决斗】",
  ["#yi__wusheng-discard"] = "发动【武圣】，弃置%arg张手牌并视为使用一张【杀】",
  ["@yi__wusheng-turn"] = "武圣",
  ["#yi__wusheng_slash"] = "武圣：视为使用一张无距离次数限制的【杀】",
  ["#yi__wusheng_duel"] = "武圣：视为使用一张【决斗】",
  ["yi__yijue"] = "义绝",
  [":yi__yijue"] = "锁定技，防止一名角色对你造成的首次致命伤害，若如此做，防止你对其造成的下一次致命伤害。",
  ["#yi__yijue_delay"] = "义绝",
  ["@@yi__yi"] = "义",
  ["@@yi__yijue"] = "义绝",

  ["$yi__wusheng1"] = "刀锋所向，战无不克！",
  ["$yi__wusheng2"] = "逆贼，哪里走！",
  ["$yi__yijue1"] = "关某，向来恩怨分明！",
  ["$yi__yijue2"] = "恩已断，义当绝！",
  ["~yi__guanyu"] = "桃园一拜，恩义常在……",
}

-- 王平
local wangping = General(extension, "yi__wangping", "shu", 4)
Fk:addQmlMark{
  name = "yi__feijun",
  qml_path = "",
  how_to_show = function(name, value, p)
    local x = p:getMark("#yi__feijun") + 1
    if x > 1 then
      return Fk:translate(Util.PhaseStrMapper(x))
    end
    return " "
  end,
}
local feijun = fk.CreateTriggerSkill{
  name = "yi__feijun",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == player:getMark("#yi__feijun") + 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local _, ret = room:askForUseActiveSkill(player, "yi__feijun_active", "#yi__feijun-invoke", false)
    if ret then
      cards = ret.cards
    end
    if #cards == 0 then return end
    room:throwCard(cards, self.name, player, player)
    player.room:addTableMark(player, "@yi__feijun-turn", Fk:getCardById(cards[1]):getSuitString(true))
    if player.dead then return end
    if room:askForChoice(player, {"#yi__feijun_draw", "#yi__feijun_slash"}, self.name, "#yi__feijun_choose") == "#yi__feijun_draw" then
      local num = player.maxHp - player:getHandcardNum()
      if num > 0 then
        room:drawCards(player, num, self.name)
      end
      local phase = math.min(player:getMark("#yi__feijun") + #cards, 6)
      room:setPlayerMark(player, "#yi__feijun", phase)
    else
      U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#yi__feijun-slash", 
      false, true, true)
      local phase = math.max(player:getMark("#yi__feijun") - #cards, 1)
      room:setPlayerMark(player, "#yi__feijun", phase)
    end
  end,

  on_acquire = function (self, player)
    player.room:setPlayerMark(player, "@[yi__feijun]", 1)
    player.room:setPlayerMark(player, "#yi__feijun", 1)
  end,
  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@[yi__feijun]", 0)
    player.room:setPlayerMark(player, "#yi__feijun", 0)
  end,
}
local feijun_active = fk.CreateActiveSkill{
  name = "yi__feijun_active",
  mute = true,
  card_filter = function(self, to_select, selected)
    if Self:prohibitDiscard(Fk:getCardById(to_select)) then return false end
    if #selected == 0 then
      return not table.contains(Self:getTableMark("@yi__feijun-turn"), 
      Fk:getCardById(to_select):getSuitString(true))
    else
      return Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
    end
  end,
}
Fk:addSkill(feijun_active)
local binglue = fk.CreateTriggerSkill{
  name = "yi__binglue",
  anim_type = "special",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #player:getTableMark("@yi__binglue-turn") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    self.cost_data = #player:getTableMark("@yi__binglue-turn") + 1
    if room:askForSkillInvoke(player, self.name, nil, "#yi__binglue-invoke:::"..Util.PhaseStrMapper(self.cost_data)) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(self.cost_data)
  end,
  
  refresh_events = {fk.TurnStart, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player == target
    elseif player.room.current == player then
      local mark = player:getMark("@yi__binglue-turn")
      if type(mark) == "table" then
        return #mark < 4
      else
        return player:hasSkill(self, true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      if player:hasSkill(self, true) then
        player.room:setPlayerMark(player, "@yi__binglue-turn", {})
      elseif player:usedSkillTimes(self.name, Player.HistoryRound) > 0 then
        player:setSkillUseHistory(self.name, 0, Player.HistoryRound)
      end
    else
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            local suit = Fk:getCardById(info.cardId):getSuitString(true)
            if not table.contains(player:getTableMark("@yi__binglue-turn"), suit) then
              room:addTableMark(player, "@yi__binglue-turn", suit)
            end
          end
        end
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if player ~= player.room.current then return end
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            local card = Fk:getCardById(info.cardId)
            if card and card.suit ~= Card.NoSuit then
              table.insertIfNeed(mark, card:getSuitString(true))
            end
          end
        end
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "@yi__binglue-turn", #mark > 0 and mark or 0)
  end,
  on_lose = function (self, player, is_start)
    player.room:setPlayerMark(player, "@yi__binglue-turn", 0)
  end,
}
wangping:addSkill(feijun)
wangping:addSkill(binglue)
Fk:loadTranslationTable{
  ["yi__wangping"] = "异王平",
  ["#yi__wangping"] = "兵谋以致用",
  ["designer:yi__wangping"] = "KidUnion",
  ["yi__feijun"] = "飞军",
  [":yi__feijun"] = "每回合每种花色限一次，准备阶段结束时，你可弃置任意张花色相同的牌并视为使用一张无距离限制的【杀】/将手牌摸至体力上限，"..
  "然后此技能的发动时机提前/延后至多等量个阶段。",
  ["yi__binglue"] = "兵略",
  [":yi__binglue"] = "你的回合结束时，你可执行本回合的第X个阶段。（X为本回合进入弃牌堆的花色数）",
  ["@[yi__feijun]"] = "飞军",
  ["yi__feijun_active"] = "飞军",
  ["@yi__feijun-turn"] = "飞军",
  ["#yi__feijun"] = "飞军",
  ["#yi__feijun-invoke"] = "发动【飞军】，弃置相同花色的任意张牌",
  ["#yi__feijun_choose"] = "飞军：选择摸牌至体力上限或视为使用【杀】",
  ["#yi__feijun_draw"] = "将手牌摸至体力上限",
  ["#yi__feijun_slash"] = "视为使用【杀】",
  ["#yi__feijun-slash"] = "飞军：视为使用一张无距离限制的【杀】",
  ["@yi__binglue-turn"] = "兵略",
  ["#yi__binglue-invoke"] = "发动【兵略】，执行一个%arg",

  ["$yi__feijun1"] = "无当飞军，伐叛乱，镇蛮夷！",
  ["$yi__feijun2"] = "山地崎岖，也挡不住飞军破势！",
  ["$yi__binglue1"] = "奇略兵速，敌未能料之。",
  ["$yi__binglue2"] = "兵略者，明战胜攻取之数，形机之势，诈谲之变。",
  ["~yi__wangping"] = "无当飞军，也有困于深林之时……",
}

-- 赵云
local zhaoyun = General(extension, "yi__zhaoyun", "shu", 4)
local longdan = fk.CreateViewAsSkill{
  name = "yi__longdan",
  anim_type = "switch",
  switch_skill_name = "yi__longdan",
  prompt = function(self)
    return "#yi__longdan_choose-"..Self:getSwitchSkillState(self.name, false, true)
  end,
  pattern = ".|.|.|.|.|basic",
  interaction = function()
    local all_names = U.getAllCardNames("b", true)
    local names = U.getViewAsCardNames(Self, "shizong", all_names)
    if #names == 0 then return false end
    return UI.ComboBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    if player:getSwitchSkillState(self.name, false) == fk.SwitchYin then
      local card = room:askForDiscard(player, 1, 1, true, self.name,
       false, ".", "#yi__longdan-yin:::"..use.card.name, false)
      if #card > 0 then return end
    elseif player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
      room:addTableMark(player, "@yi__longdan-turn", use.card.name)
      room:drawCards(player, 1, self.name)
    end
    return self.name
  end,
  enabled_at_play = function(self, player)
    return true
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
}
local longdan_prohibit = fk.CreateProhibitSkill{
  name = "#yi__longdan_prohibit",
  prohibit_use = function(self, player, card)
    return table.contains(player:getTableMark("@yi__longdan-turn"), card.trueName)
  end,
}
longdan:addRelatedSkill(longdan_prohibit)
zhaoyun:addSkill(longdan)
Fk:loadTranslationTable{
  ["yi__zhaoyun"] = "异赵云",
  ["#yi__zhaoyun"] = "虎将龙胆",
  ["designer:yi__zhaoyun"] = "KidUnion",
  ["yi__longdan"] = "龙胆",
  [":yi__longdan"] = "转换技，当你需要使用基本牌时，阴：你可弃一张牌并视为使用之；阳：你可摸一张牌并令你本回合不能使用此牌名的牌。",
  ["#yi__longdan_choose-yang"] = "龙胆：选择一种基本牌，弃一张牌并视为使用之。",
  ["#yi__longdan_choose-yin"] = "龙胆：选择一种基本牌，摸一张牌并令你本回合不能使用之。",
  ["#yi__longdan-yin"] = "弃置一张牌并视为使用%arg",
  ["#yi__longdan_prohibit"] = "龙胆",
  ["@yi__longdan-turn"] = "龙胆",
  
  ["$yi__longdan1"] = "保驾扶危主，冲阵透重围！",
  ["$yi__longdan2"] = "银枪映豪胆，赤血鉴忠心！",

  ["~yi__zhaoyun"] = "生驱单骑摧敌锐，死作忠魂佑主周！",
}

return extension

-- local lvmeng = General(extension, "suzhi__lvmeng", "wu", 4)
-- local ol_ex__qinxue = fk.CreateTriggerSkill{
--   name = "suzhi__qinxue",
--   frequency = Skill.Wake,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and
--       (player.phase == Player.Start or player.phase == Player.Finish) and
--       player:usedSkillTimes(self.name, Player.HistoryGame) == 0
--   end,
--   can_wake = function(self, event, target, player, data)
--     return (player:getHandcardNum() - player.hp > 1)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:changeMaxHp(player, -1)
--     if player.dead then return false end
--     local choices = {"draw2"}
--     if player:isWounded() then
--       table.insert(choices, "recover")
--     end
--     local choice = room:askForChoice(player, choices, self.name)
--     if choice == "draw2" then
--       room:drawCards(player, 2, self.name)
--     elseif choice == "recover" then
--       room:recover({
--         who = player,
--         num = 1,
--         recoverBy = player,
--         skillName = self.name
--       })
--     end
--     if player.dead then return false end
--     room:handleAddLoseSkills(player, "gongxin", nil)
--   end,
-- }
-- local ol_ex__botu = fk.CreateTriggerSkill{
--   name = "suzhi__botu",
--   anim_type = "drawcard",
--   events = {fk.TurnEnd},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self)
--     and player:usedSkillTimes(self.name, Player.HistoryRound) < math.min(3, #player.room.alive_players)
--     and type(player:getMark("@ol_ex__botu-turn")) == "table" and #player:getMark("@ol_ex__botu-turn") == 4
--   end,
--   on_use = function(self, event, target, player, data)
--     player:gainAnExtraTurn()
--   end,

--   refresh_events = {fk.TurnStart, fk.AfterCardsMove},
--   can_refresh = function(self, event, target, player, data)
--     if event == fk.TurnStart then
--       return player == target
--     elseif player.room.current == player then
--       local mark = player:getMark("@ol_ex__botu-turn")
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
--         player.room:setPlayerMark(player, "@ol_ex__botu-turn", {})
--       elseif player:usedSkillTimes(self.name, Player.HistoryRound) > 0 then
--         player:setSkillUseHistory(self.name, 0, Player.HistoryRound)
--       end
--     else
--       local suitsRecorded = player:getTableMark("@ol_ex__botu-turn")
--       local mark_change = false
--       for _, move in ipairs(data) do
--         if move.toArea == Card.DiscardPile then
--           for _, info in ipairs(move.moveInfo) do
--             local suit = Fk:getCardById(info.cardId):getSuitString(true)
--             if not table.contains(suitsRecorded, suit) then
--               mark_change = true
--               table.insert(suitsRecorded, suit)
--             end
--           end
--         end
--       end
--       if mark_change then
--         room:setPlayerMark(player, "@ol_ex__botu-turn", suitsRecorded)
--       end
--     end
--   end,
-- }
-- -- lvmeng:addSkill("keji")
-- lvmeng:addSkill(ol_ex__qinxue)
-- lvmeng:addSkill(ol_ex__botu)
-- lvmeng:addRelatedSkill("gongxin")
-- Fk:loadTranslationTable{
--   ["ol_ex__lvmeng"] = "界吕蒙",
--   ["#ol_ex__lvmeng"] = "士别三日",
--   ["ol_ex__qinxue"] = "勤学",
--   [":ol_ex__qinxue"] = "觉醒技，准备阶段或结束阶段，若你的手牌数比体力值多2或更多，你减1点体力上限，回复1点体力或摸两张牌，然后获得技能〖攻心〗。",
--   ["ol_ex__botu"] = "博图",
--   [":ol_ex__botu"] = "每轮限X次（X为存活角色数且最多为3），回合结束时，若本回合内置入弃牌堆的牌包含四种花色，你可以获得一个额外回合。",

--   ["@ol_ex__botu-turn"] = "博图",

--   ["$keji_ol_ex__lvmeng1"] = "哼，笑到最后的，才是赢家。",
--   ["$keji_ol_ex__lvmeng2"] = "静观其变，相机而动。",
--   ["$ol_ex__qinxue1"] = "士别三日，刮目相看！",
--   ["$ol_ex__qinxue2"] = "吴下阿蒙，今非昔比！",
--   ["$gongxin_ol_ex__lvmeng1"] = "料敌机先，攻心为上。",
--   ["$gongxin_ol_ex__lvmeng2"] = "你的举动，都在我的掌握之中。",
--   ["$ol_ex__botu1"] = "厚积而薄发。",
--   ["$ol_ex__botu2"] = "我胸怀的是这天下！",
--   ["~ol_ex__lvmeng"] = "以后……就交给年轻人了……",
-- }

-- local ol_ex__yaowu = fk.CreateTriggerSkill{
--   name = "ol_ex__yaowu",
--   mute = true,
--   anim_type = "negative",
--   frequency = Skill.Compulsory,
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and data.card
--   end,
--   on_use = function(self, event, target, player, data)
--     if data.card.color ~= Card.Red then
--       player.room:notifySkillInvoked(player, self.name, "masochism")
--       player:broadcastSkillInvoke(self.name, 1)
--       player:drawCards(1, self.name)
--     else
--       if data.from and not data.from.dead then
--         player.room:notifySkillInvoked(player, self.name, "negative")
--         player:broadcastSkillInvoke(self.name, 2)
--         data.from:drawCards(1, self.name)
--       end
--     end
--   end,
-- }
-- local ol_ex__shizhan = fk.CreateActiveSkill{
--   name = "ol_ex__shizhan",
--   anim_type = "offensive",
--   prompt = "#ol_ex__shizhan-active",
--   times = function(self)
--     return Self.phase == Player.Play and 2 - Self:usedSkillTimes(self.name, Player.HistoryPhase) or -1
--   end,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
--   end,
--   card_filter = Util.FalseFunc,
--   target_filter = function(self, to_select, selected)
--     return #selected == 0 and to_select ~= Self.id
--     and not Fk:currentRoom():getPlayerById(to_select):isProhibited(Self, Fk:cloneCard("duel"))
--   end,
--   target_num = 1,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     room:useVirtualCard("duel", nil, target, player, self.name, true)
--   end,
-- }
-- local huaxiong = General(extension, "ol_ex__huaxiong", "qun", 6)
-- huaxiong:addSkill(ol_ex__yaowu)
-- huaxiong:addSkill(ol_ex__shizhan)
-- Fk:loadTranslationTable{
--   ["ol_ex__huaxiong"] = "界华雄",
--   ["#ol_ex__huaxiong"] = "飞扬跋扈",
--   ["designer:ol_ex__huaxiong"] = "玄蝶既白",
--   ["illustrator:ol_ex__huaxiong"] = "秋呆呆",
--   ["ol_ex__yaowu"] = "耀武",
--   [":ol_ex__yaowu"] = "锁定技，当你受到牌造成的伤害时，若造成伤害的牌：为红色，伤害来源摸一张牌；不为红色，你摸一张牌。",
--   ["ol_ex__shizhan"] = "势斩",
--   [":ol_ex__shizhan"] = "出牌阶段限两次，你可以令一名其他角色视为对你使用【决斗】。",
--   ["#ol_ex__shizhan-active"] = "发动 势斩，选择一名其他角色，令其视为对你使用【决斗】",

--   ["$ol_ex__yaowu1"] = "有吾在此，解太师烦忧。",
--   ["$ol_ex__yaowu2"] = "这些杂兵，我有何惧！",
--   ["$ol_ex__shizhan1"] = "看你能坚持几个回合！",
--   ["$ol_ex__shizhan2"] = "兀那汉子，且报上名来！",
--   ["~ol_ex__huaxiong"] = "我掉以轻心了……",
-- }

-- local xiahouyuan = General(extension, "ol_ex__xiahouyuan", "wei", 4)
-- local ol_ex__shensu = fk.CreateTriggerSkill{
--   name = "ol_ex__shensu",
--   anim_type = "offensive",
--   events = {fk.EventPhaseChanging},
--   can_trigger = function(self, event, target, player, data)
--     if target == player and player:hasSkill(self) and not player:prohibitUse(Fk:cloneCard("slash")) then
--       if (data.to == Player.Judge and not player.skipped_phases[Player.Draw]) or data.to == Player.Discard then
--         return true
--       elseif data.to == Player.Play then
--         return not player:isNude()
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local slash = Fk:cloneCard("slash")
--     local max_num = slash.skill:getMaxTargetNum(player, slash)
--     local targets = {}
--     for _, p in ipairs(room.alive_players) do
--       if player ~= p and not player:isProhibited(p, slash) then
--         table.insert(targets, p.id)
--       end
--     end
--     if #targets == 0 or max_num == 0 then return end
--     if data.to == Player.Judge then
--       local tos = room:askForChoosePlayers(player, targets, 1, max_num, "#ol_ex__shensu1-choose", self.name, true)
--       if #tos > 0 then
--         self.cost_data = {tos}
--         return true
--       end
--     elseif data.to == Player.Play then
--       local tos, id = room:askForChooseCardAndPlayers(player, targets, 1, max_num, ".|.|.|.|.|equip", "#ol_ex__shensu2-choose", self.name, true)
--       if #tos > 0 and id then
--         self.cost_data = {tos, {id}}
--         return true
--       end
--     elseif data.to == Player.Discard then
--       local tos = room:askForChoosePlayers(player, targets, 1, max_num, "#ol_ex__shensu3-choose", self.name, true)
--       if #tos > 0 then
--         self.cost_data = {tos}
--         return true
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if data.to == Player.Judge then
--       player:skip(Player.Judge)
--       player:skip(Player.Draw)
--     elseif data.to == Player.Play then
--       player:skip(Player.Play)
--       room:throwCard(self.cost_data[2], self.name, player, player)
--     elseif data.to == Player.Discard then
--       player:skip(Player.Discard)
--       player:turnOver()
--     end

--     local slash = Fk:cloneCard("slash")
--     slash.skillName = self.name
--     room:useCard({
--       from = target.id,
--       tos = table.map(self.cost_data[1], function(pid) return { pid } end),
--       card = slash,
--       extraUse = true,
--     })
--     return true
--   end,
-- }
-- local ol_ex__shebian = fk.CreateTriggerSkill{
--   name = "ol_ex__shebian",
--   events = { fk.TurnedOver },
--   anim_type = "control",
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local to = room:askForChooseToMoveCardInBoard(player, "#ol_ex__shebian-choose", self.name, true, "e")
--     if #to == 2 then
--       room:askForMoveCardInBoard(player, room:getPlayerById(to[1]), room:getPlayerById(to[2]), self.name, "e")
--     end
--   end,
-- }
-- xiahouyuan:addSkill(ol_ex__shensu)
-- xiahouyuan:addSkill(ol_ex__shebian)
-- Fk:loadTranslationTable{
--   ["ol_ex__xiahouyuan"] = "界夏侯渊",
--   ["#ol_ex__xiahouyuan"] = "疾行的猎豹",
--   ["illustrator:ol_ex__xiahouyuan"] = "李秀森",
--   ["ol_ex__shensu"] = "神速",
--   [":ol_ex__shensu"] = "①判定阶段开始前，你可跳过此阶段和摸牌阶段来视为使用普【杀】。②出牌阶段开始前，你可跳过此阶段并弃置一张装备牌来视为使用普【杀】。③弃牌阶段开始前，你可跳过此阶段并翻面来视为使用普【杀】。",
--   ["ol_ex__shebian"] = "设变",
--   [":ol_ex__shebian"] = "当你翻面后，你可将一名角色装备区里的一张牌置入另一名角色的装备区。",
--   ["#ol_ex__shensu1-choose"] = "神速：你可以跳过判定阶段和摸牌阶段，视为使用一张无距离限制的【杀】",
--   ["#ol_ex__shensu2-choose"] = "神速：你可以跳过出牌阶段并弃置一张装备牌，视为使用一张无距离限制的【杀】",
--   ["#ol_ex__shensu3-choose"] = "神速：你可以跳过弃牌阶段并翻面，视为使用一张无距离限制的【杀】",
--   ["#ol_ex__shebian-choose"] = "设变：你可以移动场上的一张装备牌",

--   ["$ol_ex__shensu1"] = "奔逸绝尘，不留踪影！",
--   ["$ol_ex__shensu2"] = "健步如飞，破敌不备！",
--   ["$ol_ex__shebian1"] = "设变力战，虏敌千万！",
--   ["$ol_ex__shebian2"] = "随机应变，临机设变！",
--   ["~ol_ex__xiahouyuan"] = "我的速度，还是不够……",
-- }

-- local caoren = General(extension, "ol_ex__caoren", "wei", 4)
-- local ol_ex__jushou_select = fk.CreateActiveSkill{
--   name = "#ol_ex__jushou_select",
--   can_use = Util.FalseFunc,
--   target_num = 0,
--   card_num = 1,
--   card_filter = function(self, to_select, selected)
--     if #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip then
--       local card = Fk:getCardById(to_select)
--       if card.type == Card.TypeEquip then
--         return not Self:prohibitUse(card)
--       else
--         return not Self:prohibitDiscard(card)
--       end
--     end
--   end,
-- }
-- local ol_ex__jushou = fk.CreateTriggerSkill{
--   name = "ol_ex__jushou",
--   anim_type = "offensive",
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.phase == Player.Finish
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:turnOver()
--     if player.dead then return false end
--     room:drawCards(player, 4, self.name)
--     if player.dead then return false end
--     local jushou_card
--     for _, id in pairs(player:getCardIds(Player.Hand)) do
--       local card = Fk:getCardById(id)
--       if (card.type == Card.TypeEquip and not player:prohibitUse(card)) or (card.type ~= Card.TypeEquip and not player:prohibitDiscard(card)) then
--         jushou_card = card
--         break
--       end
--     end
--     if not jushou_card then return end
--     local _, ret = room:askForUseActiveSkill(player, "#ol_ex__jushou_select", "#ol_ex__jushou-select", false)
--     if ret then
--       jushou_card = Fk:getCardById(ret.cards[1])
--     end
--     if jushou_card then
--       if jushou_card.type == Card.TypeEquip then
--         room:useCard({
--           from = player.id,
--           tos = {{player.id}},
--           card = jushou_card,
--         })
--       else
--         room:throwCard(jushou_card:getEffectiveId(), self.name, player, player)
--       end
--     end
--   end,
-- }
-- local ol_ex__jiewei = fk.CreateViewAsSkill{
--   name = "ol_ex__jiewei",
--   anim_type = "defensive",
--   pattern = "nullification",
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return end
--     local c = Fk:cloneCard("nullification")
--     c.skillName = self.name
--     c:addSubcard(cards[1])
--     return c
--   end,
--   enabled_at_play = Util.FalseFunc,
--   enabled_at_response = function (self, player)
--     return #player.player_cards[Player.Equip] > 0
--   end,
-- }
-- local ol_ex__jiewei_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__jiewei_trigger",
--   events = { fk.TurnedOver },
--   anim_type = "control",
--   mute = true,
--   main_skill = ol_ex__jiewei,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(ol_ex__jiewei) and not player:isNude() and player.faceup
--   end,
--   on_cost = function(self, event, target, player, data)
--     local cards = player.room:askForDiscard(player, 1, 1, true, "ol_ex__jiewei", true, ".", "#ol_ex__jiewei-discard", true)
--     if #cards > 0 then
--       self.cost_data = cards
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:broadcastSkillInvoke("ol_ex__jiewei")
--     room:notifySkillInvoked(player, "ol_ex__jiewei", "control")
--     room:throwCard(self.cost_data, self.name, player, player)
--     if player.dead then return false end
--     local to = room:askForChooseToMoveCardInBoard(player, "#ol_ex__jiewei-choose", "ol_ex__jiewei", true)
--     if #to == 2 then
--       room:askForMoveCardInBoard(player, room:getPlayerById(to[1]), room:getPlayerById(to[2]), "ol_ex__jiewei")
--     end
--   end,
-- }
-- ol_ex__jushou:addRelatedSkill(ol_ex__jushou_select)
-- ol_ex__jiewei:addRelatedSkill(ol_ex__jiewei_trigger)
-- caoren:addSkill(ol_ex__jushou)
-- caoren:addSkill(ol_ex__jiewei)
-- Fk:loadTranslationTable{
--   ["ol_ex__caoren"] = "界曹仁",
--   ["ol_ex__jushou"] = "据守",
--   ["#ol_ex__jushou_select"] = "据守",
--   [":ol_ex__jushou"] = "结束阶段，你可翻面，你摸四张牌，选择：1.使用一张为装备牌的手牌；2.弃置一张不为装备牌的手牌。",
--   ["ol_ex__jiewei"] = "解围",
--   ["#ol_ex__jiewei_trigger"] = "解围",
--   [":ol_ex__jiewei"] = "①你可将一张装备区里的牌当【无懈可击】使用。②当你翻面后，若你的武将牌正面朝上，你可弃置一张牌，你可将一名角色装备区或判定区里的一张牌置入另一名角色的相同区域。",

--   ["#ol_ex__jushou-select"] = "据守：选择使用手牌中的一张装备牌或弃置手牌中的一张非装备牌",
--   ["#ol_ex__jiewei-discard"] = "解围：弃置一张牌发动，之后可以移动场上的一张牌",
--   ["#ol_ex__jiewei-choose"] = "解围：你可以移动场上的一张装备牌",

--   ["$ol_ex__jushou1"] = "兵精粮足，守土一方。",
--   ["$ol_ex__jushou2"] = "坚守此地，不退半步。",
--   ["$ol_ex__jiewei1"] = "化守为攻，出奇制胜！",
--   ["$ol_ex__jiewei2"] = "坚壁清野，以挫敌锐！",
--   ["~ol_ex__caoren"] = "长江以南，再无王土矣……",
-- }

-- local huangzhong = General(extension, "ol_ex__huangzhong", "shu", 4)
-- local ol_ex__liegong = fk.CreateTriggerSkill{
--   name = "ol_ex__liegong",
--   anim_type = "offensive",
--   events = {fk.TargetSpecified},
--   can_trigger = function(self, event, target, player, data)
--     if not (target == player and player:hasSkill(self)) then return end
--     local to = player.room:getPlayerById(data.to)
--     return data.card.trueName == "slash" and (#to:getCardIds(Player.Hand) <= #player:getCardIds(Player.Hand) or to.hp >= player.hp)
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     if room:askForSkillInvoke(player, self.name, nil, "#ol_ex__liegong-invoke::"..data.to) then
--       room:doIndicate(player.id, {data.to})
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local to = player.room:getPlayerById(data.to)
--     if #to:getCardIds(Player.Hand) <= #player:getCardIds(Player.Hand) then
--       data.disresponsive = true -- FIXME: use disreponseList. this is FK's bug
--     end
--     if to.hp >= player.hp then
--       data.additionalDamage = (data.additionalDamage or 0) + 1
--     end
--   end,
-- }
-- local ol_ex__liegong_targetmod = fk.CreateTargetModSkill{
--   name = "#ol_ex__liegong_targetmod",
--   bypass_distances =  function(self, player, skill, card, target)
--     if skill.trueName == "slash_skill" and player:hasSkill(ol_ex__liegong) then
--       return card and target and player:distanceTo(target) <= card.number
--     end
--   end,
-- }
-- ol_ex__liegong:addRelatedSkill(ol_ex__liegong_targetmod)
-- huangzhong:addSkill(ol_ex__liegong)
-- Fk:loadTranslationTable{
--   ["ol_ex__huangzhong"] = "界黄忠",
--   ["#ol_ex__huangzhong"] = "老当益壮",
--   ["illustrator:ol_ex__huangzhong"] = "匠人绘",
--   ["ol_ex__liegong"] = "烈弓",
--   [":ol_ex__liegong"] = "①你对至其距离不大于此【杀】点数的角色使用【杀】无距离关系的限制。"..
--   "②当你使用【杀】指定一个目标后，你可执行：1.若其手牌数不大于你，此【杀】不能被此目标抵消；"..
--   "2.若其体力值不小于你，此【杀】对此目标的伤害值基数+1。",

--   ["#ol_ex__liegong-invoke"] = "是否对%dest发动 烈弓",

--   ["$ol_ex__liegong1"] = "龙骨成镞，矢破苍穹！",
--   ["$ol_ex__liegong2"] = "凤翎为羽，箭没坚城！",
--   ["~ol_ex__huangzhong"] = "末将，有负主公重托……",
-- }

-- local weiyan = General(extension, "ol_ex__weiyan", "shu", 4)
-- local ol_ex__kuanggu = fk.CreateTriggerSkill{
--   name = "ol_ex__kuanggu",
--   anim_type = "drawcard",
--   events = {fk.Damage},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player and (data.extra_data or {}).kuanggucheck
--   end,
--   on_trigger = function(self, event, target, player, data)
--     for i = 1, data.damage do
--       if i > 1 and (self.cost_data == "Cancel" or not player:hasSkill(self)) then break end
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local choices = {"draw1", "Cancel"}
--     if player:isWounded() then
--       table.insert(choices, 2, "recover")
--     end
--     self.cost_data = room:askForChoice(player, choices, self.name)
--     return self.cost_data ~= "Cancel"
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if self.cost_data == "recover" then
--       room:recover({
--         who = player,
--         num = 1,
--         recoverBy = player,
--         skillName = self.name
--       })
--     elseif self.cost_data == "draw1" then
--       player:drawCards(1, self.name)
--     end
--   end,

--   refresh_events = {fk.BeforeHpChanged},
--   can_refresh = function(self, event, target, player, data)
--     if data.damageEvent and player == data.damageEvent.from and player:distanceTo(target) < 2 and not target:isRemoved() then
--       return true
--     end
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.damageEvent.extra_data = data.damageEvent.extra_data or {}
--     data.damageEvent.extra_data.kuanggucheck = true
--   end,
-- }
-- local ol_ex__qimou_targetmod = fk.CreateTargetModSkill{
--   name = "#ol_ex__qimou_targetmod",
--   residue_func = function(self, player, skill, scope)
--     if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
--       return player:getMark("@qimou-turn")
--     end
--   end,
-- }
-- local ol_ex__qimou_distance = fk.CreateDistanceSkill{
--   name = "#ol_ex__qimou_distance",
--   correct_func = function(self, from, to)
--     return -from:getMark("@qimou-turn")
--   end,
-- }
-- local ol_ex__qimou = fk.CreateActiveSkill{
--   name = "ol_ex__qimou",
--   anim_type = "offensive",
--   card_num = 0,
--   target_num = 0,
--   frequency = Skill.Limited,
--   prompt = "#ol_ex__qimou",
--   interaction = function()
--     return UI.Spin {
--       from = 1,
--       to = Self.hp,
--     }
--   end,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and player.hp > 0
--   end,
--   card_filter = Util.FalseFunc,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local tolose = self.interaction.data
--     room:loseHp(player, tolose, self.name)
--     if player.dead then return end
--     room:addPlayerMark(player, "@qimou-turn", tolose)
--     player:drawCards(tolose, self.name)
--   end,
-- }
-- ol_ex__qimou:addRelatedSkill(ol_ex__qimou_targetmod)
-- ol_ex__qimou:addRelatedSkill(ol_ex__qimou_distance)
-- weiyan:addSkill(ol_ex__kuanggu)
-- weiyan:addSkill(ol_ex__qimou)
-- Fk:loadTranslationTable{
--   ["ol_ex__weiyan"] = "界魏延",
--   ["#ol_ex__weiyan"] = "嗜血的独狼",
--   ["illustrator:ol_ex__weiyan"] = "王强",
--   ["ol_ex__kuanggu"] = "狂骨",
--   [":ol_ex__kuanggu"] = "你对距离1以内的角色造成1点伤害后，你可以选择摸一张牌或回复1点体力。",
--   ["ol_ex__qimou"] = "奇谋",
--   [":ol_ex__qimou"] = "限定技，出牌阶段，你可以失去X点体力，摸X张牌，本回合内与其他角色计算距离-X且可以多使用X张杀。",
--   ["@qimou-turn"] = "奇谋",
--   ["#ol_ex__qimou"] = "奇谋：可失去任意点体力，摸等量张牌，本回合与其他角色距离减等量，可多出等量张杀",

--   ["$ol_ex__kuanggu1"] = "反骨狂傲，彰显本色！",
--   ["$ol_ex__kuanggu2"] = "只有战场，能让我感到兴奋！",
--   ["$ol_ex__qimou1"] = "为了胜利，可以出其不意！",
--   ["$ol_ex__qimou2"] = "勇战不如奇谋。",
--   ["~ol_ex__weiyan"] = "这次失败，意料之中……",
-- }

-- local xiaoqiao = General(extension, "ol_ex__xiaoqiao", "wu", 3, 3, General.Female)
-- local ol_ex__tianxiang = fk.CreateTriggerSkill{
--   name = "ol_ex__tianxiang",
--   anim_type = "defensive",
--   events = {fk.DamageInflicted},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player and not player:isNude()
--   end,
--   on_cost = function(self, event, target, player, data)
--     local ids = table.filter(player:getCardIds("he"), function(id)
--       return not player:prohibitDiscard(Fk:getCardById(id)) and Fk:getCardById(id).suit == Card.Heart
--     end)
--     local tar, card =  player.room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, tostring(Exppattern{ id = ids }), "#ol_ex__tianxiang-choose", self.name, true)
--     if #tar > 0 and card then
--       self.cost_data = {tar[1], card}
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local to = room:getPlayerById(self.cost_data[1])
--     local cid = self.cost_data[2]
--     room:throwCard(cid, self.name, player, player)

--     if player.dead or to.dead then return true end

--     local choices = {"ol_ex__tianxiang_loseHp"}
--     if data.from and not data.from.dead then
--       table.insert(choices, "ol_ex__tianxiang_damage")
--     end
--     local choice = room:askForChoice(player, choices, self.name, "#ol_ex__tianxiang-choice::"..to.id)
--     if choice == "ol_ex__tianxiang_loseHp" then
--       room:loseHp(to, 1, self.name)
--       if not to.dead and (room:getCardArea(cid) == Card.DrawPile or room:getCardArea(cid) == Card.DiscardPile) then
--         room:obtainCard(to, cid, true, fk.ReasonJustMove)
--       end
--     else
--       room:damage{
--         from = data.from,
--         to = to,
--         damage = 1,
--         skillName = self.name,
--       }
--       if not to.dead then
--         to:drawCards(math.min(to:getLostHp(), 5), self.name)
--       end
--     end
--     return true
--   end,
-- }
-- local ol_ex__hongyan = fk.CreateFilterSkill{
--   name = "ol_ex__hongyan",
--   frequency = Skill.Compulsory,
--   card_filter = function(self, to_select, player, isJudgeEvent)
--     return to_select.suit == Card.Spade and player:hasSkill(self) and
--     (table.contains(player:getCardIds("he"), to_select.id) or isJudgeEvent)
--   end,
--   view_as = function(self, to_select)
--     return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
--   end,
-- }
-- local ol_ex__hongyan_maxcards = fk.CreateMaxCardsSkill{
--   name = "#ol_ex__hongyan_maxcards",
--   fixed_func = function (self, player)
--     if player:hasSkill(ol_ex__hongyan) and #table.filter(player:getCardIds(Player.Equip), function (id) return Fk:getCardById(id).suit == Card.Heart end) > 0  then
--       return player.maxHp
--     end
--   end,
-- }
-- local ol_ex__piaoling = fk.CreateTriggerSkill{
--   name = "ol_ex__piaoling",
--   anim_type = "support",
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self)
--       and player.phase == Player.Finish
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local judge = {
--       who = player,
--       reason = self.name,
--       pattern = ".|.|heart",
--     }
--     room:judge(judge)
--   end,
-- }
-- local ol_ex__piaoling_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__piaoling_delay",
--   events = {fk.FinishJudge},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and not player.dead and data.card.suit == Card.Heart and data.reason == ol_ex__piaoling.name
--       and player.room:getCardArea(data.card.id) == Card.Processing
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if data.card.suit == Card.Heart and room:getCardArea(data.card) == Card.Processing then
--       local targets = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#ol_ex__piaoling-choose", ol_ex__piaoling.name, true)
--       if #targets == 0 then
--         room:moveCards({
--           ids = {data.card.id},
--           fromArea = Card.Processing,
--           toArea = Card.DrawPile,
--           moveReason = fk.ReasonPut,
--           skillName = ol_ex__piaoling.name,
--         })
--       else
--         local to = room:getPlayerById(targets[1])
--         room:obtainCard(to, data.card, true, fk.ReasonJustMove)
--         if to == player and not to.dead then
--           room:askForDiscard(to, 1, 1, true, ol_ex__piaoling.name, false, ".", "#ol_ex__piaoling-discard")
--         end
--       end
--     end
--   end,
-- }
-- ol_ex__hongyan:addRelatedSkill(ol_ex__hongyan_maxcards)
-- ol_ex__piaoling:addRelatedSkill(ol_ex__piaoling_delay)
-- xiaoqiao:addSkill(ol_ex__tianxiang)
-- xiaoqiao:addSkill(ol_ex__hongyan)
-- xiaoqiao:addSkill(ol_ex__piaoling)
-- Fk:loadTranslationTable{
--   ["ol_ex__xiaoqiao"] = "界小乔",
--   ["#ol_ex__xiaoqiao"] = "矫情之花",
--   ["illustrator:ol_ex__xiaoqiao"] = "王强",
--   ["ol_ex__tianxiang"] = "天香",
--   [":ol_ex__tianxiang"] = "当你受到伤害时，你可弃置一张<font color='red'>♥</font>牌并选择一名其他角色。你防止此伤害，"..
--   "选择：1.令来源对其造成1点普通伤害，其摸X张牌（X为其已损失的体力值且至多为5）；2.令其失去1点体力，其获得牌堆或弃牌堆中你以此法弃置的牌。",
--   ["ol_ex__hongyan"] = "红颜",
--   [":ol_ex__hongyan"] = "锁定技，①你的♠牌或你的♠判定牌的花色视为<font color='red'>♥</font>。"..
--   "②若你的装备区里有<font color='red'>♥</font>牌，你的手牌上限初值改为体力上限。",
--   ["ol_ex__piaoling"] = "飘零",
--   ["#ol_ex__piaoling_delay"] = "飘零",
--   [":ol_ex__piaoling"] = "结束阶段，你可判定，然后当判定结果确定后，若为<font color='red'>♥</font>，你选择：1.将判定牌置于牌堆顶；"..
--   "2.令一名角色获得判定牌，若其为你，你弃置一张牌。",

--   ["#ol_ex__tianxiang-choose"] = "天香：弃置一张<font color='red'>♥</font>手牌并选择一名其他角色",
--   ["#ol_ex__tianxiang-choice"] = "天香：选择一项令 %dest 执行",
--   ["ol_ex__tianxiang_damage"] = "令其受到1点伤害并摸已损失体力值的牌",
--   ["ol_ex__tianxiang_loseHp"] = "令其失去1点体力并获得你弃置的牌",
--   ["#ol_ex__piaoling-choose"] = "飘零：选择一名角色令其获得判定牌，若其为你，你弃置一张牌，或点取消将判定牌置于牌堆顶",
--   ["#ol_ex__piaoling-discard"] = "飘零：弃置1张牌",

--   ["$ol_ex__tianxiang1"] = "碧玉闺秀，只可远观。",
--   ["$ol_ex__tianxiang2"] = "你岂会懂我的美丽？",
--   ["$ol_ex__hongyan1"] = "红颜娇花好，折花门前盼。",
--   ["$ol_ex__hongyan2"] = "我的容貌，让你心动了吗？",
--   ["$ol_ex__piaoling1"] = "花自飘零水自流。",
--   ["$ol_ex__piaoling2"] = "清风拂枝，落花飘零。",
--   ["~ol_ex__xiaoqiao"] = "同心而离居，忧伤以终老……",
-- }

-- local zhoutai = General(extension, "ol_ex__zhoutai", "wu", 4)
-- local ol_ex__buqu = fk.CreateTriggerSkill{
--   name = "ol_ex__buqu",
--   anim_type = "defensive",
--   derived_piles = "ol_ex__buqu_scar",
--   events = {fk.AskForPeaches},
--   frequency = Skill.Compulsory,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.dying
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local scar_id = room:getNCards(1)[1]
--     local scar = Fk:getCardById(scar_id)
--     player:addToPile("ol_ex__buqu_scar", scar_id, true, self.name)
--     if player.dead or not table.contains(player:getPile("ol_ex__buqu_scar"), scar_id) then return false end
--     local success = true
--     for _, id in pairs(player:getPile("ol_ex__buqu_scar")) do
--       if id ~= scar_id then
--         local card = Fk:getCardById(id)
--         if (Fk:getCardById(id).number == scar.number) then
--           success = false
--           break
--         end
--       end
--     end
--     if success then
--       room:recover({
--         who = player,
--         num = 1 - player.hp,
--         recoverBy = player,
--         skillName = self.name
--       })
--     else
--       room:throwCard(scar:getEffectiveId(), self.name, player) 
--     end
--   end,
-- }
-- local ol_ex__buqu_maxcards = fk.CreateMaxCardsSkill{
--   name = "#ol_ex__buqu_maxcards",
--   fixed_func = function (self, player)
--     if player:hasSkill(ol_ex__buqu) and #player:getPile("ol_ex__buqu_scar") > 0 then
--       return #player:getPile("ol_ex__buqu_scar")
--     end
--   end,
-- }
-- local ol_ex__fenji = fk.CreateTriggerSkill{
--   name = "ol_ex__fenji",
--   anim_type = "support",
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) and player.hp >= 1 then
--       for _, move in ipairs(data) do
--         if (move.moveReason == fk.ReasonDiscard or move.moveReason == fk.ReasonPrey) then
--           if move.from and move.proposer and move.from ~= move.proposer then
--             for _, info in ipairs(move.moveInfo) do
--               if info.fromArea == Card.PlayerHand then
--                 return true
--               end
--             end
--           end
--         end
--       end
--     end
--   end,
--   on_trigger = function(self, event, target, player, data)
--     local room = player.room
--     local targets = {}
--     for _, move in ipairs(data) do
--       if not table.contains(targets, move.from) and (move.moveReason == fk.ReasonDiscard or move.moveReason == fk.ReasonPrey) then
--         if move.from and move.proposer and move.from ~= move.proposer then
--           for _, info in ipairs(move.moveInfo) do
--             if info.fromArea == Card.PlayerHand then
--               table.insert(targets, move.from)
--               break
--             end
--           end
--         end
--       end
--     end
--     room:sortPlayersByAction(targets)
--     for _, target_id in ipairs(targets) do
--       if not player:hasSkill(self) or player.hp < 1 then break end
--       local skill_target = room:getPlayerById(target_id)
--       if skill_target and not skill_target.dead then
--         self:doCost(event, skill_target, player, data)
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     return player.room:askForSkillInvoke(player, self.name, nil, "#ol_ex__fenji-invoke::"..target.id)
--   end,
--   on_use = function(self, event, target, player, data)
--     player.room:doIndicate(player.id, {target.id})
--     player.room:loseHp(player, 1, self.name)
--     if not target.dead then
--       target:drawCards(2, self.name)
--     end
--   end,
-- }
-- ol_ex__buqu:addRelatedSkill(ol_ex__buqu_maxcards)
-- zhoutai:addSkill(ol_ex__buqu)
-- zhoutai:addSkill(ol_ex__fenji)
-- Fk:loadTranslationTable{
--   ["ol_ex__zhoutai"] = "界周泰",
--   ["#ol_ex__zhoutai"] = "历战之躯",
--   ["illustrator:ol_ex__zhoutai"] = "Thinking",
--   ["ol_ex__buqu"] = "不屈",
--   [":ol_ex__buqu"] = "锁定技，①当你处于濒死状态时，你将牌堆顶的一张牌置于武将牌上（称为“创”），若：没有与此“创”点数相同的其他“创”，你将体力回复至1点；有与此“创”点数相同的其他“创”，你将此“创”置入弃牌堆。②若有“创”，你的手牌上限初值改为“创”数，",
--   ["ol_ex__fenji"] = "奋激",
--   [":ol_ex__fenji"] = "当一名角色A因另一名角色B的弃置或获得而失去手牌后，你可失去1点体力，令A摸两张牌。",

--   ["ol_ex__buqu_scar"] = "创",
--   ["#ol_ex__fenji-invoke"] = "奋激：你可以失去1点体力，令 %dest 摸两张牌",

--   ["$ol_ex__buqu1"] = "战如熊虎，不惜躯命！",
--   ["$ol_ex__buqu2"] = "哼！这点小伤算什么。",
--   ["$ol_ex__fenji1"] = "百战之身，奋勇趋前！",
--   ["$ol_ex__fenji2"] = "两肋插刀，愿赴此去！",
--   ["~ol_ex__zhoutai"] = "敌众我寡，无力回天……",
-- }

-- local zhangjiao = General(extension, "ol_ex__zhangjiao", "qun", 3)
-- local ol_ex__leiji = fk.CreateTriggerSkill{
--   name = "ol_ex__leiji",
--   anim_type = "offensive",
--   events = {fk.CardUsing, fk.CardResponding, fk.FinishJudge},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) and target == player then
--       if event == fk.CardUsing or event == fk.CardResponding then
--         return data.card.trueName == "jink" or data.card.trueName == "lightning"
--       elseif event == fk.FinishJudge then
--         return data.card.color == Card.Black
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.CardUsing or event == fk.CardResponding then
--       return player.room:askForSkillInvoke(player, self.name)
--     elseif event == fk.FinishJudge then
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.CardUsing or event == fk.CardResponding then
--       local judge = {
--         who = player,
--         reason = self.name,
--       }
--       room:judge(judge)
--     elseif event == fk.FinishJudge then
--       local x = 2
--       if data.card.suit == Card.Club then
--         x = 1
--         if player:isWounded() then
--           room:recover({
--             who = player,
--             num = 1,
--             recoverBy = player,
--             skillName = self.name,
--           })
--         end
--         if player.dead then return false end
--       end
--       local targets = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
--       "#ol_ex__leiji-choose:::" .. x, self.name, true)
--       if #targets > 0 then
--         local tar = targets[1]
--         room:damage{
--           from = player,
--           to = room:getPlayerById(tar),
--           damage = x,
--           damageType = fk.ThunderDamage,
--           skillName = self.name,
--         }
--       end
--     end
-- end,
-- }
-- local ol_ex__guidao = fk.CreateTriggerSkill{
--   name = "ol_ex__guidao",
--   anim_type = "control",
--   events = {fk.AskForRetrial},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and not player:isNude()
--   end,
--   on_cost = function(self, event, target, player, data)
--     local cards = player.room:askForCard(player, 1, 1, true, self.name, true, ".|.|spade,club", 
--     "#ol_ex__guidao-ask::" .. target.id..":"..data.reason)
--     if #cards == 1 then
--       self.cost_data = {cards = cards}
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local card = Fk:getCardById(self.cost_data.cards[1])
--     player.room:retrial(card, player, data, self.name, true)
--     if not player.dead and card.suit == Card.Spade and card.number > 1 and card.number < 10 then
--       player:drawCards(1, self.name)
--     end
--   end,
-- }

-- local ol_ex__huangtian = fk.CreateTriggerSkill{
--   name = "ol_ex__huangtian$",
--   mute = true,
--   attached_skill_name = "ol_ex__huangtian_other&",

--   refresh_events = {fk.AfterPropertyChange},
--   can_refresh = function(self, event, target, player, data)
--     return target == player
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     if player.kingdom == "qun" and table.find(room.alive_players, function (p)
--       return p ~= player and p:hasSkill(self, true)
--     end) then
--       room:handleAddLoseSkills(player, self.attached_skill_name, nil, false, true)
--     else
--       room:handleAddLoseSkills(player, "-" .. self.attached_skill_name, nil, false, true)
--     end
--   end,

--   on_acquire = function(self, player)
--     local room = player.room
--     for _, p in ipairs(room.alive_players) do
--       if p ~= player and p.kingdom == "qun" then
--         room:handleAddLoseSkills(p, self.attached_skill_name, nil, false, true)
--       end
--     end
--   end
-- }
-- local ol_ex__huangtian_other = fk.CreateActiveSkill{
--   name = "ol_ex__huangtian_other&",
--   anim_type = "support",
--   prompt = "#ol_ex__huangtian-active",
--   mute = true,
--   can_use = function(self, player)
--     if player.kingdom ~= "qun" then return false end
--     local targetRecorded = player:getTableMark("ol_ex__huangtian_sources-phase")
--     return table.find(Fk:currentRoom().alive_players, function(p)
--       return p ~= player and p:hasSkill(ol_ex__huangtian) and not table.contains(targetRecorded, p.id)
--     end)
--   end,
--   card_num = 1,
--   card_filter = function(self, to_select, selected)
--     if #selected < 1 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip then
--       local card = Fk:getCardById(to_select)
--       return card.trueName == "jink" or card.suit == Card.Spade
--     end
--   end,
--   target_num = 1,
--   target_filter = function(self, to_select, selected)
--     if #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):hasSkill(ol_ex__huangtian) then
--       local targetRecorded = Self:getMark("ol_ex__huangtian_sources-phase")
--       return type(targetRecorded) ~= "table" or not table.contains(targetRecorded, to_select)
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     room:notifySkillInvoked(player, ol_ex__huangtian.name)
--     target:broadcastSkillInvoke(ol_ex__huangtian.name)
--     room:addTableMarkIfNeed(player, "ol_ex__huangtian_sources-phase", target.id)
--     room:moveCardTo(effect.cards, Player.Hand, target, fk.ReasonGive, self.name, nil, true)
--   end,
-- }

-- Fk:addSkill(ol_ex__huangtian_other)
-- zhangjiao:addSkill(ol_ex__leiji)
-- zhangjiao:addSkill(ol_ex__guidao)
-- zhangjiao:addSkill(ol_ex__huangtian)

-- Fk:loadTranslationTable{
--   ["ol_ex__zhangjiao"] = "界张角",
--   ["#ol_ex__zhangjiao"] = "天公将军",
--   ["illustrator:ol_ex__zhangjiao"] = "青骑士",
--   ["ol_ex__leiji"] = "雷击",
--   [":ol_ex__leiji"] = "①当你使用或打出【闪】或【闪电】时，你可判定。②当你的判定结果确定后，若结果为：♠，你可对一名其他角色造成2点雷电伤害；♣，你回复1点体力，然后你可对一名其他角色造成1点雷电伤害。",
--   ["ol_ex__guidao"] = "鬼道",
--   [":ol_ex__guidao"] = "当一名角色的判定结果确定前，你可打出一张黑色牌代替之，你获得原判定牌，若你打出的牌是♠2~9，你摸一张牌。",
--   ["ol_ex__huangtian"] = "黄天",
--   [":ol_ex__huangtian"] = "主公技，其他群势力角色的出牌阶段限一次，该角色可以将一张【闪】或♠手牌（正面朝上移动）交给你。",

--   ["ol_ex__huangtian_other&"] = "黄天",
--   [":ol_ex__huangtian_other&"] = "出牌阶段限一次，你可将一张【闪】或♠手牌（正面朝上移动）交给张角。",

--   ["#ol_ex__leiji-choose"] = "雷击：你可以选择一名其他角色，对其造成%arg点雷电伤害",
--   ["#ol_ex__guidao-ask"] = "鬼道：可以打出一张黑色牌替换 %dest 的“%arg”判定，若打出♠2~9，你摸一张牌",
--   ["#ol_ex__huangtian-active"] = "发动黄天，选择一张【闪】或♠手牌（正面朝上移动）交给一名拥有“黄天”的角色",

--   ["$ol_ex__leiji1"] = "疾雷迅电，不可趋避！",
--   ["$ol_ex__leiji2"] = "雷霆之诛，灭军毁城！",
--   ["$ol_ex__guidao1"] = "鬼道运行，由我把控！",
--   ["$ol_ex__guidao2"] = "汝之命运，吾来改之！",
--   ["$ol_ex__huangtian1"] = "黄天法力，万军可灭！",
--   ["$ol_ex__huangtian2"] = "天书庇佑，黄巾可兴！",
--   ["~ol_ex__zhangjiao"] = "天书无效，人心难聚……",
-- }

-- local ol_ex__yuji = General(extension, "ol_ex__yuji", "qun", 3)
-- local ol_ex__guhuo = fk.CreateViewAsSkill{
--   name = "ol_ex__guhuo",
--   pattern = ".",
--   interaction = function()
--     local all_names = U.getAllCardNames("bt")
--     local names = U.getViewAsCardNames(Self, "ol_ex__guhuo", all_names)
--     if #names > 0 then
--       return U.CardNameBox { choices = names, all_choices = all_names }
--     end
--   end,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 or not self.interaction.data then return end
--     local card = Fk:cloneCard(self.interaction.data)
--     self.cost_data = cards
--     card.skillName = self.name
--     return card
--   end,
--   before_use = function(self, player, use)
--     local room = player.room
--     local cards = self.cost_data
--     local card_id = cards[1]
--     room:moveCardTo(cards, Card.Processing, nil, fk.ReasonPut, self.name, "", false, player.id)
--     local targets = TargetGroup:getRealTargets(use.tos)
--     if targets and #targets > 0 then
--       room:sendLog{
--         type = "#guhuo_use",
--         from = player.id,
--         to = targets,
--         arg = use.card.name,
--         arg2 = self.name
--       }

--       room:doIndicate(player.id, targets)
--     else
--       room:sendLog{
--         type = "#guhuo_no_target",
--         from = player.id,
--         arg = use.card.name,
--         arg2 = self.name
--       }
--     end

--     local canuse = true
--     local players = table.filter(room:getOtherPlayers(player, false), function(p) return not p:hasSkill("ol_ex__chanyuan") end)
--     if #players > 0 then
--       local questioners = {}
--       local result = U.askForJointChoice(players, {"noquestion", "question"}, self.name,
--         "#guhuo-ask::"..player.id..":"..use.card.name, true)
--       for _, p in ipairs(players) do
--         if result[p.id] == "question" then
--           table.insert(questioners, p)
--         end
--       end
--       if #questioners > 0 then
--         player:showCards({card_id})
--         if use.card.name == Fk:getCardById(card_id).name then
--           room:setCardEmotion(card_id, "judgegood")
--           for _, p in ipairs(questioners) do
--             if not p.dead then
--               if #room:askForDiscard(p, 1, 1, true, self.name, true, ".", "#ol_ex__guhuo-discard") == 0 then
--                 room:loseHp(p, 1, self.name)
--               end
--             end
--             room:handleAddLoseSkills(p, "ol_ex__chanyuan")
--           end
--         else
--           room:setCardEmotion(card_id, "judgebad")
--           for _, p in ipairs(questioners) do
--             if not p.dead then
--               p:drawCards(1, self.name)
--             end
--           end
--           canuse = false
--         end
--       end
--     end

--     if canuse then
--       use.card:addSubcard(card_id)
--     else
--       room:moveCardTo(card_id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name)
--       return ""
--     end
--   end,
--   enabled_at_play = function(self, player)
--     return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
--   end,
--   enabled_at_response = function(self, player, response)
--     return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
--   end,
-- }
-- ol_ex__yuji:addSkill(ol_ex__guhuo)
-- local ol_ex__chanyuan = fk.CreateInvaliditySkill {
--   name = "ol_ex__chanyuan",
--   invalidity_func = function(self, from, skill)
--     return from:hasSkill(self, true, true) and from.hp <= 1 and skill:isPlayerSkill(from)
--   end
-- }
-- local ol_ex__chanyuan_audio = fk.CreateTriggerSkill{
--   name = "#ol_ex__chanyuan_audio",
--   refresh_events = {fk.HpChanged, fk.EventAcquireSkill, fk.EventLoseSkill},
--   can_refresh = function(self, event, target, player, data)
--     if event == fk.HpChanged then
--       return target == player and player:hasSkill("ol_ex__chanyuan") and not player:isFakeSkill("ol_ex__chanyuan")
--       and player.hp <= 1 and data.num < 0 and (player.hp - data.num) > 1
--     else
--       return target == player and data == ol_ex__chanyuan
--     end
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.HpChanged then
--       room:notifySkillInvoked(player, "ol_ex__chanyuan", "negative")
--       player:broadcastSkillInvoke("ol_ex__chanyuan")
--     else
--       room:setPlayerMark(player, "@@ol_ex__chanyuan", event == fk.EventAcquireSkill and 1 or 0)
--     end
--   end,
-- }
-- ol_ex__chanyuan:addRelatedSkill(ol_ex__chanyuan_audio)
-- ol_ex__yuji:addRelatedSkill(ol_ex__chanyuan)
-- Fk:loadTranslationTable{
--   ["ol_ex__yuji"] = "界于吉",
--   ["#ol_ex__yuji"] = "太平道人",
--   ["illustrator:ol_ex__yuji"] = "波子",
--   ["ol_ex__guhuo"] = "蛊惑",
--   [":ol_ex__guhuo"] = "每回合限一次，你可以扣置一张手牌，将此牌当任意一张基本牌或普通锦囊牌使用或打出。此牌使用前，其他角色同时选择是否质疑，选择结束后，若有质疑则翻开此牌，若此牌为：假，此牌作废且所有质疑角色摸一张牌；真，所有质疑角色依次弃置一张牌或失去1点体力，然后获得技能〖缠怨〗。",
--   ["#ol_ex__guhuo-discard"] = "蛊惑：弃置一张牌，否则失去1点体力",
--   ["ol_ex__chanyuan"] = "缠怨",
--   [":ol_ex__chanyuan"] = "锁定技，你不能质疑〖蛊惑〗；若你的体力值小于等于1，你的其他技能失效。",
--   ["@@ol_ex__chanyuan"] = "缠怨",

--   ["$ol_ex__guhuo1"] = "真真假假，虚实难测。",
--   ["$ol_ex__guhuo2"] = "这牌，猜对了吗？",
--   ["$ol_ex__chanyuan1"] = "此咒甚重，怨念缠身。",
--   ["$ol_ex__chanyuan2"] = "不信吾法，无福之缘。",
--   ["~ol_ex__yuji"] = "符水失效，此病难医……",
-- }

-- local ol_ex__qiangxi = fk.CreateActiveSkill{
--   name = "ol_ex__qiangxi",
--   anim_type = "offensive",
--   prompt = "#ol_ex__qiangxi",
--   max_card_num = 1,
--   target_num = 1,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
--   end,
--   card_filter = function(self, to_select, selected)
--     return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon
--   end,
--   target_filter = function(self, to_select, selected, selected_cards)
--     if #selected == 0 and to_select ~= Self.id then
--       local qiangxiRecorded = Self:getTableMark("ol_ex__qiangxi_targets-phase")
--       return not table.contains(qiangxiRecorded, to_select)
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     room:addTableMarkIfNeed(player, "ol_ex__qiangxi_targets-phase", target.id)
--     if #effect.cards > 0 then
--       room:throwCard(effect.cards, self.name, player)
--     else
--       room:damage{
--         to = player,
--         damage = 1,
--         skillName = self.name,
--       }
--     end
--     if not target.dead then
--       room:damage{
--         from = player,
--         to = target,
--         damage = 1,
--         skillName = self.name,
--       }
--     end
--   end,
-- }
-- local ol_ex__ninge = fk.CreateTriggerSkill{
--   name = "ol_ex__ninge",
--   anim_type = "control",
--   events = {fk.Damaged},
--   frequency = Skill.Compulsory,
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) and (target == player or data.from == player) then
--       local events = player.room.logic:getActualDamageEvents(2, function(e) return e.data[1].to == target end)
--       return #events > 1 and events[2].data[1] == data
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:doIndicate(player.id, { target.id })
--     player:drawCards(1, self.name)
--     if not player.dead and not target.dead and #target:getCardIds{Player.Judge, Player.Equip} > 0 then
--       local id = room:askForCardChosen(player, target, "ej", self.name)
--       room:throwCard({id}, self.name, target, player)
--     end
--   end,
-- }

-- local dianwei = General(extension, "ol_ex__dianwei", "wei", 4)
-- dianwei:addSkill(ol_ex__qiangxi)
-- dianwei:addSkill(ol_ex__ninge)

-- Fk:loadTranslationTable{
--   ["ol_ex__dianwei"] = "界典韦",
--   ["#ol_ex__dianwei"] = "古之恶来",
--   ["illustrator:ol_ex__dianwei"] = "君桓文化",
--   ["ol_ex__qiangxi"] = "强袭",
--   [":ol_ex__qiangxi"] = "出牌阶段限两次，你可受到1点普通伤害或弃置一张武器牌并选择一名于此阶段内未选择过的其他角色，你对其造成1点普通伤害。",
--   ["ol_ex__ninge"] = "狞恶",
--   [":ol_ex__ninge"] = "锁定技，当一名角色于当前回合内第二次受到伤害后，若其为你或来源为你，你摸一张牌，弃置其装备区或判定区里的一张牌。",

--   ["#ol_ex__qiangxi"] = "选择一张武器牌或不选（受到1点伤害），并选择强袭的目标",

--   ["$ol_ex__qiangxi1"] = "典韦来也，谁敢一战！",
--   ["$ol_ex__qiangxi2"] = "双戟青罡，百死无生！",
--   ["$ol_ex__ninge1"] = "古之恶来，今之典韦！",
--   ["$ol_ex__ninge2"] = "宁为刀俎，不为鱼肉！",
--   ["~ol_ex__dianwei"] = "为将者，怎可徒手而亡？",
-- }

-- local xunyu = General(extension, "ol_ex__xunyu", "wei", 3)
-- local ol_ex__jieming = fk.CreateTriggerSkill{
--   name = "ol_ex__jieming",
--   anim_type = "masochism",
--   events = {fk.Damaged, fk.Death},
--   can_trigger = function(self, event, target, player, data)
--     if target == player then
--       if event == fk.Damaged then
--         return player:hasSkill(self)
--       elseif event == fk.Death then
--         return player:hasSkill(self, false, true)
--       end
--     end
--   end,
--   on_trigger = function(self, event, target, player, data)
--     if event == fk.Damaged then
--       self.cancel_cost = false
--       for i = 1, data.damage do
--         if i > 1 and (self.cancel_cost or not player:hasSkill(self)) then break end
--         self:doCost(event, target, player, data)
--       end
--     elseif event == fk.Death then
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), Util.IdMapper), 1, 1, "#ol_ex__jieming-choose", self.name, true)
--     if #to > 0 then
--       self.cost_data = to[1]
--       return true
--     end
--     self.cancel_cost = true
--   end,
--   on_use = function(self, event, target, player, data)
--     local to = player.room:getPlayerById(self.cost_data)
--     to:drawCards(math.min(to.maxHp, 5), self.name)
--     if to.dead then return false end
--     local x = #to.player_cards[Player.Hand] - math.min(to.maxHp, 5)
--     if x > 0 then
--       player.room:askForDiscard(to, x, x, false, self.name, false, ".", "#ol_ex__jieming-discard:::"..x)
--     end
--   end,
-- }
-- xunyu:addSkill("quhu")
-- xunyu:addSkill(ol_ex__jieming)
-- Fk:loadTranslationTable{
--   ["ol_ex__xunyu"] = "界荀彧",
--   ["#ol_ex__xunyu"] = "王佐之才",
--   ["illustrator:ol_ex__xunyu"] = "罔両",
--   ["ol_ex__jieming"] = "节命",
--   [":ol_ex__jieming"] = "当你受到1点伤害后或当你死亡时，你可令一名角色摸X张牌，其将手牌弃置至X张。（X为其体力上限且至多为5）",
--   ["#ol_ex__jieming-choose"] = "节命：你可以令一名角色摸X张牌并将手牌弃至X张（X为其体力上限且至多为5）",
--   ["#ol_ex__jieming-discard"] = "节命：选择%arg张手牌弃置",

--   ["$quhu_ol_ex__xunyu1"] = "两虎相斗，旁观成败。",
--   ["$quhu_ol_ex__xunyu2"] = "驱兽相争，坐收渔利。",
--   ["$ol_ex__jieming1"] = "含气在胸，有进无退。",
--   ["$ol_ex__jieming2"] = "蕴节于形，生死无惧。",
--   ["~ol_ex__xunyu"] = "一招不慎，为虎所噬……",
-- }

-- local wolong = General(extension, "ol_ex__wolong", "shu", 3)
-- local ol_ex__huoji__fireAttackSkill = fk.CreateActiveSkill{
--   name = "ol_ex__huoji__fire_attack_skill",
--   prompt = "#fire_attack_skill",
--   target_num = 1,
--   mod_target_filter = function(_, to_select, _, _, _, _)
--     return not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
--   end,
--   target_filter = function(self, to_select, selected, _, card, _, player)
--     if #selected < self:getMaxTargetNum(Self, card) then
--       return self:modTargetFilter(to_select, selected, player, card)
--     end
--   end,
--   on_effect = function(self, room, cardEffectEvent)
--     local from = room:getPlayerById(cardEffectEvent.from)
--     local to = room:getPlayerById(cardEffectEvent.to)
--     if to:isKongcheng() then return end

--     local showCard = table.random(to:getCardIds(Player.Hand))
--     to:showCards(showCard)

--     if from.dead then return end

--     showCard = Fk:getCardById(showCard)
--     local pattern = ".|.|no_suit"
--     if showCard.color == Card.Red then
--       pattern = ".|.|heart,diamond"
--     elseif showCard.color == Card.Black then
--       pattern = ".|.|spade,club"
--     end
--     local cards = room:askForDiscard(from, 1, 1, false, "fire_attack_skill", true, pattern,
--     "#fire_attack-discard:" .. to.id .. "::" .. showCard:getColorString())
--     if #cards > 0 and not to.dead then
--       room:damage({
--         from = from,
--         to = to,
--         card = cardEffectEvent.card,
--         damage = 1,
--         damageType = fk.FireDamage,
--         skillName = "fire_attack_skill"
--       })
--     end
--   end,
-- }
-- ol_ex__huoji__fireAttackSkill.cardSkill = true
-- Fk:addSkill(ol_ex__huoji__fireAttackSkill)
-- local ol_ex__huoji = fk.CreateViewAsSkill{
--   name = "ol_ex__huoji",
--   anim_type = "offensive",
--   pattern = "fire_attack",
--   prompt = "#ol_ex__huoji-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return end
--     local card = Fk:cloneCard("fire_attack")
--     card.skillName = self.name
--     card:addSubcard(cards[1])
--     return card
--   end,
-- }
-- local ol_ex__huoji_buff = fk.CreateTriggerSkill{
--   name = "#ol_ex__huoji_buff",
--   events = {fk.PreCardEffect},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(ol_ex__huoji) and data.from == player.id and data.card.trueName == "fire_attack"
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local card = data.card:clone()
--     local c = table.simpleClone(data.card)
--     for k, v in pairs(c) do
--       card[k] = v
--     end
--     card.skill = ol_ex__huoji__fireAttackSkill
--     data.card = card
--   end,
-- }
-- local ol_ex__kanpo = fk.CreateViewAsSkill{
--   name = "ol_ex__kanpo",
--   anim_type = "control",
--   pattern = "nullification",
--   prompt = "#ol_ex__kanpo-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return end
--     local card = Fk:cloneCard("nullification")
--     card.skillName = self.name
--     card:addSubcard(cards[1])
--     return card
--   end,
-- }
-- local ol_ex__kanpo_buff = fk.CreateTriggerSkill{
--   name = "#ol_ex__kanpo_buff",

--   refresh_events = {fk.PreCardUse},
--   can_refresh = function(self, event, target, player, data)
--     return target == player and player:hasSkill(ol_ex__kanpo) and data.card.trueName == "nullification"
--   end,
--   on_refresh = function(self, event, target, player, data)
--     data.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
--   end,
-- }
-- local cangzhuo = fk.CreateTriggerSkill{
--   name = "cangzhuo",
--   anim_type = "defensive",
--   events = {fk.EventPhaseStart},
--   frequency = Skill.Compulsory,
--   can_trigger = function(self, event, target, player, data)
--     if target == player and player:hasSkill(self) and player.phase == Player.Discard then
--       local room = player.room
--       local logic = room.logic
--       local e = logic:getCurrentEvent():findParent(GameEvent.Turn, true)
--       if e == nil then return false end
--       local end_id = e.id
--       local events = logic.event_recorder[GameEvent.UseCard] or Util.DummyTable
--       for i = #events, 1, -1 do
--         e = events[i]
--         if e.id <= end_id then break end
--         local use = e.data[1]
--         if use.from == player.id and use.card.type == Card.TypeTrick then
--           return false
--         end
--       end
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     player.room:addPlayerMark(player, "cangzhuo-phase")
--   end,
-- }
-- local cangzhuo_maxcards = fk.CreateMaxCardsSkill{
--   name = "#cangzhuo_maxcards",
--   exclude_from = function(self, player, card)
--     return player:getMark("cangzhuo-phase") > 0 and card.type == Card.TypeTrick
--   end,
-- }
-- wolong:addSkill("bazhen")
-- ol_ex__huoji:addRelatedSkill(ol_ex__huoji_buff)
-- ol_ex__kanpo:addRelatedSkill(ol_ex__kanpo_buff)
-- cangzhuo:addRelatedSkill(cangzhuo_maxcards)
-- wolong:addSkill(ol_ex__huoji)
-- wolong:addSkill(ol_ex__kanpo)
-- wolong:addSkill(cangzhuo)

-- Fk:loadTranslationTable{
--   ["ol_ex__wolong"] = "界卧龙诸葛亮",
--   ["#ol_ex__wolong"] = "卧龙",
--   ["illustrator:ol_ex__wolong"] = "李秀森",
--   ["ol_ex__huoji"] = "火计",
--   [":ol_ex__huoji"] = "①你可以将一张红色牌转化为【火攻】使用。"..
--   "②你使用的【火攻】的作用效果改为：目标角色随机展示一张手牌，然后你可以弃置一张与此牌颜色相同的手牌对其造成1点火焰伤害。",
--   ["ol_ex__kanpo"] = "看破",
--   [":ol_ex__kanpo"] = "①你可以将一张黑色牌转化为【无懈可击】使用。②你使用的【无懈可击】不能被响应。",
--   ["cangzhuo"] = "藏拙",
--   [":cangzhuo"] = "锁定技，弃牌阶段开始时，若你于此回合内未使用过锦囊牌，你的锦囊牌于此阶段内不计入手牌上限。",
--   ["#ol_ex__huoji-viewas"] = "发动火计，选择一张红色牌转化为【火攻】使用",
--   ["#ol_ex__huoji_buff"] = "火计",
--   ["#ol_ex__kanpo-viewas"] = "发动看破，选择一张黑色牌转化为【无懈可击】使用",

--   ["$bazhen_ol_ex__wolong1"] = "八阵连心，日月同辉。",
--   ["$bazhen_ol_ex__wolong2"] = "此阵变化，岂是汝等可解？",
--   ["$ol_ex__huoji1"] = "赤壁借东风，燃火灭魏军。",
--   ["$ol_ex__huoji2"] = "东风，让这火烧得再猛烈些吧！",
--   ["$ol_ex__kanpo1"] = "此计奥妙，我已看破。",
--   ["$ol_ex__kanpo2"] = "还有什么是我看不破的？",
--   ["$cangzhuo1"] = "藏巧于拙，用晦而明。",
--   ["$cangzhuo2"] = "寓清于浊，以屈为伸。",
--   ["~ol_ex__wolong"] = "星途半废，夙愿未完……",
-- }

-- local pangtong = General(extension, "ol_ex__pangtong", "shu", 3)
-- local ol_ex__lianhuan = fk.CreateActiveSkill{
--   name = "ol_ex__lianhuan",
--   mute = true,
--   card_num = 1,
--   min_target_num = 0,
--   prompt = "#ol_ex__lianhuan-active",
--   can_use = Util.TrueFunc,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).suit == Card.Club
--   end,
--   target_filter = function(self, to_select, selected, selected_cards, _, _, player)
--     if #selected_cards == 1 then
--       local card = Fk:cloneCard("iron_chain")
--       card:addSubcard(selected_cards[1])
--       card.skillName = self.name
--       return player:canUse(card) and card.skill:targetFilter(to_select, selected, selected_cards, card, nil, player) and
--       not player:prohibitUse(card) and not player:isProhibited(Fk:currentRoom():getPlayerById(to_select), card)
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     player:broadcastSkillInvoke(self.name)
--     if #effect.tos == 0 then
--       room:notifySkillInvoked(player, self.name, "drawcard")
--       room:recastCard(effect.cards, player, self.name)
--     else
--       room:notifySkillInvoked(player, self.name, "control")
--       room:sortPlayersByAction(effect.tos)
--       room:useVirtualCard("iron_chain", effect.cards, player, table.map(effect.tos, Util.Id2PlayerMapper), self.name)
--     end
--   end,
-- }
-- local ol_ex__lianhuan_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__lianhuan_trigger",
--   anim_type = "control",
--   main_skill = ol_ex__lianhuan,
--   events = {fk.AfterCardTargetDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(ol_ex__lianhuan) and data.card.trueName == "iron_chain" and
--     #player.room:getUseExtraTargets(data) > 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     local to = player.room:askForChoosePlayers(player, player.room:getUseExtraTargets(data),
--     1, 1, "#ol_ex__lianhuan-choose:::"..data.card:toLogString(), ol_ex__lianhuan.name, true)
--     if #to > 0 then
--       self.cost_data = to[1]
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     player:broadcastSkillInvoke(ol_ex__lianhuan.name)
--     TargetGroup:pushTargets(data.tos, self.cost_data)
--   end,
-- }
-- local ol_ex__niepan = fk.CreateTriggerSkill{
--   name = "ol_ex__niepan",
--   anim_type = "defensive",
--   frequency = Skill.Limited,
--   events = {fk.AskForPeaches},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:throwAllCards("hej")
--     if player.dead then return false end
--     player:reset()
--     if player.dead then return false end
--     player:drawCards(3, self.name)
--     if player.dead then return false end
--     if player:isWounded() then
--       room:recover({
--         who = player,
--         num = math.min(3, player.maxHp) - player.hp,
--         recoverBy = player,
--         skillName = self.name,
--       })
--       if player.dead then return false end
--     end
--     local wolong_skills = {"bazhen", "ol_ex__huoji", "ol_ex__kanpo"}
--     local choices = table.filter(wolong_skills, function (skill_name)
--       return not player:hasSkill(skill_name, true)
--     end)
--     if #choices == 0 then return false end
--     local choice = player.room:askForChoice(player, choices, self.name, "#ol_ex__niepan-choice", true, wolong_skills)
--     room:handleAddLoseSkills(player, choice, nil)
--   end,
-- }
-- ol_ex__lianhuan:addRelatedSkill(ol_ex__lianhuan_trigger)
-- pangtong:addSkill(ol_ex__lianhuan)
-- pangtong:addSkill(ol_ex__niepan)
-- pangtong:addRelatedSkill("bazhen")
-- pangtong:addRelatedSkill("ol_ex__huoji")
-- pangtong:addRelatedSkill("ol_ex__kanpo")

-- Fk:loadTranslationTable{
--   ["ol_ex__pangtong"] = "界庞统",
--   ["#ol_ex__pangtong"] = "凤雏",
--   ["illustrator:ol_ex__pangtong"] = "MUMU",
--   ["ol_ex__lianhuan"] = "连环",
--   [":ol_ex__lianhuan"] = "①出牌阶段，你可选择：1.将一张♣牌转化为【铁索连环】使用；2.重铸一张♣牌。"..
--   "②当【铁索连环】选择目标后，若使用者为你，你可令一名角色也成为此牌的目标。",
--   ["ol_ex__niepan"] = "涅槃",
--   [":ol_ex__niepan"] = "限定技，当你处于濒死状态时，你可以：弃置区域里的所有牌，复原，"..
--   "摸三张牌，将体力回复至3点，选择下列一个技能并获得之：1.〖八阵〗；2.〖火计〗；3.〖看破〗。",

--   ["#ol_ex__lianhuan-active"] = "发动连环，你可以将一张♣牌转化为【铁索连环】使用，不选目标直接点确定则重铸",
--   ["#ol_ex__lianhuan_trigger"] = "连环",
--   ["#ol_ex__lianhuan-choose"] = "你可以发动 连环，为使用的【%arg】额外指定一个目标",
--   ["#ol_ex__niepan-choice"] = "涅槃：选择获得一项技能",

--   ["$ol_ex__lianhuan1"] = "连环之策，攻敌之计。",
--   ["$ol_ex__lianhuan2"] = "锁链连舟，困步难行。",
--   ["$ol_ex__niepan1"] = "烈火脱胎，涅槃重生。",
--   ["$ol_ex__niepan2"] = "破而后立，方有大成。",
--   ["$bazhen_ol_ex__pangtong1"] = "八卦四象，阴阳运转。",
--   ["$bazhen_ol_ex__pangtong2"] = "离火艮山，皆随我用。",
--   ["$ol_ex__huoji_ol_ex__pangtong1"] = "火计诱敌，江水助势。",
--   ["$ol_ex__huoji_ol_ex__pangtong2"] = "火烧赤壁，曹贼必败。",
--   ["$ol_ex__kanpo_ol_ex__pangtong1"] = "卧龙之才，吾也略懂。",
--   ["$ol_ex__kanpo_ol_ex__pangtong2"] = "这些小伎俩，逃不出我的眼睛！",
--   ["~ol_ex__pangtong"] = "骥飞羽落，坡道归尘……",
-- }

-- local hanzhan = fk.CreateTriggerSkill{
--   name = "hanzhan",
--   anim_type = "control",
--   events = {fk.StartPindian, fk.PindianResultConfirmed},
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return false end
--     if event == fk.StartPindian then
--       if player == data.from then
--         for _, to in ipairs(data.tos) do
--           if not (data.results[to.id] and data.results[to.id].toCard) then
--             return true
--           end
--         end
--       elseif not data.fromCard then
--         return table.contains(data.tos, player)
--       end
--     elseif event == fk.PindianResultConfirmed then
--       if player == data.from or player == data.to then
--         local cardA = Fk:getCardById(data.fromCard:getEffectiveId())
--         local cardB = Fk:getCardById(data.toCard:getEffectiveId())
--         local cards = {}
--         if cardA.trueName == "slash" then
--           cards = {cardA.id}
--         end
--         if cardB.trueName == "slash" then
--           if cardA.trueName == "slash" then
--             if cardA.number == cardB.number and cardA.id ~= cardB.id then
--               table.insert(cards, cardB.id)
--             elseif cardA.number < cardB.number then
--               cards = {cardB.id}
--             end
--           else
--             cards = {cardB.id}
--           end
--         end
--         cards = table.filter(cards, function (id)
--           return player.room:getCardArea(id) == Card.Processing
--         end)
--         if #cards > 0 then
--           self.cost_data = cards
--           return true
--         end
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.StartPindian then
--       if player == data.from then
--         for _, to in ipairs(data.tos) do
--           if not (to.dead or to:isKongcheng() or (data.results[to.id] and data.results[to.id].toCard)) then
--             data.results[to.id] = data.results[to.id] or {}
--             data.results[to.id].toCard = Fk:getCardById(table.random(to:getCardIds(Player.Hand)))
--           end
--         end
--       elseif not (data.from.dead or data.from:isKongcheng()) then
--         data.fromCard = Fk:getCardById(table.random(data.from:getCardIds(Player.Hand)))
--       end
--     elseif event == fk.PindianResultConfirmed then
--       room:moveCardTo(self.cost_data, Player.Hand, player, fk.ReasonPrey, self.name, nil, true, player.id)
--     end
--   end,
-- }
-- local taishici = General(extension, "ol_ex__taishici", "wu", 4)
-- taishici:addSkill("tianyi")
-- taishici:addSkill(hanzhan)

-- Fk:loadTranslationTable{
--   ["ol_ex__taishici"] = "界太史慈",
--   ["#ol_ex__taishici"] = "笃烈之士",
--   ["illustrator:ol_ex__taishici"] = "biou09",
--   ["hanzhan"] = "酣战",
--   [":hanzhan"] = "当你与其他角色拼点，或其他角色与你拼点时，你可令其改为用随机一张手牌拼点，你拼点后，你可获得其中点数最大的【杀】。",

--   ["$tianyi_ol_ex__taishici1"] = "天降大任，速战解围！",
--   ["$tianyi_ol_ex__taishici2"] = "义不从之，天必不佑！",
--   ["$hanzhan1"] = "伯符，且与我一战！",
--   ["$hanzhan2"] = "与君酣战，快哉快哉！",
--   ["~ol_ex__taishici"] = "无妄之灾，难以避免……",
-- }

-- local ol_ex__jianchu = fk.CreateTriggerSkill{
--   name = "ol_ex__jianchu",
--   anim_type = "offensive",
--   events = {fk.TargetSpecified},
--   can_trigger = function(self, event, target, player, data)
--     if not (target == player and player:hasSkill(self)) then return end
--     local to = player.room:getPlayerById(data.to)
--     return data.card.trueName == "slash" and not to:isNude()
--   end,
--   on_cost = function (self, event, target, player, data)
--     if player.room:askForSkillInvoke(player, self.name, nil, "#ol_ex__jianchu-invoke:"..data.to) then
--       self.cost_data = {tos = {data.to}}
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local to = room:getPlayerById(data.to)
--     if to:isNude() then return end
--     local cid = room:askForCardChosen(player, to, "he", self.name)
--     room:throwCard({cid}, self.name, to, player)
--     local card = Fk:getCardById(cid)
--     if card.type == Card.TypeBasic then
--       if not to.dead then
--         local cardlist = Card:getIdList(data.card)
--         if #cardlist > 0 and table.every(cardlist, function(id) return room:getCardArea(id) == Card.Processing end) then
--           room:obtainCard(to.id, data.card, true)
--         end
--       end
--     else
--       room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
--       data.disresponsive = true
--     end
--   end,
-- }
-- local pangde = General(extension, "ol_ex__pangde", "qun", 4)
-- pangde:addSkill("mashu")
-- pangde:addSkill(ol_ex__jianchu)
-- Fk:loadTranslationTable{
--   ["ol_ex__pangde"] = "界庞德",
--   ["#ol_ex__pangde"] = "人马一体",
--   ["illustrator:ol_ex__pangde"] = "YanBai",
--   ["ol_ex__jianchu"] = "鞬出",
--   [":ol_ex__jianchu"] = "当你使用【杀】指定一个目标后，你可弃置其一张牌，若此牌：为基本牌，其获得此【杀】；不为基本牌，此【杀】不能被此目标抵消，你于此阶段内使用【杀】的次数上限+1。",
--   ["#ol_ex__jianchu-invoke"] = "鞬出：你可以弃置 %src 一张牌",

--   ["$ol_ex__jianchu1"] = "你这身躯，怎么能快过我？",
--   ["$ol_ex__jianchu2"] = "这些怎么能挡住我的威力！",
--   ["~ol_ex__pangde"] = "人亡马倒，命之所归……",
-- }

-- local ol_ex__shuangxiong = fk.CreateViewAsSkill{
--   name = "ol_ex__shuangxiong",
--   anim_type = "offensive",
--   pattern = "duel",
--   prompt = "#ol_ex__shuangxiong-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     if #selected == 1 or type(Self:getMark("@ol_ex__shuangxiong-turn")) ~= "table" then return false end
--     local color = Fk:getCardById(to_select):getColorString()
--     if color == "red" then
--       color = "black"
--     elseif color == "black" then
--       color = "red"
--     else
--       return false
--     end
--     return table.contains(Self:getMark("@ol_ex__shuangxiong-turn"), color)
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then
--       return nil
--     end
--     local c = Fk:cloneCard("duel")
--     c.skillName = self.name
--     c:addSubcard(cards[1])
--     return c
--   end,
--   enabled_at_play = function(self, player)
--     return type(player:getMark("@ol_ex__shuangxiong-turn")) == "table"
--   end,
--   enabled_at_response = function(self, player, resp)
--     return type(player:getMark("@ol_ex__shuangxiong-turn")) == "table" and not resp
--   end,
-- }
-- local ol_ex__shuangxiong_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__shuangxiong_trigger",
--   anim_type = "offensive",
--   events = {fk.EventPhaseEnd, fk.EventPhaseStart},
--   mute = true,
--   main_skill = ol_ex__shuangxiong,
--   can_trigger = function(self, event, target, player, data)
--     if target == player and player:hasSkill(ol_ex__shuangxiong) then
--       if event == fk.EventPhaseEnd then
--         return player.phase == Player.Draw and not player:isNude()
--       elseif event == fk.EventPhaseStart and player.phase == Player.Finish then
--         local room = player.room
--         local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
--         if turn_event == nil then return false end
--         local cards = {}
--         local damage
--         room.logic:getActualDamageEvents(1, function(e)
--           damage = e.data[1]
--           if damage.to == player and damage.card then
--             table.insertTableIfNeed(cards, Card:getIdList(damage.card))
--           end
--           return false
--         end, nil, turn_event.id)
--         cards = table.filter(cards, function (id)
--           return room:getCardArea(id) == Card.DiscardPile
--         end)
--         if #cards > 0 then
--           self.cost_data = cards
--           return true
--         end
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.EventPhaseEnd then
--       local cards = player.room:askForDiscard(player, 1, 1, true, "ol_ex__shuangxiong", true, ".", "#ol_ex__shuangxiong-discard", true)
--       if #cards > 0 then
--         self.cost_data = cards
--         return true
--       end
--     elseif event == fk.EventPhaseStart then
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:broadcastSkillInvoke("ol_ex__shuangxiong")
--     room:notifySkillInvoked(player, "ol_ex__shuangxiong")
--     if event == fk.EventPhaseEnd then
--       local color = Fk:getCardById(self.cost_data[1]):getColorString()
--       room:throwCard(self.cost_data, self.name, player, player)
--       room:addTableMarkIfNeed(player, "@ol_ex__shuangxiong-turn", color)
--     elseif event == fk.EventPhaseStart then
--       room:obtainCard(player, self.cost_data, true, fk.ReasonJustMove)
--     end
--   end,
-- }
-- ol_ex__shuangxiong:addRelatedSkill(ol_ex__shuangxiong_trigger)
-- local yanliangwenchou = General(extension, "ol_ex__yanliangwenchou", "qun", 4)
-- yanliangwenchou:addSkill(ol_ex__shuangxiong)
-- Fk:loadTranslationTable{
--   ["ol_ex__yanliangwenchou"] = "界颜良文丑",
--   ["#ol_ex__yanliangwenchou"] = "虎狼兄弟",
--   ["illustrator:ol_ex__yanliangwenchou"] = "梦回唐朝",
--   ["ol_ex__shuangxiong"] = "双雄",
--   ["#ol_ex__shuangxiong_trigger"] = "双雄",
--   [":ol_ex__shuangxiong"] = "①摸牌阶段结束时，你可弃置一张牌，你于此回合内可以将一张与此牌颜色不同的牌转化为【决斗】使用。"..
--   "②结束阶段，你获得弃牌堆中于此回合内对你造成过伤害的牌。",

--   ["@ol_ex__shuangxiong-turn"] = "双雄",
--   ["#ol_ex__shuangxiong-discard"] = "双雄：你可以弃置一张牌，本回合可以将不同颜色的牌当【决斗】使用",
--   ["#ol_ex__shuangxiong-viewas"] = "发动双雄，将一张牌转化为【决斗】使用",

--   ["$ol_ex__shuangxiong1"] = "吾执矛，君执槊，此天下可有挡我者？",
--   ["$ol_ex__shuangxiong2"] = "兄弟协力，定可于乱世纵横！",
--   ["~ol_ex__yanliangwenchou"] = "双雄皆陨，徒隆武圣之名……",
-- }

-- local ol_ex__luanji = fk.CreateViewAsSkill{
--   name = "ol_ex__luanji",
--   anim_type = "offensive",
--   pattern = "archery_attack",
--   prompt = "#ol_ex__luanji-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     if #selected == 1 then
--       return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and Fk:getCardById(to_select).suit == Fk:getCardById(selected[1]).suit
--     elseif #selected == 2 then
--       return false
--     end
--     return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 2 then
--       return nil
--     end
--     local c = Fk:cloneCard("archery_attack")
--     c:addSubcards(cards)
--     return c
--   end,
-- }
-- local ol_ex__luanji_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__luanji_trigger",
--   anim_type = "control",
--   events = {fk.AfterCardTargetDeclared},
--   main_skill = ol_ex__luanji,
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(ol_ex__luanji) and data.card.name == "archery_attack" and #data.tos > 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     if #data.tos == 0 then return false end
--     local tos = player.room:askForChoosePlayers(player, TargetGroup:getRealTargets(data.tos), 1, 1, "#ol_ex__luanji-choose", "ol_ex__luanji", true)
--     if #tos > 0 then
--       self.cost_data = tos[1]
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:broadcastSkillInvoke("ol_ex__luanji")
--     room:notifySkillInvoked(player, "ol_ex__luanji", "control")
--     TargetGroup:removeTarget(data.tos, self.cost_data)
--   end,
-- }
-- local ol_ex__xueyi = fk.CreateTriggerSkill{
--   name = "ol_ex__xueyi$",
--   events = {fk.GameStart, fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) then
--       if event == fk.GameStart then
--         for _, p in ipairs(player.room.alive_players) do
--           if p.kingdom == "qun" then
--             return true
--           end
--         end
--       elseif event == fk.EventPhaseStart and player.phase == Player.Play and player:getMark("@ol_ex__xueyi_yi") > 0 then
--         return true
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.GameStart then
--       return true
--     elseif event == fk.EventPhaseStart then
--       return player.room:askForSkillInvoke(player, self.name)
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.GameStart then
--       local x = #table.filter(room.alive_players, function (p) return p.kingdom == "qun" end)
--       if x > 0 then
--         room:addPlayerMark(player, "@ol_ex__xueyi_yi", x*2)
--       end
--     elseif event == fk.EventPhaseStart then
--       room:removePlayerMark(player, "@ol_ex__xueyi_yi")
--       player:drawCards(1, self.name)
--     end
--   end,
-- }
-- local ol_ex__xueyi_maxcards = fk.CreateMaxCardsSkill{
--   name = "#ol_ex__xueyi_maxcards",
--   correct_func = function(self, player)
--     if player:hasSkill(ol_ex__xueyi) then
--       return player:getMark("@ol_ex__xueyi_yi")
--     else
--       return 0
--     end
--   end,
-- }
-- ol_ex__luanji:addRelatedSkill(ol_ex__luanji_trigger)
-- ol_ex__xueyi:addRelatedSkill(ol_ex__xueyi_maxcards)
-- local yuanshao = General:new(extension, "ol_ex__yuanshao", "qun", 4)
-- yuanshao:addSkill(ol_ex__luanji)
-- yuanshao:addSkill(ol_ex__xueyi)
-- Fk:loadTranslationTable{
--   ["ol_ex__yuanshao"] = "界袁绍",
--   ["#ol_ex__yuanshao"] = "高贵的名门",
--   ["illustrator:ol_ex__yuanshao"] = "罔両",
--   ["ol_ex__luanji"] = "乱击",
--   [":ol_ex__luanji"] = "①你可以将两张花色相同的手牌转化为【万箭齐发】使用。②当你使用【万箭齐发】选择目标后，你可取消其中一个目标。",
--   ["ol_ex__xueyi"] = "血裔",
--   [":ol_ex__xueyi"] = "主公技，①游戏开始时，你获得2X枚“裔”（X为群势力角色数）。②出牌阶段开始时，你可弃1枚“裔”，你摸一张牌。③你的手牌上限+X（X为“裔”数）",

--   ["#ol_ex__luanji-viewas"] = "发动乱击，选择两种花色相同的手牌转化为【万箭齐发】使用",
--   ["#ol_ex__luanji-choose"] = "乱击：你可以为此【万箭齐发】减少一个目标",
--   ["@ol_ex__xueyi_yi"] = "裔",

--   ["$ol_ex__luanji1"] = "我的箭支，准备颇多！",
--   ["$ol_ex__luanji2"] = "谁都挡不住，我的箭阵！",
--   ["$ol_ex__xueyi1"] = "高贵名门，族裔盛名。",
--   ["$ol_ex__xueyi2"] = "贵裔之脉，后起之秀！",
--   ["~ol_ex__yuanshao"] = "孟德此计，防不胜防……",
-- }

-- local ol_ex__duanliang = fk.CreateViewAsSkill{
--   name = "ol_ex__duanliang",
--   anim_type = "control",
--   pattern = "supply_shortage",
--   prompt = "#ol_ex__duanliang-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and Fk:getCardById(to_select).type ~= Card.TypeTrick
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then
--       return nil
--     end
--     local c = Fk:cloneCard("supply_shortage")
--     c.skillName = self.name
--     c:addSubcard(cards[1])
--     return c
--   end,
-- }
-- local ol_ex__duanliang_refresh = fk.CreateTriggerSkill{
--   name = "#ol_ex__duanliang_refresh",
--   anim_type = "control",
--   refresh_events = {fk.Damage},
--   can_refresh = function(self, event, target, player, data)
--     return target == player and player.phase ~= Player.NotActive
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:addPlayerMark(player, "ol_ex__duanliang_damage-turn", data.damage)
--   end,
-- }
-- local ol_ex__duanliang_targetmod = fk.CreateTargetModSkill{
--   name = "#ol_ex__duanliang_targetmod",
--   bypass_distances =  function(self, player, skill, card, to)
--     return player:hasSkill(ol_ex__duanliang) and skill.name == "supply_shortage_skill" and
--     player:getMark("ol_ex__duanliang_damage-turn") == 0
--   end,
-- }
-- local ol_ex__jiezi = fk.CreateTriggerSkill{
--   name = "ol_ex__jiezi",
--   anim_type = "support",
--   events = {fk.EventPhaseChanging},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) and player ~= target and target and target.skipped_phases[Player.Draw] and
--         player:usedSkillTimes(self.name, Player.HistoryTurn) < 1 then
--       return data.to == Player.Play or data.to == Player.Discard or data.to == Player.Finish
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local result = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper), 1, 1, "#ol_ex__jiezi-choose", self.name, true)
--     if #result == 1 then
--       self.cost_data = result[1]
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local to = room:getPlayerById(self.cost_data)
--     if to:getMark("@@ol_ex__jiezi_zi") == 0 and table.every(player.room.alive_players, function (p)
--         return #p:getCardIds(Player.Hand) >= #to:getCardIds(Player.Hand)
--       end) then
--       room:addPlayerMark(to, "@@ol_ex__jiezi_zi")
--     else
--       to:drawCards(1, self.name)
--     end
--   end,
-- }
-- local ol_ex__jiezi_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__jiezi_delay",
--   events = {fk.EventPhaseEnd},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player.phase == Player.Draw and player:getMark("@@ol_ex__jiezi_zi") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     player.room:notifySkillInvoked(player, ol_ex__jiezi.name, "support")
--     player.room:setPlayerMark(player, "@@ol_ex__jiezi_zi", 0)
--     player:gainAnExtraPhase(Player.Draw)
--   end,
-- }
-- ol_ex__duanliang:addRelatedSkill(ol_ex__duanliang_refresh)
-- ol_ex__duanliang:addRelatedSkill(ol_ex__duanliang_targetmod)
-- ol_ex__jiezi:addRelatedSkill(ol_ex__jiezi_delay)
-- local xuhuang = General(extension, "ol_ex__xuhuang", "wei", 4)
-- xuhuang:addSkill(ol_ex__duanliang)
-- xuhuang:addSkill(ol_ex__jiezi)
-- Fk:loadTranslationTable{
--   ["ol_ex__xuhuang"] = "界徐晃",
--   ["ol_ex__duanliang"] = "断粮",
--   [":ol_ex__duanliang"] = "①你可将一张不为锦囊牌的黑色牌转化为【兵粮寸断】使用。"..
--   "②若你于当前回合内未造成过伤害，你使用【兵粮寸断】无距离关系的限制。",
--   ["ol_ex__jiezi"] = "截辎",
--   ["#ol_ex__jiezi_delay"] = "截辎",
--   [":ol_ex__jiezi"] = "每回合限一次，其他角色的出牌阶段、弃牌阶段或结束阶段开始前，若其于此回合内跳过过摸牌阶段，"..
--   "你可选择一名角色，若其手牌数为全场最少且没有“辎”，其获得1枚“辎”；否则其摸一张牌。"..
--   "当有“辎”的角色的摸牌阶段结束时，其弃所有“辎”，获得一个额外摸牌阶段。",

--   ["#ol_ex__duanliang-viewas"] = "发动断粮，将黑色基本牌或黑色装备牌转化为【兵粮寸断】使用",
--   ["@@ol_ex__jiezi_zi"] = "辎",
--   ["#ol_ex__jiezi-choose"] = "截辎：选择一名角色，令其获得“辎”标记或摸一张牌",
--   ["$ol_ex__duanliang1"] = "兵行无常，计行断粮。",
--   ["$ol_ex__duanliang2"] = "焚其粮营，断其粮道。",
--   ["$ol_ex__jiezi1"] = "剪径截辎，馈泽同袍。",
--   ["$ol_ex__jiezi2"] = "截敌粮草，以资袍泽。",
--   ["~ol_ex__xuhuang"] = "亚夫易老，李广难封……",
-- }

-- local ol_ex__changbiao = fk.CreateViewAsSkill{
--   name = "ol_ex__changbiao",
--   anim_type = "offensive",
--   pattern = "slash",
--   prompt = "#ol_ex__changbiao-active",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards < 1 then
--       return nil
--     end
--     local c = Fk:cloneCard("slash")
--     c.skillName = self.name
--     c:addSubcards(cards)
--     return c
--   end,
--   enabled_at_play = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
--   end,
--   enabled_at_response = Util.FalseFunc,
--   before_use = function(self, player, useData)
--     useData.extra_data = useData.extra_data or {}
--     useData.extra_data.ol_ex__changbiaoUser = player.id
--   end,
-- }
-- local ol_ex__changbiao_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__changbiao_trigger",
--   events = {fk.EventPhaseEnd},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return player:getMark("@ol_ex__changbiao_draw-phase") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, "ol_ex__changbiao", "drawcard")
--     player:drawCards(player:getMark("@ol_ex__changbiao_draw-phase"), "ol_ex__changbiao")
--   end,

--   refresh_events = {fk.CardUseFinished},
--   can_refresh = function(self, event, target, player, data)
--     return (data.extra_data or {}).ol_ex__changbiaoUser == player.id and data.damageDealt
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:addPlayerMark(player, "@ol_ex__changbiao_draw-phase", #data.card.subcards)
--   end,
-- }
-- local ol_ex__changbiao_targetmod = fk.CreateTargetModSkill{
--   name = "#ol_ex__changbiao_targetmod",
--   bypass_distances =  function(self, player, skill, card, to)
--     return table.contains(card.skillNames, ol_ex__changbiao.name)
--   end,
-- }
-- ol_ex__changbiao:addRelatedSkill(ol_ex__changbiao_trigger)
-- ol_ex__changbiao:addRelatedSkill(ol_ex__changbiao_targetmod)
-- local zhurong = General(extension, "ol_ex__zhurong", "shu", 4, 4, General.Female)
-- zhurong:addSkill("juxiang")
-- zhurong:addSkill("lieren")
-- zhurong:addSkill(ol_ex__changbiao)

-- Fk:loadTranslationTable{
--   ["ol_ex__zhurong"] = "界祝融",
--   ["#ol_ex__zhurong"] = "野性的女王",
--   ["illustrator:ol_ex__zhurong"] = "匠人绘",

--   ["ol_ex__changbiao"] = "长标",
--   ["#ol_ex__changbiao_trigger"] = "长标",
--   [":ol_ex__changbiao"] = "出牌阶段限一次，你可将至少一张手牌转化为【杀】使用（无距离限制），此阶段结束时，若此【杀】造成过伤害，你摸x张牌（X为以此法转化的牌数）。",

--   ["#ol_ex__changbiao-active"] = "发动长标，将任意数量的手牌转化为【杀】使用（无距离限制）",
--   ["@ol_ex__changbiao_draw-phase"] = "长标",

--   ["$juxiang_ol_ex__zhurong1"] = "巨象冲锋，踏平敌阵！",
--   ["$juxiang_ol_ex__zhurong2"] = "南兵象阵，刀枪不入！",
--   ["$lieren_ol_ex__zhurong1"] = "烈火飞刃，例无虚发！",
--   ["$lieren_ol_ex__zhurong2"] = "烈刃一出，谁与争锋？",
--   ["$ol_ex__changbiao1"] = "长标如虹，以伐蜀汉！",
--   ["$ol_ex__changbiao2"] = "长标在此，谁敢拦我？",
--   ["~ol_ex__zhurong"] = "这汉人，竟……如此厉害……",
-- }

-- local ol_ex__zaiqi = fk.CreateTriggerSkill{
--   name = "ol_ex__zaiqi",
--   events = {fk.EventPhaseEnd},
--   can_trigger = function(self, event, target, player, data)
--     if target == player and player:hasSkill(self) and player.phase == Player.Discard then
--       local ids = {}
--       local room = player.room
--       local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
--       if turn_event == nil then return false end
--       room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
--         for _, move in ipairs(e.data) do
--           if move.toArea == Card.DiscardPile then
--             for _, info in ipairs(move.moveInfo) do
--               table.insertIfNeed(ids, info.cardId)
--             end
--           end
--         end
--         return false
--       end, turn_event.id)
--       local x = #table.filter(ids, function (id)
--         return room:getCardArea(id) == Card.DiscardPile and Fk:getCardById(id).color == Card.Red
--       end)
--       if x > 0 then
--         self.cost_data = x
--         return true
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local x = self.cost_data
--     local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, x,
--     "#ol_ex__zaiqi-choose:::"..x, self.name, true)
--     if #tos > 0 then
--       room:sortPlayersByAction(tos)
--       self.cost_data = {tos = tos}
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local targets = table.map(self.cost_data.tos, Util.Id2PlayerMapper)
--     for _, p in ipairs(targets) do
--       if not p.dead then
--         local choices = {"ol_ex__zaiqi_draw"}
--         if player and not player.dead and player:isWounded() then
--           table.insert(choices, "ol_ex__zaiqi_recover")
--         end
--         local choice = room:askForChoice(p, choices, self.name, "#ol_ex__zaiqi-choice:"..player.id)
--         if choice == "ol_ex__zaiqi_draw" then
--           p:drawCards(1, self.name)
--         else
--           room:recover({
--             who = player,
--             num = 1,
--             recoverBy = p,
--             skillName = self.name
--           })
--         end
--       end
--     end
--   end,
-- }
-- local menghuo = General(extension, "ol_ex__menghuo", "shu", 4)
-- menghuo:addSkill("huoshou")
-- menghuo:addSkill(ol_ex__zaiqi)

-- Fk:loadTranslationTable{
--   ["ol_ex__menghuo"] = "界孟获",
--   ["#ol_ex__menghuo"] = "南蛮王",
--   ["illustrator:ol_ex__menghuo"] = "磐蒲",
--   ["ol_ex__zaiqi"] = "再起",
--   [":ol_ex__zaiqi"] = "弃牌阶段结束时，你可选择至多X名角色（X为弃牌堆里于此回合内移至此区域的红色牌数），这些角色各选择：1.令你回复1点体力；2.摸一张牌。",

--   ["#ol_ex__zaiqi-choose"] = "再起：选择至多%arg名角色，这些角色各选择令你回复1点体力或摸一张牌",
--   ["#ol_ex__zaiqi-choice"] = "再起：选择摸一张牌或令%src回复1点体力",
--   ["ol_ex__zaiqi_draw"] = "摸一张牌",
--   ["ol_ex__zaiqi_recover"] = "令其回复体力",

--   ["$huoshou_ol_ex__menghuo1"] = "啸据哀牢，闻祸而喜！",
--   ["$huoshou_ol_ex__menghuo2"] = "坐据三山，蛮霸四野！",
--   ["$ol_ex__zaiqi1"] = "挫而弥坚，战而弥勇！",
--   ["$ol_ex__zaiqi2"] = "蛮人骨硬，其势复来！",
--   ["~ol_ex__menghuo"] = "勿再放我，但求速死！",
-- }

-- local ol_ex__wulie = fk.CreateTriggerSkill{
--   name = "ol_ex__wulie",
--   anim_type = "support",
--   events = {fk.EventPhaseStart},
--   frequency = Skill.Limited,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.phase == Player.Finish and
--       player:usedSkillTimes(self.name, Player.HistoryGame) < 1 and player.hp > 0
--   end,
--   on_cost = function(self, event, target, player, data)
--     local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, player.hp, "#ol_ex__wulie-choose", self.name, true)
--     if #tos > 0 then
--       player.room:sortPlayersByAction(tos)
--       self.cost_data = {tos = tos}
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, #self.cost_data.tos, self.name)
--     for _, id in ipairs(self.cost_data.tos) do
--       local p = room:getPlayerById(id)
--       if not p.dead then
--         room:addPlayerMark(p, "@@ol_ex__wulie_lie")
--       end
--     end
--   end,
-- }
-- local ol_ex__wulie_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__wulie_delay",
--   anim_type = "defensive",
--   events = {fk.DamageInflicted},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:getMark("@@ol_ex__wulie_lie") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     player.room:notifySkillInvoked(player, "ol_ex__wulie", "defensive")
--     player.room:setPlayerMark(player, "@@ol_ex__wulie_lie", 0)
--     return true
--   end,
-- }
-- ol_ex__wulie:addRelatedSkill(ol_ex__wulie_delay)
-- local sunjian = General(extension, "ol_ex__sunjian", "wu", 4, 5)
-- sunjian:addSkill("yinghun")
-- sunjian:addSkill(ol_ex__wulie)

-- Fk:loadTranslationTable{
--   ["ol_ex__sunjian"] = "界孙坚",
--   ["#ol_ex__sunjian"] = "武烈帝",
--   ["illustrator:ol_ex__sunjian"] = "匠人绘",
--   ["ol_ex__wulie"] = "武烈",
--   ["#ol_ex__wulie_delay"] = "武烈",
--   [":ol_ex__wulie"] = "限定技，结束阶段，你可以失去任意点体力，令等量的其他角色各获得1枚“烈”标记。当有“烈”的角色受到伤害时，其弃所有“烈”，防止此伤害。",

--   ["@@ol_ex__wulie_lie"] = "烈",
--   ["#ol_ex__wulie-choose"] = "武烈：选择任意名其他角色并失去等量的体力，防止这些角色受到的下次伤害",

--   ["$yinghun_ol_ex__sunjian1"] = "提刀奔走，灭敌不休。",
--   ["$yinghun_ol_ex__sunjian2"] = "贼寇草莽，我且出战。",
--   ["$ol_ex__wulie1"] = "孙武之后，英烈勇战。",
--   ["$ol_ex__wulie2"] = "兴义之中，忠烈之名。",
--   ["~ol_ex__sunjian"] = "袁术之辈，不可共谋！",
-- }

-- local ol_ex__haoshi = fk.CreateTriggerSkill{
--   name = "ol_ex__haoshi",
--   anim_type = "drawcard",
--   events = {fk.DrawNCards},
--   on_use = function(self, event, target, player, data)
--     data.n = data.n + 2
--   end,
-- }
-- local ol_ex__haoshi_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__haoshi_delay",
--   events = {fk.AfterDrawNCards, fk.TargetConfirmed},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     if player.dead then return false end
--     if event == fk.AfterDrawNCards and player:usedSkillTimes(ol_ex__haoshi.name, Player.HistoryPhase) > 0 then
--       return #player.player_cards[Player.Hand] > 5 and #player.room.alive_players > 1
--     elseif event == fk.TargetConfirmed and player == target and type(player:getMark("ol_ex__haoshi_target")) == "table" then
--       if data.card.trueName == "slash" or data.card:isCommonTrick() then
--         local targetRecorded = player:getMark("ol_ex__haoshi_target")
--         return table.find(targetRecorded, function (pid)
--           local p = player.room:getPlayerById(pid)
--           return p and p ~= player and not p:isKongcheng()
--         end)
--       end
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, ol_ex__haoshi.name, "support")
--     if event == fk.AfterDrawNCards then
--       local x = player:getHandcardNum() // 2
--       local targets = {}
--       local n = 0
--       for _, p in ipairs(room.alive_players) do
--         if p ~= player then
--           if #targets == 0 then
--             table.insert(targets, p.id)
--             n = p:getHandcardNum()
--           else
--             if p:getHandcardNum() < n then
--               targets = {p.id}
--               n = p:getHandcardNum()
--             elseif p:getHandcardNum() == n then
--               table.insert(targets, p.id)
--             end
--           end
--         end
--       end
--       local tos, cards = room:askForChooseCardsAndPlayers(player, x, x, targets, 1, 1,
--       ".|.|.|hand", "#ol_ex__haoshi-give:::" .. x, "ol_ex__haoshi", false)
--       local to = room:getPlayerById(tos[1])
--       room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, "ol_ex__haoshi", nil, false, player.id)
--       if player.dead or to.dead then return false end
--       local targetRecorded = player:getTableMark("ol_ex__haoshi_target")
--       if table.insertIfNeed(targetRecorded, to.id) then
--         room:setPlayerMark(player, "ol_ex__haoshi_target", targetRecorded)
--       end
--     elseif event == fk.TargetConfirmed then
--       local targetRecorded = player:getMark("ol_ex__haoshi_target")
--       room:doIndicate(player.id, targetRecorded)
--       room:sortPlayersByAction(targetRecorded)
--       table.forEach(targetRecorded, function (pid)
--         local p = room:getPlayerById(pid)
--         if p and not player.dead and not p.dead and p ~= player and not p:isKongcheng() then
--           local card = room:askForCard(p, 1, 1, true, ol_ex__haoshi.name, true, ".|.|.|hand", "#ol_ex__haoshi-regive:"..player.id)
--           if #card > 0 then
--             room:obtainCard(player, card[1], false, fk.ReasonGive, p.id)
--           end
--         end
--       end)
--     end
--   end,

--   refresh_events = {fk.TurnStart},
--   can_refresh = function(self, event, target, player, data)
--     return player == target and type(player:getMark("ol_ex__haoshi_target")) == "table"
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:setPlayerMark(player, "ol_ex__haoshi_target", 0)
--   end,
-- }
-- local ol_ex__dimeng = fk.CreateActiveSkill{
--   name = "ol_ex__dimeng",
--   prompt = "#ol_ex__dimeng-active",
--   anim_type = "control",
--   card_num = 0,
--   target_num = 2,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
--   end,
--   card_filter = Util.FalseFunc,
--   target_filter = function(self, to_select, selected)
--     if to_select == Self.id or #selected > 1 then return false end
--     if #selected == 0 then
--       return true
--     else
--       local x1 = Fk:currentRoom():getPlayerById(to_select):getHandcardNum()
--       local x2 = Fk:currentRoom():getPlayerById(selected[1]):getHandcardNum()
--       return (x1 > 0 or x2 > 0) and math.abs(x1 - x2) <= #Self:getCardIds({Player.Hand, Player.Equip})
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target1 = room:getPlayerById(effect.tos[1])
--     local target2 = room:getPlayerById(effect.tos[2])
--     U.swapHandCards(room, player, target1, target2, self.name)
--     room:addTableMark(player, "ol_ex__dimeng_target-phase", effect.tos)
--   end,
-- }
-- local ol_ex__dimeng_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__dimeng_delay",
--   events = {fk.EventPhaseEnd},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     if not player.dead and player:usedSkillTimes(ol_ex__dimeng.name, Player.HistoryPhase) > 0 and not player:isNude() then
--       local mark = player:getTableMark("ol_ex__dimeng_target-phase")
--       for _, tos in ipairs(mark) do
--         if type(tos) == "table" and #tos == 2 then
--           local p1 = player.room:getPlayerById(tos[1])
--           local p2 = player.room:getPlayerById(tos[2])
--           if p1 and p2 and not p1.dead and not p2.dead and p1:getHandcardNum() ~= p2:getHandcardNum() then
--             return true
--           end
--         end
--       end
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     player.room:notifySkillInvoked(player, ol_ex__dimeng.name, "negative")
--     local x = 0
--     local mark = player:getTableMark("ol_ex__dimeng_target-phase")
--     if type(mark) ~= "table" then return false end
--     for _, tos in ipairs(mark) do
--       if type(tos) == "table" and #tos == 2 then
--         local p1 = player.room:getPlayerById(tos[1])
--         local p2 = player.room:getPlayerById(tos[2])
--         if p1 and p2 and not p1.dead and not p2.dead then
--           x = x + math.abs(p1:getHandcardNum() - p2:getHandcardNum())
--         end
--       end
--     end
--     if x > 0 then
--       player.room:askForDiscard(player, x, x, true, ol_ex__dimeng.name, false, ".", "#ol_ex__dimeng-discard:::"..x)
--     end
--   end,
-- }
-- ol_ex__haoshi:addRelatedSkill(ol_ex__haoshi_delay)
-- ol_ex__dimeng:addRelatedSkill(ol_ex__dimeng_delay)
-- local lusu = General(extension, "ol_ex__lusu", "wu", 3)
-- lusu:addSkill(ol_ex__haoshi)
-- lusu:addSkill(ol_ex__dimeng)

-- Fk:loadTranslationTable{
--   ["ol_ex__lusu"] = "界鲁肃",
--   ["#ol_ex__lusu"] = "独断的外交家",
--   ["illustrator:ol_ex__lusu"] = "游漫美绘",
--   ["ol_ex__haoshi"] = "好施",
--   ["#ol_ex__haoshi_delay"] = "好施",
--   [":ol_ex__haoshi"] = "摸牌阶段，你可令额定摸牌数+2，此阶段结束时，若你的手牌数大于5，你将一半的手牌交给除你外手牌数最少的一名角色。当你于你的下个回合开始之前成为【杀】或普通锦囊牌的目标后，你令其可将一张手牌交给你。",
--   ["ol_ex__dimeng"] = "缔盟",
--   ["#ol_ex__dimeng_delay"] = "缔盟",
--   [":ol_ex__dimeng"] = "出牌阶段限一次，你可选择两名手牌数之差不大于你的牌数的其他角色，这两名角色交换手牌。此阶段结束时，你弃置X张牌（X为这两名角色手牌数之差）。",

--   ["#ol_ex__haoshi-give"] = "好施：选择%arg张手牌，交给除你外手牌数最少的一名角色",
--   ["#ol_ex__haoshi-regive"] = "好施：你可以选择一张手牌交给 %src",
--   ["#ol_ex__dimeng-active"] = "发动 缔盟，令两名其他角色交换手牌（牌数之差不能大于你的牌数）",
--   ["#ol_ex__dimeng-discard"] = "缔盟：选择%arg张牌弃置",

--   ["$ol_ex__haoshi1"] = "仗义疏财，深得人心。",
--   ["$ol_ex__haoshi2"] = "招聚少年，给其衣食。",
--   ["$ol_ex__dimeng1"] = "深知其奇，相与亲结。",
--   ["$ol_ex__dimeng2"] = "同盟之人，言归于好。",
--   ["~ol_ex__lusu"] = "一生为国，纵死无憾……",
-- }

-- local ol_ex__jiuchi = fk.CreateViewAsSkill{
--   name = "ol_ex__jiuchi",
--   anim_type = "offensive",
--   pattern = "analeptic",
--   prompt = "#ol_ex__jiuchi-viewas",
--   handly_pile = true,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).suit == Card.Spade and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then return nil end
--     local c = Fk:cloneCard("analeptic")
--     c.skillName = self.name
--     c:addSubcard(cards[1])
--     return c
--   end,
-- }
-- local ol_ex__jiuchi_targetmod = fk.CreateTargetModSkill{
--   name = "#ol_ex__jiuchi_targetmod",
--   bypass_times = function(self, player, skill, scope)
--     return player:hasSkill(ol_ex__jiuchi) and skill.trueName == "analeptic_skill" and scope == Player.HistoryTurn
--   end,
-- }
-- local ol_ex__jiuchi_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__jiuchi_trigger",
--   events = {fk.Damage},
--   mute = true,
--   main_skill = ol_ex__jiuchi,
--   can_trigger = function(self, event, target, player, data)
--     if target == player and player:hasSkill(ol_ex__jiuchi) and data.card and data.card.trueName == "slash"
--         and player:getMark("ol_ex__benghuai_invalidity-turn") == 0 then
--       local parentUseData = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
--       if parentUseData then
--         local drankBuff = parentUseData and (parentUseData.data[1].extra_data or {}).drankBuff or 0
--         return drankBuff > 0
--       end
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, "ol_ex__jiuchi", "defensive")
--     player:broadcastSkillInvoke("ol_ex__jiuchi")
--     room:addPlayerMark(player, "ol_ex__benghuai_invalidity-turn")
--   end,
-- }
-- local ol_ex__jiuchi_invalidity = fk.CreateInvaliditySkill {
--   name = "#ol_ex__jiuchi_invalidity",
--   invalidity_func = function(self, from, skill)
--     return from:getMark("ol_ex__benghuai_invalidity-turn") > 0 and skill.name == "benghuai"
--   end
-- }
-- local ol_ex__baonue = fk.CreateTriggerSkill{
--   name = "ol_ex__baonue$",
--   anim_type = "support",
--   events = {fk.Damage},
--   can_trigger = function(self, event, target, player, data)
--     return target and player:hasSkill(self) and player ~= target and target.kingdom == "qun"
--   end,
--   on_trigger = function(self, event, target, player, data)
--     self.cancel_cost = false
--     for i = 1, data.damage do
--       if i > 1 and (self.cancel_cost or not player:hasSkill(self)) then break end
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     if room:askForSkillInvoke(player, self.name, data) then
--       return true
--     end
--     self.cancel_cost = true
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local judge = {
--       who = player,
--       reason = self.name,
--       pattern = ".|.|spade",
--     }
--     room:judge(judge)
--     if judge.card.suit == Card.Spade and player:isWounded() then
--       room:recover({
--         who = player,
--         num = 1,
--         recoverBy = target,
--         skillName = self.name
--       })
--     end
--   end
-- }
-- local ol_ex__baonue_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__baonue_delay",
--   events = {fk.FinishJudge},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and data.card.suit == Card.Spade and data.reason == ol_ex__baonue.name
--       and player.room:getCardArea(data.card.id) == Card.Processing
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     player.room:obtainCard(player.id, data.card, true)
--   end,
-- }
-- ol_ex__jiuchi:addRelatedSkill(ol_ex__jiuchi_targetmod)
-- ol_ex__jiuchi:addRelatedSkill(ol_ex__jiuchi_trigger)
-- ol_ex__jiuchi:addRelatedSkill(ol_ex__jiuchi_invalidity)
-- ol_ex__baonue:addRelatedSkill(ol_ex__baonue_delay)
-- local dongzhuo = General(extension, "ol_ex__dongzhuo", "qun", 8)
-- dongzhuo:addSkill(ol_ex__jiuchi)
-- dongzhuo:addSkill("roulin")
-- dongzhuo:addSkill("benghuai")
-- dongzhuo:addSkill(ol_ex__baonue)

-- Fk:loadTranslationTable{
--   ["ol_ex__dongzhuo"] = "界董卓",
--   ["#ol_ex__dongzhuo"] = "魔王",
--   ["illustrator:ol_ex__dongzhuo"] = "磐蒲",
--   ["ol_ex__jiuchi"] = "酒池",
--   ["#ol_ex__jiuchi_trigger"] = "酒池",
--   [":ol_ex__jiuchi"] = "①你可将一张♠手牌转化为【酒】使用。②你使用【酒】无次数限制。③当你造成伤害后，若渠道为受【酒】效果影响的【杀】，你的〖崩坏〗于当前回合内无效。",
--   ["ol_ex__baonue"] = "暴虐",
--   [":ol_ex__baonue"] = "主公技，当其他群雄角色造成1点伤害后，你可判定，若结果为♠，回复1点体力，然后当判定牌生效后，你获得此牌。",

--   ["#ol_ex__jiuchi-viewas"] = "发动酒池，将一张♠手牌转化为【酒】使用",

--   ["$ol_ex__jiuchi1"] = "好酒，痛快！",
--   ["$ol_ex__jiuchi2"] = "某，千杯不醉！",
--   ["$roulin_ol_ex__dongzhuo1"] = "醇酒美人，幸甚乐甚！",
--   ["$roulin_ol_ex__dongzhuo2"] = "这些美人，都可进贡。",
--   ["$benghuai_ol_ex__dongzhuo1"] = "何人伤我？",
--   ["$benghuai_ol_ex__dongzhuo2"] = "酒色伤身呐……",
--   ["$ol_ex__baonue1"] = "吾乃人屠，当以兵为贡。",
--   ["$ol_ex__baonue2"] = "天下群雄，唯我独尊！",
--   ["~ol_ex__dongzhuo"] = "地府……可有美人乎？",
-- }

-- local ol_ex__wansha = fk.CreateTriggerSkill{
--   name = "ol_ex__wansha",
--   anim_type = "offensive",
--   frequency = Skill.Compulsory,
--   refresh_events = {fk.EnterDying},
--   can_refresh = function(self, event, target, player, data)
--     return player:hasSkill(self) and player.phase ~= Player.NotActive
--   end,
--   on_refresh = function(self, event, target, player, data)
--     player.room:notifySkillInvoked(player, self.name)
--     player:broadcastSkillInvoke(self.name)
--   end,
-- }
-- local ol_ex__wansha_prohibit = fk.CreateProhibitSkill{
--   name = "#ol_ex__wansha_prohibit",
--   prohibit_use = function(self, player, card)
--     if card.name == "peach" and not player.dying then
--       return table.find(Fk:currentRoom().alive_players, function(p)
--         return p.phase ~= Player.NotActive and p:hasSkill(ol_ex__wansha) and p ~= player
--       end)
--     end
--   end,
-- }
-- local ol_ex__wansha_invalidity = fk.CreateInvaliditySkill {
--   name = "#ol_ex__wansha_invalidity",
--   invalidity_func = function(self, from, skill)
--     if table.contains(from.player_skills, skill) and not from.dying and skill.frequency ~= Skill.Compulsory
--     and skill.frequency ~= Skill.Wake and skill:isPlayerSkill(from) then
--       return table.find(Fk:currentRoom().players, function(p)
--         return p.dying
--       end) and table.find(Fk:currentRoom().alive_players, function(p)
--         return p.phase ~= Player.NotActive and p:hasSkill(ol_ex__wansha) and p ~= from
--       end)
--     end
--   end,
-- }
-- local ol_ex__luanwu = fk.CreateActiveSkill{
--   name = "ol_ex__luanwu",
--   anim_type = "offensive",
--   prompt = "#ol_ex__luanwu-active",
--   card_num = 0,
--   target_num = 0,
--   frequency = Skill.Limited,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
--   end,
--   card_filter = Util.FalseFunc,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local targets = room:getOtherPlayers(player)
--     room:doIndicate(player.id, table.map(targets, Util.IdMapper))
--     for _, target in ipairs(targets) do
--       if not target.dead then
--         if target:isRemoved() then
--           room:loseHp(target, 1, self.name)
--         else
--           local other_players = table.filter(room.alive_players, function (p)
--             return p ~= target and not p:isRemoved()
--           end)
--           local luanwu_targets = table.map(table.filter(other_players, function(p2)
--             return table.every(other_players, function(p1)
--               return target:distanceTo(p1) >= target:distanceTo(p2)
--             end)
--           end), Util.IdMapper)
--           local use = room:askForUseCard(target, "slash", "slash", "#ol_ex__luanwu-use", true,
--           { exclusive_targets = luanwu_targets, bypass_times = true})
--           if use then
--             use.extraUse = true
--             room:useCard(use)
--           else
--             room:loseHp(target, 1, self.name)
--           end
--         end
--       end
--     end
--     if player.dead then return end
--     local slash = Fk:cloneCard("slash")
--     if player:prohibitUse(slash) then return end
--     local max_num = slash.skill:getMaxTargetNum(player, slash)
--     local slash_targets = {}
--     for _, p in ipairs(room:getOtherPlayers(player, false)) do
--       if not player:isProhibited(p, slash) then
--         table.insert(slash_targets, p.id)
--       end
--     end
--     if #slash_targets == 0 or max_num == 0 then return end
--     local tos = room:askForChoosePlayers(player, slash_targets, 1, max_num, "#ol_ex__luanwu-choose", self.name, true)
--     if #tos > 0 then
--       room:useVirtualCard("slash", nil, player, table.map(tos, Util.Id2PlayerMapper), self.name, true)
--     end
--   end,
-- }
-- local ol_ex__weimu = fk.CreateTriggerSkill{
--   name = "ol_ex__weimu",
--   anim_type = "defensive",
--   events = {fk.DamageInflicted},
--   frequency = Skill.Compulsory,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.room.current == player
--   end,
--   on_use = function(self, event, target, player, data)
--     player:drawCards(data.damage*2, self.name)
--     return true
--   end,
-- }
-- local ol_ex__weimu_prohibit = fk.CreateProhibitSkill{
--   name = "#ol_ex__weimu_prohibit",
--   frequency = Skill.Compulsory,
--   is_prohibited = function(self, from, to, card)
--     return to:hasSkill(ol_ex__weimu) and card.type == Card.TypeTrick and card.color == Card.Black
--   end,
-- }
-- ol_ex__wansha:addRelatedSkill(ol_ex__wansha_prohibit)
-- ol_ex__wansha:addRelatedSkill(ol_ex__wansha_invalidity)
-- ol_ex__weimu:addRelatedSkill(ol_ex__weimu_prohibit)

-- local jiaxu = General(extension, "ol_ex__jiaxu", "qun", 3)
-- jiaxu:addSkill(ol_ex__wansha)
-- jiaxu:addSkill(ol_ex__luanwu)
-- jiaxu:addSkill(ol_ex__weimu)

-- Fk:loadTranslationTable{
--   ["ol_ex__jiaxu"] = "界贾诩",
--   ["#ol_ex__jiaxu"] = "冷酷的毒士",
--   ["illustrator:ol_ex__jiaxu"] = "游漫美绘",
--   ["ol_ex__wansha"] = "完杀",
--   [":ol_ex__wansha"] = "锁定技，①除进行濒死流程的角色以外的其他角色于你的回合内不能使用【桃】。②在一名角色于你的回合内进行的濒死流程中，除其以外的其他角色的不带“锁定技”标签的技能无效。",
--   ["ol_ex__luanwu"] = "乱武",
--   [":ol_ex__luanwu"] = "限定技，出牌阶段，你可选择所有其他角色，这些角色各需对包括距离最小的另一名角色在内的角色使用【杀】，否则失去1点体力。最后你可视为使用普【杀】。",
--   ["ol_ex__weimu"] = "帷幕",
--   ["#ol_ex__weimu_trigger"] = "帷幕",
--   [":ol_ex__weimu"] = "锁定技，①你不是黑色锦囊牌的合法目标。②当你于回合内受到伤害时，你防止此伤害，摸2X张牌（X为伤害值）。",

--   ["#ol_ex__luanwu-active"] = "发动 乱武，所有其他角色需要对距离最近的角色出杀，否则失去1点体力",
--   ["#ol_ex__luanwu-use"] = "乱武：你需要对距离最近的一名角色使用一张【杀】，否则失去1点体力",
--   ["#ol_ex__luanwu-choose"] = "乱武：你可以视为使用一张【杀】，选择此【杀】的目标",

--   ["$ol_ex__wansha1"] = "有谁敢试试？",
--   ["$ol_ex__wansha2"] = "斩草务尽，以绝后患。",
--   ["$ol_ex__luanwu1"] = "一切都在我的掌控中！",
--   ["$ol_ex__luanwu2"] = "这乱世还不够乱！",
--   ["$ol_ex__weimu1"] = "此伤与我无关。",
--   ["$ol_ex__weimu2"] = "还是另寻他法吧。",
--   ["~ol_ex__jiaxu"] = "此劫，我亦有所算……",
-- }

-- local ol_ex__qiaobian = fk.CreateTriggerSkill{
--   name = "ol_ex__qiaobian",
--   anim_type = "control",
--   events = {fk.EventPhaseChanging, fk.GameStart, fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) then
--       if event == fk.GameStart then return true
--       elseif event == fk.EventPhaseStart and player.phase == Player.Finish then
--         return not table.contains(player:getTableMark("ol_ex__qiaobian_number"), player:getHandcardNum())
--       elseif event == fk.EventPhaseChanging and player == target and
--           (not player:isNude() or player:getMark("@ol_ex__qiaobian_change") > 0) then
--         return data.to > Player.Start and data.to < Player.Finish
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.GameStart or event == fk.EventPhaseStart then
--       return true
--     elseif event == fk.EventPhaseChanging then
--       local discard_data = {
--         num = 1,
--         min_num = player:getMark("@ol_ex__qiaobian_change") == 0 and 1 or 0,
--         include_equip = true,
--         skillName = self.name,
--         pattern = ".",
--       }
--       local success, ret = player.room:askForUseActiveSkill(player, "discard_skill",
--         "#ol_ex__qiaobian-invoke:::" .. Util.PhaseStrMapper(data.to), true, discard_data)
--       if success then
--         self.cost_data = ret.cards
--         return true
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if event == fk.GameStart then
--       room:addPlayerMark(player, "@ol_ex__qiaobian_change", 2)
--     elseif event == fk.EventPhaseStart then
--       room:addTableMark(player, "ol_ex__qiaobian_number", player:getHandcardNum())
--       room:addPlayerMark(player, "@ol_ex__qiaobian_change")
--     elseif event == fk.EventPhaseChanging then
--       if #self.cost_data > 0 then
--         room:throwCard(self.cost_data, self.name, player, player)
--         if player.dead then return false end
--       else
--         room:removePlayerMark(player, "@ol_ex__qiaobian_change")
--       end
--       if data.to == Player.Draw then
--         local tos = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player, false), function(p)
--           return not p:isKongcheng() end), Util.IdMapper), 1, 2, "#ol_ex__qiaobian-prey", self.name, true)
--         if #tos > 0 then
--           room:sortPlayersByAction(tos)
--           table.forEach(tos, function(id)
--             if not player.dead then
--               local to = room:getPlayerById(id)
--               if not to.dead and not to:isKongcheng() then
--                 local c = room:askForCardChosen(player, to, "h", self.name)
--                 room:obtainCard(player, c, false, fk.ReasonPrey)
--               end
--             end
--           end)
--         end
--       elseif data.to == Player.Play then
--         local to = room:askForChooseToMoveCardInBoard(player, "#ol_ex__qiaobian-movecard", self.name, true)
--         if #to == 2 then
--           room:askForMoveCardInBoard(player, room:getPlayerById(to[1]), room:getPlayerById(to[2]), self.name)
--         end
--       end
--       player:skip(data.to)
--       return true
--     end
--   end,
-- }
-- local zhanghe = General(extension, "ol_ex__zhanghe", "wei", 4)
-- zhanghe:addSkill(ol_ex__qiaobian)

-- Fk:loadTranslationTable{
--   ["ol_ex__zhanghe"] = "界张郃",
--   ["#ol_ex__zhanghe"] = "料敌机先",
--   ["illustrator:ol_ex__zhanghe"] = "君桓文化",
--   ["ol_ex__qiaobian"] = "巧变",
--   [":ol_ex__qiaobian"] = "游戏开始时，你获得2枚“变”标记。你可以弃置一张牌或移除1枚“变”标记并跳过你的一个阶段（准备阶段和结束阶段除外）：若跳过摸牌阶段，你可以获得至多两名角色的各一张手牌；若跳过出牌阶段，你可以移动场上的一张牌。结束阶段开始时，若你的手牌数与之前你的每一回合结束阶段开始时的手牌数均不相等，你获得1枚“变”标记。",

--   ["@ol_ex__qiaobian_change"] = "变",
--   ["#ol_ex__qiaobian-invoke"] = "巧变：你可选择一张牌弃置，或直接点确定则弃置变标记。来跳过 %arg",
--   ["#ol_ex__qiaobian-prey"] = "巧变：你可以选择一至两名角色，获得这些角色各一张手牌",
--   ["#ol_ex__qiaobian-movecard"] = "巧变：你可以选择两名角色，移动这些角色装备区或判定区的一张牌",

--   ["$ol_ex__qiaobian1"] = "顺势而变，则胜矣。",
--   ["$ol_ex__qiaobian2"] = "万物变化，固无休息。",
--   ["~ol_ex__zhanghe"] = "何处之流矢……",
-- }

-- local ol_ex__tuntian = fk.CreateTriggerSkill{
--   name = "ol_ex__tuntian",
--   anim_type = "special",
--   derived_piles = "ol_ex__dengai_field",
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) then
--       for _, move in ipairs(data) do
--         if move.from == player.id and (move.to ~= player.id or (move.toArea ~= Card.PlayerHand and move.toArea ~= Card.PlayerEquip)) then
--           for _, info in ipairs(move.moveInfo) do
--             if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
--               if (move.moveReason == fk.ReasonDiscard and Fk:getCardById(info.cardId).trueName == "slash") or
--               player.phase == Player.NotActive then return true end
--             end
--           end
--         end
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local judge = {
--       who = player,
--       reason = self.name,
--       pattern = ".|.|spade,club,diamond",
--     }
--     room:judge(judge)
--   end,
-- }
-- local ol_ex__tuntian_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__tuntian_delay",
--   events = {fk.FinishJudge},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and not player.dead and data.card.suit ~= Card.Heart and data.reason == ol_ex__tuntian.name
--       and player.room:getCardArea(data.card.id) == Card.Processing
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     player:addToPile("ol_ex__dengai_field", data.card, true, self.name)
--   end,
-- }
-- local ol_ex__tuntian_distance = fk.CreateDistanceSkill{
--   name = "#ol_ex__tuntian_distance",
--   correct_func = function(self, from, to)
--     if from:hasSkill(ol_ex__tuntian) then
--       return -#from:getPile("ol_ex__dengai_field")
--     end
--   end,
-- }
-- local ol_ex__zaoxian = fk.CreateTriggerSkill{
--   name = "ol_ex__zaoxian",
--   frequency = Skill.Wake,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.phase == Player.Start and
--       player:usedSkillTimes(self.name, Player.HistoryGame) == 0
--   end,
--   can_wake = function(self, event, target, player, data)
--     return #player:getPile("ol_ex__dengai_field") > 2
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:changeMaxHp(player, -1)
--     room:handleAddLoseSkills(player, "ol_ex__jixi", nil)
--     player:gainAnExtraTurn()
--   end,
-- }
-- local ol_ex__jixi = fk.CreateViewAsSkill{
--   name = "ol_ex__jixi",
--   anim_type = "control",
--   pattern = "snatch",
--   prompt = "#ol_ex__jixi-viewas",
--   expand_pile = "ol_ex__dengai_field",
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Self:getPileNameOfId(to_select) == "ol_ex__dengai_field"
--   end,
--   view_as = function(self, cards)
--     if #cards ~= 1 then
--       return nil
--     end
--     local c = Fk:cloneCard("snatch")
--     c.skillName = self.name
--     c:addSubcard(cards[1])
--     return c
--   end,
--   enabled_at_play = function(self, player)
--     return #player:getPile("ol_ex__dengai_field") > 0
--   end,
--   enabled_at_response = function(self, player)
--     return #player:getPile("ol_ex__dengai_field") > 0
--   end,
-- }
-- ol_ex__tuntian:addRelatedSkill(ol_ex__tuntian_delay)
-- ol_ex__tuntian:addRelatedSkill(ol_ex__tuntian_distance)
-- local dengai = General(extension, "ol_ex__dengai", "wei", 4)
-- dengai:addSkill(ol_ex__tuntian)
-- dengai:addSkill(ol_ex__zaoxian)
-- dengai:addRelatedSkill(ol_ex__jixi)

-- Fk:loadTranslationTable{
--   ["ol_ex__dengai"] = "界邓艾",
--   ["#ol_ex__dengai"] = "矫然的壮士",
--   ["illustrator:ol_ex__dengai"] = "君桓文化",
--   ["ol_ex__tuntian"] = "屯田",
--   ["#ol_ex__tuntian_delay"] = "屯田",
--   [":ol_ex__tuntian"] = "当你于回合外失去牌后，或于回合内因弃置而失去【杀】后，你可以进行判定，若结果不为<font color='red'>♥</font>，你将判定牌置于你的武将牌上，称为“田”；你计算与其他角色的距离-X（X为“田”的数量）。",
--   ["ol_ex__zaoxian"] = "凿险",
--   [":ol_ex__zaoxian"] = "觉醒技，准备阶段，若“田”的数量大于等于3，你减1点体力上限，然后获得“急袭”。此回合结束后，你获得一个额外回合。",
--   ["ol_ex__jixi"] = "急袭",
--   [":ol_ex__jixi"] = "你可以将一张“田”当【顺手牵羊】使用。",

--   ["ol_ex__dengai_field"] = "田",
--   ["#ol_ex__jixi-viewas"] = "发动 急袭，将一张“田”转化为【顺手牵羊】使用",

--   ["$ol_ex__tuntian1"] = "兵农一体，以屯养战。",
--   ["$ol_ex__tuntian2"] = "垦田南山，志在西川。",
--   ["$ol_ex__zaoxian1"] = "良田厚土，足平蜀道之难！",
--   ["$ol_ex__zaoxian2"] = "效仿五丁开川，赢粮直捣黄龙！",
--   ["$ol_ex__jixi1"] = "良田为济，神兵天降！",
--   ["$ol_ex__jixi2"] = "明至剑阁，暗袭蜀都！",
--   ["~ol_ex__dengai"] = "钟会！你为何害我！",
-- }

-- local ol_ex__tiaoxin = fk.CreateActiveSkill{
--   name = "ol_ex__tiaoxin",
--   anim_type = "control",
--   prompt = "#ol_ex__tiaoxin-active",
--   card_num = 0,
--   target_num = 1,
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < (1 + player:getMark("ol_ex__tiaoxin_extra-phase"))
--   end,
--   card_filter = Util.FalseFunc,
--   target_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(Self)
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     local use = room:askForUseCard(target, "slash", "slash", "#ol_ex__tiaoxin-use:" .. player.id, true,
--     {exclusive_targets = {player.id}, bypass_times = true})
--     if use then
--       room:useCard(use)
--       if player.dead then return false end
--     end
--     if not (use and use.damageDealt and use.damageDealt[player.id]) then
--       room:setPlayerMark(player, "ol_ex__tiaoxin_extra-phase", 1)
--       if not target:isNude() then
--         local card = room:askForCardChosen(player, target, "he", self.name)
--         room:throwCard({card}, self.name, target, player)
--       end
--     end
--   end
-- }
-- local ol_ex__zhiji = fk.CreateTriggerSkill{
--   name = "ol_ex__zhiji",
--   frequency = Skill.Wake,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and
--       player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
--       (player.phase == Player.Start or player.phase == Player.Finish)
--   end,
--   can_wake = function(self, event, target, player, data)
--     return player:isKongcheng()
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local choices = {"draw2"}
--     if player:isWounded() then
--       table.insert(choices, "recover")
--     end
--     local choice = room:askForChoice(player, choices, self.name)
--     if choice == "draw2" then
--       player:drawCards(2, self.name)
--     else
--       room:recover({
--         who = player,
--         num = 1,
--         recoverBy = player,
--         skillName = self.name
--       })
--     end
--     if player.dead then return false end
--     room:changeMaxHp(player, -1)
--     if player.dead then return false end
--     room:handleAddLoseSkills(player, "ex__guanxing", nil)
--   end,
-- }
-- local jiangwei = General(extension, "ol_ex__jiangwei", "shu", 4)
-- jiangwei:addSkill(ol_ex__tiaoxin)
-- jiangwei:addSkill(ol_ex__zhiji)
-- jiangwei:addRelatedSkill("ex__guanxing")

-- Fk:loadTranslationTable{
--   ["ol_ex__jiangwei"] = "界姜维",
--   ["#ol_ex__jiangwei"] = "龙的衣钵",
--   ["illustrator:ol_ex__jiangwei"] = "游漫美绘",
--   ["ol_ex__tiaoxin"] = "挑衅",
--   [":ol_ex__tiaoxin"] = "出牌阶段限一次，你可以选择一名攻击范围内含有你的角色，然后除非该角色对你使用一张【杀】且你因其执行此【杀】的效果而受到过伤害，否则你弃置其一张牌，然后本阶段本技能限两次。",
--   ["ol_ex__zhiji"] = "志继",
--   [":ol_ex__zhiji"] = "觉醒技，准备阶段或结束阶段，若你没有手牌，你回复1点体力或摸两张牌，然后减1点体力上限，获得“观星”。",

--   ["#ol_ex__tiaoxin-active"] = "发动挑衅，令一名角色对你出【杀】，否则你弃置其一张牌",
--   ["#ol_ex__tiaoxin-use"] = "挑衅：对 %src 使用一张【杀】，否则其弃置你一张牌",

--   ["$ol_ex__tiaoxin1"] = "会闻用师，观衅而动。",
--   ["$ol_ex__tiaoxin2"] = "宜乘其衅会，以挑敌将。",
--   ["$ol_ex__zhiji1"] = "丞相遗志，不死不休！",
--   ["$ol_ex__zhiji2"] = "大业未成，矢志不渝！",
--   ["$ex__guanxing_ol_ex__jiangwei1"] = "星象相弦，此乃吉兆！",
--   ["$ex__guanxing_ol_ex__jiangwei2"] = "星之分野，各有所属。",
--   ["~ol_ex__jiangwei"] = "星散流离……",
-- }

-- local ol_ex__fangquan = fk.CreateTriggerSkill{
--   name = "ol_ex__fangquan",
--   anim_type = "support",
--   events = {fk.EventPhaseChanging},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and player == target and data.to == Player.Play
--   end,
--   on_use = function(self, event, target, player, data)
--     player:skip(Player.Play)
--     return true
--   end,
-- }
-- local ol_ex__fangquan_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__fangquan_delay",
--   events = {fk.EventPhaseStart},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player.phase == Player.Discard and player:usedSkillTimes(ol_ex__fangquan.name, Player.HistoryTurn) > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, ol_ex__fangquan.name, "support")
--     local tar, card =  room:askForChooseCardAndPlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, ".|.|.|hand", "#ol_ex__fangquan-choose", ol_ex__fangquan.name, true)
--     if #tar > 0 and card then
--       room:throwCard(card, ol_ex__fangquan.name, player, player)
--       room:getPlayerById(tar[1]):gainAnExtraTurn()
--     end
--   end,
-- }
-- local ol_ex__ruoyu = fk.CreateTriggerSkill{
--   name = "ol_ex__ruoyu$",
--   frequency = Skill.Wake,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and
--       player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
--       player.phase == Player.Start
--   end,
--   can_wake = function(self, event, target, player, data)
--     return table.every(player.room:getOtherPlayers(player, false), function(p) return p.hp >= player.hp end)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:changeMaxHp(player, 1)
--     if player:isWounded() and player.hp < 3 then
--       room:recover({
--         who = player,
--         num = math.min(3, player.maxHp) - player.hp,
--         recoverBy = player,
--         skillName = self.name,
--       })
--     end
--     room:handleAddLoseSkills(player, "ol_ex__jijiang|ol_ex__sishu", nil, true, false)
--   end,
-- }
-- local orig_indulgence_skill = Fk.all_card_types["indulgence"].skill
-- local indulgenceSkill = fk.CreateActiveSkill{
--   name = "trans__indulgence_skill",
--   mod_target_filter = orig_indulgence_skill.modTargetFilter,
--   target_filter = orig_indulgence_skill.targetFilter,
--   target_num = 1,
--   on_effect = function(self, room, effect)
--     local to = room:getPlayerById(effect.to)
--     local judge = {
--       who = to,
--       reason = "indulgence",
--       pattern = ".|.|heart",
--     }
--     room:judge(judge)
--     local result = judge.card
--     if result.suit == Card.Heart then
--       to:skip(Player.Play)
--     end
--     self:onNullified(room, effect)
--   end,
--   on_nullified = function(self, room, effect)
--     room:moveCards{
--       ids = room:getSubcardsByRule(effect.card, { Card.Processing }),
--       toArea = Card.DiscardPile,
--       moveReason = fk.ReasonUse
--     }
--   end,
-- }
-- Fk:addSkill(indulgenceSkill)
-- local ol_ex__sishu_buff = fk.CreateTriggerSkill{
--   name = "#ol_ex__sishu_buff",
--   events = {fk.CardEffecting},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return player:getMark("@@ol_ex__sishu_effect") > 0 and target == player and data.card.trueName == "indulgence"
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local card = data.card:clone()
--     local c = table.simpleClone(data.card)
--     for k, v in pairs(c) do
--       card[k] = v
--     end
--     local ogri_skill = orig_indulgence_skill
--     card.skill = (card.skill == ogri_skill) and indulgenceSkill or ogri_skill
--     data.card = card
--   end,
-- }
-- local ol_ex__sishu = fk.CreateTriggerSkill{
--   name = "ol_ex__sishu",
--   events = {fk.EventPhaseStart},
--   anim_type = "support",
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and player.phase == Player.Play
--   end,
--   on_cost = function(self, event, target, player, data)
--     local to = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper),
--      1, 1, "#ol_ex__sishu-choose", self.name, true)
--     if #to > 0 then
--       self.cost_data = to[1]
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local tar = player.room:getPlayerById(self.cost_data)
--     if tar then
--       player.room:setPlayerMark(tar, "@@ol_ex__sishu_effect", 1- tar:getMark("@@ol_ex__sishu_effect"))
--     end
--   end,
-- }
-- local jijiang = fk.CreateViewAsSkill{
--   name = "ol_ex__jijiang$",
--   anim_type = "offensive",
--   pattern = "slash",
--   card_filter = Util.FalseFunc,
--   view_as = function(self, cards)
--     if #cards ~= 0 then
--       return nil
--     end
--     local c = Fk:cloneCard("slash")
--     c.skillName = self.name
--     return c
--   end,
--   before_use = function(self, player, use)
--     local room = player.room
--     if use.tos then
--       room:doIndicate(player.id, TargetGroup:getRealTargets(use.tos))
--     end
--     for _, p in ipairs(room:getOtherPlayers(player)) do
--       if p.kingdom == "shu" and p:isAlive() then
--         local cardResponded = room:askForResponse(p, "slash", "slash", "#jijiang-ask:" .. player.id, true)
--         if cardResponded then
--           room:responseCard({
--             from = p.id,
--             card = cardResponded,
--             skipDrop = true,
--           })
--           use.card = cardResponded
--           return
--         end
--       end
--     end
--     room:setPlayerMark(player, "jijiang-failed-phase", 1)
--     return self.name
--   end,
--   enabled_at_play = function(self, player)
--     return player:getMark("jijiang-failed-phase") == 0 and table.every(Fk:currentRoom().alive_players, function(p)
--       return p == player or p.kingdom ~= "shu"
--     end)
--   end,
--   enabled_at_response = function(self, player)
--     return not table.every(Fk:currentRoom().alive_players, function(p)
--       return p == player or p.kingdom ~= "shu"
--     end)
--   end,
-- }
-- local jijiang_trigger = fk.CreateTriggerSkill{
--   name = "#ol_ex__jijiang_trigger",
--   mute = true,
--   frequency = Skill.Compulsory,
--   events = { fk.CardUsing, fk.CardResponding },
--   can_trigger = function(self, event, target, player, data)
--     return data.card.trueName == "slash" and target ~= player and player:hasSkill(jijiang)
--     and target.kingdom == "shu" and target ~= player.room.current
--     and player:getMark("ol_ex__jijiang_draw-turn") == 0
--   end,
--   on_cost = function (self, event, target, player, data)
--     return player.room:askForSkillInvoke(target, self.name, nil, "#ol_ex__jijiang-invoke:"..player.id)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:broadcastSkillInvoke("ol_ex__jijiang")
--     room:notifySkillInvoked(player, "ol_ex__jijiang", "drawcard")
--     room:setPlayerMark(player, "ol_ex__jijiang_draw-turn", 1)
--     player:drawCards(1, "ol_ex__jijiang")
--   end,
-- }
-- jijiang:addRelatedSkill(jijiang_trigger)
-- Fk:addSkill(jijiang)
-- ol_ex__fangquan:addRelatedSkill(ol_ex__fangquan_delay)
-- local liushan = General(extension, "ol_ex__liushan", "shu", 3)
-- liushan:addSkill("xiangle")
-- liushan:addSkill(ol_ex__fangquan)
-- liushan:addSkill(ol_ex__ruoyu)
-- liushan:addRelatedSkill("ol_ex__jijiang")
-- ol_ex__sishu:addRelatedSkill(ol_ex__sishu_buff)
-- liushan:addRelatedSkill(ol_ex__sishu)
-- Fk:loadTranslationTable{
--   ["ol_ex__liushan"] = "界刘禅",
--   ["#ol_ex__liushan"] = "无为的真命主",
--   ["illustrator:ol_ex__liushan"] = "拉布拉卡",
--   ["ol_ex__fangquan"] = "放权",
--   ["#ol_ex__fangquan_delay"] = "放权",
--   [":ol_ex__fangquan"] = "出牌阶段开始前，你可跳过此阶段，然后弃牌阶段开始时，你可弃置一张手牌并选择一名其他角色，其获得一个额外回合。",
--   ["ol_ex__ruoyu"] = "若愚",
--   [":ol_ex__ruoyu"] = "主公技，觉醒技，准备阶段，若你是体力值最小的角色，你加1点体力上限，回复体力至3点，获得〖激将〗和〖思蜀〗。",
--   ["ol_ex__sishu"] = "思蜀",
--   [":ol_ex__sishu"] = "出牌阶段开始时，你可选择一名角色，其本局游戏【乐不思蜀】的判定结果反转。",
--   ["ol_ex__jijiang"] = "激将",
--   [":ol_ex__jijiang"] = "主公技，①当你需要使用或打出【杀】时，你可以令其他蜀势力角色选择是否打出一张【杀】（视为由你使用或打出）；②每回合限一次，其他蜀势力角色于其回合外使用或打出【杀】时，可令你摸一张牌。",
--   ["#ol_ex__jijiang-invoke"] = "激将：你可以令 %src 摸一张牌",

--   ["#ol_ex__fangquan-choose"] = "放权：弃置一张手牌，令一名角色获得一个额外回合",
--   ["#ol_ex__sishu-choose"] = "思蜀：选择一名角色，令其本局游戏【乐不思蜀】的判定结果反转",
--   ["@@ol_ex__sishu_effect"] = "思蜀",
--   ["#ol_ex__sishu_buff"] = "思蜀",
--   ["trans__indulgence_skill"] = "乐不思蜀",

--   ["$xiangle_ol_ex__liushan1"] = "美好的日子，应该好好享受。",
--   ["$xiangle_ol_ex__liushan2"] = "嘿嘿嘿，还是玩耍快乐。",
--   ["$ol_ex__fangquan1"] = "蜀汉有相父在，我可安心。",
--   ["$ol_ex__fangquan2"] = "这些事情，你们安排就好。",
--   ["$ol_ex__ruoyu1"] = "若愚故泰，巧骗众人。",
--   ["$ol_ex__ruoyu2"] = "愚昧者，非真傻也。",
--   ["$ol_ex__jijiang_ol_ex__liushan1"] = "爱卿爱卿，快来护驾！",
--   ["$ol_ex__jijiang_ol_ex__liushan2"] = "将军快替我，拦下此贼！",
--   ["$ol_ex__sishu1"] = "蜀乐乡土，怎不思念？",
--   ["$ol_ex__sishu2"] = "思乡心切，徘徊惶惶。",
--   ["~ol_ex__liushan"] = "将军英勇，我……我投降……",
-- }

-- local ol_ex__jiang = fk.CreateTriggerSkill{
--   name = "ol_ex__jiang",
--   anim_type = "drawcard",
--   events ={fk.TargetSpecified, fk.TargetConfirmed, fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(self) then return end
--     if (event == fk.TargetSpecified or event == fk.TargetConfirmed) and player == target and
--       ((data.card.trueName == "slash" and data.card.color == Card.Red) or data.card.name == "duel") then
--       return event == fk.TargetConfirmed or data.firstTarget
--     elseif event == fk.AfterCardsMove then
--       local x = player:getMark("jiang_record-turn")
--       local room = player.room
--       local move__event = room.logic:getCurrentEvent()
--       if not move__event or (x > 0 and x ~= move__event.id) then return false end
--       local searchJiangCards = function(move_data, findOne)
--         local cards = {}
--         for _, move in ipairs(move_data) do
--           if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
--             for _, info in ipairs(move.moveInfo) do
--               local card = Fk:getCardById(info.cardId)
--               if ((card.trueName == "slash" and card.color == Card.Red) or card.name == "duel") then
--                 table.insert(cards, info.cardId)
--                 if findOne then
--                   return cards
--                 end
--               end
--             end
--           end
--         end
--         return cards
--       end
--       local cards = searchJiangCards(data, false)
--       if #U.moveCardsHoldingAreaCheck(room, table.filter(cards, function (id)
--         return room:getCardArea(id) == Card.DiscardPile
--       end)) == 0 then return false end
--       if x == 0 then
--         room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
--           if #searchJiangCards(e.data, true) > 0 then
--             x = e.id
--             room:setPlayerMark(player, "jiang_record-turn", x)
--             return true
--           end
--           return false
--         end, Player.HistoryTurn)
--       end
--       if x == move__event.id then
--         self.cost_data = cards
--         return true
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     if event == fk.TargetSpecified or event == fk.TargetConfirmed then
--       player:drawCards(1, self.name)
--     elseif event == fk.AfterCardsMove then
--       local room = player.room
--       local cards = table.simpleClone(self.cost_data)
--       room:loseHp(player, 1, self.name)
--       if player.dead then return false end
--       cards = U.moveCardsHoldingAreaCheck(room, table.filter(cards, function (id)
--         return room:getCardArea(id) == Card.DiscardPile
--       end))
--       if #cards > 0 then
--         room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, self.name, nil, true, player.id)
--       end
--     end
--   end,
-- }

-- local ol_ex__hunzi = fk.CreateTriggerSkill{
--   name = "ol_ex__hunzi",
--   frequency = Skill.Wake,
--   events = {fk.EventPhaseStart},
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(self) and
--       player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
--       player.phase == Player.Start
--   end,
--   can_wake = function(self, event, target, player, data)
--     return player.hp == 1
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:changeMaxHp(player, -1)
--     if player.dead then return false end
--     room:handleAddLoseSkills(player, "ex__yingzi|yinghun", nil)
--   end,
-- }
-- local ol_ex__hunzi_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__hunzi_delay",
--   events = {fk.EventPhaseStart},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target and target.phase == Player.Finish and not target.dead and player:usedSkillTimes(ol_ex__hunzi.name, Player.HistoryTurn) > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:notifySkillInvoked(player, ol_ex__hunzi.name, "support")
--     local choices = {"ol_ex__hunzi_draw"}
--     if player:isWounded() then
--       table.insert(choices, "ol_ex__hunzi_recover")
--     end
--     local choice = room:askForChoice(player, choices, ol_ex__hunzi.name, "#ol_ex__hunzi-choice")
--     if choice == "ol_ex__hunzi_draw" then
--       player:drawCards(2, self.name)
--     else
--       room:recover({
--         who = player,
--         num = 1,
--         recoverBy = player,
--         skillName = ol_ex__hunzi.name
--       })
--     end
--   end,
-- }

-- local ol_ex__zhiba = fk.CreateActiveSkill{
--   name = "ol_ex__zhiba$",
--   attached_skill_name = "ol_ex__zhiba_other&",
--   anim_type = "control",
--   prompt = "#ol_ex__zhiba-active",
--   can_use = function(self, player)
--     return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 and not player:isKongcheng()
--   end,
--   card_num = 0,
--   card_filter = Util.FalseFunc,
--   target_num = 1,
--   target_filter = function(self, to_select, selected)
--     if #selected == 0 and to_select ~= Self.id then
--       local target = Fk:currentRoom():getPlayerById(to_select)
--       return target.kingdom == "wu" and Self:canPindian(target)
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     player:pindian({target}, self.name)
--   end,

--   on_acquire = function(self, player)
--     local room = player.room
--     for _, p in ipairs(room.alive_players) do
--       if p ~= player and p.kingdom == "wu" then
--         room:handleAddLoseSkills(p, self.attached_skill_name, nil, false, true)
--       end
--     end
--   end
-- }
-- local ol_ex__zhiba_delay = fk.CreateTriggerSkill{
--   name = "#ol_ex__zhiba_delay",
--   events = {fk.PindianResultConfirmed},
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     if player.dead then return false end
--     if (data.from == player and (not data.winner or data.winner == player) and data.reason == "ol_ex__zhiba") or
--       (data.to == player and (not data.winner or data.winner == player) and data.reason == "ol_ex__zhiba_other&") then
--       local room = player.room
--       return room:getCardArea(data.fromCard) == Card.Processing or room:getCardArea(data.toCard) == Card.Processing
--     end
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local cards = {}
--     local id = data.fromCard:getEffectiveId()
--     if room:getCardArea(id) == Card.Processing then
--       table.insert(cards, id)
--     end
--     id = data.toCard:getEffectiveId()
--     if room:getCardArea(id) == Card.Processing then
--       table.insertIfNeed(cards, id)
--     end
--     if #cards > 1 and room:askForChoice(player, {"ol_ex__zhiba_obtain", "ol_ex__zhiba_cancel"}, ol_ex__zhiba.name,
--     "#ol_ex__zhiba-obtain") == "ol_ex__zhiba_obtain" then
--       room:moveCards({
--         ids = cards,
--         to = player.id,
--         toArea = Card.PlayerHand,
--         moveReason = fk.ReasonPrey,
--         skillName = ol_ex__zhiba.name,
--         proposer = player.id,
--       })
--     end
--   end,

--   refresh_events = {fk.AfterPropertyChange},
--   can_refresh = function(self, event, target, player, data)
--     return target == player
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     if player.kingdom == "wu" and table.find(room.alive_players, function (p)
--       return p ~= player and p:hasSkill(self, true)
--     end) then
--       room:handleAddLoseSkills(player, "ol_ex__zhiba_other&", nil, false, true)
--     else
--       room:handleAddLoseSkills(player, "-ol_ex__zhiba_other&", nil, false, true)
--     end
--   end,
-- }
-- local ol_ex__zhiba_other = fk.CreateActiveSkill{
--   name = "ol_ex__zhiba_other&",
--   anim_type = "support",
--   prompt = "#ol_ex__zhiba_other-active",
--   mute = true,
--   can_use = function(self, player)
--     if player.kingdom ~= "wu" or player:isKongcheng() then return false end
--     local targetRecorded = player:getTableMark("ol_ex__zhiba_sources-phase")
--     return table.find(Fk:currentRoom().alive_players, function(p)
--       return p ~= player and p:hasSkill(ol_ex__zhiba) and not table.contains(targetRecorded, p.id)
--     end)
--   end,
--   card_num = 0,
--   card_filter = Util.FalseFunc,
--   target_num = 1,
--   target_filter = function(self, to_select, selected)
--     if #selected == 0 and to_select ~= Self.id then
--       local target = Fk:currentRoom():getPlayerById(to_select)
--       return target:hasSkill(ol_ex__zhiba) and Self:canPindian(target) and
--       not table.contains(Self:getTableMark("ol_ex__zhiba_sources-phase"), to_select)
--     end
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     room:notifySkillInvoked(player, ol_ex__zhiba.name)
--     target:broadcastSkillInvoke(ol_ex__zhiba.name)
--     room:addTableMarkIfNeed(player, "ol_ex__zhiba_sources-phase", target.id)

--     if room:askForChoice(target, {"ol_ex__zhiba_accept", "ol_ex__zhiba_refuse"}, ol_ex__zhiba.name,
--     "#ol_ex__zhiba-ask:" .. player.id) == "ol_ex__zhiba_accept" then
--       player:pindian({target}, self.name)
--     end
--   end,
-- }

-- Fk:addSkill(ol_ex__zhiba_other)
-- ol_ex__hunzi:addRelatedSkill(ol_ex__hunzi_delay)
-- ol_ex__zhiba:addRelatedSkill(ol_ex__zhiba_delay)
-- local sunce = General(extension, "ol_ex__sunce", "wu", 4)
-- sunce:addSkill(ol_ex__jiang)
-- sunce:addSkill(ol_ex__hunzi)
-- sunce:addSkill(ol_ex__zhiba)
-- sunce:addRelatedSkill("ex__yingzi")
-- sunce:addRelatedSkill("yinghun")

-- Fk:loadTranslationTable{
--   ["ol_ex__sunce"] = "界孙策",
--   ["#ol_ex__sunce"] = "江东的小霸王",
--   ["illustrator:ol_ex__sunce"] = "李敏然",
--   ["ol_ex__jiang"] = "激昂",
--   [":ol_ex__jiang"] = "当你使用【决斗】或红色【杀】指定目标后，或成为【决斗】或红色【杀】的目标后，你可以摸一张牌。每回合首次有包含【决斗】或红色【杀】在内的牌因弃置而置入弃牌堆后，你可以失去1点体力获得其中所有【决斗】和红色【杀】。",
--   ["ol_ex__hunzi"] = "魂姿",
--   ["#ol_ex__hunzi_delay"] = "魂姿",
--   [":ol_ex__hunzi"] = "觉醒技，准备阶段，若你的体力值为1，你减1点体力上限，获得“英姿”和“英魂”。本回合结束阶段，你摸两张牌或回复1点体力。",
--   ["ol_ex__zhiba"] = "制霸",
--   [":ol_ex__zhiba"] = "主公技，其他吴势力角色的出牌阶段限一次，其可以对你发起拼点，你可以拒绝此拼点。出牌阶段限一次，你可以与一名其他吴势力角色拼点。以此法发起的拼点，若其没赢，你可以获得两张拼点牌。",

--   ["ol_ex__zhiba_other&"] = "制霸",
--   [":ol_ex__zhiba_other&"] = "出牌阶段限一次，你可与孙策拼点（其可拒绝此次拼点），若你没赢，其获得两张拼点牌。",

--   ["#ol_ex__hunzi-choice"] = "魂姿：选择摸两张牌或者回复1点体力",
--   ["ol_ex__hunzi_draw"] = "摸两张牌",
--   ["ol_ex__hunzi_recover"] = "回复1点体力",
--   ["#ol_ex__zhiba-active"] = "发动制霸，与吴势力角色拼点！",
--   ["#ol_ex__zhiba_other-active"] = "发动制霸，与拥有“制霸”的角色拼点！",

--   ["#ol_ex__zhiba-ask"] = "制霸：%src 向你发起拼点！",
--   ["ol_ex__zhiba_accept"] = "接受拼点",
--   ["ol_ex__zhiba_refuse"] = "拒绝拼点",
--   ["#ol_ex__zhiba-obtain"] = "制霸：是否获得拼点的两张牌",
--   ["ol_ex__zhiba_obtain"] = "获得拼点牌",
--   ["ol_ex__zhiba_cancel"] = "取消",

--   ["$ol_ex__jiang1"] = "策虽暗稚，窃有微志。",
--   ["$ol_ex__jiang2"] = "收合流散，东据吴会。",
--   ["$ol_ex__hunzi1"] = "江东新秀，由此崛起。",
--   ["$ol_ex__hunzi2"] = "看汝等大展英气！",
--   ["$ol_ex__zhiba1"] = "让将军在此恭候多时了。",
--   ["$ol_ex__zhiba2"] = "有诸位将军在，此战岂会不胜？",
--   ["$ex__yingzi_ol_ex__sunce1"] = "得公瑾辅助，策必当一战！",
--   ["$ex__yingzi_ol_ex__sunce2"] = "公瑾在此，此战无忧！",
--   ["$yinghun_ol_ex__sunce1"] = "东吴繁盛，望父亲可知。",
--   ["$yinghun_ol_ex__sunce2"] = "父亲，吾定不负你期望！",
--   ["~ol_ex__sunce"] = "汝等，怎能受于吉蛊惑？",
-- }

-- local zhangzhaozhanghong = General(extension, "ol_ex__zhangzhaozhanghong", "wu", 3)
-- local ol_ex__zhijian = fk.CreateActiveSkill{
--   name = "ol_ex__zhijian",
--   anim_type = "support",
--   prompt = "#ol_ex__zhijian-active",
--   card_num = 1,
--   target_num = 1,
--   card_filter = function(self, to_select, selected)
--     return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
--   end,
--   target_filter = function(self, to_select, selected, selected_cards)
--     return #selected == 0 and #selected_cards == 1 and to_select ~= Self.id and
--     U.canMoveCardIntoEquip(Fk:currentRoom():getPlayerById(to_select), selected_cards[1], true)
--   end,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local target = room:getPlayerById(effect.tos[1])
--     room:moveCardIntoEquip(target, effect.cards[1], self.name, true, player)
--     if not player.dead then
--       room:drawCards(player, 1, self.name)
--     end
--   end,
-- }
-- local ol_ex__guzheng = fk.CreateTriggerSkill{
--   name = "ol_ex__guzheng",
--   anim_type = "support",
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) < 1 then
--       local room = player.room
--       local currentplayer = room.current
--       if currentplayer and currentplayer.phase <= Player.Finish and currentplayer.phase >= Player.Start then
--         local guzheng_pairs = {}
--         for _, move in ipairs(data) do
--           if move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile and
--           move.from ~= nil and move.from ~= player.id then
--             local guzheng_value = guzheng_pairs[move.from] or {}
--             for _, info in ipairs(move.moveInfo) do
--               if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
--                 table.insert(guzheng_value, info.cardId)
--               end
--             end
--             guzheng_pairs[move.from] = guzheng_value
--           end
--         end
--         local guzheng_data, ids = {{}, {}}, {}
--         for key, value in pairs(guzheng_pairs) do
--           if not room:getPlayerById(key).dead and #value > 1 then
--             ids = U.moveCardsHoldingAreaCheck(room, table.filter(value, function (id)
--               return room:getCardArea(id) == Card.DiscardPile
--             end))
--             if #ids > 0 then
--               table.insert(guzheng_data[1], key)
--               table.insert(guzheng_data[2], ids)
--             end
--           end
--         end
--         if #guzheng_data[1] > 0 then
--           self.cost_data = guzheng_data
--           return true
--         end
--       end
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     local targets = self.cost_data[1]
--     local card_pack = self.cost_data[2]
--     if #targets == 1 then
--       if room:askForSkillInvoke(player, self.name, nil, "#ol_ex__guzheng-invoke::"..targets[1]) then
--         self.cost_data = {tos = targets, cards = card_pack[1]}
--         return true
--       end
--     elseif #targets > 1 then
--       local tos = room:askForChoosePlayers(player, targets, 1, 1, "#ol_ex__guzheng-choose", self.name)
--       if #tos > 0 then
--         self.cost_data = {tos = {tos[1]}, cards = card_pack[table.indexOf(targets, tos[1])]}
--         return true
--       end
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     local toId = self.cost_data.tos[1]
--     room:doIndicate(player.id, {toId})
--     local cards = self.cost_data.cards
--     local to_return = table.random(cards, 1)
--     local choice = "guzheng_no"
--     if #cards > 1 then
--       to_return, choice = U.askforChooseCardsAndChoice(player, cards, {"guzheng_yes", "guzheng_no"}, self.name,
--       "#guzheng-title::" .. toId)
--     end
--     local moveInfos = {}
--     table.insert(moveInfos, {
--       ids = to_return,
--       to = toId,
--       toArea = Card.PlayerHand,
--       moveReason = fk.ReasonJustMove,
--       proposer = player.id,
--       skillName = self.name,
--     })
--     table.removeOne(cards, to_return[1])
--     if choice == "guzheng_yes" and #cards > 0 then
--       table.insert(moveInfos, {
--         ids = cards,
--         to = player.id,
--         toArea = Card.PlayerHand,
--         moveReason = fk.ReasonJustMove,
--         proposer = player.id,
--         skillName = self.name,
--       })
--     end
--     room:moveCards(table.unpack(moveInfos))
--   end,
-- }
-- zhangzhaozhanghong:addSkill(ol_ex__zhijian)
-- zhangzhaozhanghong:addSkill(ol_ex__guzheng)
-- Fk:loadTranslationTable{
--   ["ol_ex__zhangzhaozhanghong"] = "界张昭张纮",
--   ["#ol_ex__zhangzhaozhanghong"] = "经天纬地",
--   ["designer:ol_ex__zhangzhaozhanghong"] = "玄蝶既白",
--   ["illustrator:ol_ex__zhangzhaozhanghong"] = "君桓文化",
--   ["ol_ex__zhijian"] = "直谏",
--   [":ol_ex__zhijian"] = "出牌阶段，你可以将一张装备牌置于其他角色装备区（替换原装备），然后摸一张牌。",
--   ["ol_ex__guzheng"] = "固政",
--   [":ol_ex__guzheng"] = "每阶段限一次，当其他角色的至少两张牌因弃置而置入弃牌堆后，你可以令其获得其中一张牌，然后你可以获得剩余牌。",

--   ["#ol_ex__zhijian-active"] = "发动直谏，选择一张装备牌置入其他角色的装备区（替换原装备）",
--   ["#ol_ex__guzheng-invoke"] = "你可以发动固政，令%dest获得其此次弃置的牌中的一张，然后你获得剩余牌",
--   ["#ol_ex__guzheng-choose"] = "你可以发动固政，令一名角色获得其此次弃置的牌中的一张，然后你获得剩余牌",
--   ["#guzheng-title"] = "固政：选择一张牌还给 %dest",
--   ["guzheng_yes"] = "确定，获得剩余牌",
--   ["guzheng_no"] = "确定，不获得剩余牌",

--   ["$ol_ex__zhijian1"] = "君有恙，臣等当舍命除之。",
--   ["$ol_ex__zhijian2"] = "臣有言在喉，不吐不快。",
--   ["$ol_ex__guzheng1"] = "兴国为任，可驱百里之行。",
--   ["$ol_ex__guzheng2"] = "固政之责，在君亦在臣。",
--   ["~ol_ex__zhangzhaozhanghong"] = "老臣年迈，无力为继……",
-- }

-- local ol_ex__zuoci = General(extension, "ol_ex__zuoci", "qun", 3)

-- local huashen_blacklist = {
--   -- imba
--   "zuoci", "ol_ex__zuoci", "qyt__dianwei", "starsp__xiahoudun", "mou__wolong",
--   -- haven't available skill
--   "js__huangzhong", "liyixiejing", "olz__wangyun", "yanyan", "duanjiong", "wolongfengchu", "wuanguo", "os__wangling", "tymou__jiaxu",
-- }
-- local function Gethuashen(player, n)
--   local room = player.room
--   local generals = table.filter(room.general_pile, function (name)
--     return not table.contains(huashen_blacklist, name)
--   end)
--   local mark = U.getPrivateMark(player, "&ol_ex__huashen")
--   for _ = 1, n do
--     if #generals == 0 then break end
--     local g = table.remove(generals, math.random(#generals))
--     table.insert(mark, g)
--     table.removeOne(room.general_pile, g)
--   end
--   U.setPrivateMark(player, "&ol_ex__huashen", mark)
-- end
-- local function Dohuashen(player)
--   local room = player.room
--   local generals = U.getPrivateMark(player, "&ol_ex__huashen")
--   if #generals == 0 then return end
--   local default = {}
--   local skillList = {}
--   for _, g in ipairs(generals) do
--     local general = Fk.generals[g]
--     local skills = {}
--     for _, skillName in ipairs(general:getSkillNameList()) do
--       local s = Fk.skills[skillName]
--       if not (s.lordSkill or s.switchSkillName or s.frequency > 3) and #s.attachedKingdom == 0 then
--         table.insert(skills, skillName)
--         if #default == 0 then
--           default = {g, skillName}
--         end
--       end
--     end
--     table.insert(skillList, skills)
--   end
--   local result = room:askForCustomDialog(
--     player, "ol_ex__huashen",
--     "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
--     { generals, skillList, "#ol_ex__huashen-skill" }
--   )
--   if result == "" then
--     if #default == 0 then return end
--     result = default
--   else
--     result = json.decode(result)
--   end
--   local generalName, skill = table.unpack(result)
--   local general = Fk.generals[generalName]
--   room:setPlayerMark(player, "ol_ex__huashen_general", generalName)
--   if player:getMark("HuashenOrignalProperty") == 0 then
--     room:setPlayerMark(player, "HuashenOrignalProperty", {player.gender, player.kingdom})
--   end
--   player.gender = general.gender
--   room:broadcastProperty(player, "gender")
--   player.kingdom = general.kingdom
--   room:askForChooseKingdom({player})
--   room:broadcastProperty(player, "kingdom")
--   local old_mark = player:getMark("@ol_ex__huashen_skill")
--   if old_mark ~= 0 then
--     room:handleAddLoseSkills(player, "-"..old_mark[2])
--   end
--   room:setPlayerMark(player, "@ol_ex__huashen_skill", {generalName, skill})
--   room:handleAddLoseSkills(player, skill)
--   room:delay(500)
-- end
-- local function Recasthuashen(player)
--   local room = player.room
--   local generals = U.getPrivateMark(player, "&ol_ex__huashen")
--   if #generals < 2 then return end
--   local current_general = type(player:getMark("ol_ex__huashen_general")) == "string" and player:getMark("ol_ex__huashen_general") or ""
--   local result = player.room:askForCustomDialog(player, "ol_ex__huashen",
--   "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
--     generals,
--     {"OK"},
--     "#ol_ex__huashen-recast",
--     {"Cancel"},
--     1,
--     2,
--     {current_general},
--   })
--   if result == "" then return end
--   local reply = json.decode(result)
--   if reply.choice ~= "OK" then return end
--   local removed = reply.cards
--   for _, g in ipairs(removed) do
--     table.removeOne(generals, g)
--   end
--   U.setPrivateMark(player, "&ol_ex__huashen", generals)
--   Gethuashen(player, #removed)
--   room:returnToGeneralPile(removed)
-- end
-- local ol_ex__huashen = fk.CreateTriggerSkill{
--   name = "ol_ex__huashen",
--   events = {fk.GameStart, fk.TurnStart, fk.TurnEnd},
--   can_trigger = function(self, event, target, player, data)
--     if event == fk.GameStart then
--       return player:hasSkill(self)
--     else
--       return player:hasSkill(self) and target == player and #U.getPrivateMark(player, "&ol_ex__huashen") > 0
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     if event == fk.GameStart then return true end
--     local choice = player.room:askForChoice(player, {"ol_ex__huashen_re", "ol_ex__huashen_recast", "Cancel"}, self.name)
--     if choice ~= "Cancel" then
--       self.cost_data = choice
--       return true
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     if event == fk.GameStart then
--       Gethuashen(player, 3)
--       Dohuashen(player)
--     else
--       if self.cost_data == "ol_ex__huashen_re" then
--         Dohuashen(player)
--       else
--         Recasthuashen(player)
--       end
--     end
--   end,

--   refresh_events = {fk.EventLoseSkill},
--   can_refresh = function(self, event, target, player, data)
--     return player == target and data == self
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     room:setPlayerMark(player, "@[private]&ol_ex__huashen", 0)
--     local pro = player:getMark("HuashenOrignalProperty")
--     if pro ~= 0 then
--       player.gender = pro[1]
--       room:broadcastProperty(player, "gender")
--       player.kingdom = pro[2]
--       room:broadcastProperty(player, "kingdom")
--       room:setPlayerMark(player, "HuashenOrignalProperty", 0)
--     end
--   end,
-- }
-- local ol_ex__xinsheng = fk.CreateTriggerSkill{
--   name = "ol_ex__xinsheng",
--   anim_type = "masochism",
--   events = {fk.Damaged},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and target == player and player:hasSkill(ol_ex__huashen, true)
--   end,
--   on_trigger = function(self, event, target, player, data)
--     self.cancel_cost = false
--     for _ = 1, data.damage do
--       if self.cancel_cost or not (player:hasSkill(self) and player:hasSkill(ol_ex__huashen, true)) then break end
--       self:doCost(event, target, player, data)
--     end
--   end,
--   on_cost = function(self, event, target, player, data)
--     local room = player.room
--     if room:askForSkillInvoke(player, self.name, data) then return true end
--     self.cancel_cost = true
--   end,
--   on_use = function(self, event, target, player, data)
--     Gethuashen(player, 1)
--   end,
-- }
-- ol_ex__zuoci:addSkill(ol_ex__huashen)
-- ol_ex__zuoci:addSkill(ol_ex__xinsheng)
-- Fk:loadTranslationTable{
--   ["ol_ex__zuoci"] = "界左慈",
--   ["#ol_ex__zuoci"] = "迷之仙人",
--   ["illustrator:ol_ex__zuoci"] = "波子",
--   ["ol_ex__huashen"] = "化身",
--   [":ol_ex__huashen"] = "①游戏开始时，你随机获得三张武将牌作为“化身”牌，然后你选择其中一张“化身”牌的一个技能（主公技/限定技/觉醒技/转换技/势力技除外），你视为拥有此技能，且性别和势力视为与此“化身”牌相同。<br>"..
--   "②回合开始或结束时，你可以选择一项：1.重新进行一次“化身”；2.移去至多两张不为亮出的“化身”牌，然后获得等量的新“化身”牌。",
--   ["@[private]&ol_ex__huashen"] = "化身",
--   ["@ol_ex__huashen_skill"] = "化身",
--   ["ol_ex__huashen_re"] = "进行一次“化身”",
--   ["ol_ex__huashen_recast"] = "移去至多两张“化身”，获得等量新“化身”",
--   ["#ol_ex__huashen-recast"] = "移去至多两张“化身”，获得等量新“化身”",
--   ["#ol_ex__huashen-skill"] = "化身：选择一个武将，再选择一个要获得的技能",
--   ["ol_ex__xinsheng"] = "新生",
--   [":ol_ex__xinsheng"] = "当你受到1点伤害后，若你有技能“化身”，你可以随机获得一张新的“化身”牌。",

--   ["$ol_ex__huashen1"] = "容貌发肤，不过浮尘。",
--   ["$ol_ex__huashen2"] = "皮囊万千，吾皆可化。",
--   ["$ol_ex__xinsheng1"] = "枯木发荣，朽木逢春。",
--   ["$ol_ex__xinsheng2"] = "风靡云涌，万丈光芒。",
--   ["~ol_ex__zuoci"] = "红尘看破，驾鹤仙升……",
-- }

-- local ol_ex__beige = fk.CreateTriggerSkill{
--   name = "ol_ex__beige",
--   anim_type = "masochism",
--   events = {fk.Damaged},
--   can_trigger = function(self, event, target, player, data)
--     return player:hasSkill(self) and data.card and data.card.trueName == "slash" and not data.to.dead and not player:isNude()
--   end,
--   on_cost = function(self, event, target, player, data)
--     return player.room:askForSkillInvoke(player, self.name, nil, "#ol_ex__beige-invoke::"..target.id)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:doIndicate(player.id, {target.id})
--     local judge = {
--       who = target,
--       reason = self.name,
--       pattern = ".",
--     }
--     room:judge(judge)
--     if player.dead then return false end
--     local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#ol_ex__beige-discard::"..target.id, true)
--     if #card ~= 1 then return end
--     local dis_card = Fk:getCardById(card[1])
--     local suit = dis_card.suit
--     local number = dis_card.number
--     room:throwCard(card, self.name, player, player)
--     if not player.dead then
--       local cards = {}
--       if suit == judge.card.suit and room:getCardArea(judge.card.id) == Card.DiscardPile then
--         table.insert(cards, judge.card.id)
--       end
--       if number == judge.card.number and room:getCardArea(dis_card.id) == Card.DiscardPile then
--         table.insert(cards, dis_card.id)
--       end
--       if #cards > 0 then
--         room:obtainCard(player, cards, true, fk.ReasonJustMove)
--       end
--     end
--     if judge.card.suit == Card.Heart then
--       if not target.dead and target:isWounded() then
--         room:recover{
--           who = target,
--           num = 1,
--           recoverBy = player,
--           skillName = self.name
--         }
--       end
--     elseif judge.card.suit == Card.Diamond then
--       if not target.dead then
--         target:drawCards(2, self.name)
--       end
--     elseif judge.card.suit == Card.Club then
--       if data.from and not data.from.dead then
--         room:askForDiscard(data.from, 2, 2, true, self.name, false)
--       end
--     elseif judge.card.suit == Card.Spade then
--       if data.from and not data.from.dead then
--         data.from:turnOver()
--       end
--     end
--   end,
-- }
-- local caiwenji = General(extension, "ol_ex__caiwenji", "qun", 3, 3, General.Female)
-- caiwenji:addSkill(ol_ex__beige)
-- caiwenji:addSkill("duanchang")

-- Fk:loadTranslationTable{
--   ["ol_ex__caiwenji"] = "界蔡文姬",
--   ["#ol_ex__caiwenji"] = "异乡的孤女",
--   ["illustrator:ol_ex__caiwenji"] = "罔両",
--   ["ol_ex__beige"] = "悲歌",
--   [":ol_ex__beige"] = "当一名角色受到【杀】造成的伤害后，若你有牌，你可以令其判定，然后你可以弃置一张牌，根据判定结果执行："..
--   "<font color='red'>♥</font>，其回复1点体力；<font color='red'>♦</font>，其摸两张牌；"..
--   "♣，来源弃置两张牌；♠，来源翻面。若判定牌与你弃置的牌：花色相同，你获得判定牌；点数相同，你获得你弃置的牌。",

--   ["#ol_ex__beige-invoke"] = "悲歌：你可以令%dest进行判定",
--   ["#ol_ex__beige-discard"] = "悲歌：你可以弃置一张牌令%dest根据判定的花色执行对应效果",

--   ["$ol_ex__beige1"] = "箜篌鸣九霄，闻者心俱伤。",
--   ["$ol_ex__beige2"] = " 琴弹十八拍，听此双泪流。",
--   ["$duanchang_ol_ex__caiwenji1"] = "红颜留塞外，愁思欲断肠。",
--   ["$duanchang_ol_ex__caiwenji2"] = "莫吟苦辛曲，此生谁忍闻。",
--   ["~ol_ex__caiwenji"] = "飘飘外域里，何日能归乡？",
-- }