-- Zunächst werden alle Tabellen erstellt

CREATE TABLE genre (
	genre_id INTEGER PRIMARY KEY auto_increment,
    genre_name VARCHAR(100) UNIQUE
);


CREATE TABLE publisher (
	publisher_id INTEGER primary key auto_increment,
    publisher_name VARCHAR(100) UNIQUE
);


CREATE TABLE languages (
	language_id INTEGER primary key auto_increment,
    language_name VARCHAR(50) UNIQUE
);


CREATE TABLE author (
	author_id INTEGER PRIMARY KEY auto_increment,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    INDEX author_first_name (first_name),
    INDEX author_last_name (last_name)
);


CREATE TABLE book (
	book_id INTEGER PRIMARY KEY auto_increment,
    language_id INTEGER,
    genre_id INTEGER,
    publisher_id INTEGER,
    title VARCHAR(150) NOT NULL,
    publication_year INTEGER CHECK(publication_year > 0),
    FOREIGN KEY (language_id) REFERENCES languages(language_id) ON DELETE RESTRICT,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE RESTRICT,
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id) ON DELETE RESTRICT,
    INDEX idx_book_title (title),
    FULLTEXT INDEX ft_book_title (title)
);


CREATE TABLE book_author (
	book_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE RESTRICT,
    INDEX idx_fk_book_id (book_id),
    INDEX idx_fk_author_id (author_id)
);


CREATE TABLE users (
	user_id INTEGER PRIMARY KEY auto_increment,
    username VARCHAR(50) NOT NULL UNIQUE,
    hashed_password VARCHAR(254) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE CHECK(email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    is_banned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    deleted_at TIMESTAMP DEFAULT NULL
);


CREATE TABLE book_copy (
	copy_id INTEGER PRIMARY KEY auto_increment,
    owner_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    condition_rating ENUM('Neu', 'Sehr gut', 'Gut', 'Akzeptabel', 'Deutliche Schäden') NOT NULL,
    notes TEXT,
    is_available BOOLEAN NOT NULL,
    max_loan_days INTEGER CHECK(max_loan_days > 0),
    shipping_possible BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    INDEX idx_owner_id (owner_id)
);


CREATE TABLE address (
	address_id INTEGER PRIMARY KEY auto_increment,
    user_id INTEGER NOT NULL UNIQUE,
    street VARCHAR(100) NOT NULL,
    house_number SMALLINT UNSIGNED NOT NULL,
    postal_code CHAR(5) NOT NULL,
    city VARCHAR(50) NOT NULL,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    location POINT NOT NULL SRID 4326,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    SPATIAL INDEX sp_idx_location (location)
);


CREATE TABLE time_slots (
	slot_id INTEGER PRIMARY KEY auto_increment,
    user_id INTEGER NOT NULL,
    day_of_week TINYINT NOT NULL CHECK(day_of_week >=1 AND day_of_week <=7),
    start_time TIME NOT NULL CHECK(start_time >= '00:00:00' AND start_time <= '23:59:59'),
    end_time TIME NOT NULL CHECK(end_time <= '23:59:59'),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE loan (
	loan_id INTEGER PRIMARY KEY auto_increment,
    borrower_id INTEGER NOT NULL,
    copy_id INTEGER,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    loan_status ENUM('aktiv', 'erledigt', 'fällig'),
    FOREIGN KEY (borrower_id) REFERENCES users(user_id),
    FOREIGN KEY (copy_id) REFERENCES book_copy(copy_id) ON DELETE SET NULL,
    INDEX idx_loan_copy_id (copy_id)
);


CREATE TABLE review (
	review_id INTEGER PRIMARY KEY auto_increment,
    loan_id INTEGER NOT NULL,
    reviewer_user_id INTEGER NOT NULL,
    reviewed_user_id INTEGER NOT NULL,
    reviewer_role ENUM('lender', 'borrower'),
    rating TINYINT NOT NULL CHECK(rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE loan_request (
	request_id INTEGER PRIMARY KEY auto_increment,
    borrower_id INTEGER NOT NULL,
    responder_id INTEGER NOT NULL,
    copy_id INTEGER NOT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT current_timestamp,
    request_status ENUM ('ausstehend', 'akzeptiert', 'abgelehnt') NOT NULL DEFAULT 'ausstehend',
    message TEXT,
    responded_at TIMESTAMP DEFAULT NULL,
    FOREIGN KEY (borrower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (responder_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (copy_id) REFERENCES book_copy(copy_id) ON DELETE CASCADE
);


-- MySQL führt Events nur aus, wenn der Event-Scheduler eingeschaltet ist
SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- Jede Tabelle erhält Trigger, die Datenintegrität und Logik sicherstellen

-- Sicherstellung, dass Ausleiher != Verleiher
CREATE TRIGGER check_borrower_not_owner_insert
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    DECLARE owner_id_var INT;
    
    SELECT owner_id INTO owner_id_var
    FROM book_copy
    WHERE copy_id = NEW.copy_id;
    
    IF NEW.borrower_id = owner_id_var THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Der Ausleiher darf nicht der Besitzer des Buchexemplars sein.';
    END IF;
END $$


-- Sicherstellung, dass Ausleiher != Besitzer
CREATE TRIGGER check_borrower_not_owner_update
BEFORE UPDATE ON loan
FOR EACH ROW
BEGIN
    DECLARE owner_id_var INT;
    
    SELECT owner_id INTO owner_id_var
    FROM book_copy
    WHERE copy_id = NEW.copy_id;
    
    IF NEW.borrower_id = owner_id_var THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Der Ausleiher darf nicht der Besitzer des Buchexemplars sein.';
    END IF;
END $$


-- Vermeidung von mehrfachem Ausleihen desselben Exemplars
CREATE TRIGGER prevent_parallel_loan_insert
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
	DECLARE active_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO active_count
    FROM loan
    WHERE NEW.copy_id = copy_id AND loan_status = 'aktiv';
    
    IF active_count > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Ein bereits ausgeliehenes Buch kann nicht nochmals ausgeliehen werden.';
	END IF;
END $$
    
    
-- Automatisches Status-Setzen für erledigt
CREATE TRIGGER set_status_on_done
BEFORE UPDATE ON loan
FOR EACH ROW
BEGIN    
	IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
		SET NEW.loan_status = 'erledigt';
	END IF;
END $$


-- Status auf ausgeliehen setzen bei neuem Ausleih-Vorgang
CREATE TRIGGER adapt_isavailable_to_status
AFTER UPDATE ON loan
FOR EACH ROW
BEGIN	    
    IF NEW.loan_status = 'aktiv' AND OLD.loan_status != 'aktiv' THEN
		UPDATE book_copy
        SET is_available = False
        WHERE NEW.copy_id = copy_id;
	END IF;
END $$


-- Ausleihe nur erlaubt, wenn Request-Status = 'akzeptiert' ist
CREATE TRIGGER enforce_loan_after_accepted_request
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    DECLARE request_exists INT DEFAULT 0;
    
    SELECT COUNT(*) INTO request_exists
    FROM loan_request
    WHERE 
        borrower_id = NEW.borrower_id
        AND copy_id = NEW.copy_id
        AND request_status = 'akzeptiert';
    
    IF request_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ausleihe nicht erlaubt: Keine akzeptierte Anfrage vorhanden.';
    END IF;
END $$


-- Anfrage für bereits ausgeliehenes Buch nicht möglich
CREATE TRIGGER prevent_request_for_loaned_book
BEFORE INSERT ON loan_request
FOR EACH ROW
BEGIN
    DECLARE is_loaned INT DEFAULT 0;
    
    SELECT COUNT(*) INTO is_loaned
    FROM loan
    WHERE copy_id = NEW.copy_id AND loan_status = 'aktiv';
    
    IF is_loaned > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Anfrage nicht möglich: Das Buchexemplar ist bereits ausgeliehen.';
    END IF;
END $$


-- Anfrage wird gelöscht, sobald Ausleihe gestartet ist
CREATE TRIGGER delete_request_after_loan_insert
AFTER INSERT ON loan
FOR EACH ROW
BEGIN
	DELETE FROM loan_request
    WHERE borrower_id = NEW.borrower_id
		AND copy_id = NEW.copy_id
        AND request_status = 'akzeptiert';
END $$


-- Automatische Berechnung des Spatial Points für Open Source Map
CREATE TRIGGER address_set_location
BEFORE INSERT ON address
FOR EACH ROW
BEGIN
    SET NEW.location = ST_PointFromText(CONCAT('POINT(', NEW.longitude, ' ', NEW.latitude, ')'), 4326);
END $$


CREATE TRIGGER address_update_location
BEFORE UPDATE ON address
FOR EACH ROW
BEGIN
    SET NEW.location = ST_PointFromText(CONCAT('POINT(', NEW.longitude, ' ', NEW.latitude, ')'), 4326);
END$$


-- Verhindert mehrere Anfragen für das gleiche Exemplar
CREATE TRIGGER only_one_request
BEFORE INSERT ON loan_request
FOR EACH ROW
BEGIN
	DECLARE active_request INT DEFAULT 0;
    
    SELECT COUNT(*) INTO active_request
    FROM loan_request
    WHERE NEW.borrower_id = borrower_id AND request_status = 'ausstehend' AND NEW.copy_id = copy_id;
    
    IF active_request > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Bereits eine Anfrage versendet.';
	END IF;
END $$


-- Veröffentlichungsdatum kann niemals in der Zukunft sein
CREATE TRIGGER check_publication_year_insert
BEFORE INSERT ON book
FOR EACH ROW
BEGIN
	IF NEW.publication_year > YEAR(CURDATE()) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Ungültiges Jahr';
	END IF;
END $$


-- Veröffentlichungsdatum kleiner 0 ist nicht erlaubt
CREATE TRIGGER check_publication_year_update
BEFORE UPDATE ON book
FOR EACH ROW
BEGIN
	IF NEW.publication_year <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Ungültiges Jahr';
	END IF;
END $$


-- Event prüft jeden Tag, welche Ausleihungen fällig sind
CREATE EVENT update_overdue_loans
ON SCHEDULE EVERY 1 DAY
STARTS DATE_ADD(CURDATE(), INTERVAL 1 SECOND)
DO
BEGIN
	UPDATE loan
    SET loan_status = 'fällig'
    WHERE
		return_date IS NULL AND due_date < CURDATE()
        AND loan_status != 'fällig';
        
END $$


-- Zusätzlicher Trigger, der Datenintegrität schützt
CREATE TRIGGER prevent_hard_delete_users
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
	
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Fehler: Hard-Delete nicht erlaubt. Bitt Soft-Delete verwenden.';

END;


-- Da User kann nur "soft"-gelöscht werden kann
-- DSGVO-konforme User-Löschung, indem personalisierte Informationen anonymisiert werden
-- Der Timestamp für deleted_at kommt von außen
CREATE TRIGGER soft_delete_user_cleanup
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
	
    DECLARE active_borrowed_copies INT DEFAULT 0;
    
	IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
        
        SELECT COUNT(*) INTO active_borrowed_copies
        FROM loan
        WHERE NEW.user_id = borrower_id AND loan_status != 'erledigt';
        
        IF active_borrowed_copies > 0 THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fehler: Löschung nicht erlaubt, da noch aktive Leihungen';
		END IF;
        
		SET NEW.username = CONCAT('user_', NEW.user_id);
        SET NEW.email = CONCAT('user_', NEW.user_id, '@deleted.example.com');
        
        DELETE FROM loan_request
        WHERE borrower_id = NEW.user_id OR responder_id = NEW.user_id;
        
        DELETE FROM book_copy
        WHERE owner_id = NEW.user_id;
        
        DELETE FROM address
        WHERE user_id = NEW.user_id;
        
        DELETE FROM time_slots 
        WHERE user_id = NEW.user_id;
        
		DELETE FROM review 
        WHERE reviewer_user_id = NEW.user_id OR reviewed_user_id = NEW.user_id;

    END IF;
END $$
        

-- aus der Book-Tabelle wird eine Entität entfernt, sobald es keine Exemplare mehr gibt (keine toten Entitäten)
CREATE TRIGGER cleanup_book_if_no_copies_left
AFTER DELETE ON book_copy
FOR EACH ROW
BEGIN
	DECLARE copies_left INT DEFAULT 0;
    
    SELECT COUNT(*) INTO copies_left
    FROM book_copy
    WHERE book_id = OLD.book_id;
    
    IF copies_left = 0 THEN
		DELETE FROM book
		WHERE book_id = OLD.book_id;
	END IF;
END $$
		

-- Datumslogik
CREATE TRIGGER check_loan_dates_insert
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    IF NOT (NEW.loan_date < NEW.due_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'loan_date muss vor due_date liegen.';
    END IF;
    
    IF NEW.return_date IS NOT NULL AND NOT (NEW.loan_date < NEW.return_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'loan_date muss vor return_date liegen.';
    END IF;
END $$


CREATE TRIGGER check_loan_dates_update
BEFORE UPDATE ON loan
FOR EACH ROW
BEGIN
    IF NOT (NEW.loan_date < NEW.due_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'loan_date muss vor due_date liegen.';
    END IF;
    
    IF NEW.return_date IS NOT NULL AND NOT (NEW.loan_date < NEW.return_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'loan_date muss vor return_date liegen.';
    END IF;
END $$


-- Sobald ein Exemplar in Ausleihe ist, wird dessen is_available-Flag auf False gesetzt
CREATE TRIGGER set_isavailable_on_loan_insert
AFTER INSERT ON loan
FOR EACH ROW
BEGIN
    IF NEW.loan_status = 'aktiv' THEN
        UPDATE book_copy
        SET is_available = FALSE
        WHERE copy_id = NEW.copy_id;
    END IF;
END$$


-- Manuelles is_available setzen verhindern, wenn es noch in Ausleihe ist (Datenintegrität)
CREATE TRIGGER prevent_manual_available_when_in_loan
BEFORE UPDATE ON book_copy
FOR EACH ROW
BEGIN
	DECLARE active_loan INT DEFAULT 0;
    
	IF NEW.is_available = TRUE AND OLD.is_available = FALSE THEN
    
		SELECT COUNT(*) INTO active_loan
		FROM loan
		WHERE copy_id = NEW.copy_id
		AND (loan_status = 'aktiv' OR loan_status = 'fällig');
		
		IF active_loan > 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Fehler: Buch noch in Ausleihe.';
		END IF;
	END IF;
END $$
    

-- Review nur bei tatsächlichen Ausleihungen möglich
CREATE TRIGGER review_check_loan_exists
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE loan_exists INT DEFAULT 0;
    
    SELECT COUNT(*) INTO loan_exists
    FROM loan
    WHERE loan_id = NEW.loan_id;
    
    IF loan_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Ungültige loan_id – Leihgabe existiert nicht.';
    END IF;
END$$


-- Bei review muss der Autor entweder Ausleiher oder Verleiher gewesen sein
CREATE TRIGGER review_check_reviewer_participated
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE borrower_id_var INT;
    DECLARE owner_id_var INT;
    DECLARE copy_id_var INT;
    
    SELECT borrower_id, copy_id
    INTO borrower_id_var, copy_id_var
    FROM loan
    WHERE loan_id = NEW.loan_id;
    
    SELECT owner_id INTO owner_id_var
    FROM book_copy
    WHERE copy_id = copy_id_var;
    
    IF NEW.reviewer_user_id != borrower_id_var AND NEW.reviewer_user_id != owner_id_var THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Rezensent war weder Leiher noch Verleiher dieser Leihgabe.';
    END IF;
END$$


-- Mehrfache Reviews desselben Ausleihungs-Prozesses verhindern
CREATE TRIGGER review_prevent_duplicate
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE existing_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO existing_count
    FROM review
    WHERE loan_id = NEW.loan_id
      AND reviewer_user_id = NEW.reviewer_user_id;
      
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Für diese Leihgabe wurde bereits eine Bewertung abgegeben.';
    END IF;
END$$


-- Review erst nach Abschluss der Leihgabe möglich machen
CREATE TRIGGER review_check_loan_ended_or_overdue
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE v_loan_status VARCHAR(20);
    DECLARE v_due_date DATE;
    
    SELECT loan_status, due_date
    INTO v_loan_status, v_due_date
    FROM loan
    WHERE loan_id = NEW.loan_id;
    
    IF NOT (
        v_loan_status = 'erledigt'
        OR
        (v_loan_status != 'erledigt' AND v_due_date IS NOT NULL AND CURDATE() >= DATE_ADD(v_due_date, INTERVAL 3 DAY))
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Bewertungen sind nur nach Abschluss der Leihgabe oder 3 Tage nach Fälligkeit erlaubt.';
    END IF;
END$$


-- Die Rolle des Rezensent automatisch vergeben
CREATE TRIGGER review_set_reviewer_role
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE borrower_id_var INT;
    DECLARE owner_id_var INT;
    DECLARE copy_id_var INT;
    
    SELECT borrower_id, copy_id
    INTO borrower_id_var, copy_id_var
    FROM loan
    WHERE loan_id = NEW.loan_id;
    
    SELECT owner_id INTO owner_id_var
    FROM book_copy
    WHERE copy_id = copy_id_var;
    
    IF NEW.reviewer_user_id = borrower_id_var THEN
        SET NEW.reviewer_role = 'borrower';
    ELSEIF NEW.reviewer_user_id = owner_id_var THEN
        SET NEW.reviewer_role = 'lender';
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Rezensent ist weder Leiher noch Verleiher.';
    END IF;
END$$


-- Exemplar kann niemals direkt und manuell gelöscht werden, solange es sich noch in Ausleihe befindet
CREATE TRIGGER delete_copy_only_without_loan
BEFORE DELETE ON book_copy
FOR EACH ROW
BEGIN
	DECLARE active_loans INT DEFAULT 0;
    
    SELECT COUNT(*) INTO active_loans
    FROM loan l
    WHERE OLD.copy_id = l.copy_id AND l.loan_status != 'erledigt';
    
    IF active_loans > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fehler: Exemplar kann nicht gelöscht werden, da es sich noch in Ausleihe befindet';
	END IF;
END $$


DELIMITER ;
