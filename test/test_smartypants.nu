(load "SmartyPants")

(class TestSmartyPants is NuTestCase
     
	(imethod (id) testQuotes is
		(set x "'Single quote', \"Double quote\", ``backticks''")
		(set y (NuSmartyPants convert:x))
		(set z "&#8216;Single quote&#8217;, &#8220;Double quote&#8221;, &#8220;backticks&#8221;")
		(assert_equal y z))
		
	(imethod (id) testDashes is
		(set x "En--dash; Em---dash.")
		(set y (NuSmartyPants convert:x))
		(set z "En&#8212;dash; Em&#8211;dash.") 
		; Note, the official SmartyPants gets this wrong.  Em dashes are caught as en dashes+"-".
		(assert_equal y z))

	(imethod (id) testEllipsis is
		(set x "ellip...sis")
		(set y (NuSmartyPants convert:x))
		(set z "ellip&#8230;sis")
		(assert_equal y z))
	
	(imethod (id) testBug is
		; This is a known bug in SmartyPants.  This can be fixed with "smart" quote processing instead of regex matching.
		; However, this is not the method that SmartyPants uses.  NuSmartyPants will get this wrong, too.
		(set x "'Twas the night before Christmas.")
		(set y (NuSmartyPants convert:x))
		(set z "&#8216;Twas the night before Christmas.")
		(assert_equal y z))
)      




