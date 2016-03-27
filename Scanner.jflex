package Example;

import java_cup.runtime.SymbolFactory;
%%
%cup
%class Scanner

%{
	public Scanner(java.io.InputStream r, SymbolFactory sf){
		this(r);
		this.sf=sf;
	}
	private SymbolFactory sf;
	private StringBuffer str = new StringBuffer();
%}//End of class definition for Scanner

%eofval{
	return sf.newSymbol("EOF",sym.EOF);//This denotes the end of your string
%eofval}

%state STRING

%%
<YYINITIAL> "{" { return sf.newSymbol("Left Curly Brace",sym.LCURLYBRACE);}
<YYINITIAL> "}" { return sf.newSymbol("Right Curly Brace",sym.RCURLYBRACE);}

//Here I define the terminals to be defined in my cup file, and what symbols to generate.
//http://stackoverflow.com/questions/32155133/regex-to-match-a-json-string
//http://stackoverflow.com/questions/13340717/json-numbers-regular-expression
<YYINITIAL> {

-?(0|[1-9][0-9]*)/*Positive or negative zero or any digits starting with 1-9*/
(\.[0-9]+)?/*Followed by one or zero optional decimal places followed by lots of digits, both of which optional*/
([eE][+|-]?[0-9]+)? /*Optional exponents with one or more digits*/
{ return sf.newSymbol("Number",sym.NUMBER);}
[ \t\r\n\f] { /* ignore white space. */ }
"[" { return sf.newSymbol("Left Square Bracket",sym.LSQBRACKET);}
"]" { return sf.newSymbol("Right Square Bracket",sym.RSQBRACKET);}
"," { return sf.newSymbol("Comma",sym.COMMA);}
":" { return sf.newSymbol("Colon",sym.COLON);}//Autocompletion to sym.Colon, but I kept my convention to define all terminals in capitals
/*A double quotation starts the definition for a STRING object, which we set to 0 in length to start with*/
\" {str.setLength(0); yybegin(STRING);}
"null" { return sf.newSymbol("Null", sym.NULL); }
"true" | "false" { return sf.newSymbol("Boolean", sym.BOOLEAN); }//the words true or false signify a boolean.
}

<STRING> {
	//This is when the string ends, and it has been defined
	\" { yybegin(YYINITIAL); return sf.newSymbol("String", sym.STRING, str.toString()); } 
	/*Account for actions within string literal*/
	//A string is anything that is not a new line, return, a quotation or a backslash.
	[^\n\r\"\\]+ { str.append( yytext() ); } 
	/*Tab within a string literal*/
	\\t { str.append('\t'); }
	/*New line within a string literal*/
	\\n { str.append('\n'); }
	/*Returns within a string literal*/
	\\r  { str.append('\r'); }
	/*Quotation within a string literal*/
	\\\" { str.append('\"'); }
	/*Backslash within a string literal*/
	\\ 	{ str.append('\\'); }
}

. {System.err.println("Illegal character: " + yytext());}
