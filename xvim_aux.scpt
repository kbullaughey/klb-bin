#!/usr/bin/osascript
on run argv
	tell application "iTerm"
		activate
		set myterm to (make new terminal)
		tell myterm
			set mysession to (make new session at the end of sessions)
			tell mysession
            exec command "bash"
            set name to item 2 of argv
            write text "cd " & item 1 of argv
            write text "vim " & item 2 of argv & "; exit"
			end tell
		end tell
	end tell
end run
