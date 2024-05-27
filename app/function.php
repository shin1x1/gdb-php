<?php

function to_lower(array $s): array {
    return array_map(fn (string $v) => strtolower($v), $s);
}