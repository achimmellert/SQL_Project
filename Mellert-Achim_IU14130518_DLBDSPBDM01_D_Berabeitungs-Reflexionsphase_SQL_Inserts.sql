-- Test-Datensätze für die Testfälle hinzufügen

-- Users hinzufügen

INSERT INTO users 
	(username, hashed_password, email, is_admin, is_banned, created_at, deleted_at) 
VALUES
	('anna_mueller', '$2y$10$abcdefghijklmnopqrstuv', 'anna.mueller@example.com', FALSE, FALSE, '2024-01-15 10:30:00', NULL),
	('max_schmidt', '$2y$10$bcdefghijklmnopqrstuvw', 'max.schmidt@example.com', FALSE, FALSE, '2024-01-16 14:22:00', NULL),
	('lisa_wagner', '$2y$10$cdefghijklmnopqrstuvwx', 'lisa.wagner@example.com', TRUE, FALSE, '2024-01-10 09:15:00', NULL), -- Admin
	('tom_becker', '$2y$10$defghijklmnopqrstuvwxy', 'tom.becker@example.com', FALSE, TRUE, '2023-12-05 16:45:00', NULL), -- Gebannt
	('julia_hoffmann', '$2y$10$efghijklmnopqrstuvwxyz', 'julia.hoffmann@example.com', FALSE, FALSE, '2024-02-01 11:10:00', NULL),
	('felix_krause', '$2y$10$fghijklmnopqrstuvwxyza', 'felix.krause@example.com', FALSE, FALSE, '2024-02-03 13:20:00', NULL),
	('sarah_meyer', '$2y$10$ghijklmnopqrstuvwxyzab', 'sarah.meyer@example.com', FALSE, FALSE, '2024-01-28 17:05:00', NULL),
	('david_schulz', '$2y$10$hijklmnopqrstuvwxyzabc', 'david.schulz@example.com', FALSE, FALSE, '2024-01-20 08:55:00', NULL),
	('lena_fischer', '$2y$10$ijklmnopqrstuvwxyzabcd', 'lena.fischer@example.com', TRUE, FALSE, '2023-11-12 12:00:00', NULL), -- Admin
	('marc_weber', '$2y$10$jklmnopqrstuvwxyzabcde', 'marc.weber@example.com', FALSE, FALSE, '2024-02-10 15:30:00', NULL)
;


-- TimeSlots hinzufügen

-- Slots für anna_mueller (user_id = 1)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(1, 1, '09:00:00', '12:00:00'), -- Mo
(1, 3, '14:00:00', '18:00:00'); -- Mi

-- Slots für max_schmidt (user_id = 2)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(2, 2, '10:00:00', '13:00:00'), -- Di
(2, 4, '15:00:00', '19:00:00'); -- Do

-- Slots für lisa_wagner (user_id = 3, Admin)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(3, 1, '08:00:00', '16:00:00'), -- Mo (lang)
(3, 5, '09:30:00', '12:30:00'); -- Fr

-- tom_becker (user_id = 4) ist gebannt – aber kann trotzdem Slots haben (wird nicht genutzt)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(4, 2, '11:00:00', '14:00:00'); -- Di

-- julia_hoffmann (user_id = 5)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(5, 1, '13:00:00', '17:00:00'), -- Mo
(5, 3, '09:00:00', '11:00:00'), -- Mi
(5, 5, '16:00:00', '20:00:00'); -- Fr

-- felix_krause (user_id = 6)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(6, 4, '10:00:00', '15:00:00'); -- Do

-- sarah_meyer (user_id = 7)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(7, 2, '14:00:00', '18:00:00'), -- Di
(7, 6, '10:00:00', '13:00:00'); -- Sa (Ausnahme: Wochenende)

-- david_schulz (user_id = 8)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(8, 1, '09:00:00', '12:00:00'), -- Mo
(8, 3, '13:00:00', '17:00:00'); -- Mi

-- lena_fischer (user_id = 9, Admin)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(9, 5, '08:00:00', '14:00:00'); -- Fr

-- marc_weber (user_id = 10)
INSERT INTO time_slots (user_id, day_of_week, start_time, end_time) VALUES
(10, 2, '09:30:00', '12:30:00'), -- Di
(10, 4, '14:30:00', '18:30:00') -- Do
;


-- Adressen hinzufügen

INSERT INTO address
	(user_id, street, house_number, postal_code, city, latitude, longitude)
VALUES
	(1, 'Ettlinger Straße', 4, '76137', 'Karlsruhe', 49.001617, 8.402347),
    (2, 'Bismarckstraße', 10, '76133', 'Karlsruhe', 49.013304, 8.393485),
    (3, 'Am Sportpark', 1, '76131', 'Karlsruhe', 49.025607, 8.444766),
    (4, 'Opernplatz', 1, '60313', 'Frankfurt am Main', 50.116047, 8.671986),
    (5, 'Liebfrauenplatz', 4, '55116', 'Mainz', 49.998990, 8.274613),
    (6, 'Berliner Straße', 23, '67059', 'Ludwigshafen am Rhein', 49.479796, 8.443953),
    (7, 'Karlsplatz', 1, '80335', 'München', 48.139221, 11.564418),
    (8, 'Kartäusergasse', 1, '90402','Nürnberg', 49.448082, 11.076159),
    (9, 'Karl-Liebknecht-Straße', 8, '10178', 'Berlin', 52.520550, 13.407178),
    (10, 'Kantstraße', 12, '10623','Berlin', 52.505904, 13.329005)
;    


-- Genres hinzufügen

INSERT INTO genre (genre_name)
VALUES
	('Roman'),
	('Krimi'),
	('Science-Fiction'),
	('Fantasy'),
	('Biografie'),
	('Sachbuch'),
	('Historischer Roman'),
	('Liebesroman'),
	('Thriller'),
	('Kinderbuch')
;


-- Publisher hinzufügen

INSERT INTO publisher (publisher_name)
VALUES
	('Penguin Random House'),
	('Suhrkamp Verlag'),
	('Rowohlt Verlag'),
	('Fischer Verlag'),
	('Heyne Verlag'),
	('Carlsen Verlag'),
	('Klett-Cotta'),
	('dtv (Deutscher Taschenbuch Verlag)'),
	('Hanser Verlag'),
	('Thieme Verlag'),
    ('Packt Publishing'),
    ('O’Reilly Media')
;


-- Languages hinzufügen

INSERT INTO languages (language_name)
VALUES
	('Deutsch'),
	('Englisch'),
	('Französisch'),
	('Spanisch'),
	('Italienisch'),
	('Russisch'),
	('Chinesisch'),
	('Japanisch'),
	('Portugiesisch'),
	('Niederländisch')
;


-- Autoren hinzufügen

INSERT INTO author (first_name, last_name)
VALUES
	('George', 'Orwell'),
	('Aldous', 'Huxley'),
	('J.K.', 'Rowling'),
	('J.R.R.', 'Tolkien'),
	('Haruki', 'Murakami'),
	('Charlotte', 'Link'),
	('Friedrich', 'Dürrenmatt'),
	('Stephen', 'King'),
	('Agatha', 'Christie'),
	('Erich', 'Kästner')
;


-- Bücher hinzufügen

INSERT INTO book (title, language_id, genre_id, publisher_id, publication_year)
VALUES
	-- 1. 1984 (Englisch, Science-Fiction, Penguin)
	('1984', 2, 3, 1, 1949),
	
	-- 2. Schöne neue Welt (Englisch, Science-Fiction, Suhrkamp)
	('Brave New World', 2, 3, 2, 1932),
	
	-- 3. Harry Potter und der Stein der Weisen (Deutsch, Fantasy, Carlsen)
	('Harry Potter und der Stein der Weisen', 1, 4, 6, 1997),
	
	-- 4. Der Herr der Ringe (Deutsch, Fantasy, Klett-Cotta)
	('Der Herr der Ringe', 1, 4, 7, 1954),
	
	-- 5. Kafka auf dem Dorf (Deutsch, Roman, Rowohlt)
	('Kafka auf dem Dorf', 1, 1, 3, 1995),
	
	-- 6. Die Physiker (Deutsch, Roman, Fischer)
	('Die Physiker', 1, 1, 4, 1962),
	
	-- 7. Shining (Deutsch, Thriller, Heyne)
	('Shining', 1, 9, 5, 1977),
	
	-- 8. Mord im Orient-Express (Deutsch, Krimi, dtv)
	('Mord im Orient-Express', 1, 2, 8, 1934),
	
	-- 9. Emil und die Detektive (Deutsch, Kinderbuch, Hanser)
	('Emil und die Detektive', 1, 10, 9, 1929),
	
	-- 10. 1Q84 (Japanisch, Roman, Suhrkamp)
	('1Q84', 8, 1, 2, 2009),
    
    -- 11. Testbuch für Leihanfrage
    ('Testbuch für Leihanfrage', 1, 1, 1, 2020);
;


-- Daten für die Assoziationstabelle hinzufügen

INSERT INTO book_author (book_id, author_id)
VALUES
	-- Buch 1: 1984 → George Orwell
	(1, 1),
	
	-- Buch 2: Schöne neue Welt → Aldous Huxley
	(2, 2),
	
	-- Buch 3: Harry Potter → J.K. Rowling
	(3, 3),
	
	-- Buch 4: Herr der Ringe → J.R.R. Tolkien
	(4, 4),
	
	-- Buch 5: Kafka auf dem Dorf → Haruki Murakami
	(5, 5),
	
	-- Buch 6: Die Physiker → Friedrich Dürrenmatt
	(6, 7),
	
	-- Buch 7: Shining → Stephen King
	(7, 8),
	
	-- Buch 8: Mord im Orient-Express → Agatha Christie
	(8, 9),
	
	-- Buch 9: Emil und die Detektive → Erich Kästner
	(9, 10),
	
	-- Buch 10: 1Q84 → Haruki Murakami
	(10, 5)
;


-- Einzelne Examplare hinzufügen

INSERT INTO book_copy (owner_id, book_id, condition_rating, notes, is_available, max_loan_days, shipping_possible) VALUES
-- Anna (1) besitzt "1984" (1)
(1, 1, 'Sehr gut', 'Leichte Lesezeichen-Spuren', TRUE, 14, TRUE),

-- Max (2) besitzt "Schöne neue Welt" (2)
(2, 2, 'Gut', NULL, TRUE, 21, FALSE),

-- Lisa (3, Admin) besitzt "Harry Potter" (3)
(3, 3, 'Neu', 'Ungelesen, Geschenk', TRUE, 14, TRUE),

-- Tom (4, gebannt) besitzt "Herr der Ringe" (4) – aber nicht verfügbar (vielleicht beschädigt)
(4, 4, 'Deutliche Schäden', 'Einband lose', FALSE, 7, FALSE),

-- Julia (5) besitzt "Kafka auf dem Dorf" (5)
(5, 5, 'Akzeptabel', 'Seiten leicht wellig', TRUE, 14, TRUE),

-- Felix (6) besitzt "Die Physiker" (6)
(6, 6, 'Sehr gut', NULL, TRUE, 14, TRUE),

-- Sarah (7) besitzt "Shining" (7)
(7, 7, 'Gut', 'Einige Unterstreichungen', TRUE, 21, TRUE),

-- David (8) besitzt "Mord im Orient-Express" (8)
(8, 8, 'Neu', NULL, FALSE, 14, TRUE), -- Nicht verfügbar (vielleicht gerade ausgeliehen)

-- Lena (9, Admin) besitzt "Emil und die Detektive" (9)
(9, 9, 'Sehr gut', 'Kinderbuch, altersgemäß genutzt', TRUE, 14, FALSE),

-- Marc (10) besitzt "1Q84" (10)
(10, 10, 'Gut', 'Japanische Ausgabe, Originalverpackung dabei', TRUE, 21, TRUE),

-- Zusätzlich: Anna (1) besitzt noch ein zweites Buch – "Emil" (9)
(1, 9, 'Akzeptabel', 'Aus der Schulzeit', TRUE, 14, TRUE),

-- Und Max (2) hat auch "1984" (1) – zweites Exemplar im System!
(2, 1, 'Gut', 'Ältere Ausgabe', TRUE, 7, FALSE),

-- 13. Lena (9) besitzt auch "1984" (1)
(9, 1, 'Gut', 'Gebraucht gekauft, aber gut erhalten', TRUE, 14, TRUE),

-- 14. Sarah (7) hat "Harry Potter" (3) – zweites Exemplar
(7, 3, 'Neu', 'Sammledition', TRUE, 21, TRUE),

-- 15. David (8) besitzt "Schöne neue Welt" (2)
(8, 2, 'Akzeptabel', 'Ältere Taschenbuchausgabe', TRUE, 14, FALSE),

-- 16. Marc (10) hat "Der Herr der Ringe" (4)
(10, 4, 'Sehr gut', 'Hardcover, Schutzumschlag vorhanden', TRUE, 21, TRUE),

-- 17. Julia (5) besitzt "Shining" (7) – aber nicht verfügbar (gerade ausgeliehen)
(5, 7, 'Gut', 'Leichte Feuchtigkeitsspuren', FALSE, 14, TRUE),

-- 18. Felix (6) hat "Emil und die Detektive" (9) – für seine Kinder
(6, 9, 'Akzeptabel', 'Viele Eselsohren, aber vollständig', TRUE, 14, FALSE),

-- 19. Lisa (3) besitzt "1Q84" (10) – Sammlerstück
(3, 10, 'Neu', 'Erstausgabe, signiert', TRUE, 7, FALSE), -- Kurze Leihfrist, kein Versand

-- 20. Anna (1) hat "Die Physiker" (6) – aber beschädigt
(1, 6, 'Deutliche Schäden', 'Wasserflecken auf den letzten Seiten', FALSE, 14, TRUE),

-- 21. Jana (9) hat "Testbuch für Leihanfrage"
(9, 11, 'Gut', NULL, TRUE, 14, FALSE)
;


-- Anfragen hinzufügen

INSERT INTO loan_request (borrower_id, responder_id, copy_id, request_status, message, responded_at) VALUES
-- 1. Julia (5) bittet Anna (1) um "1984" (copy_id=1) – akzeptiert
(5, 1, 1, 'akzeptiert', 'Hallo Anna, ich würde dein Exemplar von 1984 gerne für mein Seminar ausleihen. Ist das möglich?', NULL),

-- 2. David (8) bittet Max (2) um "Schöne neue Welt" (copy_id=2) – akzeptiert
(8, 2, 2, 'akzeptiert', 'Hi Max, brauche das Buch für eine Buchrezension. Danke!', NOW() - INTERVAL 2 DAY),

-- 3. Felix (6) bittet Lisa (3) um "Harry Potter" (copy_id=3) – abgelehnt
(6, 3, 3, 'abgelehnt', 'Liebe Lisa, mein Sohn möchte Harry Potter lesen. Wärst du bereit, es zu verleihen?', NOW() - INTERVAL 1 DAY),

-- 4. Marc (10) bittet Lena (9) um "1984" (copy_id=13) – ausstehend
(10, 9, 13, 'ausstehend', 'Hallo Lena, ich suche dringend eine gut erhaltene Ausgabe von 1984. Dein Exemplar sieht perfekt aus!', NULL),

-- 5. Sarah (7) bittet Felix (6) um "Die Physiker" (copy_id=6) – akzeptiert
(7, 6, 6, 'akzeptiert', 'Hi Felix, ich brauche das Buch für meinen Literaturkurs. Würdest du es mir leihen?', NULL),

-- 6. Anna (1) bittet Marc (10) um "Herr der Ringe" (copy_id=16) – ausstehend
(1, 10, 16, 'ausstehend', 'Hallo Marc, ich würde gerne deinen Herrn der Ringe ausleihen – falls noch verfügbar?', NULL),

-- 7. Julia (5) leiht "Emil und die Detektive" (copy_id=9) von Lena (9) - akzeptiert
(5, 9, 9, 'akzeptiert', 'Liebe Lena, darf ich dein Exemplar von Emil ausleihen? Für meinen Neffen.', '2024-03-09'),

(
    5,               -- borrower_id
    9,               -- responder_id (Besitzer des Exemplars)
    21,             -- copy_id (muss existieren!)
    'akzeptiert',    -- Status: akzeptiert
    'Hallo, ich möchte das Buch ausleihen.',
    NOW()            -- responded_at = jetzt
);


-- Loans hinzufügen

-- 1. AKTIV: David (8) leiht "Schöne neue Welt" (copy_id=2) von Max (owner_id=2)
--    → Entstanden aus akzeptierter Anfrage (loan_request #2)
INSERT INTO loan (borrower_id, copy_id, loan_date, due_date, return_date, loan_status) VALUES
(8, 2, CURDATE() - INTERVAL 5 DAY, CURDATE() + INTERVAL 3 DAY, NULL, 'aktiv');

-- 2. AKTIV: Sarah (7) leiht "Die Physiker" (copy_id=6) von Felix (6)
--    (angenommen, Anfrage wurde akzeptiert)
INSERT INTO loan (borrower_id, copy_id, loan_date, due_date, return_date, loan_status) VALUES
(7, 6, CURDATE() - INTERVAL 2 DAY, CURDATE() + INTERVAL 12 DAY, NULL, 'aktiv');

-- 3. ERLEDIGT: Julia (5) hat "1984" (copy_id=1) von Anna (1) ausgeliehen und zurückgegeben
INSERT INTO loan (borrower_id, copy_id, loan_date, due_date, return_date, loan_status) VALUES
(5, 1, '2024-04-01', '2024-04-15', '2024-04-12', 'erledigt');

-- 4. ERLEDIGT: Julia (5) leiht "Emil und die Detektive" (copy_id=9) von Lena (9)
INSERT INTO loan (borrower_id, copy_id, loan_date, due_date, return_date, loan_status) VALUES
(5, 9, '2024-03-10', '2024-03-24', '2024-03-22', 'erledigt')
;


-- Reviews hinzufügen

-- Rezension 1: Julia (borrower) bewertet Anna (lender) nach Ausleihe von "1984" (loan_id=3)
INSERT INTO review (loan_id, reviewer_user_id, reviewed_user_id, reviewer_role, rating, review_text, created_at) VALUES
(3, 5, 1, 'borrower', 5, 'Super schneller Versand und das Buch war in einem sehr guten Zustand. Gerne wieder!', NOW() - INTERVAL 2 DAY);

-- Rezension 2: Anna (lender) bewertet Julia (borrower) nach Rückgabe (loan_id=3)
INSERT INTO review (loan_id, reviewer_user_id, reviewed_user_id, reviewer_role, rating, review_text, created_at) VALUES
(3, 1, 5, 'lender', 4, 'Pünktliche Rückgabe und das Buch war sauber. Danke!', NOW() - INTERVAL 1 DAY);

-- Rezension 3: Lena (lender) bewertet Julia (borrower) (loan_id=4)
INSERT INTO review (loan_id, reviewer_user_id, reviewed_user_id, reviewer_role, rating, review_text, created_at) VALUES
(4, 9, 5, 'lender', 5, 'Julia hat das Buch sehr sorgfältig behandelt. Sehr zu empfehlen als Borrower!', NOW() - INTERVAL 4 DAY)
;

