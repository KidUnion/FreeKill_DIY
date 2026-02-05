local extension = Package:new("suzhi")
extension.extensionName = "FreeKill_DIY"

extension:loadSkillSkelsByPath("./packages/FreeKill_DIY/pkg/suzhi/skills")

Fk:loadTranslationTable{
  ["suzhi"] = "素质杀",
  }
  
  General:new(extension, "xuzhicheng", "shu", 4):addSkills { "shangzeng", "luanjuan" }
  Fk:loadTranslationTable{
    ["xuzhicheng"] = "徐志诚",
    ["#xuzhicheng"] = "危言危行",
    ["designer:xuzhicheng"] = "KidUnion",
  
    ["~xuzhicheng"] = "我……我输了……",
  }
  
  General:new(extension, "yujiajiang", "wei", 4):addSkills { "refeng", "miyan" }
  Fk:loadTranslationTable{
    ["yujiajiang"] = "喻家江",
    ["#yujiajiang"] = "老大",
    ["designer:yujiajiang"] = "KidUnion",
  
    ["~yujiajiang"] = "我……我输了……",
  }
  
  General:new(extension, "chenbaohai", "wei", 4):addSkills { "tihai" }
  Fk:loadTranslationTable{
    ["chenbaohai"] = "陈宝海",
    ["#chenbaohai"] = "海宝",
    ["designer:chenbaohai"] = "KidUnion",
  
    ["~chenbaohai"] = "我……我输了……",
  }
  
  -- General:new(extension, "zhouyunjie", "qun", 3):addSkills { "raoshe" }
  -- Fk:loadTranslationTable{
  --   ["zhouyunjie"] = "周云杰",
  --   ["#zhouyunjie"] = "黑神",
  --   ["designer:zhouyunjie"] = "KidUnion",
  
  --   ["~zhouyunjie"] = "我……我输了……",
  -- }
  
  General:new(extension, "quanzezhi", "qun", 4):addSkills { "suzhi__wangyue", "zuiquan" }
  Fk:loadTranslationTable{
    ["quanzezhi"] = "全泽之",
    ["#quanzezhi"] = "僧",
    ["designer:quanzezhi"] = "KidUnion",
  
    ["~quanzezhi"] = "我……我输了……",
  }
  
  General:new(extension, "weijiayan", "shu", 4):addSkills { "lvji", "wumian" }
  Fk:loadTranslationTable{
    ["weijiayan"] = "魏家炎",
    ["#weijiayan"] = "无眠的卷王",
    ["designer:weijiayan"] = "KidUnion",
  
    ["~weijiayan"] = "我……我输了……",
  }
  
  General:new(extension, "lubing", "wu", 3):addSkills { "lvdong", "renlun" }
  Fk:loadTranslationTable{
    ["lubing"] = "陆彬",
    ["#lubing"] = "节奏大师",
    ["designer:lubing"] = "KidUnion",

    ["~lubing"] = "我……我输了……",
  }

  General:new(extension, "niyangyin", "wei", 3):addSkills { "lunzhang", "chengyun" }
  Fk:loadTranslationTable{
    ["niyangyin"] = "倪扬英",
    ["#niyangyin"] = "NaNi",
    ["designer:niyangyin"] = "KidUnion",

    ["~niyangyin"] = "我……我输了……",
  }
  
  return extension

-- -- 周云杰
-- local zhouyunjie = General(extension, "zhouyunjie", "qun", 3)
-- local raoshe = fk.CreateTriggerSkill{
--   name = "raoshe",
--   anim_type = "offensive",
--   events = {fk.EventPhaseEnd},
--   can_trigger = function(self, event, target, player, data)
--     local num = player:getHandcardNum()
--     if num > 5 or num < 1 then return false end
--     return target == player and player:hasSkill(self) and (num == Player.Finish - player.phase) and
--     (player:getMark("raoshe1-turn") == 0 or player:getMark("raoshe2-turn") == 0)
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     if #player:getCardIds(Player.Hand) < 5 then
--       room:drawCards(player, 5 - #player:getCardIds(Player.Hand), self.name, "top", {"@@raoshe-phase", 1})
--     end
--     local discard_num = Player.Finish - player.phase
--     local all_choices = {"raoshe1", "raoshe2:::"..discard_num}
--     local choices = all_choices
--     if player:getMark("raoshe1-turn") > 0 or not player:canUse(Fk:cloneCard("fire_attack")) then
--       table.removeOne(choices, "raoshe1")
--     end
--     if player:getMark("raoshe2-turn") > 0 then
--       table.removeOne(choices, "raoshe2:::"..discard_num)
--     end
--     local choice = room:askForChoice(player, choices, self.name, "#raoshe-choose:::"..discard_num, false, all_choices)
--     if choice == "raoshe1" then
--       U.askForUseVirtualCard(room, player, "fire_attack", nil, self.name, "#raoshe-use", false)
--       local cards = table.filter(player:getCardIds(Player.Hand), function(id)
--         return Fk:getCardById(id):getMark("@@raoshe-phase") > 0
--       end)
--       if #cards > 0 then
--         room:throwCard(cards, self.name, player, player)
--       end
--       room:setPlayerMark(player, "raoshe1-turn", 1)
--     else
--       room:askForDiscard(player, discard_num, discard_num, false, self.name, false, nil, 
--       "#raoshe-discard:::"..discard_num)
--       room:setPlayerMark(player, "raoshe2-turn", 1)
--     end
--   end,
-- }
-- zhouyunjie:addSkill(raoshe)
-- Fk:loadTranslationTable{
--   ["zhouyunjie"] = "周云杰",
--   ["#zhouyunjie"] = "黑神",
--   ["designer:zhouyunjie"] = "KidUnion",
--   ["raoshe"] = "饶舌",
--   [":raoshe"] = "每回合各限一次，你的阶段结束时，若你的手牌数等于X且不为零，你可将手牌摸至五张并选择一项（X为你本回合剩余的阶段数）："..
--   "1、视为使用一张【火攻】并于结算完毕后弃置以此法获得的牌；2、弃置X张牌。",

--   ["$raoshe"] = "饶舌",
--   ["@@raoshe-phase"] = "饶舌",
--   ["#raoshe-choose"] = "饶舌：选择视为使用【火攻】或弃置%arg张牌",
--   ["raoshe1"] = "视为使用一张【火攻】",
--   ["raoshe2"] = "弃置%arg张牌",
--   ["raoshe1-turn"] = "饶舌：火攻",
--   ["raoshe2-turn"] = "饶舌：弃牌",
--   ["#raoshe-discard"] = "饶舌：弃置%arg张牌",
--   ["#raoshe-use"] = "饶舌：视为对一名角色使用一张【火攻】",

--   ["~zhouyunjie"] = "我……我输了……",
-- }

