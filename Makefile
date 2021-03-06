#  This file generates the xml files in the raw directory from
#  the corresponding files from the Taminations project.
#  Requires $(TAMINATIONS) to be set to the location of that project
#  On Windows, use Cygwin

#  These are the files to copy from Taminations to the app
TAMDIRS = b1 b2 ms plus a1 a2 c1 c2 c3a c3b src sequences
TAMTYPES = xml html png css dtd py txt
SRC = $(foreach dir,$(TAMDIRS),\
      $(foreach type,$(TAMTYPES),\
      $(wildcard $(TAMINATIONS)/$(dir)/*.$(type))))
CALLINDEX = files/src/callindex.xml
PYTHON = python3

#  Generate destinations filename from source filenames
SRCNAMES = $(subst $(TAMINATIONS),,$(SRC))
OBJDIR = files
OBJ = $(addprefix $(OBJDIR),$(SRCNAMES))
PREVOBJ = $(filter-out files/info/about.html files/info/sequencer.html,$(wildcard $(OBJDIR)/*/*))

#  Dependencies
.PHONY: git all clean
all : git $(OBJ) $(CALLINDEX)

git :
	cd $(TAMINATIONS) && git pull

#  The mobile site requires a viewport tag, but that breaks
#  scrolling for Gingerbread on the app.  So remove the viewport tag here.
#  Also remove scripts
files/%.html : $(TAMINATIONS)/%.html
	perl -p -e "s/^<.*(viewport|script|favicon).*//" $(subst $(OBJDIR),$(TAMINATIONS),$@) >$@

files/% : $(TAMINATIONS)/%
	cp $< $@

#  Generate index used by sequencer
$(CALLINDEX) : $(OBJ)
	cd files/src/ && $(PYTHON) indexcalls.py >callindex.xml

clean :
	-rm $(PREVOBJ)
