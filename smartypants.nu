; smartypants.nu is based on SmartyPants by John Gruber
; Development and maintenance on smartypants.nu by Grayson Hansard <info@fromconcentratesoftware.com> 2007

(function smartypants_tokenize (str)
	(set arr (NSMutableArray array))
	(set r /(?s: <! ( -- .*? -- \s* )+ > ) |  # comment
			(?s: <\? .*? \?> ) |              # processing instruction
			(?:<(?:[^<>]|(?:<(?:[^<>]|(?:<(?:[^<>]|(?:<(?:[^<>]|(?:<(?:[^<>]|(?:<(?:[^<>])*>))*>))*>))*>))*>))*>)/x)
	(set used 0)
	((r findAllInString:str) each: (do (m)
		(set wholeTag (m group))
		(set secStart (car (m range)))
		(set tagStart (- secStart (wholeTag length)))
		(if (< used tagStart) (arr addObject:(list "text" (str substringWithRange:(list used (- secStart used)) )) ))
		(arr addObject:(list "tag" wholeTag))
		(set used (+ secStart (wholeTag length))) ))
	(arr addObject:(list "text" (str substringFromIndex:used)))
	(arr each:(do (a) (puts (a stringValue))))
	(puts "--")
	(arr))

(function smartypants_ProcessEscapes (str)
     ; (set str ((regex ("\\\\ " substringToIndex:3)) replaceWithString:"&#92;" inString:str))
	(set str (/\\\\/x replaceWithString:"&#92;" inString:str))
	(set str (/\\"/x replaceWithString:"&#34;" inString:str))
	(set str (/\\'/x replaceWithString:"&#39;" inString:str))
	(set str (/\\\./x replaceWithString:"&#46;" inString:str))
	(set str (/\\-/x replaceWithString:"&#45;" inString:str))
	(set str (/\\`/x replaceWithString:"&#96;" inString:str))
    str)

(function smartypants_EducateQuotes (str)
     (set punct_class "[!\"#\$\%'()*+,-.\/:;<=>?\@\[\\\]\^_`{|}~]")
     
     ; Special case if the very first character is a quote
     ; followed by punctuation at a non-word-break. Close the quotes by brute force:
     (set str ((regex "^'(?=#{punct_class}\B)") replaceWithString:"&#8217;" inString:str))
     (set str ((regex "^\"(?=#{punct_class}\B)") replaceWithString:"&#8221;" inString:str))
     
     ; Special case for double sets of quotes
     (set str ((regex "\"'(?=\w)") replaceWithString:"&#8220;&#8216;" inString:str))
     (set str ((regex "'\"(?=\w)") replaceWithString:"&#8216;&#8220;" inString:str))
     
     ; Special case for decade abbreviations (the '80s)
     (set str ((regex "'(?=\d{2}s)") replaceWithString:"&#8217;" inString:str))
     
     (set close_class "[^\ \t\r\n\[\{\(\-]")
     (set dec_dashes "&#8211;|&#8212;")
     
     (set str ((regex "(\s|&nbsp;|--|&[mn]dash;|&\#x201[34];|#{dec_dashes})'(?=\w)") replaceWithString:"$1&#8216;" inString:str)) ; Get most opening single quotes
     (set str ((regex "(#{close_class})?'(?(1)|(?=\s | s\b))") replaceWithString:"$1&#8217;" inString:str)) ; Single closing quotes
     (set str ((regex "'") replaceWithString:"&#8216;" inString:str)) ; Any remaining single quotes should be opening ones:
     
     (set str ((regex "(\s|&nbsp;|--|&[mn]dash;|&\#x201[34];|#{dec_dashes})\"(?=\w)") replaceWithString:"$1&#8220;" inString:str)) ; Get most opening double quotes
     (set str ((regex "(#{close_class})?\"(?(1)|(?=\s | s\b))") replaceWithString:"$1&#8221;" inString:str)) ; Double closing quotes
     (set str ((regex "\"") replaceWithString:"&#8220;" inString:str))
     
     (str)
     )

(class NSString (- lastCharacter is 
	(if (== (self length) 0) ("")
	(else (self substringFromIndex:(- (self length) 1))))))

(function SmartyPants (str)
     ;; Does this document SmartyPants?
     (set result (NSMutableString string))
     (set in_pre 0)
     (set prev_token_last_char "")
     (set tags_to_skip (regex "<(/?)(?:pre|code|kbd|script|math)[\s>]"))
     (set tokens (smartypants_tokenize str))
     (tokens each: (do (token)
                       (set value (head (tail token)))
                       (if (== (head token) "tag")
                           (if (tags_to_skip findInString:value) (set in_pre 1) ; Set if inside an HTML block
                               (else (set in_pre 0))) ; Unset if not an HTML block
                           (result appendString:value) ; Append this HTML
                           (else
                                (set last_char (value lastCharacter))
                                (if (== in_pre 0)
                                    (set value (smartypants_ProcessEscapes value))
                                    (set value ((regex "&quot;") replaceWithString:"\"" inString:value)) ; Ignoring an if from the original source
									; Educate dashes
									(set value (/---/ replaceWithString:"&#8211;" inString:value))
                                    (set value (/--/ replaceWithString:"&#8212;" inString:value))

									; Educate ellipses
                                    (set value (/\. ?\. ?\./ replaceWithString:"&#8230;" inString:value))
                                    
                                    ; Educate backticks
                                    (set value (/``/ replaceWithString:"&#8220;" inString:value))
                                    (set value (/''/ replaceWithString:"&#8221;" inString:value))
                                    ; Educate single backticks
                                    (set value ((regex "`") replaceWithString:"&#8216;" inString:value))
                                    (set value ((regex "''") replaceWithString:"&#8217;" inString:value))
                                    
                                    ; Do quotes
                                    (if (== value "'")
                                        (set value "&#8216;") ; Add special case
                                        (else (if (== value "\"")
                                                  (set value "&#8220;") ; Again, add special case
                                                  (else
                                                       (set value (smartypants_EducateQuotes value))
                                                       ))))
                                    ; What is the stupefying for?
                                    )
                                (set prev_token_last_char last_char)
                                (result appendString:value)
                                ))
                       ))
     (result)
     )

(class NuSmartyPants is NSObject
     (+ (id) convert:(id) text is (SmartyPants text)))