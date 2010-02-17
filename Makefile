NAME=rush

.PHONY: $(NAME)

linux:
	make $(NAME) PLATFORM=linux

macosx:
	make $(NAME) PLATFORM=macosx

mingw:
	make $(NAME) PLATFORM=mingw

$(NAME):
	make -C dokidoki-support $(PLATFORM) NAME="../$(NAME)"

clean:
	make -C dokidoki-support clean NAME="../$(NAME)"

