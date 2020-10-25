module ShopCrawler.Common.Encoding

let encodeBase64 text =
    let tripletToList ending (x, y, z) =
        // RFC 4648: The Base 64 Alphabet
        let A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

        // RFC 4648: The "URL and Filename safe" Base 64 Alphabet
        // let A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="

        let triplet = (int x <<< 16)
                            ||| (int y <<<  8)
                            ||| (int z)
        let a = (triplet &&& 0xFC0000) >>> 18
        let b = (triplet &&& 0x03F000) >>> 12
        let c = (triplet &&& 0x000FC0) >>>  6
        let d = (triplet &&& 0x00003F)
        match ending with
        | 1 -> [A.[a]; A.[b];  '=' ;  '=' ;] // 01==
        | 2 -> [A.[a]; A.[b]; A.[c];  '=' ;] // 
        | _ -> [A.[a]; A.[b]; A.[c]; A.[d];] // 

    let rec parse result input =
        match input with
        | a :: b :: c :: tail -> parse (result @ tripletToList 3 (a, b, c)) tail
        | a :: b :: []        -> result @ tripletToList 2 (a,   b, 0uy)
        | a :: []             -> result @ tripletToList 1 (a, 0uy, 0uy)
        | []                  -> result

    (text:string)
    |> System.Text.Encoding.UTF8.GetBytes
    |> Array.toList
    |> parse []
    |> List.toArray
    |> System.String.Concat



/// Decodes a Base64 string to a UTF8 string
let decodeBase64 text = 
    if (text:string).Length % 4 <> 0 then "" else
        // RFC 4648: The Base 64 Alphabet
        let A = [for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=" -> c]
                        |> List.mapi (fun i a -> a, i)
                        |> Map.ofList

        // RFC 4648: The "URL and Filename safe" Base 64 Alphabet
        // let A = [for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=" -> c]
        //         |> List.mapi (fun i a -> a, i)
        //         |> Map.ofList

        let (.@) (m: Map<char, int>) key = try m.[key] with _ -> 0
    
        let quadToList ending (a, b, c, d) =
            let quad = (A.@ a &&& 0x3F <<< 18)
                         ||| (A.@ b &&& 0x3F <<< 12)
                         ||| (A.@ c &&& 0x3F <<<  6)
                         ||| (A.@ d &&& 0x3F)
            let x = (quad &&& 0xFF0000) >>> 16
            let y = (quad &&& 0x00FF00) >>>  8
            let z = (quad &&& 0x0000FF)
            match ending with
            | 2 -> [byte x;]
            | 3 -> [byte x; byte y;]
            | _ -> [byte x; byte y; byte z;]
    
        let rec parse result input =
            match input with
            | a :: b ::'='::'=':: []   -> result @ quadToList 2 (a, b, '=', '=')
            | a :: b :: c ::'=':: []   -> result @ quadToList 3 (a, b,  c , '=')
            | a :: b :: c :: d :: tail -> parse (result @ quadToList 4 (a, b, c, d)) tail
            | _                        -> result

        [for c in text -> c]
        |> parse []
        |> List.toArray
        |> System.Text.Encoding.UTF8.GetString