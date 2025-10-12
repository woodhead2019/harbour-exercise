FUNCTION Main
   local c , harr := hb_Hash( "six", 6, "eight", 8, "eleven", 11 )

      harr[10] := "str1"
      harr[23] := "str2"
      harr["fantasy"] := "fiction"

      ? harr[10], harr[23]                                   // str1  str2
      ? harr["eight"], harr["eleven"], harr["fantasy"]       // 8       11  fiction
      ? len(harr)                                            // 6
      ?
c := "11234"      
for each c in harr
	? c:__enumindex, c:__enumbase, c:__enumvalue, c:__enumkey, c 
next

      RETURN nil
