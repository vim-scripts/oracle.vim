"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Purpose: Set the VIM environment for SQL files
" Author: Rajesh Kallingal <RajeshKallingal@email.com>
" Version: 6.0.4
" Last Modified: Tue Feb 05 13:32:07 2002
" vim tw=0
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Description:
" 	This is a file type plugin for Oracle SQL files. This is a companion file
" 	for oracle.vim script (Oracle IDE).
"
"	This has a lot of abbreviations, some mappings, few settings and syntax.
" 
" Installation:
" 	Just drop it in your ftplugin folder/directory
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

setlocal tabstop=4 shiftwidth=4
setlocal comments=sr:/*,mb:*,el:*/,:--,:REM\ * 
"setlocal errorformat=%f\|%l\|%c\|%m
setlocal errorformat=%E%l/%c\	%m,%C%m,%Z,%PFile:%f
setlocal tags=d:/dbs/sql/tags
let b:comment='--'


"Custom Mappings
"put dbms_output.put_line for word/selection
map <LocalLeader>d yawoDP <C-H>'<C-R>": ' \|\| <C-R>"<ESC>
map <LocalLeader>D yawODP <C-H>'<C-R>": ' \|\| <C-R>"<ESC>
vmap <LocalLeader>d yoDP <C-H>'<C-R>": ' \|\| <C-R>"<ESC>
vmap <LocalLeader>D yODP <C-H>'<C-R>": ' \|\| <C-R>"<ESC>

"Describe the object under cursor
if exists ("*DescribeObject")
	map <C-D> yiw:call DescribeObject()<C-M>
	vmap <C-D> y:call DescribeObject()<C-M>
else
	map <C-D> :echohl ErrorMsg\|echo "Unknown function DescribeObject, get 'oracle.vim' from vim.sf.net"\|echohl None<C-M>
	vmap <C-D> <ESC>:echohl ErrorMsg\|echo "Unknown function DescribeObject, get 'oracle.vim' from vim.sf.net"\|echohl None<C-M>

endif

" enable Insert menu for SQL*Plus

"Local Abbreviations

iab <buffer> ABS ABS (<NUMBER> )<C-O>T(
iab <buffer> abs ABS (<NUMBER> )<C-O>T(
iab <buffer> ACOS ACOS ( )<C-O>T(
iab <buffer> acos ACOS ( )<C-O>T(
iab <buffer> AM ADD_MONTHS (<DATE>, <NUMBER> )<C-O>T(
iab <buffer> ADD_MONTHS ADD_MONTHS (<DATE>, <NUMBER> )<C-O>T(
iab <buffer> add_months ADD_MONTHS ( )<C-O>T(
iab <buffer> ASCII ASCII ( )<C-O>T(
iab <buffer> ascii ASCII ( )<C-O>T(
iab <buffer> ASIN ASIN ( )<C-O>T(
iab <buffer> asin ASIN ( )<C-O>T(
iab <buffer> ATAN ATAN ( )<C-O>T(
iab <buffer> atan ATAN ( )<C-O>T(
iab <buffer> ATAN2 ATAN2 ( )<C-O>T(
iab <buffer> atan2 atan2 ( )<C-O>T(
iab <buffer> AVG AVG ( )<C-O>T(
iab <buffer> avg AVG ( )<C-O>T(
iab <buffer> CEIL CEIL ( )<C-O>T(
iab <buffer> ceil CEIL ( )<C-O>T(
iab <buffer> CHARTOROWID CHARTOROWID ( )<C-O>T(
iab <buffer> chartorowid CHARTOROWID ( )<C-O>T(
iab <buffer> CHR CHR ( )<C-O>T(
iab <buffer> chr CHR ( )<C-O>T(
iab <buffer> CONCAT CONCAT ( )<C-O>T(
iab <buffer> concat CONCAT ( )<C-O>T(
iab <buffer> CONVERT CONVERT ( )<C-O>T(
iab <buffer> convert CONVERT ( )<C-O>T(
iab <buffer> COS COS ( )<C-O>T(
iab <buffer> cos COS ( )<C-O>T(
iab <buffer> COSH COSH ( )<C-O>T(
iab <buffer> cosh COSH ( )<C-O>T(
iab <buffer> COUNT COUNT ( )<C-O>T(
iab <buffer> count COUNT ( )<C-O>T(
iab <buffer> DECODE DECODE ( )<C-O>T(
iab <buffer> decode DECODE ( )<C-O>T(
iab <buffer> DUMP DUMP ( )<C-O>T(
iab <buffer> dump DUMP ( )<C-O>T(
iab <buffer> EXP EXP ( )<C-O>T(
iab <buffer> exp EXP ( )<C-O>T(
iab <buffer> FLOOR FLOOR ( )<C-O>T(
iab <buffer> floor FLOOR ( )<C-O>T(
iab <buffer> GLB GLB ( )<C-O>T(
iab <buffer> glb GLB ( )<C-O>T(
iab <buffer> GREATEST GREATEST ( )<C-O>T(
iab <buffer> greatest GREATEST ( )<C-O>T(
iab <buffer> GREATEST_LB GREATEST_LB ( )<C-O>T(
iab <buffer> greatest_lb GREATEST_LB ( )<C-O>T(
iab <buffer> HEXTORAW HEXTORAW ( )<C-O>T(
iab <buffer> hextoraw HEXTORAW ( )<C-O>T(
iab <buffer> IC INITCAP ( )<C-O>T(
iab <buffer> INITCAP INITCAP ( )<C-O>T(
iab <buffer> initcap INITCAP ( )<C-O>T(
iab <buffer> INSTR INSTR ( )<C-O>T(
iab <buffer> instr INSTR ( )<C-O>T(
iab <buffer> INSTRB INSTRB ( )<C-O>T(
iab <buffer> instrb INSTRB ( )<C-O>T(
iab <buffer> LD LAST_DAY ( )<C-O>T(
iab <buffer> LAST_DAY LAST_DAY ( )<C-O>T(
iab <buffer> last_day LAST_DAY ( )<C-O>T(
iab <buffer> LEAST LEAST ( )<C-O>T(
iab <buffer> least LEAST ( )<C-O>T(
iab <buffer> LEAST_UB LEAST_UB ( )<C-O>T(
iab <buffer> least_ub LEAST_UB ( )<C-O>T(
iab <buffer> LENGTH LENGTH ( )<C-O>T(
iab <buffer> length LENGTH ( )<C-O>T(
iab <buffer> LENGTHB LENGTHB ( )<C-O>T(
iab <buffer> lengthb LENGTHB ( )<C-O>T(
iab <buffer> LN LN ( )<C-O>T(
iab <buffer> ln LN ( )<C-O>T(
iab <buffer> LOG LOG ( )<C-O>T(
iab <buffer> log LOG ( )<C-O>T(
iab <buffer> LOWER LOWER ( )<C-O>T(
iab <buffer> lower LOWER ( )<C-O>T(
iab <buffer> LPAD LPAD ( )<C-O>T(
iab <buffer> lpad LPAD ( )<C-O>T(
iab <buffer> LTRIM LTRIM ( )<C-O>T(
iab <buffer> ltrim LTRIM ( )<C-O>T(
iab <buffer> LUB LUB ( )<C-O>T(
iab <buffer> lub LUB ( )<C-O>T(
iab <buffer> MAX MAX ( )<C-O>T(
iab <buffer> max MAX ( )<C-O>T(
iab <buffer> MIN MIN ( )<C-O>T(
iab <buffer> min MIN ( )<C-O>T(
iab <buffer> MOD MOD ( )<C-O>T(
iab <buffer> mod MOD ( )<C-O>T(
iab <buffer> MB MONTHS_BETWEEN ( )<C-O>T(
iab <buffer> MONTHS_BETWEEN MONTHS_BETWEEN ( )<C-O>T(
iab <buffer> months_between MONTHS_BETWEEN ( )<C-O>T(
iab <buffer> NEW_TIME NEW_TIME ( )<C-O>T(
iab <buffer> new_time NEW_TIME ( )<C-O>T(
iab <buffer> NEXT_DAY NEXT_DAY ( )<C-O>T(
iab <buffer> next_day NEXT_DAY ( )<C-O>T(
iab <buffer> NLSSORT NLSSORT ( )<C-O>T(
iab <buffer> nlssort NLSSORT ( )<C-O>T(
iab <buffer> NLS_INITCAP NLS_INITCAP ( )<C-O>T(
iab <buffer> nls_initcap NLS_INITCAP ( )<C-O>T(
iab <buffer> NLS_LOWER NLS_LOWER ( )<C-O>T(
iab <buffer> nls_lower NLS_LOWER ( )<C-O>T(
iab <buffer> NLS_UPPER NLS_UPPER ( )<C-O>T(
iab <buffer> nls_upper NLS_UPPER ( )<C-O>T(
iab <buffer> NVL NVL ( )<C-O>T(
iab <buffer> nvl NVL ( )<C-O>T(
iab <buffer> POWER POWER ( )<C-O>T(
iab <buffer> power POWER ( )<C-O>T(
iab <buffer> RAWTOHEX RAWTOHEX ( )<C-O>T(
iab <buffer> rawtohex RAWTOHEX ( )<C-O>T(
iab <buffer> REPLACE REPLACE ( )<C-O>T(
iab <buffer> replace REPLACE ( )<C-O>T(
iab <buffer> ROUND ROUND ( )<C-O>T(
iab <buffer> round ROUND ( )<C-O>T(
iab <buffer> ROWIDTOCHAR ROWIDTOCHAR ( )<C-O>T(
iab <buffer> rowidtochar ROWIDTOCHAR ( )<C-O>T(
iab <buffer> RPAD RPAD ( )<C-O>T(
iab <buffer> rpad RPAD ( )<C-O>T(
iab <buffer> RTRIM RTRIM ( )<C-O>T(
iab <buffer> rtrim RTRIM ( )<C-O>T(
iab <buffer> SIGN SIGN ( )<C-O>T(
iab <buffer> sign SIGN ( )<C-O>T(
iab <buffer> SIN SIN ( )<C-O>T(
iab <buffer> sin SIN ( )<C-O>T(
iab <buffer> SINH SINH ( )<C-O>T(
iab <buffer> sinh SINH ( )<C-O>T(
iab <buffer> SOUNDEX SOUNDEX ( )<C-O>T(
iab <buffer> soundex SOUNDEX ( )<C-O>T(
iab <buffer> SQRT SQRT ( )<C-O>T(
iab <buffer> sqrt SQRT ( )<C-O>T(
iab <buffer> STDDEV STDDEV ( )<C-O>T(
iab <buffer> stddev STDDEV ( )<C-O>T(
iab <buffer> SUBSTR SUBSTR ( )<C-O>T(
iab <buffer> substr SUBSTR ( )<C-O>T(
iab <buffer> SUBSTRB SUBSTRB ( )<C-O>T(
iab <buffer> substrb SUBSTRB ( )<C-O>T(
iab <buffer> SUM SUM ( )<C-O>T(
iab <buffer> sum SUM ( )<C-O>T(
"iab <buffer> SYSDATE SYSDATE ( )<C-O>T(
"iab <buffer> sysdate SYSDATE ( )<C-O>T(
iab <buffer> TAN TAN ( )<C-O>T(
iab <buffer> tan TAN ( )<C-O>T(
iab <buffer> TANH TANH ( )<C-O>T(
iab <buffer> tanh TANH ( )<C-O>T(


iab <buffer> TOC TO_CHAR (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> TO_C TO_CHAR (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> TO_CHAR TO_CHAR (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> to_char TO_CHAR (, <C-R>=dateformat<C-M>)<C-O>T(


iab <buffer> TOD TO_DATE (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> TO_D TO_DATE (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> TO_DATE TO_DATE (, <C-R>=dateformat<C-M>)<C-O>T(
iab <buffer> to_date TO_DATE (, <C-R>=dateformat<C-M>)<C-O>T(


iab <buffer> TO_LABEL TO_LABEL ( )<C-O>T(
iab <buffer> to_label TO_LABEL ( )<C-O>T(
iab <buffer> TO_MULTI_BYTE TO_MULTI_BYTE ( )<C-O>T(
iab <buffer> to_multi_byte TO_MULTI_BYTE ( )<C-O>T(
iab <buffer> TON TO_NUMBER ( )<C-O>T(
iab <buffer> TO_NUMBER TO_NUMBER ( )<C-O>T(
iab <buffer> to_number TO_NUMBER ( )<C-O>T(
iab <buffer> TO_SINGLE_BYTE TO_SINGLE_BYTE ( )<C-O>T(
iab <buffer> to_single_byte TO_SINGLE_BYTE ( )<C-O>T(
iab <buffer> TRANSLATE TRANSLATE ( )<C-O>T(
iab <buffer> translate TRANSLATE ( )<C-O>T(
iab <buffer> TRUNC TRUNC ( )<C-O>T(
iab <buffer> trunc TRUNC ( )<C-O>T(
iab <buffer> UID UID ( )<C-O>T(
iab <buffer> uid UID ( )<C-O>T(
iab <buffer> UPPER UPPER ( )<C-O>T(
iab <buffer> upper UPPER ( )<C-O>T(
iab <buffer> USER USER ( )<C-O>T(
iab <buffer> user USER ( )<C-O>T(
iab <buffer> USERENV USERENV ( )<C-O>T(
iab <buffer> userenv USERENV ( )<C-O>T(
iab <buffer> VARIANCE VARIANCE ( )<C-O>T(
iab <buffer> variance VARIANCE ( )<C-O>T(
iab <buffer> VSIZE VSIZE ( )<C-O>T(
iab <buffer> vsize VSIZE ( )<C-O>T(


" BEGIN block
iab <buffer> BEG BEGIN<CR>EXCEPTION<CR><TAB>WHEN OTHERS<CR>THEN<CR><Tab>RAISE_APPLICATION_ERROR (-20001, SQLERRM);<CR><C-D><C-D>END;<C-O>5k<End>

" Create Function
iab <buffer> CF CREATE OR REPLACE FUNCTION<CR><TAB>(<CR><Parameters_if_any,_if_none_remove_paranthesis><CR>)<CR>RETURN DataType <DataType><CR>IS<CR><CR><C-D>-- Local Variables<CR><CR>BEGIN<CR><Tab><Statements><CR><C-D>EXCEPTION<CR><TAB>WHEN OTHERS<CR>THEN<CR><Tab>RAISE_APPLICATION_ERROR (-20001, SQLERRM);<CR><C-D><C-D>END;<CR>/<C-O>16k<End><NAME><C-Left><C-Left><C-Left>

" Create Procedure
iab <buffer> CP CREATE OR REPLACE PROCEDURE<CR><TAB>(<CR><Parameters_if_any,_if_none_remove_paranthesis><CR>)<CR>IS<CR><CR><C-D>-- Local Variables<CR><CR>BEGIN<CR><Tab><Statements><CR><C-D>EXCEPTION<CR><TAB>WHEN OTHERS<CR>THEN<CR><Tab>RAISE_APPLICATION_ERROR (-20001, SQLERRM);<CR><C-D><C-D>END;<CR>/<C-O>15k<End><NAME><C-Left><C-Left><C-Left>

" Create Table
iab <buffer> CTA CREATE TABLE<CR><TAB>(<CR><Columns><CR>);<C-O>3k<End><NAME><C-Left><C-Left><C-Left>

" Create Trigger
iab <buffer> CTR CREATE OR REPLACE TRIGGER<CR><TAB>BEFORE INSERT OR UPDATE OR DELETE ON <TableName><CR>FOR EACH ROW<CR><C-D>DECLARE<CR><TAB><Local_Variables><CR><C-D>BEGIN<CR><TAB><Statments><CR><C-D>EXCEPTION<CR><TAB>WHEN OTHERS<CR>THEN<CR><Tab>RAISE_APPLICATION_ERROR (-20001, SQLERRM);<CR><C-D><C-D>END;<CR>/<C-O>12k<End><NAME><C-Left><C-Left><C-Left>

" Create View
iab <buffer> CV CREATE OR REPLACE VIEW<CR><TAB>(<CR><Column_Aliases><CR>)<CR>AS<CR>SELECT<CR><TAB><Columns><CR><C-D>FROM<CR><TAB><Tables><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>10k<End><NAME><C-Left><C-Left><C-Left>

" CURSOR
iab <buffer> CUR CURSOR<CR><TAB>(<CR><Parameters_if_any,_if_none_remove_paranthesis><CR>)<CR>IS<CR>SELECT<CR><TAB><Columns><CR><C-D>FROM<CR><TAB><Tables><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>10k<HOME><C-O>E<Right><NAME><C-Left><C-Left><C-Left>

" dbms_output.put_line
iab <buffer> DP dbms_output.put_line ();<ESC>F(a

" IF
iab <buffer> IF IF<CR>THEN<CR>ELSIF<CR>THEN<CR>ELSE<CR>END IF;<C-O>5k<End>

" FOR
iab <buffer> FOR FOR <CR>LOOP<CR>END LOOP; -- for loop for<C-O>2k

" DELETE
iab <buffer> DEL DELETE<CR>FROM<CR><TAB><TableName><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>2k<Home><C-Right>
iab <buffer> DELETE DELETE<CR>FROM<CR><TAB><TableName><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>2k<Home><C-Right>

" INSERT
iab <buffer> INS INSERT<CR>INTO<CR><TAB><CR>(<CR><Columns><CR>)<CR><C-D>VALUES<CR><TAB>(<CR><Values/Variables><CR>);<C-O>7k<End><TableName><C-Left><C-Left><C-Left>
iab <buffer> INSERT INSERT<CR>INTO<CR><TAB><CR>(<CR><Columns><CR>)<CR><C-D>VALUES<CR><TAB>(<CR><Values/Variables><CR>);<C-O>7k<End><TableName><C-Left><C-Left><C-Left>

" SELECT
iab <buffer> SEL SELECT<CR><TAB><Columns><CR><C-D>INTO<CR><TAB><Local_Variables><CR><C-D>FROM<CR><TAB><Tables><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>6k<Home><C-Right>
iab <buffer> SELECT SELECT<CR><TAB><Columns><CR><C-D>INTO<CR><TAB><Local_Variables><CR><C-D>FROM<CR><TAB><Tables><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>6k<Home><C-Right>

" UPDATE
iab <buffer> UPD UPDATE<CR><TAB><TableName><CR><C-D>SET<CR><TAB><Column=Value><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>4k<Home><C-Right>
iab <buffer> UPDATE UPDATE<CR><TAB><TableName><CR><C-D>SET<CR><TAB><Column=Value><CR><C-D>WHERE<CR><TAB><Conditions>;<C-O>4k<Home><C-Right>

" Statement Number
iab <buffer> STMT l_statement<C-X><C-L><Home><C-O>10<kPlus><End>

" ORDER BY
iab <buffer> OB ORDER BY<CR><TAB><Columns><C-Left><C-Left><C-Left>

" GROUP BY
iab <buffer> GB GROUP BY<CR><TAB><Columns><C-Left><C-Left><C-Left>

" RAISE_APPLICATION_ERROR
iab <buffer> RAE RAISE_APPLICATION_ERROR (-20001, SQLERRM );<C-O>17h

" NO_DATA_FOUND
iab <buffer> NDF NO_DATA_FOUND

" VARCHAR2
iab <buffer> VC VARCHAR2 ()<Left>
" WHEN
iab <buffer> WH WHEN<CR>THEN<CR><TAB>;<C-O>2k<End>




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax Enhancements
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Error lines - contains text '--ERRn--' where n is a number or null
syntax match sqlErrLine		"^.*--ERR\d*--$" contains=sqlErrMarker
syntax match sqlErrMarker 	" --ERR\d*--" contained
hi link sqlErrLine	Error
hi link sqlErrMarker	Ignore

" Debug commands:
syn region sqlDebug		start="dbms_output\.put_line" end=";"
hi link sqlDebug	Debug
