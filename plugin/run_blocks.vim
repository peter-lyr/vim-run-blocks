if has('win32')
    let g:temp_dir = 'C:\Windows\Temp\'
elseif has('unix')
    let g:temp_dir = '/tmp/'
elseif has('mac')
    let g:temp_dir = '/tmp/'
endif


"默认不开启警告
let g:clang_warning = 0


function! RunCodeBlock(method)
    call InitCodeBlock()
    python3 << EOF
if 'not_ok' in locals():
    del not_ok
else:
    temp_path = vim.eval('g:temp_dir ."tmp_from_neovim."')

    if file_type == 'python':
        temp_path += 'py'
    elif file_type == 'c':
        temp_path += 'c'

    with open(temp_path, 'wt') as f:
        f.write('\n'.join(code_lines))
    del up_num, down_num, code_lines, line_num, temp_path, f, file_type, block_head
EOF
    if g:file_type == 'python'
        let cmd = 'python ' .g:temp_dir .'tmp_from_neovim.py'
    elseif g:file_type == 'c'
        if g:clang_warning
            let warning_flag = '-Wall '
        else
            let warning_flag = ''
        endif
        let cmd = 'gcc ' .g:temp_dir .'tmp_from_neovim.c -lm ' .warning_flag .'-o ' .g:temp_dir .'tmp_from_neovim && ' 
                    \ .'echo -e "[ \033[1;32mOK\033[0m ] gcc "' .g:temp_dir .'tmp_from_neovim.c -lm ' .warning_flag .'-o ' .g:temp_dir .'tmp_from_neovim && '
                    \ .g:temp_dir .'tmp_from_neovim'
    endif

    if a:method == 'term'
        exec 'sp|te ' .cmd
    elseif a:method == 'asyn'
        exec 'AsyncRun ' .cmd
        exec 'copen'
    endif
endfunction


"运行python代码，在markdown文件中的code block中：
map <silent> <F7> :call RunCodeBlock('term')<cr>
imap <silent> <F7> <esc>:call RunCodeBlock('term')<CR>
vmap <silent> <F7> <esc>:call RunCodeBlock('term')<CR>

map <silent> <F8> :call RunCodeBlock('asyn')<cr>
imap <silent> <F8> <esc>:call RunCodeBlock('asyn')<CR>
vmap <silent> <F8> <esc>:call RunCodeBlock('asyn')<CR>
