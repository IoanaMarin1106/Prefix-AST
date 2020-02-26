# Prefix-AST
======================== Marin Ioana-Valentina - 325CB ========================

===============================================================================
		Introduction to computer organization and assembly language
		           Project 1 - Prefix AST
===============================================================================

	The project consists of implementing a program in assembly language that 
performs the evaluation of a prefixed mathematical expression and then displays
the result at stdout. The numbers that appear in the expression are 32-bit
signed integers, and the operations that can be applied to them are: +, -, /, *.
A prefixed expression will be used in the program in the form of an abstract
syntax tree, obtained from the call of an external function - getAST().

	The program uses as an input a string that represents a codification of the
pre-order tree traversal, bearing the name "The prefixed Polish form". This 
expression is read and transformed into a tree by getAST(). To avoid any memory
leaks and to restore the stack registers, the freeAST() function is used.

-------------------------------------------------------------------------------

	In order to implement the required program the following steps have been
	taken:

• Pre-order tree traversal (Root -> Left -> Right) using a recursive function.

• Storing tree data (operands or operators) in a declared array of strings and 
  initializing it in section ".data".

• Implementation of a function that performs tree data conversion, more precisely
  the conversion from string type to integer data type.

• Iteration through the array containing the parameters and actual calculation
  of the prefixed Polish form.

-------------------------------------------------------------------------------

	-> Conversion() function:

• This function performs convertion from a string received as a parameter to an
  integer, using the 'edi' register.

• Each byte of the string is scanned and checked whether it has the ASCII
  value of a digit or if it is an operation.

• If it is a digit then it is converted to its integer value, and otherwise, 
  the function returns "-1" by entering the label "not_digit", meaning that the
  analyzed string is not a number.

• In the case of negative numbers, their first byte is being checked and if it is
  equal to the ASCII code of '-', the 'edx' register, used as a boolean
  pseudo-variable, is being changed from a 0 to a 1. After that, the function
  tries to convert the rest of string that will be analyzed as an unsigned number. 
  After having checked all the characters in the string, the function checks the
  value in the 'edx' register. If that is different from zero, then the number was
  negative, so the number is negated and incremented by 1 (two's complement),
  thus getting the correct result, otherwise the number was positive so the
  function's return value will no longer be processed.

• The return value is in the 'eax' register.


-------------------------------------------------------------------------------

	-> Main() function:

• First of all, the RLR() function is called to traverse the tree and store the
  information from its nodes in the "parameters" array. In addition, the length
  of that array is being computed and stored in the 'ecx' register.

• A copy of the array's length is made, whose value is stored in the ebx register.

• The 'edi' register is set to point to the starting address of the "parameters"
  array, after which the array is being iterated through so that at the end of
  the scan the 'edi' register will point to the end address of the array. Also,
  the value stored in the 'ecx' register will be updated. The loop uses the copy
  stored in the 'ebx' register.

• The "parameters" array is traversed from the end address to the beginning address
  and the result of the prefixed Polish form will be calculated according to the 
  following algorithm:
	->	Check each element of the array and as long as it is a number,
	  its value will be pushed on the stack. When an operation is found, 
          the last two stored values will be popped from the stack and the 
	  operation will be performed between them.
		Then, the result of the operation will be pushed back into the stack and
	  the "parameters" array will continue to provide the stack with values
	  until it no longer contains elements.
		The final result will be stored in the ''eax' register and will be 
	  displayed at stdout using the "PRINT_DEC" macro in SASM.

===============================================================================
