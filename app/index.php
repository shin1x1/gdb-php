<?php
function foo(string $s): void {
    if (strlen($s) > 0) {
        echo $s, PHP_EOL;
    }
}

$a = "Hello";
foo($a);
echo "end\n";