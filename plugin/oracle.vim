""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File: oracle.vim
" Purpose: Oracle SQL*Plus Plugin
" Author: Rajesh Kallingal <RajeshKallingal@email.com>
" Version: 6.0.4
" Last Modified: Tue Feb 05 11:14:08 2002
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Description:
" This file contains functions/menus/commands/abbreviations to make Vim an
" Oracle SQL*Plus IDE.
" Here are the main highlights of this script:
"
" 	- SqlMake(): lets you open any stored procedure and compile from within vim.
" 				 Will display and optionally highlight the errors, navigate
" 				 thru errors in the quickfix mode.
" 	
" 	- Adds a SQL*Plus menu
" 	
" 	- SqlPlus(): lets you start an external SQL*Plus, execute the whole file
" 				 contents in SQL*Plus and return the results back in the same
" 				 buffer, or select a portion of the buffer, execute it and
" 				 display the results in a new buffer.
" 	
" 	- GetSource(): get the stored procedure code from the database
"
" 	- Abbreviations: lot of abbreviations to make coding in PL/SQL a breeze,
" 					 all accessible thru menu as well
"
" Mappings:
" 
"	<Leader>c	Select Database dialog
"	<Leader>C	Get column names for the tablename under cursor
"	<Leader>F	Stored procedure code from DB for the function/procedure name
"				under cursor
"	<Leader>i	Find Invalid Objects
"	CTRL+S 		Start SQL*Plus window (external)
"	<Leader>r	Execute current file in SQL*Plus window (external)
"	<Leader>s	Execute current file in SQL*Plus and get the result to same
"				buffer
"	<Leader>s	Execute current selection in SQL*Plus and get the result to a
"				new window
"
" QuickFix mode mappings
"	Alt-M		Make/Compile the script and enter quickfix mode
"	Alt-Up/Down	Go to next/previous error
"	Alt-A		List all the errors
"	Alt-C		List current error
"	Alt-O		Open error window
"
"
" Following mappings from ftplugin sql.vim
"	<C-D>			Describe the object under cursor
"	<LocalLeader>d	make a dbms_output.put_line statement for word/selection
"					below current line
"	<LocalLeader>D	make a dbms_output.put_line statement for word/selection
"					above current line
"
" 	
" 	
" 
" Optional files:
"	sql.vim	- sql filetype plugin load to your ftplugin folders. This file is
"			  needed for Abbreviations and some mappings
"
" Note:
" 	I have tested this only under gvim6.0 on Win2000 and Oracle 8.1.5. I do
" 	not have any other platform to test these.
"
" Installation:
" 	Just drop it this file in your plugin folder/directory
"
" Installation:
" 	Just drop it this file in your plugin folder/directory. To get some of the
" 	additional features you have to download the ftplugin sql.vim and put that
" 	in the ftplugin folder/directory
"
"TODO
"	- add more SQL*Plus commmands
"	- replace normal commands
"
" vim:ts=4:sw=4:tw=75
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Do not load, if already been loaded
if exists("loaded_sqlrc")
  finish
endif

let loaded_sqlrc=1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Variables
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" following are the default values for the variables used to connect to an
" Oracle instance. you can change these variables to connect to a different
" instance or as a different user. use :CC command to change the connection
" variables. The value will be remembered for the future sessions based on the
" value of s:save_settings

let s:sqlcmd='sqlplus '	" executable name of SQL*Plus (non GUI version), if sqlplus is not in the PATH, use the complete path to sqlplus. Make sure you insert a space before the ending quote (')
let s:user=''	" Default Oracle user name
let s:password=''	" Default Oracle password
let s:server=''	" Default Oracle server to use
let g:dateformat="'YYYYMMDD HH24MI'"	" Default date format to use
let s:do_highlight_errors=1 " set this variable to 1 to highlight errors after compiling, set to 0 to turn it off
let s:save_settings=1	"set this variable to 1 if you want the session info saved for next Vim session.



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! SqlMake call SqlMake ()
command! CC call ChangeConnection ()
command! -range=% Sql call SqlPlus ()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! ORAInitialize()
	" This function initializes variables from the previous session if
	" available.
	
	if s:save_settings != 1
		" don't load connection info from the previous session
		let s:connect_string = s:user . '/' . s:password . '@' .  s:server
		return
	endif

	if exists('g:SQLCMD')
		let s:sqlcmd = g:SQLCMD
	endif

	if exists('g:USER')
		" Oracle user name
		let s:user = g:USER
	endif
	if exists('g:PASSWORD')
		" Oracle user password
		let s:password = g:PASSWORD
	endif
	if exists('g:SERVER')
		" Oracle server name
		let s:server = g:SERVER
	endif

	let s:connect_string = s:user . '/' . s:password . '@' .  s:server

"	let g:dateformat="'YYYYMMDD HH24MI'"	" Default date format to use

	if exists('g:DO_HIGHLIGHT_ERRORS')
		let s:do_highlight_errors = g:DO_HIGHLIGHT_ERRORS
	endif

endfunction




function! CheckModified ()
	"check the file is modified
	if &modified
		let l:choice = confirm ("Do you want to save changes before continuing?", "&Yes\n&No\n&Cancel", 1, "Question")
		if l:choice == 1
			write
		elseif l:choice == 2
			"nothing to do
		else
			return -1
		endif
	endif
endfunction





function! CheckConnection ()
	" Check to ensure the connection details are defined in the global
	" variables
	if exists ("s:user") == 0 || exists ("s:password") == 0 || exists ("s:server") == 0 || s:user == "" || s:password == "" || s:server == ""
		call ChangeConnection ()
	endif
	" if the variables are still not set return error
	if exists ("s:user") == 0 || exists ("s:password") == 0 || exists ("s:server") == 0 || s:user == "" || s:password == "" || s:server == ""
		echohl ErrorMsg
		echo "Invalid connection information"
		echohl None
		return -1
	else
		return 0
	endif
endfunction




function! ChangeConnection ()
	" Prompt user for all the connection information to Oracle
	exec 'let l:user = input ("Enter userid [' . s:user . ']: ")'
	exec 'let l:password = inputsecret ("Enter Password [' . substitute (s:password, '.', '*', 'g') . ']: ")'
	exec 'let l:server = input ("Enter Server [' . s:server . ']: ")'
	if l:user != ""
		let s:user = l:user
	endif
	if l:password != ""
		let s:password = l:password
	endif
	if l:server != ""
		let s:server = l:server
	endif

	let s:connect_string = s:user . '/' . s:password . '@' .  s:server

endfunction


function! DescribeObject ()
	if CheckConnection () != 0
		return
	endif

	" create a new buffer with server:user:object.sql name and delete all the
	" texts
	let l:object = @"
	silent execute 'new ' . s:server . ':' . s:user . ':' . l:object . '.sql'
	1,$delete	" empty the buffer

	" create the SQL statements for describe and execute
	call append (0, "prompt " . l:object)
	call append (1, "desc " . l:object )
	1,$call SqlPlus()

	"delete the SQL> prompts
	normal dW+df 
	setlocal ts=8 nomodified

endfunction



function! GetColumn ()
" Get column names for the tablename under cursor. This will delete the
" current line. So make sure you have just the table name in the current line
	if CheckConnection () != 0
		return
	endif

	normal yiw
	let l:object = @"
	silent execute 'new '
	call append (0, "Desc " . l:object . "")

	%call SqlPlus()

	" remove the first 2 and last lines
	silent delete 2
	silent $delete

	let old_search=@/
	" replace everything after column with comma ","
	%s/ \(\S\+\)\s.*/\1,/
	" remove the comma from last line
	s/,//
	let @/=old_search
	unlet old_search

	" yank everything
	normal yap
	bdelete!
	normal ]pkdd

endfunction



function! GetSource ()
	" Get the source of the function/procedure under the cursor
	if CheckConnection () != 0
		return
	endif

	normal yiw
	let l:object = @"
	silent execute 'new ' . s:server . ':' . s:user . ':' . l:object . '.sql'
	call append (0, "Upper ('" . l:object . "');")
	call append (0, 'select text from user_source where name = ')
	call append (0, 'set pagesize 0')

	%call SqlPlus()

	" now remove the unwanted SQL*Plus prompts and add some SQL verbs
	normal 3dW
	call append (0, "CREATE OR REPLACE ")
	1join

	$-2,$delete
	call append ("$", "/")
	1
	setlocal nomodified

endfunction



function! SelectDatabase ()
"funtion to quickly change to your predefined database connections
	" Menu showing available databse connections
	let l:old_guioptions = &guioptions
	set guioptions+=v
	let l:choice = confirm("Select the Database Instance", "DataMart (&Prod)\nDataMart (&Dev)\n&Warehouse (Prod)\n&ODS (Prod)\nO&ther...\n&Cancel", 1, "Question")
	let &guioptions=l:old_guioptions
	if l:choice == 0
		return
	elseif l:choice == 1
		let s:user = 'username'
		let s:password = 'password'
		let s:server = 'edmprod'
		let s:connect_string = s:user . '/' . s:password . '@' .  s:server
	elseif l:choice == 2
		let s:user = 'username'
		let s:password = 'password'
		let s:server = 'edmdevl'
		let s:connect_string = s:user . '/' . s:password . '@' .  s:server
	elseif l:choice == 3
		let s:user = 'username'
		let s:password = 'password'
		let s:server = 'edwprod'
		let s:connect_string = s:user . '/' . s:password . '@' .  s:server
	elseif l:choice == 4
		let s:user = 'username'
		let s:password = 'password'
		let s:server = 'eodsprod'
		let s:connect_string = s:user . '/' . s:password . '@' .  s:server
	elseif l:choice == 5
		call ChangeConnection ()
	else
		return
	endif
endfunction



function! SqlPlus (...) range
" this function lets you 
" 	- start SQL*Plus
" 	- execute the contents of the current buffer and show the results back in
" 	the same buffer
" 	- execute the selected lines from the current buffer and show results in a
" 	new buffer

	if CheckConnection () != 0
		return
	endif

	"echo a:0
	if a:0 > 0 
		if a:1 == "@"
			" run the 2nd parameter as a file

			"check the file is modified
			if CheckModified () == -1
				return
			endif
			silent execute '!' . s:sqlcmd . ' ' . s:connect_string . ' @' . a:2
		else
			" just start SQL*Plus
			silent execute '!start ' . s:sqlcmd . s:connect_string
		endif
	else
		" Execute the range and display the result in buffer
		"echo a:firstline "," a:lastline
		silent execute a:firstline ',' a:lastline '!' . s:sqlcmd . ' ' . s:connect_string

		let l:old_search = @/
		" this is for standard SQLPROMPT
		silent execute '/SQL>'
		" use the following search for user@server> SQLPROMPT
		"silent execute "/" . s:user . '@' . s:server . ' >'
		" remove the unwanted SQL*Plus details from top & bottom
		silent execute "normal kVggdGNdGgg"
		"silent execute "g/" . s:user . '@' . s:server . ' >/d'
		let @/ = l:old_search
		setlocal ts=8 nomodified
	endif
endfunction


function! InvalidObjects (Option)
	if CheckConnection () != 0
		return
	endif
	silent execute 'new ' . s:server . ':' . s:user . ':invalid_objects.sql'
	if a:Option == "C" || a:Option == "c"
		"TODO
		"echo "Compile Invalid Objects"
"		normal ggVGsset serveroutput on size 1000000exec dbms_output.put_line ( re_compile )\s
	else
		"echo "List Invalid Objects"
		normal ggVGsselect object_type, object_name from all_objects where status = 'INVALID';\s
	endif
endfunction



function! SqlMake ()
" Assumes that the stored procedure code starts with "^create or replace..."
" at the beginning of the line
"
" Change the following settings (done in sql.vim ftplugin):
" To use multiline error format of SQL*Plus
" 	set efm=%E%l/%c%m,%C%m,%Z

	"check the file is modified
	if CheckModified () == -1
		return
	endif

	if CheckConnection () != 0
		return
	endif
"	close the error window, in case its open
	cclose
	redraw

"	File Names used in this function
	let l:alt_buf = buffer_number("#")
	let l:cur_buf = buffer_number("%")
	let l:ef_save	= &errorfile
	let &errorfile = $TEMP . "/sqlmake.err"
	let l:sqlfile = $TEMP . "/sqltmp.sql"

"	delete the old errorfile
	if filereadable (&errorfile)
		call delete (&errorfile)
	endif

"	Copy the source file to a temporary SQL file and added SQL commands to
"	show the error messages and to exit SQL*Plus after compilation is
"	finished
	exec 'silent write! ' . l:sqlfile
	exec 'silent edit ' . l:sqlfile
	let l:tmp_buf = buffer_number("%")

	" add show error at the end of SQL file
	call append ("$", "set pagesize 0")
	call append ("$", "show error")

	" add EXIT at the end of SQL file
	call append ("$", "EXIT")
	silent write

" compile the l:sqlfile in SQL*Plus
"	let l:connect_string = s:user . '/' . s:password . '@' . s:server
	let l:command = s:sqlcmd . s:connect_string . " @" .  l:sqlfile
"echo l:command
	echohl MoreMsg
	echo "Compiling..."
	echohl None
	let l:sqlout = system (l:command)
"TODO check for v:shell_error

	let l:error_exists = FormatErrorMessage (l:sqlout)

" delete the temporary SQL file and buffer
	exec 'silent bwipeout! ' . l:tmp_buf
	silent call delete ( l:sqlfile )

"	buffer # " now we are back in the original buffer
"	bdelete # "delete the temporary buffer

	" go to the original alternate buffer
"	execute 'silent buffer ' . l:alt_buf
	execute 'silent buffer ' . l:cur_buf
"	buffer # " now we are back in the original buffer

	" if vih has +signs then use signs else put special character ("--ERR--")
	" for highlighting on the error lines if this is used an autocmd event for
	" BufWritePre will remove all these error marks/signs
	if l:error_exists != 0 && exists ("s:do_highlight_errors") && s:do_highlight_errors == 1
		" save the modified status
		let l:mod_flag = &modified
		let l:error_lines = s:sqlErrLines " this variable is set in FormatErrorMessage() function
		" if its a vim with +sings then use signs else use --ERR-- to
		" mark and highlight error lines
		if has ("signs")
			let l:sign_count = 0
			while strlen (l:error_lines) > 1
				let l:line_num = matchstr (l:error_lines, '[0-9]\+')
	"echo 'l:line_num : ' l:line_num 
				if l:line_num != ""
					let l:sign_count = l:sign_count + 1
					execute 'sign place ' . l:sign_count . ' line=' . l:line_num . ' name=SQLMakeError buffer=' . l:cur_buf
				endif
				let l:error_lines = strpart (l:error_lines, strlen (l:line_num) + 1, 99999999)
			endwhile
		else
			while strlen (l:error_lines) > 1
				let l:line_num = matchstr (l:error_lines, '[0-9]\+')
	"echo 'l:line_num : ' l:line_num 
				if l:line_num != ""
					let l:line_text = getline (l:line_num) . " --ERR--"
					call setline (l:line_num, l:line_text)
				endif
				let l:error_lines = strpart (l:error_lines, strlen (l:line_num) + 1, 99999999)
			endwhile
		endif
		let &modified = l:mod_flag
	endif

	" load the errors, if any
	cfile
	if l:error_exists != 0
		copen
		norm 
"	else
"		echohl MoreMsg
"		echo "No Errors"
"		echohl None
	endif
	let &errorfile = l:ef_save
	norm 
endfunction



function! FormatErrorMessage (sqloutput)
" Map error line numbers to correct line number in the file, as SQL*Plus
" removes all blank lines from compiled code and lines numbers are changed
" accordingly
	
	let l:errmsgs = a:sqloutput

	" remove the headings
	" wher there are errors
	let l:match_pos = match (l:errmsgs,'[0-9]\+/[0-9]\+\t')
	let l:errmsgs = strpart (l:errmsgs, l:match_pos, 99999999) 
"	echo 'l:errmsgs : ' strlen (l:errmsgs)

	" wher there are no errors
	let l:match_pos = matchend (l:errmsgs,'No errors\.')
	let l:errmsgs = strpart (l:errmsgs, l:match_pos, 99999999) 
"	echo 'l:errmsgs : ' strlen (l:errmsgs)

	" remove the footers
	let l:match_pos = match (l:errmsgs, 'Disconnected from Oracle')
	let l:errmsgs = strpart (l:errmsgs, 0, l:match_pos - 1) 
"	echo 'l:errmsgs : ' strlen (l:errmsgs)

"let g:sqloutorg = l:errmsgs


	if ( strlen ( l:errmsgs ) <= 0)
		" create empty error file
		exec 'redir > ' . &errorfile
		redir end

"		echohl ErrorMsg
"		echo 'No Errors.'
"		echohl None
		return 0
	else
		" find the first line of code (starting with "create or replace")
		let l:total_lines = line("$")
		let l:current_line = 1
		while (l:current_line <= l:total_lines)
			let l:line = getline (l:current_line)
			if (l:line =~? '^create\s\+or\s\+replace')
				break
			else
				let l:current_line = l:current_line + 1
			endif
		endwhile
		let l:comments_count = l:current_line - 1

		" map the linenumbers
		let l:new_errmsg = ''
		let s:sqlErrLines = '' " use a script variable to return the formatted error message
		while strlen (l:errmsgs)
			" first get the line/col part of the current message
			let l:match_pos = matchend (l:errmsgs,'[0-9]\+\/[0-9]\+\t')
			let l:curr_msg = strpart (l:errmsgs, 0, l:match_pos)

			" now get the rest of message upto next line/col or the left out
			let l:errmsgs = strpart (l:errmsgs, l:match_pos + 1, 99999999)
			let l:match_pos = match (l:errmsgs,'[0-9]\+\/[0-9]\+\t')
"echo 'l:match_pos : ' l:match_pos 
			if l:match_pos > 0
				let l:curr_msg = l:curr_msg . strpart (l:errmsgs, 0, l:match_pos)
				let l:errmsgs = strpart (l:errmsgs, l:match_pos, 99999999)
			else
				let l:curr_msg = l:curr_msg . l:errmsgs
				let l:errmsgs = ''
			endif
"echo 'l:curr_msg : ' l:curr_msg 

			" now get the correct line numbers
			let l:linenum = matchstr (l:curr_msg,'[0-9]\+')
			let l:new_linenum = l:linenum + l:comments_count
			let l:new_errmsg = l:new_errmsg . l:new_linenum . strpart (l:curr_msg, strlen (l:linenum), 99999999)
			"store linenumbers in a global variable
			let s:sqlErrLines = s:sqlErrLines . l:new_linenum . ';'
"echo 'l:new_errmsg : ' l:new_errmsg 
		endwhile

"let g:sqlout1 = l:errmsgs
		" save the errormessages to the error file
		exec 'redir > ' . &errorfile
		echo l:new_errmsg
		redir end
		return 1
	endif


	return 

endfunction


function! ORAVimLeavePre()
	" save the connection information in global variables

	let g:SQLCMD = s:sqlcmd
	let g:USER = s:user
	let g:PASSWORD = s:password
	let g:SERVER = s:server
"	let g:DATEFORMAT = s:dateformat
	let g:DO_HIGHLIGHT_ERRORS = s:do_highlight_errors
	
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Select Database dialog
nmap <Leader>c :call SelectDatabase ()<CR>

"get column names for the tablename under cursor
nmap <Leader>C :call GetColumn()<CR>

" Stored procedure code from DB for the function/procedure name under cursor
"TODO make this a function
map <Leader>F :call GetSource()<CR>

" Find Invalid Objects
map <Leader>i :call InvalidObjects ('')<CR>

"" Compile Invalid Objects
"map <Leader>I :call InvalidObjects ('C')<CR>

" Start SQL*Plus window
nmap <C-S> :call SqlPlus (1)<CR>

" Execute current file in SQL*Plus window
map <Leader>r :call SqlPlus ('@', @%)<CR>

" Execute current file in SQL*Plus and get the result to this window
map <Leader>s :1,$call SqlPlus()<CR>

" Execute current selection in SQL*Plus and get the result to a new window
vmap <Leader>s yn[P\s

" QuickFix mode (Conditional)
"
" Make (Alt+M)
if mapcheck ("í") == ""
 map í :Make<CR>


" Map Alt - <Up>/<Down> to do a previous/next error
 map <M-Up> :cp<CR>
 map <M-Down> :cn<CR>

" Alt-A - list all errors
 map á :c!<CR>

" Alt-C - list current error
 map ã :cc!<CR>

" Alt-O - open error window
 map ï :copen<CR>
endif





""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Menus
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"TODO make the rootmenu a user option
"let l:rootmenu = 'SQL*&Plus'

amenu SQL*&Plus.&Start<TAB>Ctrl+S			<C-S>
amenu SQL*Plus.&Run<Tab>\\r                             \r
amenu SQL*Plus.&Execute<Tab>\\s                         \s
nmenu SQL*Plus.&Invalid\ Objects<Tab>\\i                \i
"amenu SQL*Plus.Record\ Count                            \C
"nmenu SQL*Plus.Compile\ &Invalid<Tab>\\I                \I
amenu SQL*Plus.&Describe\ Object<Tab>Ctrl+D				<C-D>
amenu SQL*Plus.-sep1-                     <NUL>
imenu SQL*Plus.&Insert.&Begin\ Block<TAB>BEG            BEG<Space>
nmenu SQL*Plus.&Insert.&Begin\ Block<TAB>BEG            iBEG<Space>
imenu SQL*Plus.&Insert.Create\ &Function<TAB>CF         CF<Space>
nmenu SQL*Plus.&Insert.Create\ &Function<TAB>CF         iCF<Space>
imenu SQL*Plus.&Insert.Create\ &Procedure<Tab>CP        CP<Space>
nmenu SQL*Plus.&Insert.Create\ &Procedure<Tab>CP        iCP<Space>
imenu SQL*Plus.&Insert.Create\ &Table<Tab>CTA           CTA<Space>
nmenu SQL*Plus.&Insert.Create\ &Table<Tab>CTA           iCTA<Space>
imenu SQL*Plus.&Insert.Create\ T&rigger<Tab>CTR         CTR<Space>
nmenu SQL*Plus.&Insert.Create\ T&rigger<Tab>CTR         iCTR<Space>
imenu SQL*Plus.&Insert.Create\ &View<Tab>CV             CV<Space>
nmenu SQL*Plus.&Insert.Create\ &View<Tab>CV             iCV<Space>
amenu SQL*Plus.&Insert.-sep2-                     <NUL>
imenu SQL*Plus.&Insert.&Cursor\ Definition<Tab>CUR      CUR<Space>
nmenu SQL*Plus.&Insert.&Cursor\ Definition<Tab>CUR      iCUR<Space>
imenu SQL*Plus.&Insert.Dbms_&output<Tab>DP              DP<Space>
nmenu SQL*Plus.&Insert.Dbms_&output<Tab>DP              iDP<Space>
imenu SQL*Plus.&Insert.&FOR\ Loop<Tab>FOR               FOR<Space>
nmenu SQL*Plus.&Insert.&FOR\ Loop<Tab>FOR               iFOR<Space>
imenu SQL*Plus.&Insert.&IF\ Statement<Tab>IF            IF<Space>
nmenu SQL*Plus.&Insert.&IF\ Statement<Tab>IF            iIF<Space>
amenu SQL*Plus.&Insert.-sep3-                     <NUL>
imenu SQL*Plus.&Insert.I&NSERT<Tab>INS                  INS<Space>
nmenu SQL*Plus.&Insert.I&NSERT<Tab>INS                  iINS<Space>
imenu SQL*Plus.&Insert.&UPDATE\ Statement<Tab>UPD       UPD<Space>
nmenu SQL*Plus.&Insert.&UPDATE\ Statement<Tab>UPD       iUPD<Space>
imenu SQL*Plus.&Insert.&DELETE<Tab>DEL                  DEL<Space>
nmenu SQL*Plus.&Insert.&DELETE<Tab>DEL                  iDEL<Space>
imenu SQL*Plus.&Insert.&SELECT\ Statement<Tab>SEL       SEL<Space>
nmenu SQL*Plus.&Insert.&SELECT\ Statement<Tab>SEL       iSEL<Space>
imenu SQL*Plus.&Insert.Order\ By<Tab>OB                 OB<Space>
nmenu SQL*Plus.&Insert.Order\ By<Tab>OB                 iOB<Space>
imenu SQL*Plus.&Insert.&Group\ By<Tab>GB                GB<Space>
nmenu SQL*Plus.&Insert.&Group\ By<Tab>GB                iGB<Space>
imenu SQL*Plus.&Insert.&WHEN<Tab>WH                     WH<Space>
nmenu SQL*Plus.&Insert.&WHEN<Tab>WH                     iWH<Space>
amenu SQL*Plus.&Insert.-sep4-                     <NUL>
imenu SQL*Plus.&Insert.NO_DATA_FOUND<Tab>NDF            NDF<Space>
nmenu SQL*Plus.&Insert.NO_DATA_FOUND<Tab>NDF            iNDF<Space>
imenu SQL*Plus.&Insert.RAISE_APPLICATION_ERROR<Tab>RAE  RAE<Space>
nmenu SQL*Plus.&Insert.RAISE_APPLICATION_ERROR<Tab>RAE  iRAE<Space>
amenu SQL*Plus.-sep5-                     <NUL>
amenu SQL*Plus.Compile\ (&Make)<Tab>Alt+M               í
amenu SQL*Plus.&Next\ Error<TAB>Alt+<Down>              <M-Down>
amenu SQL*Plus.&Previous\ Error<TAB>Alt+<Up>            <M-Up>
amenu SQL*Plus.&Current\ Error<TAB>Alt+C                ã
amenu SQL*Plus.&List\ All\ Errors<TAB>Alt+A             á
amenu SQL*Plus.-sep6-                     <NUL>
amenu SQL*&Plus.Select\ &Database\.\.\.<TAB>\\c			\c
amenu SQL*&Plus.&Change\ Connection\.\.\.<TAB>:CC			:CC<CR>
execute 'amenu SQL*&Plus.&Customize			:edit ' expand ('<sfile>:p') . '<CR>'

" SQL*Plus Menu in PopUp
amenu PopUp.SQL*&Plus.&Start<TAB>Ctrl+S			<C-S>
amenu PopUp.SQL*Plus.&Run<Tab>\\r                             \r
amenu PopUp.SQL*Plus.&Execute<Tab>\\s                         \s
nmenu PopUp.SQL*Plus.&Invalid\ Objects<Tab>\\i                \i
"amenu PopUp.SQL*Plus.Record\ Count                            \C
"nmenu PopUp.SQL*Plus.Compile\ &Invalid<Tab>\\I                \I
amenu PopUp.SQL*Plus.&Describe\ Object<Tab>Ctrl+D				<C-D>
amenu PopUp.SQL*Plus.-sep1-                     <NUL>
imenu PopUp.SQL*Plus.&Insert.&Begin\ Block<TAB>BEG            BEG<Space>
nmenu PopUp.SQL*Plus.&Insert.&Begin\ Block<TAB>BEG            iBEG<Space>
imenu PopUp.SQL*Plus.&Insert.Create\ &Function<TAB>CF         CF<Space>
nmenu PopUp.SQL*Plus.&Insert.Create\ &Function<TAB>CF         iCF<Space>
imenu PopUp.SQL*Plus.&Insert.Create\ &Procedure<Tab>CP        CP<Space>
nmenu PopUp.SQL*Plus.&Insert.Create\ &Procedure<Tab>CP        iCP<Space>
imenu PopUp.SQL*Plus.&Insert.Create\ &Table<Tab>CTA           CTA<Space>
nmenu PopUp.SQL*Plus.&Insert.Create\ &Table<Tab>CTA           iCTA<Space>
imenu PopUp.SQL*Plus.&Insert.Create\ T&rigger<Tab>CTR         CTR<Space>
nmenu PopUp.SQL*Plus.&Insert.Create\ T&rigger<Tab>CTR         iCTR<Space>
imenu PopUp.SQL*Plus.&Insert.Create\ &View<Tab>CV             CV<Space>
nmenu PopUp.SQL*Plus.&Insert.Create\ &View<Tab>CV             iCV<Space>
amenu PopUp.SQL*Plus.&Insert.-sep1-                     <NUL>
imenu PopUp.SQL*Plus.&Insert.&Cursor\ Definition<Tab>CUR      CUR<Space>
nmenu PopUp.SQL*Plus.&Insert.&Cursor\ Definition<Tab>CUR      iCUR<Space>
imenu PopUp.SQL*Plus.&Insert.Dbms_&output<Tab>DP              DP<Space>
nmenu PopUp.SQL*Plus.&Insert.Dbms_&output<Tab>DP              iDP<Space>
imenu PopUp.SQL*Plus.&Insert.&FOR\ Loop<Tab>FOR               FOR<Space>
nmenu PopUp.SQL*Plus.&Insert.&FOR\ Loop<Tab>FOR               iFOR<Space>
imenu PopUp.SQL*Plus.&Insert.&IF\ Statement<Tab>IF            IF<Space>
nmenu PopUp.SQL*Plus.&Insert.&IF\ Statement<Tab>IF            iIF<Space>
amenu PopUp.SQL*Plus.&Insert.-sep2-                     <NUL>
imenu PopUp.SQL*Plus.&Insert.I&NSERT<Tab>INS                  INS<Space>
nmenu PopUp.SQL*Plus.&Insert.I&NSERT<Tab>INS                  iINS<Space>
imenu PopUp.SQL*Plus.&Insert.&UPDATE\ Statement<Tab>UPD       UPD<Space>
nmenu PopUp.SQL*Plus.&Insert.&UPDATE\ Statement<Tab>UPD       iUPD<Space>
imenu PopUp.SQL*Plus.&Insert.&DELETE<Tab>DEL                  DEL<Space>
nmenu PopUp.SQL*Plus.&Insert.&DELETE<Tab>DEL                  iDEL<Space>
imenu PopUp.SQL*Plus.&Insert.&SELECT\ Statement<Tab>SEL       SEL<Space>
nmenu PopUp.SQL*Plus.&Insert.&SELECT\ Statement<Tab>SEL       iSEL<Space>
imenu PopUp.SQL*Plus.&Insert.Order\ By<Tab>OB                 OB<Space>
nmenu PopUp.SQL*Plus.&Insert.Order\ By<Tab>OB                 iOB<Space>
imenu PopUp.SQL*Plus.&Insert.&Group\ By<Tab>GB                GB<Space>
nmenu PopUp.SQL*Plus.&Insert.&Group\ By<Tab>GB                iGB<Space>
imenu PopUp.SQL*Plus.&Insert.&WHEN<Tab>WH                     WH<Space>
nmenu PopUp.SQL*Plus.&Insert.&WHEN<Tab>WH                     iWH<Space>
amenu PopUp.SQL*Plus.&Insert.-sep2-                     <NUL>
imenu PopUp.SQL*Plus.&Insert.NO_DATA_FOUND<Tab>NDF            NDF<Space>
nmenu PopUp.SQL*Plus.&Insert.NO_DATA_FOUND<Tab>NDF            iNDF<Space>
imenu PopUp.SQL*Plus.&Insert.RAISE_APPLICATION_ERROR<Tab>RAE  RAE<Space>
nmenu PopUp.SQL*Plus.&Insert.RAISE_APPLICATION_ERROR<Tab>RAE  iRAE<Space>
amenu PopUp.SQL*Plus.-sep2-                     <C-L>
amenu PopUp.SQL*Plus.Compile\ (&Make)<Tab>Alt+M               í
amenu PopUp.SQL*Plus.&Next\ Error<TAB>Alt+<Down>              <M-Down>
amenu PopUp.SQL*Plus.&Previous\ Error<TAB>Alt+<Up>            <M-Up>
amenu PopUp.SQL*Plus.&Current\ Error<TAB>Alt+C                ã
amenu PopUp.SQL*Plus.&List\ All\ Errors<TAB>Alt+A             á
amenu PopUp.SQL*Plus.-sep6-                     <NUL>
amenu PopUp.SQL*&Plus.Select\ &Database\.\.\.<TAB>\\c			\c
amenu PopUp.SQL*&Plus.&Change\ Connection\.\.\.<TAB>:CC			:CC<CR>
execute 'amenu PopUp.SQL*&Plus.&Customize			:edit ' expand ('<sfile>:p') . '<CR>'


" ToolBar
if has ("win32")
	amenu 1.216 ToolBar.SQLrun		\r
	tmenu 1.216 ToolBar.SQLrun		Run current file in SQL*Plus
	amenu 1.217 ToolBar.SQLexecute	\s
	tmenu 1.217 ToolBar.SQLexecute	Execute current file/selection in SQL*Plus and get the result in the buffer
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Signs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("signs")
	let v:errmsg = ""
	silent! sign list SQLMakeError
	if "" != v:errmsg
		sign define SQLMakeError linehl=Error text=?> texthl=Error
	endif
endif



augroup SqlPlus
"  au!
"
" This is to remove any error indicators that was added as part of SqlMake().
	autocmd! BufWritePre,FileWritePre *.sql,*.pls
	if has("signs")
		autocmd BufWritePre,FileWritePre *.sql,*.pls normal :sign unplace *
	else
		autocmd BufWritePre,FileWritePre *.sql,*.pls normal :g/ --ERR\d*--/s///g
	endif

	"  autocmd BufEnter *.iqd,*.sql,*.pls,afiedt.buf, source $VIM/user/sqlEnter.vim
	"  autocmd BufLeave,WinLeave *.iqd,*.sql,*.pls,afiedt.buf source $VIM/user/sqlLeave.vim

	au VimEnter * call ORAInitialize()
	au VimLeavePre * nested call ORAVimLeavePre()
augroup end

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save
