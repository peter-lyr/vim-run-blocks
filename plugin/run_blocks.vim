if has('win32')
    let g:tmp_root = 'C:\Windows\Temp\'
elseif has('unix')
    let g:tmp_root = '/tmp/'
elseif has('mac')
    let g:tmp_root = '/tmp/'
endif


"默认不开启警告
let g:runblocks_clang_warning = 0


function! RunCodeBlock(method)
    call InitCodeBlock()
    python3 << EOF
if 'not_ok' in locals():
    del not_ok
else:
    temp_path = vim.eval('g:tmp_root ."tmp_from_neovim."')
    if file_type == 'python':
        temp_path += 'py'
    elif file_type == 'c':
        temp_path += 'c'

    with open(temp_path, 'wb') as f:
        f.write('\n'.join(code_lines).encode('utf-8'))
    del up_num, down_num, code_lines, line_num, temp_path, f, file_type, block_head
EOF
    if g:file_type == 'python'
        let cmd = 'python ' .g:tmp_root .'tmp_from_neovim.py'
    elseif g:file_type == 'c'
        if g:runblocks_clang_warning
            let warning_flag = '-Wall '
        else
            let warning_flag = ''
        endif
        if and(exists('g:runblocks_simple_output'), g:runblocks_simple_output == 1)
            let cmd = 'gcc ' .g:tmp_root .'tmp_from_neovim.c -lm ' .warning_flag .'-o ' .g:tmp_root .'tmp_from_neovim && ' 
                        \ .g:tmp_root .'tmp_from_neovim'
        else
            let cmd = 'gcc ' .g:tmp_root .'tmp_from_neovim.c -lm ' .warning_flag .'-o ' .g:tmp_root .'tmp_from_neovim && ' 
                        \ .'echo -e "[ \033[1;32mOK\033[0m ] gcc "' .g:tmp_root .'tmp_from_neovim.c -lm ' .warning_flag .'-o ' .g:tmp_root .'tmp_from_neovim && '
                        \ .'echo -e "[ \033[1;32m***\033[0m ] "' .g:tmp_root .'tmp_from_neovim && '
                        \ .g:tmp_root .'tmp_from_neovim && '
                        \ .'echo -e "[ \033[1;32mOK\033[0m ]"'
        endif
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
