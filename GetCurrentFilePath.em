macro GetCurrentFilePath()
{
	var hBuf
	hBuf = GetCurrentBuf ()
	if( hNil != hBuf )
	{
		name = GetBufName( hBuf )
        hBuf = NewBuf( "" )
        AppendBufLine( hBuf, name )
        
        CopyBufLine( hBuf, 0 )
        ClearBuf( hBuf )
        CloseBuf( hBuf )
	}
}
