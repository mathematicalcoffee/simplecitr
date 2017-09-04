# Autocomplete citations in Rstudio

This is an Rstudio addin that implements rudimentary autocomplete of citation
keys from a bib file. Ideally triggered by a keybinding.
The idea is to save clicking/raising hands from the keyboard as much as possible.

This is different to [`citr`](https://github.com/crsh/citr) and both can be used together.
The intended usage of `simplecitr` is to autocomplete a single reference from a key that
you have already partly typed in, only showing a UI if absolutely necessary (if there
is more than one match). If the UI is shown it is meant to be able to be operated
with minimial clicking/extra keystrokes.

`citr` is for adding multiple citations at once, has Zotero support, better search, etc etc.
It does more, but more clicking is generally required (or Tabbing, to get to the 'Done' button of the
diagog). It searches authors and titles and so on while `simplecitr` is really just for quick and dirty autocompletion of cite keys.

(This package isn't officially affiliated with `citr` or anything, I was just looking for a citation autocomplete, found `citr`, and wanted a version of it that didn't need so much clicking/keyboarding).

## Installation

You need a version of RStudio that supports Addins.

```
library(devtools)
install_github('mathematicalcoffee/simplecitr')
```

## Usage

1. Bind it to a keybinding (for me Ctrl+X Ctrl+O, what I use in Vim)
2. Type in the start of a citekey e.g. `@Bes` (the `@` is needed to recognise the citation).
3. Use the keybinding.
4. If there is
   * exactly one match in your cite keys (e.g. `@Besag1986`), it is completed. Done!
   * more than one match, a dialog is shown with matches. Press `Tab` to give focus
   to the dropdown, choose the relevant option and `Enter` to choose it. The dialog
   is automatically closed and it's inserted.
   * no match at all, a dialog is shown with *all* entries in your bibtex. You can type to
   do a search (only of citekeys and titles, not of second authors, sorry), choose
   your selection. The dialog is automatically closed and the citation inserted.

The idea is not to need to use the mouse or press many keystrokes. For me it's
`@Bes`, ^X ^O, `Tab`, use keyboard to get my selection (arrow keys - I have mapped
mod3 (`;` for me) + vikeys to arrow keys so my hands can stay on home position),
press `Enter`, done. In `citr` you get better search ability and customisation but
you have to take your hand off the keyboard and click 'Done'. Or Tab a lot to give
focus to the 'Done' button.

## Configuration

### Set bibliography location

We use whatever is in `getOption(citr.bibliography_path)` (so that both `simplecitr` and `citr` use the same).
Can set it like

```
set.bibfile('path/to/my/bibfile.bib')
# or
options(citr.bibliography_path='path/to/my/bibfile.bib')
```

### Don't validate the bibliography

For some reason my bibliography doesn't validate properly - missing fields and so on (I use Zotero to make my bibfile, so unsure how these crept in).
Since I made this package for me not for other people, by default validation is turned off.
To change it:

```
set.check.bib(TRUE)  # if you want to validate
# or
RefManageR::BibOptions(check.entries=TRUE)
```

### Refresh the bibliography

My master bibfile is very large and takes ages to load in, so I cache it in the same way `citr` does.
If you want to reload it you have to call `reload.bib()`.

## Caveats

If your bibfile is quite big, the first time you execute the addin it will take some time (to read in the bibfile).
If you keep getting startled by this, run `reload.bib()` somewhere in your session before you start using the addin (when you run it, it will still take the same amount of time, but at least you're expecting it. It only needs to be done once. Then when you're mid-edit you don't need to freak out wondering why RStudio seems frozen when you've just forgotten that it is reading in your bibfile for the first time). I wouldn't recommend putting it in your Rprofile though or else you'll have to wait for the bibfile to be read in every time you start R, and you probably won't be using this addin every time you start R.

----

I wrote this in an afternoon with no shiny/Addins experience, learning from [`citr`](https://github.com/crsh/citr) (how to read in a bibliography) and [`littleboxes`](https://github.com/ThinkR-open/littleboxes) (how to get the word under the cursor).

If it screws up it's not surprising.

## Help!

If you know how to

* have the dropdown automatically open when the dialog appears (so it doesn't need to be Tabbed to)
* make the dropdown smaller (more like Rstudio autocomplete - I set height to 100px but it still displays big)
* press Esc to kill the whole dialog if you change your mind
* any general pull requests/improvements

Let me know.