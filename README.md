## 介绍
该插件可以帮你快速执行代码块中的代码。

## 依赖
```vim
call plug#begin('~/.vim/bundle')
Plug 'peter-lyr/vim-get-blocks'
Plug 'skywind3000/asyncrun.vim'
call plug#end()
```

## 安装
我更倾向于使用vim-plug( https://github.com/junegunn/vim-plug/ )管理器来安装：
```vim
call plug#begin('~/.vim/bundle')
Plug 'peter-lyr/vim-run-blocks'
call plug#end()
```

## 用法
- 按`<F7>`，新开一个标签页执行。
- 按`<F8>`，异步打开quick fix执行。
