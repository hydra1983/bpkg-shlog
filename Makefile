SCRIPT=shlog
VERSION=0.0.1

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/$(SCRIPT)
MANDIR=$(PREFIX)/share/man/man1

CP = cp -rvf
RM = rm -rfv
MKDIR = mkdir -p
RONN = ronn
PATH := $(PATH):./build-deps/shinclude/dist/shinclude
SHINCLUDE = shinclude

SCRIPT_SOURCES = \
				 src/shlog.bash \
				 src/shlog-init.bash \
				 src/shlog-usage.bash \
				 src/shlog-dump.bash \
				 src/shlog-selfdebug.bash \
				 src/shlog-main.bash

dist: $(SCRIPT) $(SCRIPT).1 README.md

$(SCRIPT): $(SCRIPT_SOURCES)
	cat $(SCRIPT_SOURCES) > "$@"
	chmod a+x "$@"

$(SCRIPT).1: doc/$(SCRIPT).1.md $(SCRIPT)
	$(SHINCLUDE) -c markdown doc/$(SCRIPT).1.md \
		| $(RONN) --date=`date -I` --name="shlog" --pipe --roff \
		> "$@"

README.md: $(wildcard doc/* src/*)
	$(SHINCLUDE) -c xml doc/README.md > README.md

install: dist
	mkdir -p $(BINDIR)
	$(CP) $(SCRIPT) $(BINDIR)/$(SCRIPT)
	chmod a+x $(BINDIR)/$(SCRIPT)
	$(MKDIR) $(MANDIR) && $(CP) -t $(MANDIR) $(SCRIPT).1
	$(MKDIR) $(SHAREDIR) && cp -t $(SHAREDIR) README.md LICENSE

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	rm -f $(MANDIR)/$(SCRIPT).1
	rm -rf $(SHAREDIR)

test: $(SCRIPT)
	./test/tsht

clean:
	$(RM) $(SCRIPT) $(SCRIPT).1
