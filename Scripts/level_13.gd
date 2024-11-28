extends Control

# Points required for each card
var card_costs = [4, 3, 3, 4]  # Example costs for the cards

# Track whether each card is selected
var selected_cards = [false, false, false, false]  # Matches the number of cards
var selected_count = 0  # Count of selected cards

# Reference to the grid container, points label, and next page button
@onready var grid_container = $GridContainer
@onready var points_label = $Backround/TextureRect/points
@onready var next_page_button = $Button

func _ready():
	# Retrieve total points from GameState
	points_label.text = str(GameState.total_points)

	# Disable the next page button initially
	next_page_button.disabled = true

	# Connect the pressed signals for each card
	for i in range(card_costs.size()):
		var card = grid_container.get_child(i)  # Get existing card
		# Connect the card's "pressed" signal
		card.connect("pressed", Callable(self, "_on_card_clicked").bind(i))

	# Connect the next page button's signal
	next_page_button.connect("pressed", Callable(self, "_on_next_page_pressed"))

# Handle card clicks
func _on_card_clicked(index: int) -> void:
	var card = grid_container.get_child(index)  # Get the clicked card

	if selected_cards[index]:  # Prevent unselecting cards
		print("Card", index, "is already selected.")
		return
	else:  # Select the card
		if GameState.total_points >= card_costs[index]:
			selected_cards[index] = true
			selected_count += 1
			GameState.total_points -= card_costs[index]  # Deduct points
			card.modulate = Color(0.5, 0.5, 0.5)  # Highlight the card visually
			print("Selected card", index, ". Points spent:", card_costs[index])
		else:
			print("Not enough points to select this card!")

	# Update points label and next page button state
	points_label.text = str(GameState.total_points)
	update_next_page_button_state()

# Update the next page button state
func update_next_page_button_state():
	# Enable the button only if exactly 2 cards are selected
	next_page_button.disabled = selected_count != 2

# Handle next page button press
func _on_next_page_pressed() -> void:
	# Ensure exactly 2 cards are selected
	if selected_count == 2:
		print("Two cards selected! Proceeding to the next page.")
		
		# Check the selected gender and load the appropriate scene
		if GameState.selected_gender == "male":
			get_tree().change_scene_to_file("res://Scenes/man_purno.tscn")  # Male scene path
		elif GameState.selected_gender == "female":
			get_tree().change_scene_to_file("res://Scenes/woman_purno.tscn")  # Female scene path
		else:
			print("No gender selected, unable to proceed!")
	else:
		print("You must select exactly two cards to proceed!")
