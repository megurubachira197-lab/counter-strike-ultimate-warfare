extends Node
class_name MatchStats

var kills := 0
var deaths := 0
var assists := 0
var headshots := 0
var damage_dealt := 0
var rounds_won := 0
var rounds_lost := 0

func record_kill(headshot: bool = false) -> void:
    kills += 1
    if headshot:
        headshots += 1

func record_death() -> void:
    deaths += 1

func record_damage(amount: int) -> void:
    damage_dealt += maxi(0,amount)

func reset_match() -> void:
    kills = 0
    deaths = 0
    assists = 0
    headshots = 0
    damage_dealt = 0
    rounds_won = 0
    rounds_lost = 0

func get_kd_ratio() -> float:
    return float(kills) / maxf(1.0,float(deaths))
