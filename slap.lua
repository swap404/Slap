Tab = {
	-- "Botname" ["" = hub bot]
	Bot = "Mechazawa",
	-- Register Bot? [show on user list] true/false
	BotReg = true,
	-- "Description for Bot" ["" = Script Name]
	BotDesc = "",
	-- Email Address for Bot ["" = None]
	BotMail = "",
	-- Should Bot have a key? true/false
	BotKey = true,
	--"Command Menu" ["" = hub name]
	Menu = "",
	--"Command SubMenu" ["" = script name]
	SubMenu = "",
	-- Admins nick for status / error messages, Set this to your nick
	OpNick = "ashaman",
	-- Message file path/name
	File = "test.dat",
}
 
 
OnStartup = function()
	-- Set another variable to the table above, a name for the script
	Tab.Scp = "Slap 1.0"
	-- If this string from the table above is emtpy, we will set the script bot's name to that of the hub bot
	if Tab.Bot == "" then Tab.Bot = SetMan.GetString(21) end
	-- If this string from the table above is emtpy, we will set the script bot's description to script's name
	if Tab.BotDesc == "" then Tab.BotDesc = Tab.Scp end
	-- Should we register the bot?
	if Tab.BotReg then
		-- The value from the configuration table is true.
		-- If the botname is not equal to the hub bot's name let's reg the bot, using the parameters from the table
		if Tab.Bot ~= SetMan.GetString(21) then Core.RegBot(Tab.Bot,Tab.BotDesc,Tab.BotMail,Tab.BotKey) end
	end
	-- Given the changes to the path call and the porting to other OS's...
	-- When working with saving data to file let's ensure we have the correct and absolute path.
	-- I want to save to the script directory, so I'll set the Path variable to the root of Ptokax and ammend "scripts/"
	local Path = Core.GetPtokaXPath().."scripts/"
	-- Now to check if the path to file is complete, if not set it as such
	if not Tab.File:find("^"..Path,1,true) then Tab.File = Path..Tab.File end
	-- Is the code executable? [table, or Lua code etc.] We can use the loadfile statement for check this.
	-- If it is we will load it, if not we will use the OnError function to fire an error message
	if loadfile(Tab.File) then dofile(Tab.File) else OnError(Tab.File.." could not be loaded.") end
	-- Do we need a timer in this script? For example sake, we do :P
	-- Add a timer with a given interval in ms. [3000 = 3 seconds] An Id is returned from this function.
	-- The global Tmr var is assigend that Id. Written as such the timer will call the OnTimer function at interval
    math.randomseed(os.time())
end
 
-- Script errors shall be sent to this function. We can also call it 'manually'.
OnError = function(msg)
	-- We intend to send these messages to the OpNick listed in the table above.
	-- It would be foolish to try and send the message if the OpNick is offline, let's check first.
	local user = Core.GetUser(Tab.OpNick)
	-- If OpNick is online, send the message...
	if user then Core.SendToUser(user,"<"..Tab.Bot.."> "..msg.."|") end
end
 
function trim1(s)
      return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function parseCommand(s)
    k = 1
    for i = 1, #s do
        local c = s:sub(i,i)
        if c == ' ' then
            return trim1(string.sub(s,0,k))
        end
        k = k + 1
    end 
    return trim1(string.sub(s,0,-2))
end

function parseParam(s)
   k = 1
   for i = 1, #s do
       local c = s:sub(i,i)
       if c == ' ' then
           break;
       end
       k = k + 1
   end
   return trim1(string.sub(s,k,-2))
end

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function execCommand(user, command, param)
    RegMan.Save()
    output = "Unknown command"
    command = command:lower()
    if command == "slap" then
        output = "*" .. user .. " slaps " .. param .. " with a large trout"
    elseif command == "poke" then
        output = "*" .. user .. " pokes " .. param .. " on the nose" 
    elseif command == "d10" or command == "t10" then
        num = math.random(10)
        output = "<Mechazawa> " .. user .. ": " .. num
    elseif command == "d6" or command == "t6" then
        num = math.random(6)
        output = "<Mechazawa> " .. user .. ": " .. num
    elseif command == "hug" then
        output = "*" .. user .. " gives " .. param .. " a warm hug"
    elseif command == "8ball" then
        local question = param        
        local answers = { 'It is certain', 'It is decidedly so', 'Without a doubt', 'Yes – definitely', 'You may rely on it', 'As I see it, yes', 'Most likely', 'Outlook good', 'Yes', 'Signs point to yes', 'Reply hazy, try again', 'Ask again later', 'Better not tell you now', 'Cannot predict now', 'Concentrate and ask again', 'Don\'t count on it', 'My reply is no', 'My sources say no', 'Outlook not so good', 'Very doubtful' }
        answer = question .. "? " .. ( answers[ math.random(#answers) ] )
        output = "<Mechazawa> " .. answer
    elseif command == "spin" then
        local list = Core.GetOnlineUsers();
        local nicks = {}
        local index = 1;
        for i,value in ipairs(list) do
            nicks[index] = value["sNick"];
            index = index + 1;
        end
        output = "<Mechazawa> "..param.."? " .. nicks[math.random(#nicks)];
    elseif command == "fortune" then
        output = "<Mechazawa> " .. os.capture("ruby /opt/ptokax/fortune.rb")
    end
    if output == "Unknown command" then
	    return false
    else
        Core.SendToAll(output)
        return true
    end
end

ChatArrival = function(user,data)
    k = 1
    for i = 1, #data do
            local c = data:sub(i,i)
             if c == '>' then 
                break      
             end
             k = k + 1
    end   
    user = trim1(string.sub(data,2,k-1))
    message = trim1(string.sub(data,k+1))
    if message:sub(1,1) == '!' or message:sub(1,1) == '+' then
        command = parseCommand(string.sub(message,2))
        param = parseParam(string.sub(message,2))
        return execCommand(user,command, param)
    end    
end
