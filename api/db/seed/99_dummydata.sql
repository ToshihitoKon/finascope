delete from finance_records
;
delete from categories
;
delete from payment_methods
;

INSERT INTO categories 
(id, label, created_at, updated_at) 
VALUES
('F3aBcT8Z', '食費', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('X2yLmV9P', '給与', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('H1qWeR4K', '教育', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('D8nBpS6M', '交通費', '2024-03-25 10:00:00', '2024-03-25 10:00:00');

INSERT INTO payment_methods 
(id, label, created_at, updated_at) 
VALUES
('P7rTvK2Q', '現金', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('M3wEcL1X', '銀行振込', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('Z4kJnU5A', 'クレジットカード', '2024-03-25 10:00:00', '2024-03-25 10:00:00'),
('L9xQaE3N', '交通系IC', '2024-03-25 10:00:00', '2024-03-25 10:00:00');

INSERT INTO finance_records 
(id, type_id, state, title, amount, category_id, payment_method_id, date, description, created_at, updated_at) 
VALUES
('A7f9D1bC', 'T5m4Qw8L', 1,'ランチ代', 850, 'F3aBcT8Z', 'P7rTvK2Q', '2024-03-25', '社員食堂にて', '2024-03-25 12:34:00', '2024-03-25 12:34:00'),
('Xz82Klm9', 'Z9x1Ab7Q', 2,'給与振込', 280000, 'X2yLmV9P', 'M3wEcL1X', '2024-03-20', '3月分の給与', '2024-03-20 09:00:00', '2024-03-20 09:00:00'),
('hY3Nc7Q1', 'T5m4Qw8L', 1,'書籍購入', 1600, 'H1qWeR4K', 'Z4kJnU5A', '2024-03-24', '技術書籍「Ruby超入門」', '2024-03-24 18:20:00', '2024-03-24 18:20:00'),
('pL8sWz9B', 'T5m4Qw8L', 1,'電車代', 220, 'D8nBpS6M', 'L9xQaE3N', '2024-03-26', '出勤交通費', '2024-03-26 08:10:00', '2024-03-26 08:10:00'),
('Dq7eM4Rt', 'T5m4Qw8L', 1,'カフェ', 480, 'F3aBcT8Z', 'Z4kJnU5A', '2024-03-27', '打ち合わせ時のコーヒー', '2024-03-27 15:30:00', '2024-03-27 15:30:00');
