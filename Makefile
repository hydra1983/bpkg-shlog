SCRIPT=shlog
VERSION=0.0.1

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/$(PKG_NAME)
MANDIR=$(PREFIX)/share/man/man1

CP = cp -rvf
MKDIR = mkdir -p
RONN = ronn
SHINCLUDE = ./build-deps/shinclude/shinclude

dist: dist/$(SCRIPT) dist/shlog.1 README.md

dist/$(SCRIPT): $(SCRIPT) $(wildcard src/*.bash)
	$(MKDIR) dist ; SHLOG_SILENT=true $(SHINCLUDE) -c pound $(SCRIPT) > "$@"
	chmod a+x "$@"

dist/$(SCRIPT).1: $(SCRIPT).1.md dist/$(SCRIPT)
	$(SHINCLUDE) -c markdown $(SCRIPT).1.md \
		| $(RONN) --date=`date -I` --name="shlog" --pipe --roff \
		> "$@"

README.md: doc/README.md 
	$(SHINCLUDE) -c xml "$<" > "$@"

install: dist
	mkdir -p $(BINDIR)
	$(SHINCLUDE) dist/$(SCRIPT) > $(BINDIR)/$(SCRIPT)
	chmod a+x $(BINDIR)/$(SCRIPT)
	$(MKDIR) $(MANDIR) && $(CP) -t $(MANDIR) dist/$(SCRIPT).1
	$(MKDIR) $(SHAREDIR) && cp -t $(SHAREDIR) README.md LICENSE

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	rm -f $(MANDIR)/$(SCRIPT).1
	rm -rf $(SHAREDIR)

test: dist/$(SCRIPT)
	./test/tsht
