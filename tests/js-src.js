// one liner

/*
multi-liner
*/

var a = /* one */1, b = /* two */2

/*@cc_on
	alert("Hello IE user (please, please switch)!");
@*/

/*@cc_on
	@if (@_win32)
		alert("You have 32-bit Windows");
	@elif (@_jscript)
		alert("You have IE but not 32-bit Windows");
	@else */
		alert("Browser is not IE");
	/*@end
@*/

var ie = /*@cc_on!@*/false;

var wrapped = "multiline\
text";

/* some
   long
   two */

function f1(a, b/* String */) {

	return true;
}

/*! important */
function f2 () {
	if (1 in arguments) return 1;
	if ("2" in arguments) return '2';
	if ('3' in arguments) return "3";
}

