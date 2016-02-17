active = false -- Determines whether or not the game is active
paused = false -- Determines if the game is paused or not

-- Get the center of the screen
center_screen = Vector2(Render.Width / 2, Render.Height / 2) - Vector2(4, 4)

-- Set the pong table parameters and store some useful drawing data
pong_table_width = 600
pong_table_height = 300
pong_table_top_offset = 20
pong_table_vector = Vector2(pong_table_width, pong_table_height)
pong_table_center = Vector2((pong_table_width / 2), (pong_table_height / 2))
pong_draw_start = Vector2((Render.Width / 2) - (pong_table_width / 2), pong_table_top_offset)

-- Set the bat parameters which are based on the table parameters
-- 		Note: Has not been tested with different table sizes
ping_width = pong_table_width / 40
ping_height = pong_table_height / 5
ping_pos = (pong_table_height / 2) - (ping_height / 2)
ping_pos_opp = (pong_table_height / 2) - (ping_height / 2)
ping_increment = 3

-- Set the ball parameters which are based on the table parameters
-- 		Note: Has not been tested with different table sizes
ball_width = pong_table_width / 60
ball_height = pong_table_height / 30
ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))
ball_speed = Vector2(2, 2)
ball_speed_limit = {}
ball_speed_limit.upper = 6
ball_speed_limit.lower = -ball_speed_limit.upper

angle_modifier = 2.5

-- Set the table for holding the scores and set the score limit
scores = {0, 0}
score_limit = 3

-- Set the default CPU difficulty (how fast the CPU can move in pixels)
cpu_difficulty = 1.5

-- Set the status text and status colour, which are used when the game is paused
status_text = ""
status_colour = Color(0, 0, 0)

-- Global variable to store the last position of the mouse
mouse_last = Vector2(0, 0)

difficulty_level = {
	["woet"] = {0.5, 3.8, 2.5},
	["n00b"] = {1, 4, 2.5},
	["easy"] = {1.3, 5.5, 2.5},
	["medium"] = {1.6, 7.6, 3},
	["hard"] = {1.9, 9, 3.3},
	["extreme"] = {2.3, 11, 4.6},
	["xddd"] = {4, 16, 5.5}
}