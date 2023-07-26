if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif

vim9script

import 'vimcompletor.vim'
import autoload '../autoload/ngcomplete.vim' as complete
import autoload '../autoload/options.vim' as opts
import autoload '../autoload/unigram.vim'
import autoload '../autoload/bigram.vim'

# Download dictionary if it doesn't exist yet
# if empty(glob($'~/.vim/data/count_1w.txt')) && executable('curl')
#     silent !curl -fLo ~/.vim/data/count_1w.txt --create-dirs
# 		\ http://norvig.com/ngrams/count_1w.txt
# endif

const name = 'ngram'

def Register()
    var o = opts.opts
    if !o->has_key('enable') || o.enable
	var ftypes = o->get('filetypes', ['text', 'markdown'])
	vimcompletor.Register(name, complete.Completor, ftypes, o->get('priority', 10))
	if &ft->empty() || ftypes->index(&ft) != -1
	    unigram.SetupDict()
	    if o.bigram
		bigram.SetupDict()
	    endif
	endif
    else
	vimcompletor.Unregister(name)
    endif
enddef

autocmd User VimCompleteLoaded ++once Register()

def OptionsChanged()
    var options = vimcompletor.GetOptions(name)
    if !options->empty()
	opts.options->extend(options)
	Register()
    endif
enddef

autocmd User VimCompleteOptionsChanged ++once OptionsChanged()