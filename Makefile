BACKUP_DIR=$$HOME/dotfiles-backup

.PHONY: all
all: install

.PHONY .SILENT: install
install: install-dotfiles install-brew install-powerline-fonts install-oh-my-zsh

.PHONY .SILENT: backup-dotfiles
backup-dotfiles:
	echo "Creating backup directory at ${BACKUP_DIR}"
	mkdir -p ${BACKUP_DIR}
	for file in $(shell find $(CURDIR) -maxdepth 1 -name ".*" -not -name ".git"); do \
		filename=$$(basename $$file); \
		target="$$HOME/$$filename"; \
		if [ -f $$target ]; then \
			echo "Copying $$target into ${BACKUP_DIR}"; \
			cp $$target ${BACKUP_DIR}; \
		fi; \
	done; \

.PHONY .SILENT: install-dotfiles
install-dotfiles:
	for file in $(shell find $(CURDIR) -maxdepth 1 -name ".*" -not -name ".git"); do \
		filename=$$(basename $$file); \
		target="$$HOME/$$filename"; \
		echo "Linking $$file to $$target"; \
		ln -sf $$file $$target; \
	done; \


.PHONY .SILENT: install-brew	
install-brew: 
## Check if xcode command line tools are installed
ifeq ($(shell which brew),)
	$(shell ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")
endif
	## Install apps using Brewfile
	brew bundle

.PHONY .SILENT: install-powerline-fonts
install-powerline-fonts:
	git clone https://github.com/powerline/fonts.git --depth=1
	./fonts/install.sh
	rm -rf fonts

.PHONY .SILENT: install-zsh-autosuggestions
install-zsh-autosuggestions:
	rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

.PHONY .SILENT: setup-vim
setup-vim:
	mkdir -p ~/.vim/autoload ~/.vim/bundle
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	rm -rf ~/.vim/bundle/vim-colors-solarized
	git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
	rm -rf ~/.vim/bundle/nerdtree
	git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
	rm -rf ~/.vim/bundle/syntastic
	git clone https://github.com/scrooloose/syntastic.git ~/.vim/bundle/syntastic

.PHONY .SILENT: install-oh-my-zsh
install-oh-my-zsh:
	## Change shell
	chsh -s $(shell which zsh)
	## Install oh-my-zsh
	curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

.PHONY .SILENT: clean
clean: ## Clean old formulas
	brew update
	brew upgrade
	brew cleanup
