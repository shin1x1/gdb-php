<?php

namespace App;

final class Foo
{
    public function __construct(private int $id, private string $name) {}

    public function getId(): int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getUpperName(): string
    {
        return strtoupper($this->name);
    }
}
