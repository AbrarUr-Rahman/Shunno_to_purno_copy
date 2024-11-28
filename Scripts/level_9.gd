extends Control

# Hidden point values for each card
var card_points = [5, 3, 0, 4, 5, 3, 2, 0, 5, 2, 1, 5]

# Tracks whether each card is selected
var selected_cards = [false, false, false, false, false, false, false, false, false, false, false, false]
var selected_card_indices = []  # Indices of selected cards

# Number of cards that need to be selected
const REQUIRED_SELECTION = 5
var selected_count = 0  # Current count of selected cards

# Reference nodes
@onready var grid_container = $GridContainer
@onready var next_button = $Button
#@onready var points_label = $PointsLabel  # Optional, to display total points

func _ready():
	# Connect card signals and initialize UI
	for i in range(card_points.size()):
		var card = grid_container.get_child(i)
		card.connect("pressed", Callable(self, "_on_card_clicked").bind(i))

	# Initially disable the next page button
	update_next_page_button_state()

	# Connect the "Next Page" button to its handler
	next_button.connect("pressed", Callable(self, "_on_next_page_pressed"))

	## Optional: Initialize points label
	#points_label.text = str(GameState.total_points)

# Handles card click events
func _on_card_clicked(card_index: int) -> void:
	var card = grid_container.get_child(card_index)

	if selected_cards[card_index]:
		# Deselect the card
		selected_cards[card_index] = false
		selected_count -= 1
		selected_card_indices.erase(card_index)
		card.modulate = Color(1, 1, 1, 1)  # Reset appearance
	else:
		# Select the card if within the limit
		if selected_count < REQUIRED_SELECTION:
			selected_cards[card_index] = true
			selected_count += 1
			selected_card_indices.append(card_index)
			card.modulate = Color(0.5, 0.5, 0.5)  # Highlight the card
		else:
			print("You can only select", REQUIRED_SELECTION, "cards!")

	print("Selected cards count:", selected_count)
	print("Selected card indices:", selected_card_indices)

	# Update the next page button state
	update_next_page_button_state()

# Update the next page button state
func update_next_page_button_state():
	next_button.disabled = selected_count != REQUIRED_SELECTION

# Handles "Next Page" button press
func _on_next_page_pressed() -> void:
	if selected_count == REQUIRED_SELECTION:
		print("Proceeding to the next page with selected cards!")

		# Calculate total points from selected cards
		var selected_points = []
		var total_points = GameState.total_points
		for index in selected_card_indices:
			selected_points.append(card_points[index])
			total_points += card_points[index]

		# Update GameState with the selected data
		GameState.selected_card_indices = selected_card_indices
		GameState.selected_card_points = selected_points
		GameState.total_points = total_points

		print("Selected card indices:", selected_card_indices)
		print("Selected card points:", selected_points)
		print("Total points collected:", total_points)

		## Optional: Update points label
		#points_label.text = str(GameState.total_points)

		# Proceed to the next scene
		get_tree().change_scene_to_file("res://Scenes/level_11.tscn")  # Adjust the path
	else:
		print("You must select exactly", REQUIRED_SELECTION, "cards to proceed!")
