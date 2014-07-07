
**Updated 2008-02-26**: changed the syntax a little

Logical grouping / DIV syntax for Markdown
==========================================

`+--` starts a div, `=--` ends a div (both with up to 3 indentation):

    +--
      Inside a div..
    =--

DIVs can be nested:

    +--
    Inside first DIV
     +--
      DIV inside DIV
     =--
    =--

Attribute lists can be put after `+--` or after `---`:

    +--                           {.warning}
    This is a Warning!
    =--

    +--
    Second Warning!
    =--                           {.warning}

Compressed syntax: if the first line after `+--` begins with `|`,
the content of the DIV is anything following beginning with `|`.

    +--                           {.warning}
    | third 
    | warning!

In this case, a final `+----` line can be added for visual candy:

    +--                           {.warning}
    | third 
    | warning!
    +--------------

Example nesting and attributes:

    +-----------------------------------{.warning}------
    | this is the last warning!
    |
    | please, go away!
    |
    |+------------------------------------- {.menace} --
    || or else terrible things will happen
    |+--------------------------------------------------
    +---------------------------------------------------

this translates to:

    <div class="warning">
      <p>this is the last warning!</p>
      <p>please, go away!</p>
      <div class="menace">
      <p>or else terrible things will happen</p>
      </div>
    </div>

