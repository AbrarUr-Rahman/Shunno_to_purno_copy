extends Control
# Points required for each card
var card_costs = [7, 5, 4]  # Example costs for the cards

# Track whether each card is selected
var selected_cards = [false, false, false]  # Matches the number of cards
var selected_card_indices = []  # List of selected card indices

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
			selected_card_indices.append(index)
			GameState.total_points -= card_costs[index]  # Deduct points
			card.modulate = Color(0.5, 0.5, 0.5)  # Highlight the card visually
			print("Selected card", index, ". Points spent:", card_costs[index])
		else:
			print("Not enough points to select this card!")

	# Update points label and next page button state
	points_label.text = str(GameState.total_points)
	update_next_page_button_state()

# Check if all cards are selected
func all_cards_selected() -> bool:
	for selected in selected_cards:
		if not selected:
			return false
	return true

# Update the next page button state
func update_next_page_button_state():
	# Enable the button only if all cards are selected
	next_page_button.disabled = not all_cards_selected()

# Handle the next page button press
func _on_next_page_pressed() -> void:
	if all_cards_selected():
		print("All cards selected!")
		print("Points remaining:", GameState.total_points)
		print("Selected card indices:", selected_card_indices)

		# Update GameState
		var total_points_spent = 0
		for index in selected_card_indices:
			total_points_spent += card_costs[index]
			GameState.selected_card_points.append(card_costs[index])

		GameState.selected_card_indices += selected_card_indices

		# Check if enough points remain to proceed
		if GameState.total_points >= 0:
			print("Proceeding to the coin toss!")
			get_tree().change_scene_to_file("res://Scenes/coin_toss.tscn")
		#else:
			#next_page_button.disabled=false
			#if GameState.selected_gender == "male":
				#get_tree().change_scene_to_file("res://Scenes/man_fail.tscn")  # Male scene path
			#elif GameState.selected_gender == "female":
				#get_tree().change_scene_to_file("res://Scenes/woman_fail.tscn")  # Female scene path # Adjust path
	else:
		next_page_button.disabled=false
		if GameState.selected_gender == "male":
			get_tree().change_scene_to_file("res://Scenes/man_fail.tscn")  # Male scene path
		elif GameState.selected_gender == "female":
			get_tree().change_scene_to_file("res://Scenes/woman_fail.tscn")
		print("You must select all cards to proceed!")
