macro GetCurrentFileName()
{
	var hBuf
	hBuf = GetCurrentBuf ()
	if( hNil != hBuf )
	{
		name = GetBufName( hBuf )
		cch = strlen(name)
		ich = GetLastCharInString(name, "\\")
		if(ich>0)
		{
		       fileName = "#include \""
		       ich = ich + 1
			while(ich<cch)
			{
				fileName = cat(fileName, name[ich])
				ich = ich + 1
			}
			fileName = cat(fileName, "\"")
			hBuf = NewBuf( "" )
			AppendBufLine( hBuf, fileName )
			CopyBufLine( hBuf, 0 )
			ClearBuf( hBuf )
	                CloseBuf( hBuf )
		}
	}
}

macro GetLastCharInString(s, ch)
{
	i = 0
	index = 0-1
	cch = strlen(s)
	while (i < cch)
	{
		if (s[i] == ch)
			index = i
		i = i + 1
	}

	return index
}

