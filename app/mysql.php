<?php
declare(strict_types=1);

$pdo = new PDO('mysql:host=mysql;dbname=app', 'root', 'pass');
foreach ($pdo->query('select version()') as $row) {
    var_dump($row);
}