/*
宏功能描述:
根据用户输入的tag name，
在所选语句前插入性能分析起始语句TIME_CHECK_POINT_BEGIN("tag")，
在所选语句后插入性能分析结束语句TIME_CHECK_POINT_END("tag")
*/
macro ProfileAnalysis()
{
    tag = Ask("input the tag name...")
    start_tag = "TIME_CHECK_POINT_BEGIN(\"@tag@\");"
    end_tag = "TIME_CHECK_POINT_END(\"@tag@\");"
    hbuf = GetCurrentBuf()
    hwnd = GetCurrentWnd()
    first_row = GetWndSelLnFirst(hwnd)
    last_row = GetWndSelLnLast(hwnd)
    
    line = GetBufLine(hbuf, first_row)
    i = 0
    Tab = CharFromAscii(9)
    while (line[i] == " " || line[i] == Tab)
    {
        if (line[i] == " ")
        {
            start_tag = cat(" ", start_tag)
            end_tag = cat(" ", end_tag)
        }
        if (line[i] == Tab)
        {
            start_tag = cat(Tab, start_tag)
            end_tag = cat(Tab, end_tag)
        }
        i = i + 1
    }

    InsBufLine(hbuf, last_row + 1, end_tag)
    InsBufLine(hbuf, first_row, start_tag)
}

macro Test()
{
    Msg( GetCurSymbol() )
}

macro Comment_A_Word()
{
    hbuf = GetCurrentBuf()
    arg = GetBufSelText(hbuf)
    arg = cat( "/*", arg )
    arg = cat( arg, "*/" )
    SetBufSelText(hbuf, arg)    
}

macro Comment_Codes_With_Old_Style()
{
    cur_buf = GetCurrentBuf ()
    cur_wnd = GetCurrentWnd ()
    ln_first = GetWndSelLnFirst (cur_wnd)
    ln_last = GetWndSelLnLast (cur_wnd)

    InsBufLine (cur_buf, ln_last+1, "*/")
    InsBufLine (cur_buf, ln_first, "/*")
    InsBufLine (cur_buf, ln_first, "// Removed by lkf")
}

macro Disable_Codes()
{
    cur_buf = GetCurrentBuf ()
    cur_wnd = GetCurrentWnd ()
    ln_first = GetWndSelLnFirst (cur_wnd)
    ln_last = GetWndSelLnLast (cur_wnd)

    InsBufLine (cur_buf, ln_last+1, "#endif")
    InsBufLine (cur_buf, ln_first, "#if 0")
    InsBufLine (cur_buf, ln_first, "// Removed by lkf")
}

macro Comment_Codes()
{
    cur_buf = GetCurrentBuf ()
    cur_wnd = GetCurrentWnd ()
    ln_first = GetWndSelLnFirst (cur_wnd)
    ln_last = GetWndSelLnLast (cur_wnd)

    i = ln_first
    while( i<=ln_last )
    {
        line = GetBufLine ( cur_buf, i )
        line = cat( "//", line )
        PutBufLine ( cur_buf, i, line )
        i = i+1
    }
    
    //DumpMacroState( GetCurrentBuf() )
}

macro UnComment_Codes()
{
    cur_buf = GetCurrentBuf ()
    cur_wnd = GetCurrentWnd ()
    ln_first = GetWndSelLnFirst (cur_wnd)
    ln_last = GetWndSelLnLast (cur_wnd)

    i = ln_first
    while( i<=ln_last )
    {
        line = GetBufLine ( cur_buf, i )
        if( strlen(line)>=2 )
        {
            s = strmid (line, 0, 2)
            if( s == "//" )
            {
                line = strmid(line, 2, strlen(line))
                PutBufLine ( cur_buf, i, line )
            }
        }
        i = i+1
    }
    
    //DumpMacroState( GetCurrentBuf() )
}

















	/*   A U T O   E X P A N D   */
/*-------------------------------------------------------------------------
    Automatically expands C statements like if, for, while, switch, etc..

    To use this macro, 
    	1. Add this file to your project or your Base project.
		
		2. Run the Options->Key Assignments command and assign a 
		convenient keystroke to the "AutoExpand" command.
		
		3. After typing a keyword, press the AutoExpand keystroke to have the
		statement expanded.  The expanded statement will contain a ### string
		which represents a field where you are supposed to type more.
		
		The ### string is also loaded in to the search pattern so you can 
		use "Search Forward" to select the next ### field.

	For example:
		1. you type "for" + AutoExpand key
		2. this is inserted:
			for (###; ###; ###)
				{
				###
				}
		3. and the first ### field is selected.
-------------------------------------------------------------------------*/
macro AutoExpand()
{
    //配置信息
    // get window, sel, and buffer handles
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	if (sel.ichFirst == 0)
		stop
	hbuf = GetWndBuf(hwnd)
    Language = getreg(LANGUAGE)
	if(Language != 1)
	{
	    Language = 0
	}
	szMyName = getreg(MYNAME)
	if(strlen( szMyName ) == 0)
	{
		szMyName = Ask("Enter your name:")
		setreg(MYNAME, szMyName)
	}
	// get line the selection (insertion point) is on
	szLine = GetBufLine(hbuf, sel.lnFirst);
	// parse word just to the left of the insertion point
	wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
	ln = sel.lnFirst;
	chTab = CharFromAscii(9)
		
	// prepare a new indented blank line to be inserted.
	// keep white space on left and add a tab to indent.
	// this preserves the indentation level.
	chSpace = CharFromAscii(32);
	ich = 0
	while (szLine[ich] == chSpace || szLine[ich] == chTab)
	{
		ich = ich + 1
	}
	szLine1 = strmid(szLine,0,ich)
	szLine = strmid(szLine, 0, ich) # "    "
	
	sel.lnFirst = sel.lnLast
	sel.ichFirst = wordinfo.ich
	sel.ichLim = wordinfo.ich

    //注释输入，可以自动换行
	if (wordinfo.szWord == "pn")
	{
        DelBufLine(hbuf, ln)
	    AddPromblemNo()
	    return
	}
	else if (wordinfo.szWord == "config")
	{
	    DelBufLine(hbuf, ln)
    	ConfigureSystem()
    	return
	}
	else if (wordinfo.szWord == "hi")
	{
    	DelBufLine(hbuf, ln)
        InsertHistory(hbuf,ln,language)
	}
    if(Language == 0)
    {
    	if (wordinfo.szWord == "/*")
    	{   
        	szCurLine = GetBufLine(hbuf, sel.lnFirst);
        	szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        	lineLen = strlen(szCurLine)
        	kk = 0
        	while(wordinfo.ichLim + kk < lineLen)
        	{
        	    if(szCurLine[wordinfo.ichLim + kk] != " ")
        	    {
        	        msg("只能在行尾插入");
        	        return
        	    }
        	    kk = kk + 1
        	}
        	szContent = Ask("请输入注释的内容")
    	    DelBufLine(hbuf, ln)
        	CommentContent(hbuf,ln,szLeft,szContent,1)        	
        	return
    	}
    	else if(wordinfo.szWord == "{")
    	{
    		InsBufLine(hbuf, ln + 1, "@szLine@" # "###")
    		InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
    	}
    	else if (wordinfo.szWord == "while" ||
    		wordinfo.szWord == "else")
    	{
        	SetBufSelText(hbuf, " ( ### )")
        	InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        	InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
        	InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    	}
        else if (wordinfo.szWord == "ifd")
        {
              DelBufLine(hbuf, ln)
              InsIfdef()
              return
        }
        else if (wordinfo.szWord == "cpp")
        {
              DelBufLine(hbuf, ln)
              InsertCPP(hbuf,ln)
              return
        }    
    	else if (wordinfo.szWord == "if")
    	{
    		SetBufSelText(hbuf, " ( ### )")
    		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
    		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
    		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    		InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
    		InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
    		InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
    		InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    	}
     	else if (wordinfo.szWord == "for")
    	{
     		SetBufSelText(hbuf, " ( ###; ###; ### )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
    	}
     	else if (wordinfo.szWord == "fo")
    	{
     		SetBufSelText(hbuf, "r ( ulI = 0; ulI < ###; ulI++ )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
            symname =GetCurSymbol ()
            symbol = GetSymbolLocation(symname)
           	if(strlen(symbol) > 0)
           	{
         		InsBufLine(hbuf, symbol.lnName+2, "    UINT32 ulI = 0;");        
             }
    	}
     	else if (wordinfo.szWord == "switch")
    	{
     		SetBufSelText(hbuf, " ( ### )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "case ###:")
     		InsBufLine(hbuf, ln + 3, "@szLine@" # "    " # "###")
     		InsBufLine(hbuf, ln + 4, "@szLine@" # "    " # "break;")
     		InsBufLine(hbuf, ln + 5, "@szLine@" # "default:")
     		InsBufLine(hbuf, ln + 6, "@szLine@" # "    " # "###")
     		InsBufLine(hbuf, ln + 7, "@szLine@" # "    " # "break;")
     		InsBufLine(hbuf, ln + 8, "@szLine1@" # "}")
    	}
     	else if (wordinfo.szWord == "do")
    	{
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while (###);")
    	}
     	else if (wordinfo.szWord == "case")
    	{
     		SetBufSelText(hbuf, " ###:")
     		InsBufLine(hbuf, ln + 1, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    	}
     	else if (wordinfo.szWord == "struct")
    	{
    	    DelBufLine(hbuf, ln)
            szStructName = toupper(Ask("请输入结构名:"))
            InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
            InsBufLine(hbuf, ln + 1, "@szLine1@{");
            InsBufLine(hbuf, ln + 2, "@szLine1@    ###             /* */");
            szStructName = cat(szStructName,"_STRU")
            InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
    	}
     	else if (wordinfo.szWord == "enum")
    	{
    	    DelBufLine(hbuf, ln)
            szStructName = toupper(Ask("请输入枚举名:"))
            InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
            InsBufLine(hbuf, ln + 1, "@szLine1@{");
            InsBufLine(hbuf, ln + 2, "@szLine1@    ###             /* */");
            szStructName = cat(szStructName,"_ENUM")
            InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
    	}
        else if (wordinfo.szWord == "file")
    	{
            InsertFileHeaderCN( hbuf,ln, szMyName,"" )
            return
        }
    	else if (wordinfo.szWord == "func")
    	{
    		DelBufLine(hbuf,ln);
    	    symbol = GetCurSymbol()
        	if(strlen(symbol) != 0)
        	{
        	    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                return
        	}
            szFuncName = Ask("请输入函数名称:")
       	    FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    	}
    	else if (wordinfo.szWord == "tab")
    	{
        	DelBufLine(hbuf, ln)
            ReplaceBufTab()
    	}
    	else if (wordinfo.szWord == "ap")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
            szQuestion = AddPromblemNo()
            InsBufLine(hbuf, ln, "@szLine1@/* 问 题 单: D@szQuestion@     修改人:@szMyName@,   时间:@sz@/@sz1@/@sz3@ ");
        	szContent = Ask("修改原因")
            szLeft = cat(szLine1,"   修改原因: ");
        	ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        	return
    	}
    	else if (wordinfo.szWord == "app")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
        	szContent = Ask("修改说明")
            szLeft = cat(szLine1,"/*修改说明: ");
            InsBufLine(hbuf, ln, "@szLine1@// 修改说明: @szContent@ ");
            InsBufLine(hbuf, ln + 1, "@szLine1@// 修改人:@szMyName@       ");
            InsBufLine(hbuf, ln + 2, "@szLine1@// 修改时间:@sz@/@sz1@/@sz3@             ");
            
        	return
    	}
     	else if (wordinfo.szWord == "cs")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln , "@szLine1@// 修改人:@szMyName@    @sz@/@sz1@/@sz3@         BEGIN");
            
        	return
    	}
     	else if (wordinfo.szWord == "ce")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln , "@szLine1@// 修改人:@szMyName@    @sz@/@sz1@/@sz3@         END");
            
        	return
    	}
     	else if (wordinfo.szWord == "cse")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln , "@szLine1@// 修改人:@szMyName@    @sz@/@sz1@/@sz3@         BEGIN");
            InsBufLine(hbuf, ln + 1, "//");
            InsBufLine(hbuf, ln + 2, "@szLine1@// 修改人:@szMyName@    @sz@/@sz1@/@sz3@         END");
        	return
    	}
    	

    	else if (wordinfo.szWord == "fd")
    	{
      	    DelBufLine(hbuf, ln)
         	CreateFuncDef(hbuf,szMyName,Language)
         	return
    	}
        else if (wordinfo.szWord == "as")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	    if(strlen(szQuestion)>0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   问题单号:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ ");        
            }
            return
        }
        else if (wordinfo.szWord == "ae")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln, "@szLine1@// END:   Added by @szMyName@, @sz@.@sz1@.@sz3@ ");
            return
        }
        else if (wordinfo.szWord == "ds")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	        if(strlen(szQuestion) > 0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   问题单号:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ ");
            }
            
            return
        }
        else if (wordinfo.szWord == "de")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln + 0)
            InsBufLine(hbuf, ln, "@szLine1@// END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ ");
            return
        }
        else if (wordinfo.szWord == "ms")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	        if(strlen(szQuestion) > 0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   问题单号:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ ");
            }
            return
        }
        else if (wordinfo.szWord == "me")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln, "@szLine1@// END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ ");
            return
        }
    	else
    	{
    		stop
        }
    }
    else
    {
    	if (wordinfo.szWord == "/*")
    	{   
        	szCurLine = GetBufLine(hbuf, sel.lnFirst);
        	szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        	lineLen = strlen(szCurLine)
        	kk = 0
        	while(wordinfo.ichLim + kk < lineLen)
        	{
        	    if((szCurLine[wordinfo.ichLim + kk] != " ")||(szCurLine[wordinfo.ichLim + kk] != "\t")
        	    {
        	        msg("you must insert /* at the end of line");
        	        return
        	    }
        	    kk = kk + 1
        	}
        	szContent = Ask("Please input comment")
    	    DelBufLine(hbuf, ln)
        	CommentContent(hbuf,ln,szLeft,szContent,1)        	
        	return
    	}
    	else if(wordinfo.szWord == "{")
    	{
    		InsBufLine(hbuf, ln + 1, "@szLine@" # "###")
    		InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
    	}
    	else if (wordinfo.szWord == "while" ||
    		wordinfo.szWord == "else")
    	{
        	SetBufSelText(hbuf, " ( ### )")
        	InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        	InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
        	InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    	}
        else if (wordinfo.szWord == "ifd")
        {
              DelBufLine(hbuf, ln)
              InsIfdef()
              return
        }
        else if (wordinfo.szWord == "cpp")
        {
              DelBufLine(hbuf, ln)
              InsertCPP(hbuf,ln)
              return
        }    
    	else if (wordinfo.szWord == "if")
    	{
    		SetBufSelText(hbuf, " ( ### )")
    		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
    		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
    		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    		InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
    		InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
    		InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
    		InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    	}
     	else if (wordinfo.szWord == "for")
    	{
     		SetBufSelText(hbuf, " ( ###; ###; ### )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
    	}
     	else if (wordinfo.szWord == "fo")
    	{
     		SetBufSelText(hbuf, "r ( ulI = 0; ulI < ###; ulI++ )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
            symname =GetCurSymbol ()
            symbol = GetSymbolLocation(symname)
           	if(strlen(symbol) > 0)
           	{
         		InsBufLine(hbuf, symbol.lnName+2, "    UINT32 ulI = 0;");        
             }
    	}
     	else if (wordinfo.szWord == "switch")
    	{
     		SetBufSelText(hbuf, " ( ### )")
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "case ###:")
     		InsBufLine(hbuf, ln + 3, "@szLine@" # "    " # "###")
     		InsBufLine(hbuf, ln + 4, "@szLine@" # "    " # "break;")
     		InsBufLine(hbuf, ln + 5, "@szLine@" # "default;")
     		InsBufLine(hbuf, ln + 6, "@szLine@" # "    " # "###")
     		InsBufLine(hbuf, ln + 7, "@szLine1@" # "}")
    	}
     	else if (wordinfo.szWord == "do")
    	{
     		InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "###");
     		InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while (###);")
    	}
     	else if (wordinfo.szWord == "case")
    	{
     		SetBufSelText(hbuf, " ###:")
     		InsBufLine(hbuf, ln + 1, "@szLine@" # "###")
     		InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    	}
     	else if (wordinfo.szWord == "struct")
    	{
    	    DelBufLine(hbuf, ln)
            szStructName = toupper(Ask("Please input struct name"))
            InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
            InsBufLine(hbuf, ln + 1, "@szLine1@{");
            InsBufLine(hbuf, ln + 2, "@szLine1@    ###             //");
            szStructName = cat(szStructName,"_STRU")
            InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
    	}
     	else if (wordinfo.szWord == "enum")
    	{
    	    DelBufLine(hbuf, ln)
            szStructName = toupper(Ask("Please input enum name"))
            InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
            InsBufLine(hbuf, ln + 1, "@szLine1@{");
            InsBufLine(hbuf, ln + 2, "@szLine1@    ###             //");
            szStructName = cat(szStructName,"_ENUM")
            InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
    	}
        else if (wordinfo.szWord == "file")
    	{
            InsertFileHeaderEN( hbuf,ln, szMyName,"" )
            return
        }
    	else if (wordinfo.szWord == "func")
    	{
    		DelBufLine(hbuf,ln);
    	    symbol = GetCurSymbol()
        	if(strlen(symbol) != 0)
        	{
              	FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)  
              	return
        	}
        	szFuncName = Ask("Please input function name")
           	FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    	}
    	else if (wordinfo.szWord == "tab")
    	{
        	DelBufLine(hbuf, ln)
            ReplaceBufTab()
            return
    	}
    	else if (wordinfo.szWord == "ap")
    	{   
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	    if(strlen(szQuestion) == 0)
            {
                szQuestion = AddPromblemNo()
            }
            InsBufLine(hbuf, ln, "@szLine1@/* Promblem Number: D@szQuestion@     Author:@szMyName@,   Date:@sz@/@sz1@/@sz3@ ");
        	szContent = Ask("Description")
            szLeft = cat(szLine1,"   Description    : ");
        	ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        	return
       	}
        else if (wordinfo.szWord == "fd")
    	{
      	    DelBufLine(hbuf, ln)
      	    //禁用该功能 lkf 2003-9-4
           //CreateFuncDef(hbuf,szMyName,Language)
         	return
    	}
        else if (wordinfo.szWord == "as")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
        	
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	    if(strlen(szQuestion)>0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   PN:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ ");        
            }
            return
        }
        else if (wordinfo.szWord == "ae")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln, "@szLine1@// END:   Added by @szMyName@, @sz@.@sz1@.@sz3@ ");
            return
        }
        else if (wordinfo.szWord == "ds")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	        if(strlen(szQuestion) > 0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   PN:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ ");
            }
            
            return
        }
        else if (wordinfo.szWord == "de")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln + 0)
            InsBufLine(hbuf, ln, "@szLine1@// END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ ");
            return
        }
        else if (wordinfo.szWord == "ms")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
    	    szQuestion = GetReg ("PNO")
    	    if(strlen(szQuestion) > 0)
    	    {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   PN:D@szQuestion@");
            }
            else
            {
                InsBufLine(hbuf, ln, "@szLine1@// BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ ");
            }
            return
        }
        else if (wordinfo.szWord == "me")
        {
          	SysTime = GetSysTime(1)
           	sz=SysTime.Year
        	sz1=SysTime.month
        	sz3=SysTime.day
    
    	    DelBufLine(hbuf, ln)
            InsBufLine(hbuf, ln, "@szLine1@// END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ ");
            return
        }
    	else
    	{
    		stop
        }
    }
	SetWndSel(hwnd, sel)
	LoadSearchPattern("###", 1, 0, 1);
	Search_Forward
}

macro InsertFuncName()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	hbuf = GetWndBuf(hwnd)
	symbolname = GetCurSymbol()
    SetBufSelText (hbuf, symbolname)
}

macro strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
        return 0
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j]) 
                    break
            }     
            if(j == len2)
                return i
            j = 0
        }
        i = i + 1      
    }  
    return 0
}

macro InsertTraceInfo()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	hbuf = GetWndBuf(hwnd)
	symbolname = GetCurSymbol()
	InsBufLine(hbuf, sel.lnFirst,  "")
	InsBufLine(hbuf, sel.lnFirst,  "    VOS_Debug_Trace(\" \\r\\n @symbolname@() entry\");")
	symbol = GetSymbolLocation (symbolname)
	szLine = GetBufLine(hbuf, symbol.lnLim);
	ret =strstr(szLine,"return")
	if(ret != 0)
	{
	    ln = symbol.lnLim;
	}
	else
	{
    	szLine = GetBufLine(hbuf, symbol.lnLim-1);
    	ret =strstr(szLine,"return")
    	if(ret != 0)
    	{
    	    ln = symbol.lnLim - 1
    	}
    	else
    	{
    	    ln = symbol.lnLim + 1 
    	}
	}
	InsBufLine(hbuf, ln,  "    VOS_Debug_Trace(\"\\r\\n @symbolname@() exit\");")	    
	InsBufLine(hbuf, ln,  "")	    
}

macro InsertFileHeaderEN(hbuf, ln,szName,szContent)
{
	DelBufLine(hbuf, ln + 0)
	
    isymMax = GetBufSymCount (hbuf)
	InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
	InsBufLine(hbuf, ln + 1,  "")
	InsBufLine(hbuf, ln + 2,  "  Copyright (C), 2001-2011, Mindray Tech. Co., Ltd.")
	InsBufLine(hbuf, ln + 3,  "")
	InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
	sz = GetFileName(GetBufName (hbuf))
	InsBufLine(hbuf, ln + 5,  "  File Name     : @sz@")
	InsBufLine(hbuf, ln + 6,  "  Version       : Initial Draft")
	InsBufLine(hbuf, ln + 7,  "  Author        : @szName@")
	SysTime = GetSysTime(1)
	sz=SysTime.Year
	sz1=SysTime.month
	sz3=SysTime.day
	szTime = SysTime.Date
	InsBufLine(hbuf, ln + 8,  "  Created       : @sz@/@sz1@/@sz3@")
	InsBufLine(hbuf, ln + 9,  "  Last Modified :")
//	InsBufLine(hbuf, ln + 10, "  Description   :")
//	InsBufLine(hbuf, ln + 11, "  Function List :")
	szTmp = "  Description   : "
	iLen = strlen (szContent)
	if( iLen != 0)
	{
    	InsBufLine(hbuf, ln + 10, "  Description   : @szContent@")
	}
	else
	{
    	szContent = Ask("Description")
    	ln = CommentContent(hbuf,ln + 10,"  Description   : ",szContent,0) - 10
/*		iLen = strlen (szContent)
        i = 0
	    while  (iLen - i > 63 )
	    {
	        j = 0
	        while(j < 63)
	        {
	            iNum = szContent[i + j]
	            if( AsciiFromChar (iNum)  > 160 )
	            {
	               j = j + 2
	            }
	            else
	            {
                   j = j + 1
	            }
	            if( (j > 50) && (szContent[i + j] == " ") )
	            {
	                break
	            }
	        }
	        szLine = strmid(szContent,i,i+j)
	        szLine = cat(szTmp,szLine)
	        ln = ln + 1
        	InsBufLine(hbuf, ln + 9, "@szLine@")
        	szTmp = "               "
	        i = i + j
	    }
        szLine = strmid(szContent,i,iLen)
        szLine = cat(szTmp,szLine)
    	InsBufLine(hbuf, ln + 10, "@szLine@")*/
	}
/*	InsBufLine(hbuf, ln + 11, "  Function List :")
    isym = 0
    while (isym < isymMax) 
    {
    	symbol = GetBufSymLocation(hbuf, isym)
    	if(strlen(symbol) > 0)
    	{
    		if((symbol.Type == "Function") || ("Editor Macro" == symbol.Type))
        	{
        	    symtype = SymbolDeclaredType (symbol)
        	    symname = symbol.Symbol
            	InsBufLine(hbuf, ln+12, "              @symname@")
            	ln = ln + 1;
           	}
       	}
    	isym = isym + 1
    }*/
	InsBufLine(hbuf, ln + 12, "  History       :")
	InsBufLine(hbuf, ln + 13, "  1.Date        : @sz@/@sz1@/@sz3@")
	InsBufLine(hbuf, ln + 14, "    Author      : @szName@")
	InsBufLine(hbuf, ln + 15, "    Modification: Created file")
	InsBufLine(hbuf, ln + 16, "")
	InsBufLine(hbuf, ln + 17, "******************************************************************************/")
	InsBufLine(hbuf, ln + 18, "")
}

macro InsertClassHeaderCN(hbuf, ln,szName,szContent)
{
    
}

macro InsertFileHeaderCN(hbuf, ln,szName,szContent)
{
	DelBufLine(hbuf, ln + 0)
    isymMax = GetBufSymCount (hbuf)
	
	InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
	InsBufLine(hbuf, ln + 1,  "")
	InsBufLine(hbuf, ln + 2,  "                  版权所有 (C), 2001-2011, 深圳迈瑞生物医疗电子股份有限公司")
	InsBufLine(hbuf, ln + 3,  "")
	InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
	sz = GetFileName(GetBufName (hbuf))
	InsBufLine(hbuf, ln + 5,  "  文 件 名   : @sz@")
	InsBufLine(hbuf, ln + 6,  "  版 本 号   : 初稿")
	InsBufLine(hbuf, ln + 7,  "  作    者   : @szName@")
	SysTime = GetSysTime(1)
	sz=SysTime.Year
	sz1=SysTime.month
	sz3=SysTime.day
	szTime = SysTime.Date
	InsBufLine(hbuf, ln + 8,  "  生成日期   : @szTime@")
	InsBufLine(hbuf, ln + 9,  "  最近修改   :")
	iLen = strlen (szContent)
	szTmp = "  功能描述   : "
	if( iLen != 0)
	{
    	InsBufLine(hbuf, ln + 10, "  功能描述   : @szContent@")
	}
	else
	{
    	szContent = Ask("请输入文件功能描述的内容")
    	ln = CommentContent(hbuf,ln+10,"  功能描述   : ",szContent,0) - 10

/*    	iLen = strlen (szContent)
	    i = 0
	    while  (iLen - i > 63 )
	    {
	        j = 0
	        while(j < 63)
	        {
	            iNum = szContent[i + j]
	            if( AsciiFromChar (iNum)  > 160 )
	            {
	               j = j + 2
	            }
	            else
	            {
                   j = j + 1
	            }
	            if( (j > 50) && (szContent[i + j] == " ") )
	            {
	                break
	            }
	        }
	        szLine = strmid(szContent,i,i+j)
	        szLine = cat(szTmp,szLine)
	        ln = ln + 1
        	InsBufLine(hbuf, ln + 9, "@szLine@")
        	szTmp = "               "
	        i = i + j
	    }
        szLine = strmid(szContent,i,iLen)
        szLine = cat(szTmp,szLine)
    	InsBufLine(hbuf, ln + 10, "@szLine@")
    	*/
	}
/*	InsBufLine(hbuf, ln + 11, "  函数列表   :")
    isym = 0
    while (isym < isymMax) 
    {
    	symbol = GetBufSymLocation(hbuf, isym)
    	if(strlen(symbol) > 0)
    	{
    		if((symbol.Type == "Function") || ("Editor Macro" == symbol.Type))
        	{
        	    symtype = SymbolDeclaredType (symbol)
        	    symname = symbol.Symbol
            	InsBufLine(hbuf, ln+12, "              @symname@")
            	ln = ln + 1;
           	}
       	}
    	isym = isym + 1
    }*/

	InsBufLine(hbuf, ln + 12, "  修改历史   :")
	InsBufLine(hbuf, ln + 13, "  1.日    期   : @szTime@")

	if( strlen(szMyName)>0 )
	{
       InsBufLine(hbuf, ln + 14, "    作    者   : @szName@")
	}
	else
	{
       InsBufLine(hbuf, ln + 14, "    作    者   : ###")
	}
	InsBufLine(hbuf, ln + 15, "    修改内容   : 生成")	
	InsBufLine(hbuf, ln + 16, "")
	InsBufLine(hbuf, ln + 17, "******************************************************************************/")
	InsBufLine(hbuf, ln + 18, "")
}

macro PDLFuncHead(hbuf, ln, szFunc, szMyName,newFunc)
{
    symbol = GetSymbolLocation (szFunc)
   	if(strlen(symbol) > 0)
   	{
        szLine = GetBufLine (hbuf, symbol.lnName)
        iLineLen = strlen(szLine)
        iBegin = symbol.ichName +strlen(szFunc)
    }
    else
    {
        szLine = ""
    }
	InsBufLine(hbuf, ln, "/*****************************************************************************")
	if( strlen(szFunc)>0 )
	{
		InsBufLine(hbuf, ln+1, " 函 数 名  : @szFunc@")
	}
	else
	{
		InsBufLine(hbuf, ln+1, " 函 数 名  : ###")
	}
	szContent = Ask("请输入函数功能描述的内容")
	iLen = strlen (szContent)
	szTmp = " 功能描述  : "
   	InsBufLine(hbuf, ln+2, " 功能描述  : ###")
	szIns = " 输入参数  : "
	i = iBegin
	if(iLineLen > 0)
	{
        iIns = 0
        while(i < iLineLen)
        {
            if(szLine[i] == "(")
            {
               while(szLine[i+1] == " ")
               {
                     i = i + 1
               }
               j = i + 1
               while( i < iLineLen)
               {
                  if((szLine[i] == ",") || (szLine[i] == ")"))
                  {
                       szTmp = strmid(szLine,j,i)
                       while(szLine[i+1] == " ")
                       {
                             i = i + 1
                       }
                       j = i + 1
                       ln = ln + 1
                       szTmp = cat(szIns,szTmp)
                       InsBufLine(hbuf, ln+2, "@szTmp@")
                       iIns = 1
                       szIns = "             "
                  }
                  i = i + 1
               }
            }
            i = i + 1
        }
	}
	if(iIns == 0)
	{       
	        ln = ln + 1
    		InsBufLine(hbuf, ln+2, " 输出参数  : 无")
	}
	InsBufLine(hbuf, ln+3, " 输出参数  : 无")
	InsBufLine(hbuf, ln+4, " 返 回 值  : 无")
	InsBufLine(hbuf, ln+5, " 调用函数  : 无")
	InsBufLine(hbuf, ln+6, " 被调函数  : 无")
	InsbufLIne(hbuf, ln+7, " ");
	if ((newFunc == 1) && (strlen(szFunc)>0))
	{
	    InsBufLine(hbuf, ln+13, "### @szFunc@(###)")
	    InsBufLine(hbuf, ln+14, "{");
	    InsBufLine(hbuf, ln+16, "}");
    }	    
}


macro CommentContent1(hbuf,ln,szPreStr,szContent)
{
	iLen = strlen (szContent)
	k = strlen (szPreStr)
	isFirst = 1
	if( iLen == 0)
	{
         SetBufSelText(hbuf, "###  */");
	}
	else if (iLen <= 73 - iLen)
	{
         SetBufSelText(hbuf, "@szContent@ */");
	}
	else
	{
	    i = 0
	    /*如果注释超过一行*/
	    while  (iLen - i > 73 )
	    {
	        j = 0
	        while(j < 73)
	        {
	            iNum = szContent[i + j]
	            if( AsciiFromChar (iNum)  > 160 )
	            {
	               j = j + 2
	            }
	            else
	            {
                   j = j + 1
	            }
	            if( (j > 50) && (szContent[i + j] == " ") )
	            {
	                break
	            }
	        }
	        sz1 = strmid(szContent,i,i+j)
	        sz1 = cat(szPreStr,sz1)
	        if(isFirst == 1)
	        {
                 SetBufSelText(hbuf, "@sz1@");      
                 isFirst = 0
	        }
	        else
	        {
            	InsBufLine(hbuf, ln, "@sz1@")
          	}
	        ln = ln + 1
	        i = i + j
	    }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
       	InsBufLine(hbuf, ln, "@sz1@ */")
	}
    return ln
}

macro FormatLine()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	if (sel.ichFirst == 0)
		stop
	hbuf = GetWndBuf(hwnd)
	// get line the selection (insertion point) is on
	szCurLine = GetBufLine(hbuf, sel.lnFirst);
	lineLen = strlen(szCurLine)
	szLeft = strmid(szCurLine,0,sel.ichFirst)
	szContent = strmid(szCurLine,sel.ichFirst,lineLen)
    DelBufLine(hbuf, sel.lnFirst)
	CommentContent(hbuf,sel.lnFirst,szLeft,szContent,0)        	

}

macro CommentContent(hbuf,ln,szPreStr,szContent,isEnd)
{
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }
	iLen = strlen (szContent)
	szTmp = cat(szPreStr,"###");
	if( iLen == 0)
	{
    	InsBufLine(hbuf, ln, "@szTmp@")
	}
	else
	{
	    i = 0
	    while  (iLen - i > 75 - k )
	    {
	        j = 0
	        while(j < 75 - k)
	        {
	            iNum = szContent[i + j]
	            if( AsciiFromChar (iNum)  > 160 )
	            {
	               j = j + 2
	            }
	            else
	            {
                   j = j + 1
	            }
	            if( (j > 70 - k) && (szContent[i + j] == " ") )
	            {
	                break
	            }
	        }
            if( (szContent[i + j] != " " ) )
            {
                n = 1;
                iNum = szContent[i + j + n]
                while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
    	        {
    	            n = n + 1
    	            if((n >= 3) ||(i + j + n >= iLen))
         	            break;
    	            iNum = szContent[i + j + n]
   	            }
	            if(n < 3)
	            {
	                j = j + n - 1
        	        sz1 = strmid(szContent,i,i+j)
        	        sz1 = cat(szPreStr,sz1)                
	            }
	            else
	            {
        	        sz1 = strmid(szContent,i,i+j)
        	        sz1 = cat(szPreStr,sz1)                
        	        sz1 = cat(sz1,"-")                
	            }
            }
            else
            {
    	        sz1 = strmid(szContent,i,i+j)
    	        sz1 = cat(szPreStr,sz1)
   	        }
        	InsBufLine(hbuf, ln, "@sz1@")
	        ln = ln + 1
        	szPreStr = szLeftBlank
	        i = i + j
            while(szContent[i] == " ")
	        {
	            i = i + 1
	        }
	    }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
        if(isEnd)
        {
            sz1 = cat(sz1,"*/")
        }
       	InsBufLine(hbuf, ln, "@sz1@")
	}
    return ln
}


macro FuncHeadCommentCN(hbuf, ln, szFunc, szMyName,newFunc)
{
    if(newFunc != 1)
    {
        symbol = GetSymbolLocation (szFunc)
       	if(strlen(symbol) > 0)
       	{
            szLine = GetBufLine (hbuf, symbol.lnName)
            iLineLen = strlen(szLine)
            iBegin = symbol.ichName +strlen(szFunc)
            iBegLn = symbol.lnFirst + 3
        }
    }
    else
    {
        iLineLen = 0
        iBegLn = ln + 4
        iIns = 0
        szLine = ""
    }
	InsBufLine(hbuf, ln, "/*****************************************************************************")
	if( strlen(szFunc)>0 )
	{
		InsBufLine(hbuf, ln+1, " 函 数 名  : @szFunc@")
	}
	else
	{
		InsBufLine(hbuf, ln+1, " 函 数 名  : ###")
	}
	szContent = Ask("请输入函数功能描述的内容")
	oldln = ln
	ln = ln + 2
	ln = CommentContent(hbuf,ln," 功能描述  : ",szContent,0) - 2
	szIns = " 输入参数  : "
	isSingleLn = 1;
	i = iBegin
	iBegLn = iBegLn + ln - oldln
	if(iLineLen > 0)
	{
        iIns = 0
        while(i < iLineLen)
        {
            if(szLine[i] == "(")
            {
               while(szLine[i+1] == " ")
               {
                     i = i + 1
               }
               j = i + 1
               while(i < iLineLen)
               {
                  if((szLine[i] == ",") || (szLine[i] == ")") || (i == iLineLen-1)
                  {
                       if(szLine[i] == ")")
                       {
                           isSingleLn = 0;
                       }    
                       if((szLine[i] == ",") || (szLine[i] == ")"))
                       {                           
                           szTmp = strmid(szLine,j,i)
                       } 
                       else
                       {
                           szTmp = strmid(szLine,j,iLineLen)
                       }
                       while(szLine[i+1] == " ")
                       {
                             i = i + 1
                             if(i == iLineLen)
                             {
                                break;
                             }
                       }
                       j = i + 1
                       if(strlen(szTmp))
                       {
                          ln = ln + 1
                          iBegLn = iBegLn + 1;
                          szTmp = cat(szIns,szTmp)
                          InsBufLine(hbuf, ln+2, "@szTmp@")
                          iIns = 1
                          szIns = "             "
                       }
                  }
                  if(szLine[i] == "{")
                  {
                       break;
                  }
                  i = i + 1
                  /*参数是由多行组成的*/
                  if((isSingleLn != 0) && (iLineLen == i))
                  {
                      iBegLn = iBegLn + 1;
                      szLine = GetBufLine (hbuf, iBegLn) 
                      iLineLen = strlen(szLine)
                      if(iLineLen == 0)
                      {
                          break
                      }
                      i = 0;
                      while(szLine[i] == " ")
                      {
                            if(szLine[i] == "{")
                            {
                               break;
                               i = iLineLen
                            }
                            i = i + 1
                      }
                      j = i 
                  }
               }
            }
            i = i + 1
        }
	}
	if(iIns == 0)
	{       
	        ln = ln + 1
    		InsBufLine(hbuf, ln+2, " 输入参数  : 无")
	}
	InsBufLine(hbuf, ln+3, " 输出参数  : 无")
	InsBufLine(hbuf, ln+4, " 返 回 值  : 无")
	InsBufLine(hbuf, ln+5, " 调用函数  : 无")
	InsBufLine(hbuf, ln+6, " 被调函数  : 无")
	InsbufLIne(hbuf, ln+7, " ");
	InsBufLine(hbuf, ln+8, " 修改历史      :")
	
	SysTime = GetSysTime(1);
	szTime = SysTime.Date

	InsBufLine(hbuf, ln+9, "  1.日    期   : @szTime@")

	if( strlen(szMyName)>0 )
	{
       InsBufLine(hbuf, ln+10, "    作    者   : @szMyName@")
	}
	else
	{
       InsBufLine(hbuf, ln+10, "    作    者   : ###")
	}
	InsBufLine(hbuf, ln+11, "    修改内容   : 新生成函数")	
	InsBufLine(hbuf, ln+12, "")	
	InsBufLine(hbuf, ln+13, "*****************************************************************************/")
	if ((newFunc == 1) && (strlen(szFunc)>0))
	{
	    InsBufLine(hbuf, ln+14, "### @szFunc@(###)")
	    InsBufLine(hbuf, ln+15, "{");
	    InsBufLine(hbuf, ln+16, "}");
    }	    
    return ln + 16
}


macro FuncHeadCommentEN(hbuf, ln, szFunc, szMyName,newFunc)
{
    if(newFunc != 1)
    {
        symbol = GetSymbolLocation (szFunc)
       	if(strlen(symbol) > 0)
       	{
            szLine = GetBufLine (hbuf, symbol.lnName)
            iLineLen = strlen(szLine)
            iBegin = symbol.ichName +strlen(szFunc)
            iBegLn = symbol.lnFirst + 3
        }
    }
    else
    {
        iLineLen = 0
        iBegLn = ln + 4
        iIns = 0
        szLine = ""
    }
	InsBufLine(hbuf, ln, "/*****************************************************************************")
	InsBufLine(hbuf, ln+1, " Prototype    : @szFunc@")
	szContent = Ask("Description")
	oldln = ln
	ln = ln + 2
	ln = CommentContent(hbuf,ln," Description  : ",szContent,0) - 2
	szIns = " Input Param  : "
	isSingleLn = 1;
	i = iBegin
	iBegLn = iBegLn + ln - oldln
	if(iLineLen > 0)
	{
        iIns = 0
        while(i < iLineLen)
        {
            if(szLine[i] == "(")
            {
               while(szLine[i+1] == " ")
               {
                     i = i + 1
               }
               j = i + 1
               while(i < iLineLen)
               {
                  if((szLine[i] == ",") || (szLine[i] == ")") || (i == iLineLen-1)
                  {
                       if(szLine[i] == ")")
                       {
                           isSingleLn = 0;
                       }    
                       if((szLine[i] == ",") || (szLine[i] == ")"))
                       {                           
                           szTmp = strmid(szLine,j,i)
                       } 
                       else
                       {
                           szTmp = strmid(szLine,j,iLineLen)
                       }
                       while(szLine[i+1] == " ")
                       {
                             i = i + 1
                             if(i == iLineLen)
                             {
                                break;
                             }
                       }
                       j = i + 1
                       if(strlen(szTmp))
                       {
                          ln = ln + 1
                          iBegLn = iBegLn + 1;
                          szTmp = cat(szIns,szTmp)
                          InsBufLine(hbuf, ln+2, "@szTmp@")
                          iIns = 1
                          szIns = "                "
                       }
                  }
                  if(szLine[i] == "{")
                  {
                       break;
                  }
                  i = i + 1
                  /*参数是由多行组成的*/
                  if((isSingleLn != 0) && (iLineLen == i))
                  {
                      iBegLn = iBegLn + 1;
                      szLine = GetBufLine (hbuf, iBegLn) 
                      iLineLen = strlen(szLine)
                      if(iLineLen == 0)
                      {
                          break
                      }
                      i = 0;
                      while(szLine[i] == " ")
                      {
                            if(szLine[i] == "{")
                            {
                               break;
                               i = iLineLen
                            }
                            i = i + 1
                      }
                      j = i 
                  }
               }
            }
            i = i + 1
        }
	}
	if(iIns == 0)
	{       
	        ln = ln + 1
    		InsBufLine(hbuf, ln+2, " Input        : None")
	}
	InsBufLine(hbuf, ln+3, " Output       : None")
	InsBufLine(hbuf, ln+4, " Return Value : None")
	InsBufLine(hbuf, ln+5, " Calls        : None")
	InsBufLine(hbuf, ln+6, " Called By    : None")
	InsbufLIne(hbuf, ln+7, " ");
	
	SysTime = GetSysTime(1);
	sz1=SysTime.Year
	sz2=SysTime.month
	sz3=SysTime.day

	InsBufLine(hbuf, ln + 8, "  History        :")
	InsBufLine(hbuf, ln + 9, "  1.Date         : @sz1@/@sz2@/@sz3@")
	InsBufLine(hbuf, ln + 10, "    Author       : @szMyName@")
	InsBufLine(hbuf, ln + 11, "    Modification : Created function")
	InsBufLine(hbuf, ln + 12, "")	
	InsBufLine(hbuf, ln + 13, "*****************************************************************************/")
	if ((newFunc == 1) && (strlen(szFunc)>0))
	{
	    InsBufLine(hbuf, ln+14, "### @szFunc@(###)")
	    InsBufLine(hbuf, ln+15, "{");
	    InsBufLine(hbuf, ln+16, "}");
    }	    
    return ln + 16
}

macro InsertHistory(hbuf,ln,language)
{
    iHistoryCount = 1
	isLastLine = ln
    i = 0
    while(ln-i>0)
    {
        szCurLine = GetBufLine(hbuf, ln-i);
        if(language == 0)
        {
            iBeg = strstr(szCurLine,"日    期   :")
        }
        else
        {
            iBeg = strstr(szCurLine,"Date         :")
        }
        if(iBeg != 0)
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
        if(language == 0)
        {
            iBeg = strstr(szCurLine,"修改历史")
        }
        else
        {
            iBeg = strstr(szCurLine,"History        :")
        }
        if(iBeg != 0)
        {
            break
        }
        i = i + 1
    }
    if(language == 0)
    {
        InsertHistoryContentCN(hbuf,ln,iHistoryCount)
    }
    else
    {
        InsertHistoryContentEN(hbuf,ln,iHistoryCount)
    }
}

macro UpdateFunctionList()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	sel = GetWndSel(hwnd)
	if (sel.ichFirst == 0)
		stop
	hbuf = GetWndBuf(hwnd)
	ln = sel.lnFirst
    iHistoryCount = 1
	isLastLine = ln
    iTotalLn = GetBufLineCount (hbuf) 
    i = 0
    while(ln+i < iTotalLn)
    {
        szCurLine = GetBufLine(hbuf, ln+i);
        iLen = strlen(szCurLine)
        j = 0;
        while(j < iLen)
        {
            if(szCurLine[j] != " ")
                break
            j = j + 1
        }
        if(j > 10)
        {
            DelBufLine(hbuf, ln+i)   
        }
        else
        {
            break
        }
    }
    isym = 0
    isymMax = GetBufSymCount (hbuf)
    while (isym < isymMax) 
    {
    	symbol = GetBufSymLocation(hbuf, isym)
    	if(strlen(symbol) > 0)
    	{
    		if((symbol.Type == "Function") || ("Editor Macro" == symbol.Type))
        	{
        	    symtype = SymbolDeclaredType (symbol)
        	    symname = symbol.Symbol
            	InsBufLine(hbuf, ln+i, "              @symname@")
            	ln = ln + 1;
           	}
       	}
    	isym = isym + 1
    }
  	InsBufLine(hbuf, ln+i, "")
 }
 
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
	SysTime = GetSysTime(1);
	szTime = SysTime.Date
	szMyName = getreg(MYNAME)

	InsBufLine(hbuf, ln, "")
	InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.日    期   : @szTime@")

	if( strlen(szMyName) > 0 )
	{
       InsBufLine(hbuf, ln + 2, "    作    者   : @szMyName@")
	}
	else
	{
       InsBufLine(hbuf, ln + 2, "    作    者   : ###")
	}
   	szContent = Ask("请输入修改的内容")
   	CommentContent(hbuf,ln + 3,"    修改内容   : ",szContent,0)
}

macro  InsertHistoryContentEN(hbuf,ln,iHostoryCount)
{
	SysTime = GetSysTime(1);
	szTime = SysTime.Date
	sz1=SysTime.Year
	sz2=SysTime.month
	sz3=SysTime.day
	szMyName = getreg(MYNAME)
	InsBufLine(hbuf, ln, "")
	InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.Date         : @sz1@/@sz2@/@sz3@")

    InsBufLine(hbuf, ln + 2, "    Author       : @szMyName@")
   	szContent = Ask("Please input modification")
   	CommentContent(hbuf,ln + 3,"    Modification : ",szContent,0)
}

/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the 
    text word just to the left of the ich.

    Output:
    	wordinfo.szWord = the word string
    	wordinfo.ich = the first ich of the word
    	wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
	wordinfo = "" // create a "wordinfo" structure
	
	chTab = CharFromAscii(9)
	
	// scan backwords over white space, if any
	ich = ich - 1;
	if (ich >= 0)
		while (sz[ich] == " " || sz[ich] == chTab)
			{
			ich = ich - 1;
			if (ich < 0)
				break;
			}
	
	// scan backwords to start of word	
	ichLim = ich + 1;
	asciiA = AsciiFromChar("A")
	asciiZ = AsciiFromChar("Z")
	while (ich >= 0)
		{
		ch = toupper(sz[ich])
		asciiCh = AsciiFromChar(ch)
		

		if ((asciiCh < asciiA || asciiCh > asciiZ) 
	       && !IsNumber(ch)
		   && (ch != "{" && ch != "/" && ch != "*"))
			break;

		/*
		* del by sukun, 2001.3.1
		* to recognise { or /*
		*
		*if ((asciiCh < asciiA || asciiCh > asciiZ) && !IsNumber(ch))
		*	break // stop at first non-identifier character
		* del end, 2001.3.1
		*/			
		ich = ich - 1;
		}
	
	ich = ich + 1
	wordinfo.szWord = strmid(sz, ich, ichLim)
	wordinfo.ich = ich
	wordinfo.ichLim = ichLim;
	
	return wordinfo
}

/*
macro ReplaceBufTab(hbuf)
{
    iTotalLn = GetBufLineCount (hbuf)
    ReplaceInBuf(hbuf,"\t","    ",0, iTotalLn, 1, 0, 0, 1)
}
*/
macro ReplaceBufTab()
{
	hwnd = GetCurrentWnd()
	if (hwnd == 0)
		stop
	hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    ReplaceInBuf(hbuf,"\t","    ",0, iTotalLn, 1, 0, 0, 1)
}

macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)

    ifile = 0
    while (ifile < ifileMax)
	{
	    filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t","    ",0, iTotalLn, 1, 0, 0, 1)
        }
        ifile = ifile + 1
	}
}

macro CreateFuncDef(hbuf,szName,Language)
{
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    ln = 0
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {    
        szFileName = "TEMP"
    }
    szPreH = toupper (szFileName)
    sz = cat(szFileName,".h")
    szPreH = cat("__",szPreH)
    szPreH = cat(szPreH,"_H__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
    	stop
    while (isym < isymMax) 
    {
        isLastLine = 0;
    	symbol = GetBufSymLocation(hbuf, isym)

    	if(strlen(symbol) > 0)
    	{
    		if(symbol.Type == "Function")
        	{
                szLine = GetBufLine (hbuf, symbol.lnName)
                szLine = cat("extern ",szLine)
          	    sline = symbol.lnFirst	 
          	    while((isLastLine == 0) && (sline < symbol.lnLim))
            	{   
            	    i = 0
            	    j = 0
            	    iLen = strlen(szLine)
                	while(i < iLen)
                	{
                	    if(szLine[i]=="(")
                	    {
                	       j = j + 1;
                	    }
                	    else if(szLine[i]==")")
                	    {
                	        j = j - 1;
                	        if(j <= 0)
                	        {
                    	        isLastLine = 1                    	        
                    	        strtrunc(szLine,i);
                    	        szLine = cat(szLine,";")
                    	        break
                	        }
                	    }
                	    i = i + 1
                 	}
                   	InsBufLine(hOutbuf, ln, "@szLine@")
                 	ln = ln + 1
                 	sline = sline + 1
                    if(isLastLine != 1)
                    {              
                        szLine = GetBufLine (hbuf, sline)
               	        szLine = cat("       ",szLine)
                   	}                    
               	}
           	}
       	}
    	isym = isym + 1
    }
    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(Language == 0)
    {
        szContent = cat(szContent," 的头文件")
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)        
    }
}



macro ConfigureSystem()
{
    szLanguage = ASK("Please select language: 0 Chinese ,1 English");
    if(szLanguage == "###")
    {
       SetReg ("LANGUAGE", "0")
    }
    else
    {
       SetReg ("LANGUAGE", szLanguage)
    }
    
    szName = ASK("Please input your name");
    if(szName == "###")
    {
       SetReg ("MYNAME", "")
    }
    else
    {
       SetReg ("MYNAME", szName)
    }
}

macro AddPromblemNo()
{
    szQuestion = ASK("Please Input problem number (five digits)");
    if(szQuestion == "###")
    {
       szQuestion = ""
       SetReg ("PNO", "")
    }
    else
    {
       SetReg ("PNO", szQuestion)
    }
    return szQuestion
}

/*
this macro convet selected  C++ coment block to C comment block 
for example:
  line "  // aaaaa "
  convert to  /* aaaaa */
*/
macro ComentCPPtoC()
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	lnCurrent = lnFirst
	while lnCurrent <= lnLast
	{
		CmtCvtLine(lnCurrent)
		lnCurrent = lnCurrent + 1;
	}
}

//   aaaaaaa
macro CmtCvtLine(lnCurrent)
{
	hbuf = GetCurrentBuf()
	szLine = GetBufLine(hbuf,lnCurrent)
	ch_comment = CharFromAscii(47)   
	ich = 0
	ilen = strlen(szLine)

	iIsComment = 0;
	
	while ( ich < ilen -1 )
	{
		if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
		{
			szLine[ich+1] = "*"
			szLine = cat(szLine,"  */")
			DelBufLine(hbuf,lnCurrent)
			InsBufLine(hbuf,lnCurrent,szLine)
			return 1
		}
		ich = ich + 1
	}
	return 0
}
macro GetFileNameNoExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i 
      }
      if((sz[iLen-i] == "\\") || (i == iLen))
      {
        szName = strmid(sz,iLen-i+1,j)
        break
      }
      i = i + 1
    }
    return szName
}

macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == "\\")
      {
        szName = strmid(sz,iLen-i+1,iLen)
        break
      }
      i = i + 1
    }
    return szName
}

macro InsIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefStr(sz);
}

macro InsertCPP(hbuf,ln)
{
	InsBufLine(hbuf, ln, "")
	InsBufLine(hbuf, ln, "#endif /* __cplusplus */")
	InsBufLine(hbuf, ln, "#endif")
	InsBufLine(hbuf, ln, "extern \"C\"{")
	InsBufLine(hbuf, ln, "#if __cplusplus")
	InsBufLine(hbuf, ln, "#ifdef __cplusplus")
	InsBufLine(hbuf, ln, "")
	
    iTotalLn = GetBufLineCount (hbuf)            
	InsBufLine(hbuf, iTotalLn, "")
	InsBufLine(hbuf, iTotalLn, "#endif /* __cplusplus */")
	InsBufLine(hbuf, iTotalLn, "#endif")
	InsBufLine(hbuf, iTotalLn, "}")
	InsBufLine(hbuf, iTotalLn, "#if __cplusplus")
	InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
	InsBufLine(hbuf, iTotalLn, "")
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefStr(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	if(lnLast > 0)
    	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
	else
		InsBufLine(hbuf, lnLast+1, "#endif /* @sz@ */")
}

macro HeadIfdefStr(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "")
	InsBufLine(hbuf, lnFirst, "#define @sz@")
	InsBufLine(hbuf, lnFirst, "#ifndef @sz@")
    iTotalLn = GetBufLineCount (hbuf)            	
	InsBufLine(hbuf, iTotalLn, "#endif /* @sz@ */")
	InsBufLine(hbuf, iTotalLn, "")
}
macro FormatIdFile()
{
	hwnd = GetCurrentWnd()
	hbuf = GetCurrentBuf()
    iTotalLn = GetBufLineCount (hbuf)       
    iIndexLn = 0
    iIndexChar = 0
	strConstInt = SearchInBuf(hbuf,"const\\s+int\\s+[_a-zA-Z0-9]+",iIndexLn,iIndexChar,False,True,True)
    while( strConstInt != Nil )
    {
  		//Msg (strConstInt)
    	iIndexLn = strConstInt.lnFirst
    	iIndexChar = strConstInt.ichLim 
 		szLineContent = strmid(GetBufLine(hbuf,iIndexLn),0,iIndexChar)
  		//Msg (szLineContent)
		iPosiOfEq = 55;
		iSpaceNumToEq = iPosiOfEq - strlen(szLineContent)
		while(iSpaceNumToEq > 0)
		{
			szLineContent = cat(szLineContent," ");
			iSpaceNumToEq = iSpaceNumToEq -1
		}

		strConstInt = SearchInBuf(hbuf,"=[^;]+",iIndexLn,iIndexChar-1,False,True,False)
  		//Msg (strConstInt)
		if(iIndexLn == strConstInt.lnFirst)
		{
	    	iIndexChar = strConstInt.ichLim 
	 		szLineContent = cat(szLineContent, strmid(GetBufLine(hbuf,iIndexLn),strConstInt.ichFirst ,iIndexChar))
	 		szLineContent = cat(szLineContent ,";")
	 		//Msg (szLineContent)		

			DelBufLine (hbuf, iIndexLn)
			InsBufLine (hbuf, iIndexLn,szLineContent)
		}
  		//Msg (szLineContent)		
		strConstInt = SearchInBuf(hbuf,"const\\s+int\\s+[_a-zA-Z0-9]+",iIndexLn,iIndexChar,False,True,True)
    } 

}

