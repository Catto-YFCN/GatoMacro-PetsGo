IniFile := A_ScriptDir . "\settings\config.ini"
; HUGE HUGE HUGE CREDIT TO DOLPHSOL 

; hookWhite := 16777215
; hookDiscord := 5066239
; hookRed := 16711680
; hookGreen := 3066993
; hookYellow := 16776960
; hookGray := 8421504
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(retData, retHeader, objParam)
}

Class CreateFormData {

    __New(ByRef retData, ByRef retHeader, objParam) {

        Local CRLF := "`r`n", i, k, v, str, pvData
        ; Create a random Boundary
        Local Boundary := this.RandomBoundary()
        Local BoundaryLine := "------------------------------" . Boundary

        this.Len := 0 ; GMEM_ZEROINIT|GMEM_FIXED = 0x40
        this.Ptr := DllCall( "GlobalAlloc", "UInt",0x40, "UInt",1, "Ptr" ) ; allocate global memory

        ; Loop input paramters
        For k, v in objParam
        {
            If IsObject(v) {
                For i, FileName in v
                {
                    str := BoundaryLine . CRLF
                    . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
                    . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
                    this.StrPutUTF8( str )
                    this.LoadFromFile( Filename )
                    this.StrPutUTF8( CRLF )
                }
            } Else {
                str := BoundaryLine . CRLF
                . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
                . v . CRLF
                this.StrPutUTF8( str )
            }
        }

        this.StrPutUTF8( BoundaryLine . "--" . CRLF )

        ; Create a bytearray and copy data in to it.
        retData := ComObjArray( 0x11, this.Len ) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
        pvData := NumGet( ComObjValue( retData ) + 8 + A_PtrSize )
        DllCall( "RtlMoveMemory", "Ptr",pvData, "Ptr",this.Ptr, "Ptr",this.Len )

        this.Ptr := DllCall( "GlobalFree", "Ptr",this.Ptr, "Ptr" ) ; free global memory 

        retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
    }

    StrPutUTF8( str ) {
        Local ReqSz := StrPut( str, "utf-8" ) - 1
        this.Len += ReqSz ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42
        this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len + 1, "UInt", 0x42 ) 
        StrPut( str, this.Ptr + this.len - ReqSz, ReqSz, "utf-8" )
    }

    LoadFromFile( Filename ) {
        Local objFile := FileOpen( FileName, "r" )
        this.Len += objFile.Length ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42 
        this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len, "UInt", 0x42 )
        objFile.RawRead( this.Ptr + this.Len - objFile.length, objFile.length )
        objFile.Close() 
    }

    RandomBoundary() {
        str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
        Sort, str, D| Random
        str := StrReplace(str, "|")
        Return SubStr(str, 1, 12)
    }

    MimeType(FileName) {
        n := FileOpen(FileName, "r").ReadUInt()
        Return (n = 0x474E5089) ? "image/png"
        : (n = 0x38464947) ? "image/gif"
        : (n&0xFFFF = 0x4D42 ) ? "image/bmp"
        : (n&0xFFFF = 0xD8FF ) ? "image/jpeg"
        : (n&0xFFFF = 0x4949 ) ? "image/tiff"
        : (n&0xFFFF = 0x4D4D ) ? "image/tiff"
        : "application/octet-stream"
    }

}

webhookPost(data := 0) {
    global webhookLink
    global webhookToggle

    if (webhookToggle = 1) {
        ; Get the current time whenever this function is called
        FormatTime, currentTime,, HH:mm:ss
        data := data ? data : {}
        
        ; Use the currentTime in the embed content
        url := webhookLink
        payload_json := "
        (LTrim Join
        {
            ""content"": """ data.content """,
            ""embeds"": [{
                " (data.embedAuthor ? """author"": {""name"": """ data.embedAuthor """" (data.embedAuthorImage ? ",""icon_url"": """ data.embedAuthorImage """" : "") "}," : "") "
                " (data.embedTitle ? """title"": """ data.embedTitle """," : "") "
                ""description"": ""[" currentTime "] " data.embedContent """,
                " (data.embedThumbnail ? """thumbnail"": {""url"": """ data.embedThumbnail """}," : "") "
                " (data.embedImage ? """image"": {""url"": """ data.embedImage """}," : "") "
                " (data.embedFooter ? """footer"": {""text"": """ data.embedFooter """}," : "") "
                ""color"": """ (data.embedColor ? data.embedColor : 0) """
            }]
        }
        )"

        if ((!data.embedContent && !data.embedTitle) || data.noEmbed)
            payload_json := RegExReplace(payload_json, ",.*""embeds.*}]", "")

        objParam := {payload_json: payload_json}
        for i,v in (data.files ? data.files : []) {
            objParam["file" i] := [v]
        }
        CreateFormData(postdata,hdr_ContentType,objParam)
        WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        WebRequest.Open("POST", url, true)
        WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
        WebRequest.SetRequestHeader("Content-Type", hdr_ContentType)
        WebRequest.SetRequestHeader("Pragma", "no-cache")
        WebRequest.SetRequestHeader("Cache-Control", "no-cache, no-store")
        WebRequest.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
        WebRequest.Send(postdata)
        WebRequest.WaitForResponse()
    }
}