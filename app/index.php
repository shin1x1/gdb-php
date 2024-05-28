<?php
require_once __DIR__ . '/function.php';
require_once __DIR__ . '/class.php';

use App\Foo;

$strings = to_lower(['Hello', 'Wolrd']);
var_dump($strings);

$o = new Foo(100, 'name');
var_dump($o->getName());
var_dump($o->getUpperName());

echo "end\n";