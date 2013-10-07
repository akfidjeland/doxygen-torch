# Documenting Lua/Torch code

doxygen-torch is a Doxygen plugin that adds supports for documenting torch code.  

Doxygen is a well-established documentation tool that produces excellent
documentation for C++, C, and some other related languages.
doxygen-torch is a filter that converts lua code into a format readable by
Doxygen. It is an adaptation of Alex Chen's [doxygen-lua](https://github.com/alecchen/doxygen-lua),
with additions for torch-specific constructs and which also integrates Doxygen
with doxygen-torch into the regular cmake-based torch build process.

## Installation

### On OS X

Doxygen-torch can be installed via [Homewbrew](http://brew.sh/) using our home-made head-only formula:

```bash
brew install --HEAD https://raw.github.com/akfidjeland/doxygen-torch/master/doxygen-torch.rb
```

This will also install doxygen if you do not already have it.

### Other OSs

Doxygen is required, which can be installed using your system's regular package
manager.

``doxygen-torch`` should be downloaded from [@akfidjeland's public
repo](https://github.com/akfidjeland/doxygen-torch) and can be installed using
the normal cmake-based build process:

```bash
git clone https://github.com/akfidjeland/doxygen-torch
cd doxygen-torch
mkdir build
cd build
cmake ..
make install
```

## Documenting your code

Doxygen extracts documentation from specially-marked comment blocks. These can
take one of two forms:

	--[[! This is a comment

	... that spans multiple lines
	--]]

or

	--! This is also a comment
	--! that also spans multiple lines

These documentation blocks should precede the entity that is being documented,
i.e. a class, function, variable etc. Providing such blocks is enough to
document a project, but Doxygen also provides a number of formatting directives
for special purposes, e.g. to document parameters, create links etc. There is a
large number of these, a full listing of which can be found
[here](http://www.stack.nl/~dimitri/doxygen/manual/commands.html). Markdown
format can be used for free-form documentation.

For some examples of how to document your lua code have a look at
[this pure lua example file](https://github.com/alecchen/doxygen-lua/blob/master/example/example.lua).
For more info, read [Doxygen Getting started guide](http://www.stack.nl/~dimitri/doxygen/manual/starting.html).
Some useful directives and documentation patterns can be found in the following sections.

### Functions

Functions can be simply preceded by a comment block as above. The first line
will be used as a summary in brief documentation listings, while the remainder
of the block provides more detail. Parameters can be documented using
``@param`` and the return value can be documented using ``@return``. For
example:

	--[[! Add two to a number

	@param x (tensor) a tensor to which 2 shall be added
	@return (tensor) x + 2,

	@see add3 for an even more exciting function!

	--]]
	local function add2(x)
		return x + 2
	end

doxygen-torch will identify member and static functions and group them withing
the appropriate class.

Doxygen will recognise allready documented entities, so if ``add3`` is
documented separately, the above will result in a hyperlink to the
documentation for ``add3``.

### Classes

Classes are documented with a general documentation block preceeding the
``torch.class`` definition:

	--[[! Linear module without biases

	This class behaves exactly like @c nn.Linear, except it does not have bias
	parameters.
	--]]
	local BiasFreeLinear, parent = torch.class('nnx.BiasFreeLinear', 'nn.Module')

This documentation block is required in order for any of the class' members
functions to be documented.

### Packages

A package will normally contain a single table with all the package's
functions, classes etc. To document such a package provide a documentation
block preceding the creation of the main package table and add a ``@defgroup
<name> <title>`` directive (note no quotes around title).

	--! @defgroup nnx nnx extensions to torch neural networks package
	nnx = {}

Functions and classes in this namespace will be automatically added to this
group.

In the generated documentation a package will be referred to as a module.

For a package it might also be useful to provide a main page for the
documentation. This can explain the purpose, structure, etc of the package, and
link to other parts of the documentation. To create such a main page use the
``@mainpage`` directive. This could go anywhere, but the package's init.lua
file is probably ideal.

	--[[! @mainpage Overview

	The @c nnx package contains extensions to the nn package. It mostly
	consists of additional modules with the same interface as regular @c nn
	modules (i.e. deriving from @c nn.Module) all in the namespace nnx.
	--]]

### Code examples

Code example can be added to a comment block by adding ``@code`` and
``@endcode`` directives:

	--[[! Reversed sequential container module

	A reverse sequential container is similar to an @c nn.Sequence, but differ in
	that submodules are added in reverse order, i.e. the first module added is the
	output and the last module is the input. Except for the reverse order, usage is
	as for @c nn.Sequential:

	@code
	local mlp = nnx.ReverseSequential()
	mlp:add(nn.Linear(5,5))
	mlp:add(nn.Tanh())
	mlp:add(nn.Linear(5,5))
	mlp:add(nn.Tanh())
	@endcode

	--]]
	local ReverseSequential, parent = torch.class('nnx.ReverseSequential', 'nn.Module')

### Mixed Lua/C code

In packages containing both lua and C code, both can be documented using
Doxygen, and documentation will be extracted if using the macros above. Note
that global function documentation will only be extracted if the file
containing it is documented.

	//! @file
	//! some auxilliary functions

	//! Add two to a value
	int add2(int x)
	{
		return x + 2
	}

### Global variables and member variables

Simply precede the variable with a documentation block. If the variable is a
member variable it will be added to the appropriate class' documentation. This
relies on the convention that ``self`` is used to refer to the class instance.

### Other/best practice

* Free-form documentation can be written using [Markdown](http://www.stack.nl/~dimitri/doxygen/manual/markdown.html)
* Equations can be written in [LaTeX format](http://www.stack.nl/~dimitri/doxygen/manual/formulas.html) with ``@f$ math latex code @f$``
* Graphs can be drawn with the [\dot command](http://www.stack.nl/~dimitri/doxygen/manual/commands.html#cmddot) following GraphVIZ syntax
* In a description, put parameter names in italics using `@a myparam`
* [Doxygen style guide](http://openocd.sourceforge.net/doc/doxygen/html/styledoxygen.html)

## cmake/torch-pkg integration

In a cmake/torch-pkg based package documentation can be extracted by using the
macro ``ADD_TORCH_DOX`` which is provided by doxygen-torch. In your project's
CMakeLists add the following
	
	FIND_PACKAGE(Lua2Dox)
	IF(Lua2Dox_FOUND)
		ADD_TORCH_DOX(<package name> <section> <title> <section number>)
	ENDIF

Now when you build the project you will get doxygen documentation in your build
tree.  When you install you will get this documentation in your install tree
(typically ``/usr/local/share/torch/html/<package name>/index.html``)
and also have the 'regular' torch documentation
(typically in [/usr/local/share/torch/html/index.html](file:///usr/local/share/torch/html/index.html))
link to your package documentation.

``lua2dox`` automatically uses a default Doxyfile which assumes that all the
sources to document will be found in the directory from which ``ADD_TORCH_DOX``
is called. If you want or need to modify the Doxyfile copy the default
Doxyfile.in to this directory and modify it. It can be found in
``<install-prefix>/share/cmake/lua2dox/Doxyfile.in``.

Some other variables you may want to change:

```
INPUT                  = my/source/folder
HIDE_UNDOC_MEMBERS     = YES
HIDE_UNDOC_CLASSES     = YES
```

Otherwise, Doxygen searches files matching the pattern in the directory where
the ``Doxyfile`` resides.

Doxygen can generate a large number of (incorrect) warnings. To suppress all
warnings add

	SET(DOXYGEN_WARNINGS NO)

to your ``CMakeLists.txt``.


## Possible issues

* In Markdown fenced code `~~~~~{.py}` is different than github code blocks, and extension `.lua` not recognized
* In Markdown fenced code, Lua comments are stripped off and thus not rendered
* Lots of warning of not finding the parameters in the function declaration, e.g.:

    ```
    warning: argument 'model' of command @param is not found in the argument list of buildChain(model, opt)
    ```
