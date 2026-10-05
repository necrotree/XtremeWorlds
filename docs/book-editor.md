# Book editor

Developers can open **Book Editor** from the admin panel or use `/bookeditor`.
Enter a book ID (1–32767) and click **Load / Create**. Set the name and header,
write the two pages, choose an optional connecting book and quest, then click
**OK** to save. **Preview** opens the game's book reader; Close returns to editing.
Each page supports 2000 characters. Names and headers support 64 characters.
Item editor Book IDs continue to reference the same IDs.

The server stores versioned binary records in `Server/books/<ID>.bin`.
Existing `<ID>.txt` files convert on startup, retaining up to 64 pages. The
original text files remain available as migration backups. Once a binary file
exists, it takes precedence. Editing the first two pages preserves any later
imported pages. Successful replacements retain the previous binary as `.bak`.

The Next button opens a connecting book after the last spread. Players must
own a book item leading to that book. Connections are checked for cycles and
limited to 64 books. Reading a book with a quest starts that quest if its class,
level, and previous-quest requirements are met and it has not already started.
Completion and rewards still use the quest NPC dialogue.
