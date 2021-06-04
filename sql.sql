ALTER TABLE `users` ADD roue int;
ALTER TABLE `users` ALTER roue SET DEFAULT '1';
ALTER TABLE `users` MODIFY roue int NOT NULL;