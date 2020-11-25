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
    let status = InitCodeBlock()
    if status == 'not_ok'
        return
    endif
    python3 << EOF
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
        let g:run_block_cmd_pre = ""
        try
            let g:run_block_cmd = 'sp|te ' ."workon " .g:work_on .' && ' .cmd
        catch
            let g:run_block_cmd = 'sp|te ' .' && ' .cmd
        endtry
        exec g:run_block_cmd
    elseif a:method == 'asyn'
        let g:run_block_cmd_pre = "copen | normal \<c-w>J"
        try
            let g:run_block_cmd = "AsyncRun! " ."workon " .g:work_on .' && ' .cmd
        catch
            let g:run_block_cmd = "AsyncRun! " .' && ' .cmd
        endtry
        exec g:run_block_cmd_pre
        exec g:run_block_cmd
    endif
endfunction


"运行python代码，在markdown文件中的code block中：
map <silent> <F7> :call RunCodeBlock('term')<cr>
imap <silent> <F7> <esc>:call RunCodeBlock('term')<CR>
vmap <silent> <F7> <esc>:call RunCodeBlock('term')<CR>

map <silent> <F8> :call RunCodeBlock('asyn')<cr>
imap <silent> <F8> <esc>:call RunCodeBlock('asyn')<CR>
vmap <silent> <F8> <esc>:call RunCodeBlock('asyn')<CR>

map <F10> :call RunAgain('block')<CR>
imap <F10> <esc>:call RunAgain('block')<CR>
vmap <F10> <esc>:call RunAgain('block')<CR>
