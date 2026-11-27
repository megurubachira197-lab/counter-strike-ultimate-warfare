extends Node
class_name RoundManager

signal round_started(round_number: int, team_cash: int)
signal round_ended(winner: String, round_number: int)
signal match_ended(winner: String)

@export var starting_cash := 800
@export var round_time := 100.0
@export var rounds_to_win := 13
var round_number := 0
var attackers_wins := 0
var defenders_wins := 0
var team_cash := 800
var time_left := 0.0
var phase := "warmup"

func start_match() -> void:
    round_number = 0
    attackers_wins = 0
    defenders_wins = 0
    team_cash = starting_cash
    start_round()

func start_round() -> void:
    round_number += 1
    time_left = round_time
    phase = "live"
    round_started.emit(round_number,team_cash)

func _process(delta: float) -> void:
    if phase != "live":
        return
    time_left = maxf(0.0,time_left-delta)
    if time_left <= 0:
        finish_round("Defenders")

func finish_round(winner: String) -> void:
    if phase != "live":
        return
    phase = "ended"
    if winner == "Attackers":
        attackers_wins += 1
        team_cash += 3250
    else:
        defenders_wins += 1
        team_cash += 3250
    round_ended.emit(winner,round_number)
    if attackers_wins >= rounds_to_win or defenders_wins >= rounds_to_win:
        match_ended.emit("Attackers" if attackers_wins > defenders_wins else "Defenders")
    else:
        await get_tree().create_timer(3.0).timeout
        start_round()

func award_kill() -> void:
    team_cash += 300

func can_afford(cost: int) -> bool:
    return team_cash >= cost

func purchase(cost: int) -> bool:
    if cost < 0 or not can_afford(cost):
        return false
    team_cash -= cost
    return true
