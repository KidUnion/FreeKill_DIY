local jianxiong = fk.CreateSkill {
  name = "yi__jianxiong",
  derived_piles = "$yi__jianxiong",
}

Fk:loadTranslationTable{
  ["yi__jianxiong"] = "奸雄",
  [":yi__jianxiong"] = "全场手牌数最多或你本回合对其发动过【护驾】的角色受到伤害后，你可观看并获得其一张手牌，"..
  "若为伤害牌，你可明置并视为对伤害来源使用之。",

  ["#yi__jianxiong-ask"] = "奸雄：你可观看并获得 %src 一张手牌",
  ["#yi__jianxiong_choose"] = "奸雄：选择获得其中一张牌",
  ["#yi__jianxiong_show"] = "奸雄：你可明置并视为对伤害来源使用之"
}

local mobileUtil = require "packages.mobile.mobile_util"

jianxiong:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(jianxiong.name) and target:getHandcardNum() ~= 0 then
      if target:getMark("@@yi__hujia-turn") > 0 then return true end
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p:getHandcardNum() > target:getHandcardNum() then
          return false
        end
      end
      return true
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = jianxiong.name,
      prompt = "#yi__jianxiong-ask:" .. target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askToChooseCard(player, {
      target = target,
      flag = { card_data = { { "$Hand", target:getCardIds("h") } } },
      skill_name = jianxiong.name,
      prompt = "#yi__jianxiong_choose"
    })
    local card = Fk:getCardById(id)
    room:obtainCard(player, card, false, fk.ReasonPrey, target, jianxiong.name)
    if card.is_damage_card then
      if room:askToSkillInvoke(player, {
        skill_name = jianxiong.name,
        prompt = "#yi__jianxiong_show"
      }) then
        mobileUtil.displayCards(player, {card})
        player:showCards(card)
        if data.from and not data.from.dead and player:canUseTo(Fk:cloneCard(card.name), 
          data.from, { bypass_times = true, bypass_distances = true, extraUse = true}) then
          room:useCard {
            from = player,
            card = Fk:cloneCard(card.name),
            tos = {data.from},
            extraUse = true
          }
        end
      end
    end
  end,
})

return jianxiong
