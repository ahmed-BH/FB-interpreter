# FB-interpreter

FB-interpreter is logic-arithmetic interpreter with variable and string support, build with Flex and Bison.

### Prerequisites

* C++ compiler should be installed [GNU Compiler](https://gcc.gnu.org/install/)

### Running

```shell
cd FB-interpreter/

```

Compiling and generating the executable (**interpreter.tab.c, interpreter.tab.h and lex.yy.c** are auto-generated files produced by Bison and Flex from **interpreter.y** and **interpreter.l**)

```shell
g++ src/interpreter.tab.c -o fb-interpreter

```

The example folder contains some input_files, to test an example, run :

```shell
fb-interpreter <examples/input_1.txt>

```

Scrots
------

![Testing](scrots/tests.png?raw=true "Testing")
![basic string and fonction support](scrots/fct_str.png?raw=true "basic string and fonction support")
### Adding new features

* [Flex](https://www.gnu.org/software/flex/) : Fast Lexical Analyzer should be installed

* [Bison](https://www.gnu.org/software/bison/) : General-purpose parser generator should be installed

Generate **interpreter.tab.h**(is included in **interpreter.l**) and **interpreter.tab.c**

```shell
bison -d interpreter.y

```

Generate **lex.yy.c** (included in **interpreter.y**)

```shell
flex interpreter.l

```



## Included Features

- [x] Basic arithmetic and logic interpreter
- [x] Basic string operation
- [x] Support Variable storage (only **double** C++ type)
- [x] Basic Error(lexical and syntaxe) handling
- [x] Detect semantic errors such as **Division by Zero** and **Undefined Variable**...
- [x] Support inline and multiline comments
- [x] Add built-in C-math functions support


## To Do List 

- [ ] Better memory management, like Garbage Collector
- [ ] Include other features like **if-else** and **loops**
- [ ] Add user fonction support
- [ ] Use of Dynamically typed variables
