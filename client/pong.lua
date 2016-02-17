-- Function is called whenever a user sends input (i.e presses a button which equates to JC2 action)
function LocalPlayerInput(args)
	-- Make sure the game is active and the user is sending input
	if active and args.state ~= 0 then
		-- Check if the user is using any of the mouse look actions
		if args.input == Action.LookUp or args.input == Action.LookDown or args.input == Action.LookLeft or args.input == Action.LookRight then
			return false -- Return false so the camera won't move
		end
	end
end

-- Function is called whenever the client ticks (i.e A LOT)
function ClientTick(args)
	-- Don't run the game mechanics unless we're active and NOT paused
	if active and not paused then
		HandleBallData(args)
		HandleCPU(args)
	end
end

-- Function takes care of the CPU's artifical intelligence, currently a very
-- simple implementation.
function HandleCPU(args)
	-- We check if the ball position is greater than the top of the CPU's bat
	if ball_pos.y > ping_pos_opp + (ping_height / 2) and (ping_pos_opp + ping_height) < pong_table_height then 
		-- It is, so increment the CPU bat based on the difficulty set
		ping_pos_opp = ping_pos_opp + cpu_difficulty
	elseif ball_pos.y < ping_pos_opp + (ping_height / 2) and ping_pos_opp > 0 then
		-- Otherwise we check if the ball position is greater than the bottom of the CPU's bat and then
		-- decrement the bat's position
		ping_pos_opp = ping_pos_opp - cpu_difficulty 
	end
end

-- Function will set status text to be displayed when the game is paused
function DrawStatus(text, colour)
	status_text = text
	status_colour = colour
end

-- Function calculates the y angle of the ball based on some voodoo
function CalculateBallAngle(ball_y, ping_y)
	-- Okay so it's not voodoo but it is strange. Here is a step by step explanation:
	-- 		Goal: We want a negative value if the ball hits the top of the bat and a
	--			  positive value if the ball hits the bottom of the bat. The middle
	--			  should be 0.
	--
	--		1. Get the height of the bat and divide it by 2 to get the distance from the top to the center
	--		2. Get the current position of the bat and add on half of the height which gives us current center location
	-- 		3. Subtract the ball position from the previously calculated value to get the difference
	--		4. Now the difference will be quite large, so we need to scale it down, divide by 40
	--		5. Now it has been scaled down to be between -1 and 1, multiply that by the angle_modifier to amplify it to a nice y axis speed
	--		6. Hope for good results :)
	return (((ball_y + (ball_height / 2)) - (ping_y + (ping_height / 2))) / 40) * angle_modifier
end

-- This lengthy function handles the ball collisions with the walls and the bats
function HandleBallData(args)
	-- This horrifying if statement will check if there was a collision with the CPU's bat
	if (ball_pos.x) >= (pong_table_width - ping_width - 20) and (ball_pos.y + ball_height) >= ping_pos_opp and ball_pos.y <= (ping_pos_opp + ping_height) then -- there was a CPU collision
		-- Reverse the ball on the x axis as it was hit by the CPU's bat
		ball_speed.x = -ball_speed.x
		
		-- If the speed limit has not been reached, then increase (decrement in this case) the speed of the ball.
		--		Bonus Note: I originally forgot to reverse the ball if it had NOT reached the speed limit, this caused major issues!
		if ball_speed.x > ball_speed_limit.lower then ball_speed.x = ball_speed.x - 1 end

		if ball_speed.x < ball_speed_limit.lower then ball_speed.x = ball_speed_limit.lower end
		
		-- Calculate the ball y axis speed and set it
		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos_opp)
		
		-- Check if the ball is gone past the bat (as it may be stepping past it, it will cause issues later if it is not fixed)
		if (ball_pos.x) > (pong_table_width - ping_width - 20) then 
			-- Put it back in front of the bat
			ball_pos.x = pong_table_width - ping_width - 20
		end
	elseif ball_pos.x <= ping_width + 10 and (ball_pos.y + ball_height) >= ping_pos and ball_pos.y <= (ping_pos + ping_height) then -- there was a player collision
		-- This section is the same as the CPU's bat handling for the most part
		ball_speed.x = -ball_speed.x

		if ball_speed.x < ball_speed_limit.upper then ball_speed.x = ball_speed.x + 1 end

		if ball_speed.x > ball_speed_limit.upper then ball_speed.x = ball_speed_limit.upper end
		
		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos)
		
		if ball_pos.x < ping_width + 10 then ball_pos.x = ping_width + 10 end
	end

	-- Check if the ball went outside of the y boundaries, if so, reverse the ball's speed on the y axis
	if (ball_pos.y + ball_height + ball_speed.y) > pong_table_height or ball_pos.y < 0 then ball_speed.y = -ball_speed.y end
	
	-- Increment the ball on the x and y axis by the ball's x and y axis speed (i.e pixels it jumps)
	ball_pos.x = ball_pos.x + ball_speed.x
	ball_pos.y = ball_pos.y + ball_speed.y

	-- Check if the ball went passed the x boundaries, this means someone missed depending on which boundary it went passed
	if ball_pos.x <= 0 then -- You miss
	
		-- Reset the ball speed and increment the CPU's score
		ball_speed.x = 2
		ball_speed.y = 0
		scores[2] = scores[2] + 1
		
		-- Reset the ball to the center of the pong table
		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))
		
		-- Check if the CPU has reached the score limit
		if scores[2] == score_limit then 
			-- Inform them of their loss and pause the game
			DrawStatus("You lose!", Color(255, 0, 0))
			paused = true
		end
	elseif ball_pos.x + ball_width >= pong_table_width then -- CPU misses
	
		-- Reset the ball speed and increment the user's score
		ball_speed.x = -2
		ball_speed.y = 0
		scores[1] = scores[1] + 1
		
		-- Reset the ball to the center of the pong table
		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))
		
		-- Check if the player has reached the score limit
		if scores[1] == score_limit then 
			-- Inform them of their victory and pause the game
			DrawStatus("You win!", Color(0, 255, 0))
			paused = true
		end
	end
end

-- This function handles mouse movement and converts it to bat movement
function MouseMove(args)
	if active then
		if args.position.y >= mouse_last.y and (ping_pos + ping_height) < pong_table_height then
			ping_pos = ping_pos + (args.position.y - mouse_last.y)
			
			if (ping_pos + ping_height) + (args.position.y - mouse_last.y) > pong_table_height then ping_pos = (pong_table_height - ping_height) end
		elseif args.position.y <= mouse_last.y and ping_pos > 0 then
			ping_pos = ping_pos - (mouse_last.y - args.position.y)
			
			if ping_pos - (mouse_last.y - args.position.y) < 0 then ping_pos = 0 end
		end
		mouse_last.y = args.position.y
	end
end

-- This handles the Render event.
function RenderEvent(args)
	-- Check if the game is active
	if active then
		-- Do the bunch of crazy wild renders :D (Displaying the GUI of the game to the player)
		Render:FillArea(pong_draw_start, Vector2(pong_table_width, pong_table_height), Color(0, 0, 0))	
		Render:FillArea(pong_draw_start + Vector2(10, ping_pos), Vector2(ping_width, ping_height), Color(255, 255, 255))
		Render:FillArea(pong_draw_start + Vector2(pong_table_width - ping_width - 10, ping_pos_opp), Vector2(ping_width, ping_height), Color(255, 255, 255))
		Render:FillArea(pong_draw_start + ball_pos, Vector2(ball_width, ball_height), Color(255, 255, 255))
		
		Render:DrawText(pong_draw_start + Vector2(0, pong_table_height), "You: "..scores[1], Color(255, 255, 255))
		Render:DrawText(pong_draw_start + Vector2(pong_table_width - 70, pong_table_height), "CPU: "..scores[2], Color(255, 255, 255))
		Render:DrawText(pong_draw_start + Vector2(pong_table_width / 2 - 75, pong_table_height), "Score Limit: "..score_limit, Color(255, 255, 255))
		
		Render:DrawText(pong_draw_start + Vector2(pong_table_width / 2 - 290, pong_table_height + 50), "Instructions: Use mouse to move your bat and type \"/pong quit\" to leave", Color(255, 0, 0), 18)
		
		-- If the game is paused it means it's over (or maybe paused if that was added) so display the status text
		if paused then
			Render:DrawText(pong_draw_start + pong_table_center + Vector2(Render:GetTextWidth(status_text, TextSize.Huge) * -0.5, Render:GetTextHeight(status_text, TextSize.Huge) * -0.5), status_text, status_colour, TextSize.Huge)
		end
	end
end

-- Function is called when the player writes something into chat
function PlayerChat(args)
	local player = LocalPlayer
    local msg = args.text

	-- We only want /commands.
	if string.sub(msg , 1 , 1) ~= "/" then
		return true
	end

	-- Split the message up into parameters (by spaces).
	local params = {}
    for param in string.gmatch(msg, "[^%s]+") do
        table.insert(params, param)
    end

	-- Check if the user wrote /pong
	if params[1] == "/pong" then
		if params[2] and params[2] == "quit" then
			active = false
			return false
		end

		if not params[2] then
			Chat:Print("[USAGE]: /pong difficulty", Color(224, 112, 0))
			Chat:Print("[USAGE]: Difficulties: Easy, Medium, Hard, Extreme", Color(224, 112, 0))
			return false
		end

		params[2] = params[2]:lower()

		if not difficulty_level[params[2]] then Chat:Print("Invalid difficulty", Color(255, 0, 0)) return false end

		cpu_difficulty = difficulty_level[params[2]][1]
		angle_modifier = difficulty_level[params[2]][3]
		ball_speed_limit.upper = difficulty_level[params[2]][2]
		ball_speed_limit.lower = -ball_speed_limit.upper
	
		-- He did, so start the game or else reset it
		active = true -- Enable the game
		paused = false -- Make sure it's not paused
		scores = {0, 0} -- Reset the scores
		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2)) -- Put the ball back in the middle of the game
		ball_speed.x = 2 -- Set the speed back to a decent amount
		ball_speed.y = 0
		return false
	end
end

-- Subscribe to events so we can handle these events in Lua
Events:Subscribe("MouseMove", MouseMove)
Events:Subscribe("LocalPlayerInput", LocalPlayerInput)
Events:Subscribe("Render", RenderEvent)
Events:Subscribe("PreTick", ClientTick)
Events:Subscribe("LocalPlayerChat", PlayerChat)