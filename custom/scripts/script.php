<?php
/**
 * Этот скрипт использует Redis для установки блокировки,
 * чтобы предотвратить одновременное выполнение нескольких экземпляров
 * одного и того же скрипта.
 * Если скрипт уже выполняется, новый запуск будет запрещен.
 *
 * @author Ksenia Ziman
 */

// Подключение к Redis
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// Ключ для блокировки
$lockKey = 'script_lock';
$lockTimeout = 10;

// Проверяем, есть ли блокировка
if ($redis->exists($lockKey)) {
    echo "Скрипт уже выполняется. Повторный запуск запрещен.\n";
    exit;
}

// Устанавливаем блокировку
$redis->set($lockKey, 1, $lockTimeout);

// Выполнение скрипта
echo "Скрипт запущен. Выполнение...\n";

// Пример функционала: запись текущего времени в файл
$filePath = 'execution_log.txt';
$currentTime = date('Y-m-d H:i:s');
file_put_contents($filePath, "Скрипт запущен в: $currentTime\n", FILE_APPEND);

// Имитация длительной задачи
sleep(5);

// Запись завершения в файл
$currentTime = date('Y-m-d H:i:s');
file_put_contents($filePath, "Скрипт завершен в: $currentTime\n", FILE_APPEND);

// Удаляем блокировку
$redis->del($lockKey);
echo "Скрипт завершен.\n";
