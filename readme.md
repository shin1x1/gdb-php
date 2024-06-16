# gdb-php

php-fpm(php) の内部動作を確認するため、gdb でデバッグ実行できるようにした Docker Compose 環境です。

php-src から任意のブランチをチェックアウトしてビルドした php-fpm(php) に対して gdb でアタッチできるので、調査対象のバージョン（ブランチ）の挙動を確認できます。

## Usage

主な利用コマンドは make コマンドが用意されています。

### 環境構築

`make` コマンドを実行すると、Docker イメージ、php-fpm(php) コマンドをビルドします。

### gdb で php コマンドにアタッチ

`make gdb-php` コマンドで gdb を起動し、php コマンドにアタッチします。

```
GNU gdb (Debian 13.1-3) 13.1
Copyright (C) 2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "aarch64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /php-src/php/bin/php...
>>>
```

gdb コマンド入力待ちとなっています。ここではこのリポジトリに同梱している PHP コード（`/app/index.php`）をデバッグ実行してみます。

このコードでは var_dump() を実行しているので、ここにブレークポイントを仕掛けます。ブレークポイントは `break` もしくは `b` コマンドで設定できます。PHP 関数は内部的には `zif_` という prefix がついているので、これを付与します。

```
>>> b zif_var_dump
Breakpoint 1 at 0x58a128: file /php-src/ext/standard/var.c, line 224.
```

次に /app/index.php を php コマンドに与えてプログラムを実行します。プログラムの実行には `run` もしくは `r` コマンドを実行します。

```
>>> r /app/index.php
```

実行すると、先ほど設定したブレークポイントで処理が停止します。

```
─── Output/messages ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Breakpoint 1, zif_var_dump (execute_data=0xfffff4e15150, return_value=0xffffffffcea8) at /php-src/ext/standard/var.c:224
224             ZEND_PARSE_PARAMETERS_START(1, -1)
─── Breakpoints ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[1] break at 0x0000aaaaab02a128 in /php-src/ext/standard/var.c:224 for zif_var_dump hit 1 time
─── Stack ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x0000aaaaab02a128 in zif_var_dump+16 at /php-src/ext/standard/var.c:224
[1] from 0x0000aaaaab1f28c8 in ZEND_DO_ICALL_SPEC_RETVAL_UNUSED_HANDLER+144 at /php-src/Zend/zend_vm_execute.h:1275
[2] from 0x0000aaaaab27c850 in execute_ex+2272 at /php-src/Zend/zend_vm_execute.h:57212
[3] from 0x0000aaaaab281044 in zend_execute+296 at /php-src/Zend/zend_vm_execute.h:61604
[4] from 0x0000aaaaab1a9d70 in zend_execute_scripts+332 at /php-src/Zend/zend.c:1891
[5] from 0x0000aaaaab0ecf78 in php_execute_script+640 at /php-src/main/main.c:2515
[6] from 0x0000aaaaab3467ec in do_cli+3076 at /php-src/sapi/cli/php_cli.c:966
[7] from 0x0000aaaaab347494 in main+940 at /php-src/sapi/cli/php_cli.c:1340
─── Source ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 219  {
 220      zval *args;
 221      int argc;
 222      int    i;
 223
!224      ZEND_PARSE_PARAMETERS_START(1, -1)
 225          Z_PARAM_VARIADIC('+', args, argc)
 226      ZEND_PARSE_PARAMETERS_END();
 227
 228      for (i = 0; i < argc; i++) {
─── Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg execute_data = 0xfffff4e15150: {opline = 0xfffff4e6c560,call = 0x0,return_value = 0xfffff4e150b0,func = 0x…, return_value = 0xffffffffcea8: {value = {lval = 281474790150560,dval = 1.3906702398376577e-309,counted = 0…
loc _num_args = 4108694176, _arg = 0xfffff4e151b0: {value = {lval = 281474790507264,dval = 1.3906702416000096e-309,counted = 0…, _dummy = false, _error_code = -1424021348, _max_num_args = 1, _expected_type = 43690, _error = 0x100000000 <error: Cannot access memory at address 0x100000000>: Cannot access memory…, _optional = false, _flags = 65535, _min_num_args = 4294954640, _i = 43690, _real_arg = 0xfffff4e15150: {value = {lval = 281474790507872,dval = 1.3906702416030135e-309,counted = 0…, args = 0xaaaaabf4ed60: {value = {lval = 106656922861569,dval = 5.2695521477041101e-310,counted = 0…, argc = 65535, i = -186560176, __PRETTY_FUNCTION__ = "zif_var_dump"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>>
```

var_dump() の開始位置で処理が停止しています。`next`もしくは `n`コマンドでステップ実行してみましょう。

```
>>> n
```

n コマンドを実行していくと Source でハイライト表示されているコード行が進んでいることが分かります。下記の for 文あたりまで、n コマンドで進みます。なお、n コマンドなどいくつかのコマンドではエンターだけを入力することで同じコマンドを実行できます。1 行づつ実行したい場合は便利です。

```c
 228      for (i = 0; i < argc; i++) {
 229          php_var_dump(&args[i], 1);
 230      }
```

ここで args の値を確認してみましょう。値を見る場合は `print` もしくは `p` コマンドを利用します。var_dump() の場合、argc には引数の数（+1）、args は引数の値が入っています。

```
>>> p argc
$2 = 1
>>> p args
$3 = (zval *) 0xfffff4e151a0
```

args は zval ポインタとなっているので、`p *args` とすることで内容を確認できます。ただ、これだと zval の内部構造を知らないと分かりづらいので、`printzv` コマンドを利用します。このコマンドは、php-src に含まれる .gdbinit（gdb 設定）に定義されています。

```
>>> printzv args
[0xfffff4e151a0] (refcount=2) array:     Packed(2)[0xfffff4e5b2a0]: {
      [0] 0 => [0xfffff4e5f248] (refcount=1) string: hello
      [1] 1 => [0xfffff4e5f258] (refcount=1) string: wolrd
}
```

これを見れば、2 要素を持つ配列（Packed なのでリスト）で、要素には string が格納されていることが分かります。

このように内部の挙動や値を確認したら、`continue` もしくは `c`コマンドを実行することで、処理を再開します。次の停止位置（ブレークポイントなど）がある場合はそこまで実行して停止します。

gdb を終了するには、`quit` もしくは `q` コマンドを実行します。`q` コマンドを実行すると、gdb と共にアタッチしている php コマンドも終了します。

### gdb で php-fpm コマンドにアタッチ

php-fpm コマンドにアタッチするには、`make gdb-php-fpm`コマンド実行します。gdb が起動したら、`b main`と ` r` コマンドで php-fpm の main() の先頭からステップ実行できます。この動作は `start` コマンドでも同様の操作が可能です。

```
>>> b main
>>> r

もしくは

>>> start
```

この状態では php-fpm プロセス（親プロセス）が起動しただけであり、ワーカープロセスは起動していないので FastCGI リクエストは待ち受けていません。

`c` コマンドで処理を再開することで、ワーカープロセスが生成されます。

```
>>> c

─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[03-Jun-2024 07:58:48] NOTICE: fpm is running, pid 24
[Detaching after fork from child process 27]
[03-Jun-2024 07:58:48] NOTICE: ready to handle connections
```

php-fpm は実行し続けるので、qdb コマンドを入力したい場合は `ctrl + c`を入力します。

```
^C
Program received signal SIGINT, Interrupt.
0x00007ffff7517de3 in epoll_wait (epfd=8, events=0x555556e0b930, maxevents=1, timeout=1000) at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
30      ../sysdeps/unix/sysv/linux/epoll_wait.c: No such file or directory.
─── Breakpoints ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Stack ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x00007ffff7517de3 in epoll_wait+19 at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
[1] from 0x0000555555c8e2be in fpm_event_epoll_wait+94 at /php-src/sapi/fpm/fpm/events/epoll.c:122
[2] from 0x0000555555c7a4e8 in fpm_event_loop+725 at /php-src/sapi/fpm/fpm/fpm_events.c:427
[3] from 0x0000555555c719df in fpm_run+105 at /php-src/sapi/fpm/fpm/fpm.c:113
[4] from 0x0000555555c801c2 in main+2067 at /php-src/sapi/fpm/fpm/fpm_main.c:1847
─── Source ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Cannot display "epoll_wait.c"
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg epfd = 8, events = 0x555556e0b930: {events = 0,data = {ptr = 0x0,fd = 0,u32 = 0,u64 = 0}}, maxevents = 1, timeout = 1000
loc sc_ret = -4
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>>
```

`q`コマンドを実行すると gdb と共に php-fpm が終了します。

### gdb で php-fpm ワーカープロセスにアタッチ

上記の `make gdb-php-fpm` コマンドや `make up` コマンドで、php-fpm プロセスを実行すると php-fpm ワーカープロセスが実行されます。この状態で `make gdb-php-fpm-worker` コマンドを実行するとワーカープロセスに gdb でアタッチできます。

php-fpm ワーカープロセスにアタッチすると、accept() で接続待ちの状態で処理が停止します。ここで `c` コマンドを実行すると FastCGI リクエストを待ちます。

```
$ make gdb-php-fpm
(snip)

0x00007ffff75195d0 in __libc_accept (fd=9, addr=..., len=0x7fffffffe6dc) at ../sysdeps/unix/sysv/linux/accept.c:26
26      ../sysdeps/unix/sysv/linux/accept.c: No such file or directory.
─── Breakpoints ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Stack ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x00007ffff75195d0 in __libc_accept+16 at ../sysdeps/unix/sysv/linux/accept.c:26
[1] from 0x0000555555c70a15 in fcgi_accept_request+118 at /php-src/main/fastcgi.c:1406
[2] from 0x0000555555c80747 in main+3480 at /php-src/sapi/fpm/fpm/fpm_main.c:1862
─── Source ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Cannot display "accept.c"
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg fd = 9, addr = {<No data fields>}, len = 0x7fffffffe6dc: 112
loc sc_ret = -512
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>> c

─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

別ターミナルから `make send-fcgi`コマンドを実行すると、FastCGI リクエストを送信します。ワーカープロセスはこのリクエストを処理して、レスポンスを返します。

```
$ make send-fcgi
docker compose exec -e SCRIPT_FILENAME=/app/index.php -e REQUEST_METHOD=GET php-fpm cgi-fcgi -bind -connect 127.0.0.1:9000
X-Powered-By: PHP/8.3.8-dev
Content-type: text/html; charset=UTF-8

array(2) {
  [0]=>
  string(5) "hello"
  [1]=>
  string(5) "wolrd"
}
string(4) "name"
string(4) "NAME"
end
```

ワーカープロセスをアタッチした gdb で任意のブレークポイントを仕掛けると、FastCGI リクエスト受信から PHP コード実行の流れを確認できます。例えば、fpm_main.c の 1863 行目にブレークポイントをセットすると、リクエスト着信からの処理をステップ実行できます。

```
>>> b fpm_main.c:1863
>>> c
```

## 設定

.env ファイルの内容を変更することで# gdb-php

php-fpm(php) の内部動作を確認するため、gdb でデバッグ実行できるようにした Docker Compose 環境です。

php-src から任意のブランチをチェックアウトしてビルドした php-fpm(php) に対して gdb でアタッチできるので、調査対象のバージョン（ブランチ）の挙動を確認できます。

## Usage

主な利用コマンドは make コマンドが用意されています。

### 環境構築

`make` コマンドを実行すると、Docker イメージ、php-fpm(php) コマンドをビルドします。

### gdb で php コマンドにアタッチ

`make gdb-php` コマンドで gdb を起動し、php コマンドにアタッチします。

```
GNU gdb (Debian 13.1-3) 13.1
Copyright (C) 2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "aarch64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /php-src/php/bin/php...
>>>
```

gdb コマンド入力待ちとなっています。ここではこのリポジトリに同梱している PHP コード（`/app/index.php`）をデバッグ実行してみます。

このコードでは var_dump() を実行しているので、ここにブレークポイントを仕掛けます。ブレークポイントは `break` もしくは `b` コマンドで設定できます。PHP 関数は内部的には `zif_` という prefix がついているので、これを付与します。

```
>>> b zif_var_dump
Breakpoint 1 at 0x58a128: file /php-src/ext/standard/var.c, line 224.
```

次に /app/index.php を php コマンドに与えてプログラムを実行します。プログラムの実行には `run` もしくは `r` コマンドを実行します。

```
>>> r /app/index.php
```

実行すると、先ほど設定したブレークポイントで処理が停止します。

```
─── Output/messages ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/aarch64-linux-gnu/libthread_db.so.1".

Breakpoint 1, zif_var_dump (execute_data=0xfffff4e15150, return_value=0xffffffffcea8) at /php-src/ext/standard/var.c:224
224             ZEND_PARSE_PARAMETERS_START(1, -1)
─── Breakpoints ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[1] break at 0x0000aaaaab02a128 in /php-src/ext/standard/var.c:224 for zif_var_dump hit 1 time
─── Stack ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x0000aaaaab02a128 in zif_var_dump+16 at /php-src/ext/standard/var.c:224
[1] from 0x0000aaaaab1f28c8 in ZEND_DO_ICALL_SPEC_RETVAL_UNUSED_HANDLER+144 at /php-src/Zend/zend_vm_execute.h:1275
[2] from 0x0000aaaaab27c850 in execute_ex+2272 at /php-src/Zend/zend_vm_execute.h:57212
[3] from 0x0000aaaaab281044 in zend_execute+296 at /php-src/Zend/zend_vm_execute.h:61604
[4] from 0x0000aaaaab1a9d70 in zend_execute_scripts+332 at /php-src/Zend/zend.c:1891
[5] from 0x0000aaaaab0ecf78 in php_execute_script+640 at /php-src/main/main.c:2515
[6] from 0x0000aaaaab3467ec in do_cli+3076 at /php-src/sapi/cli/php_cli.c:966
[7] from 0x0000aaaaab347494 in main+940 at /php-src/sapi/cli/php_cli.c:1340
─── Source ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 219  {
 220      zval *args;
 221      int argc;
 222      int    i;
 223
!224      ZEND_PARSE_PARAMETERS_START(1, -1)
 225          Z_PARAM_VARIADIC('+', args, argc)
 226      ZEND_PARSE_PARAMETERS_END();
 227
 228      for (i = 0; i < argc; i++) {
─── Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg execute_data = 0xfffff4e15150: {opline = 0xfffff4e6c560,call = 0x0,return_value = 0xfffff4e150b0,func = 0x…, return_value = 0xffffffffcea8: {value = {lval = 281474790150560,dval = 1.3906702398376577e-309,counted = 0…
loc _num_args = 4108694176, _arg = 0xfffff4e151b0: {value = {lval = 281474790507264,dval = 1.3906702416000096e-309,counted = 0…, _dummy = false, _error_code = -1424021348, _max_num_args = 1, _expected_type = 43690, _error = 0x100000000 <error: Cannot access memory at address 0x100000000>: Cannot access memory…, _optional = false, _flags = 65535, _min_num_args = 4294954640, _i = 43690, _real_arg = 0xfffff4e15150: {value = {lval = 281474790507872,dval = 1.3906702416030135e-309,counted = 0…, args = 0xaaaaabf4ed60: {value = {lval = 106656922861569,dval = 5.2695521477041101e-310,counted = 0…, argc = 65535, i = -186560176, __PRETTY_FUNCTION__ = "zif_var_dump"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>>
```

var_dump() の開始位置で処理が停止しています。`next`もしくは `n`コマンドでステップ実行してみましょう。

```
>>> n
```

n コマンドを実行していくと Source でハイライト表示されているコード行が進んでいることが分かります。下記の for 文あたりまで、n コマンドで進みます。なお、n コマンドなどいくつかのコマンドではエンターだけを入力することで同じコマンドを実行できます。1 行づつ実行したい場合は便利です。

```c
 228      for (i = 0; i < argc; i++) {
 229          php_var_dump(&args[i], 1);
 230      }
```

ここで args の値を確認してみましょう。値を見る場合は `print` もしくは `p` コマンドを利用します。var_dump() の場合、argc には引数の数（+1）、args は引数の値が入っています。

```
>>> p argc
$2 = 1
>>> p args
$3 = (zval *) 0xfffff4e151a0
```

args は zval ポインタとなっているので、`p *args` とすることで内容を確認できます。ただ、これだと zval の内部構造を知らないと分かりづらいので、`printzv` コマンドを利用します。このコマンドは、php-src に含まれる .gdbinit（gdb 設定）に定義されています。

```
>>> printzv args
[0xfffff4e151a0] (refcount=2) array:     Packed(2)[0xfffff4e5b2a0]: {
      [0] 0 => [0xfffff4e5f248] (refcount=1) string: hello
      [1] 1 => [0xfffff4e5f258] (refcount=1) string: wolrd
}
```

これを見れば、2 要素を持つ配列（Packed なのでリスト）で、要素には string が格納されていることが分かります。

このように内部の挙動や値を確認したら、`continue` もしくは `c`コマンドを実行することで、処理を再開します。次の停止位置（ブレークポイントなど）がある場合はそこまで実行して停止します。

gdb を終了するには、`quit` もしくは `q` コマンドを実行します。`q` コマンドを実行すると、gdb と共にアタッチしている php コマンドも終了します。

### gdb で php-fpm コマンドにアタッチ

php-fpm コマンドにアタッチするには、`make gdb-php-fpm`コマンド実行します。gdb が起動したら、`b main`と ` r` コマンドで php-fpm の main() の先頭からステップ実行できます。この動作は `start` コマンドでも同様の操作が可能です。

```
>>> b main
>>> r

もしくは

>>> start
```

この状態では php-fpm プロセス（親プロセス）が起動しただけであり、ワーカープロセスは起動していないので FastCGI リクエストは待ち受けていません。

`c` コマンドで処理を再開することで、ワーカープロセスが生成されます。

```
>>> c

─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[03-Jun-2024 07:58:48] NOTICE: fpm is running, pid 24
[Detaching after fork from child process 27]
[03-Jun-2024 07:58:48] NOTICE: ready to handle connections
```

php-fpm は実行し続けるので、qdb コマンドを入力したい場合は `ctrl + c`を入力します。

```
^C
Program received signal SIGINT, Interrupt.
0x00007ffff7517de3 in epoll_wait (epfd=8, events=0x555556e0b930, maxevents=1, timeout=1000) at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
30      ../sysdeps/unix/sysv/linux/epoll_wait.c: No such file or directory.
─── Breakpoints ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Stack ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x00007ffff7517de3 in epoll_wait+19 at ../sysdeps/unix/sysv/linux/epoll_wait.c:30
[1] from 0x0000555555c8e2be in fpm_event_epoll_wait+94 at /php-src/sapi/fpm/fpm/events/epoll.c:122
[2] from 0x0000555555c7a4e8 in fpm_event_loop+725 at /php-src/sapi/fpm/fpm/fpm_events.c:427
[3] from 0x0000555555c719df in fpm_run+105 at /php-src/sapi/fpm/fpm/fpm.c:113
[4] from 0x0000555555c801c2 in main+2067 at /php-src/sapi/fpm/fpm/fpm_main.c:1847
─── Source ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Cannot display "epoll_wait.c"
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg epfd = 8, events = 0x555556e0b930: {events = 0,data = {ptr = 0x0,fd = 0,u32 = 0,u64 = 0}}, maxevents = 1, timeout = 1000
loc sc_ret = -4
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>>
```

`q`コマンドを実行すると gdb と共に php-fpm が終了します。

### gdb で php-fpm ワーカープロセスにアタッチ

上記の `make gdb-php-fpm` コマンドや `make up` コマンドで、php-fpm プロセスを実行すると php-fpm ワーカープロセスが実行されます。この状態で `make gdb-php-fpm-worker` コマンドを実行するとワーカープロセスに gdb でアタッチできます。

php-fpm ワーカープロセスにアタッチすると、accept() で接続待ちの状態で処理が停止します。ここで `c` コマンドを実行すると FastCGI リクエストを待ちます。

```
$ make gdb-php-fpm
(snip)

0x00007ffff75195d0 in __libc_accept (fd=9, addr=..., len=0x7fffffffe6dc) at ../sysdeps/unix/sysv/linux/accept.c:26
26      ../sysdeps/unix/sysv/linux/accept.c: No such file or directory.
─── Breakpoints ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Stack ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x00007ffff75195d0 in __libc_accept+16 at ../sysdeps/unix/sysv/linux/accept.c:26
[1] from 0x0000555555c70a15 in fcgi_accept_request+118 at /php-src/main/fastcgi.c:1406
[2] from 0x0000555555c80747 in main+3480 at /php-src/sapi/fpm/fpm/fpm_main.c:1862
─── Source ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Cannot display "accept.c"
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg fd = 9, addr = {<No data fields>}, len = 0x7fffffffe6dc: 112
loc sc_ret = -512
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>> c

─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

別ターミナルから `make send-fcgi`コマンドを実行すると、FastCGI リクエストを送信します。ワーカープロセスはこのリクエストを処理して、レスポンスを返します。

```
$ make send-fcgi
docker compose exec -e SCRIPT_FILENAME=/app/index.php -e REQUEST_METHOD=GET php-fpm cgi-fcgi -bind -connect 127.0.0.1:9000
X-Powered-By: PHP/8.3.8-dev
Content-type: text/html; charset=UTF-8

array(2) {
  [0]=>
  string(5) "hello"
  [1]=>
  string(5) "wolrd"
}
string(4) "name"
string(4) "NAME"
end
```

ワーカープロセスをアタッチした gdb で任意のブレークポイントを仕掛けると、FastCGI リクエスト受信から PHP コード実行の流れを確認できます。例えば、fpm_main.c の 1863 行目にブレークポイントをセットすると、リクエスト着信からの処理をステップ実行できます。

```
>>> b fpm_main.c:1863
>>> c
```

### PHP コードの AST をダンプ

`make dump-ast` コマンドを実行すると、`./app/index.php` の AST をダンプします。

```shell
$ make dump-ast
AST_STMT_LIST
    0: AST_FUNC_DECL
        name: "foo"
        docComment: null
        params: AST_PARAM_LIST
        stmts: AST_STMT_LIST
            0: AST_CALL
                expr: AST_NAME
                    flags: NAME_NOT_FQ (1)
                    name: "var_dump"
                args: AST_ARG_LIST
                    0: "hoge"
        returnType: null
        attributes: null
        __declId: 0
    1: AST_CALL
        expr: AST_NAME
            flags: NAME_NOT_FQ (1)
            name: "foo"
        args: AST_ARG_LIST
```

### PHP コードのオペコードをダンプ

`make dump-opcode` コマンドを実行すると、`./app/index.php` のオペコードをダンプします。ここで出力されるものは最適化前のものです。（opcache.opt_debug_level=0x10000）

```shell
$ make dump-opcode

$_main:
     ; (lines=3, args=0, vars=0, tmps=1)
     ; (before optimizer)
     ; /app/index.php:1-7
     ; return  [] RANGE[0..0]
0000 INIT_FCALL 0 96 string("foo")
0001 DO_UCALL
0002 RETURN int(1)

foo:
     ; (lines=4, args=0, vars=0, tmps=1)
     ; (before optimizer)
     ; /app/index.php:3-5
     ; return  [] RANGE[0..0]
0000 INIT_FCALL 1 96 string("var_dump")
0001 SEND_VAL string("hoge") 1
0002 DO_ICALL
0003 RETURN null
```

`make dump-opcode-optimized` コマンドを実行すると、最適化されたオペコードを出力します。出力対象の PHP ファイルは `make dump-opcode` と同じです。

```shell
$ cat ./app/index.php
<?php

if (false) {
    echo 'Hello' . '!!';
}

$ make dump-opcode

$_main:
     ; (lines=3, args=0, vars=0, tmps=0)
     ; (before optimizer)
     ; /app/index.php:1-7
     ; return  [] RANGE[0..0]
0000 JMPZ bool(false) 0002
0001 ECHO string("Hello!!")
0002 RETURN int(1)

$ make dump-opcode-optimized

$_main:
     ; (lines=1, args=0, vars=0, tmps=0)
     ; (after optimizer)
     ; /app/index.php:1-7
0000 RETURN int(1)
```

## 設定

.env には下記の設定項目があります。必要に応じて変更してください。

| 項目              | 内容                                                         |
| ----------------- | ------------------------------------------------------------ |
| PHP_BRANCH        | チェックアウト、ビルドする php-src ブランチ（デフォルト: PHP-8.3.8） |
| CONFIGURE_OPTIONS | php-src ビルド時の ./configure オプション                    |






