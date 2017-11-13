require 'strict'
x = require 'compiler'
x('#include <stdio.h>', 'int main(){printf("hello\n");}', 't')
