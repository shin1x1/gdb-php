<?php

namespace App;

use Path\To\ClassA;
use Path\To\ClassB as B;

new ClassA();
ClassA::method();
class_exists(ClassA::class);
echo ClassA::class;
