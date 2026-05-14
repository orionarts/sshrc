NAME       := sshrc

PREFIX     ?= /usr/local
BINDIR     ?= $(DESTDIR)$(PREFIX)/bin
MANDIR     ?= $(DESTDIR)$(PREFIX)/man/man1
DOCDIR     ?= $(DESTDIR)$(PREFIX)/share/doc/$(NAME)
LICENSEDIR ?= $(DESTDIR)$(PREFIX)/share/licenses/$(NAME)

PANDOC ?= pandoc

bin     := $(NAME)
license := LICENSE
docs    := $(license) README.md
manpage := $(bin).1

%.1: %.1.md
	$(PANDOC) --standalone $(PANDOCFLAGS) --to man -V section=1 $< -o $@

.PHONY: all
all: $(manpage)

.PHONY: install
install: all
	install -m 0755 -Dt $(BINDIR) $(bin)
	install -m 0644 -Dt $(LICENSEDIR) $(license)
	install -m 0644 -Dt $(DOCDIR) $(docs)
	install -m 0644 -Dt $(MANDIR) $(manpage)

.PHONY: distclean
distclean:
	$(RM) $(manpage)
