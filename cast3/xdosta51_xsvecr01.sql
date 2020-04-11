-- SQL skript pro vytvoření základních objektů schématu databáze.
-- Zadání č. 26. - Banka

--------------------------------------------------------------------------------

-- Autor: Michal Dostal xdosta51@stud.fit.vutbr.cz
-- Autor: Radek Svec xsvecr01@stud.fit.vutbr.cz

------ SMAZANI TABULEK -------

DROP TABLE operace;
DROP TABLE karta;
DROP TABLE disponence;
DROP TABLE ucet;
DROP TABLE zamestnanec;
DROP TABLE pobocka;
DROP TABLE klient;
DROP TABLE osoba;

------ VYTVORENI TABULEK ------

CREATE TABLE osoba (
	rodne_cislo INT PRIMARY KEY,
	jmeno VARCHAR(25) NOT NULL,
	prijmeni VARCHAR(25) NOT NULL,
	email VARCHAR(40) NOT NULL
		CHECK(REGEXP_LIKE(
			email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
	telefon VARCHAR(9) NOT NULL
        CHECK(REGEXP_LIKE(
			telefon, '^[0-9]{9}$', 'i'
		)),
	mesto VARCHAR(25) NOT NULL,
	ulice VARCHAR(25) NOT NULL,
	cislo_popisne INT NOT NULL,
	psc INT NOT NULL
        CHECK(REGEXP_LIKE(
			psc, '^[0-9]{5}$', 'i'
		))
);

CREATE TABLE pobocka (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    mesto VARCHAR(25) NOT NULL,
    ulice VARCHAR(25) NOT NULL,
	cislo_popisne INT NOT NULL,
	psc INT NOT NULL
        CHECK(REGEXP_LIKE(
			psc, '^[0-9]{5}$', 'i'
		))
);

CREATE TABLE klient (
	id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	datum_registrace DATE DEFAULT CURRENT_TIMESTAMP,
    osoba_id INT NOT NULL,
        CONSTRAINT osoba_klient_id_fk
		FOREIGN KEY (osoba_id) REFERENCES osoba (rodne_cislo)
		ON DELETE CASCADE
);

CREATE TABLE zamestnanec (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    opravneni VARCHAR(15) NOT NULL,
        CHECK(opravneni IN ('cteni', 'vlastnictvi', 'prispivani', 'upravy')),
    osoba_id INT NOT NULL,
        CONSTRAINT osoba_zamestnanec_id_fk
		FOREIGN KEY (osoba_id) REFERENCES osoba (rodne_cislo)
		ON DELETE CASCADE,
    pobocka_id INT DEFAULT NULL,
        CONSTRAINT zamestnanec_pobocka_id_fk
	    FOREIGN KEY (pobocka_id) REFERENCES pobocka (id)
	    ON DELETE SET NULL    
);

CREATE TABLE ucet (
    cislo INT NOT NULL PRIMARY KEY,
    zustatek VARCHAR(30) DEFAULT 0,
    typ VARCHAR(10) NOT NULL
        CHECK(typ IN ('bezny', 'sporici', 'junior')),
    vlastnik_id INT NOT NULL,
        CONSTRAINT vlastnik_ucet_id_fk
		FOREIGN KEY (vlastnik_id) REFERENCES klient (id)
        ON DELETE CASCADE,
    zamestnanec_id INT DEFAULT NULL,
        CONSTRAINT zamestnanec_zridil_id_fk
		FOREIGN KEY (zamestnanec_id) REFERENCES zamestnanec (id)
        ON DELETE SET NULL
);

CREATE TABLE disponence (
    limit VARCHAR(30) DEFAULT 10000,
    opravneni VARCHAR(40) DEFAULT 'zobrazit_zustatek',
	disponent_id INT NOT NULL,
        CONSTRAINT disponent_id_fk
		FOREIGN KEY (disponent_id) REFERENCES klient (id)
        ON DELETE CASCADE,
    ucet_cislo INT NOT NULL,    
        CONSTRAINT ucet_cislo_fk
		FOREIGN KEY (ucet_cislo) REFERENCES ucet (cislo)
        ON DELETE CASCADE,
    CONSTRAINT disponence_pk
		PRIMARY KEY (disponent_id, ucet_cislo)
);

CREATE TABLE karta (
    cislo_karty INT NOT NULL PRIMARY KEY,
	typ_karty VARCHAR(10) NOT NULL,
        CHECK(typ_karty IN ('zlata', 'stribrna', 'debit', 'kredit')),
    klient_id INT NOT NULL,
        CONSTRAINT klient_karta_id_fk
		FOREIGN KEY (klient_id) REFERENCES klient (id)
		ON DELETE CASCADE,
    vlastnici_ucet INT NOT NULL,
        CONSTRAINT vlastnici_ucet_fk
		FOREIGN KEY (vlastnici_ucet) REFERENCES ucet (cislo)
		ON DELETE CASCADE
);

CREATE TABLE operace (
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    datum_provedeni DATE DEFAULT CURRENT_TIMESTAMP,
    typ VARCHAR(20) NOT NULL,
    castka VARCHAR(30),
    stav VARCHAR(15) default 'cekajici'
		CHECK(stav IN ('cekajici', 'dokoncena', 'zrusena', 'probihajici')),
    zamestnanec_id INT DEFAULT NULL,
        CONSTRAINT zamestnanec_provedl_id_fk
		FOREIGN KEY (zamestnanec_id) REFERENCES zamestnanec (id)
        ON DELETE SET NULL,
    klient_id INT NOT NULL,
        CONSTRAINT klient_operace_id_fk
		FOREIGN KEY (klient_id) REFERENCES klient (id)
		ON DELETE CASCADE,
    ucet_z INT DEFAULT NULL,
        CONSTRAINT ucet_z_fk
		FOREIGN KEY (ucet_z) REFERENCES ucet (cislo)
		ON DELETE SET NULL,
    ucet_na INT DEFAULT NULL,
        CONSTRAINT ucet_na_fk
		FOREIGN KEY (ucet_na) REFERENCES ucet (cislo)
		ON DELETE SET NULL
);

-------- VLOZENI DAT DO TABULEK ---------

INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (9801226655, 'Jan', 'Novak', 'novak@gmail.com', '773821234', 'Brno', 'Hybesova', 211, 76432);
INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (9902305544, 'Jan', 'Pospech', 'xpospe@gmail.com', '773222111', 'Novy Jicin', 'Ostravska', 356, 75222);
INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (9305126233, 'Radek', 'Svec', 'svec1@gmail.com', '772333111', 'Kvasice', 'U Zamku', 552, 71233);
INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (9904186544, 'Petr', 'Fiser', 'petros@gmail.com', '766543211', 'Zlin', 'Jizni Svahy', 1337, 77555);
INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (8787876555, 'Myspulin', 'Kot', 'kotmysp@gmail.com', '666555444', 'Kocourkov', 'Ocaskova', 13, 10022);
INSERT INTO osoba (rodne_cislo, jmeno, prijmeni, email, telefon, mesto, ulice, cislo_popisne, psc)
VALUES (9235419865, 'Pamela', 'Andersonova', 'AnderPam@gmail.com', '777888999', 'Kurim', 'Luxusni', 25, 65487);


INSERT INTO pobocka (mesto, ulice, cislo_popisne, psc)
VALUES ('Zlin', 'Svermova', 3251, 76302);
INSERT INTO pobocka (mesto, ulice, cislo_popisne, psc)
VALUES ('Brno', 'Veveri', 1234, 62500);

INSERT INTO klient (datum_registrace, osoba_id)
VALUES (TO_DATE('1972-07-30', 'yyyy/mm/dd'), 9801226655);
INSERT INTO klient (datum_registrace, osoba_id)
VALUES (TO_DATE('1972-07-31', 'yyyy/mm/dd'), 9902305544);
INSERT INTO klient (datum_registrace, osoba_id)
VALUES (TO_DATE('1972-07-31', 'yyyy/mm/dd'), 9904186544);
INSERT INTO klient (datum_registrace, osoba_id)
VALUES (TO_DATE('1972-07-31', 'yyyy/mm/dd'), 8787876555);
INSERT INTO klient (datum_registrace, osoba_id)
VALUES (TO_DATE('1972-07-31', 'yyyy/mm/dd'), 9235419865);


INSERT INTO zamestnanec (opravneni, osoba_id, pobocka_id)
VALUES ('cteni', 9801226655, 1);
INSERT INTO zamestnanec (opravneni, osoba_id, pobocka_id)
VALUES ('upravy', 9902305544, 2);
INSERT INTO zamestnanec (opravneni, osoba_id, pobocka_id)
VALUES ('vlastnictvi', 9305126233, 2);

INSERT INTO ucet (cislo, zustatek, typ, vlastnik_id, zamestnanec_id)
VALUES (12345, '566321', 'bezny',  2, 1);
INSERT INTO ucet (cislo, zustatek, typ, vlastnik_id, zamestnanec_id)
VALUES (13370, '2500666', 'sporici',  1, 1);
INSERT INTO ucet (cislo, zustatek, typ, vlastnik_id, zamestnanec_id)
VALUES (12346, '566321', 'bezny',  2, 1);
INSERT INTO ucet (cislo, zustatek, typ, vlastnik_id, zamestnanec_id)
VALUES (11111, '123654', 'bezny',  3, 3);
INSERT INTO ucet (cislo, zustatek, typ, vlastnik_id, zamestnanec_id)
VALUES (22222, '99666', 'bezny',  4, 3);



INSERT INTO disponence (limit, opravneni, disponent_id, ucet_cislo)
VALUES ('5000', 'vyber', 1, 12346);
INSERT INTO disponence (limit, opravneni, disponent_id, ucet_cislo)
VALUES ('20000', 'vklad', 2, 13370);
INSERT INTO disponence (limit, opravneni, disponent_id, ucet_cislo)
VALUES ('10000', 'vyber', 5, 11111);
INSERT INTO disponence (limit, opravneni, disponent_id, ucet_cislo)
VALUES ('4500', 'vyber', 5, 22222);

INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('zlata', 47791333, 1,12345);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('stribrna', 47791334, 2,12345);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('kredit', 47794001, 1,13370);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('debit', 47794002, 2, 12346);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('stribrna', 11100111, 3, 11111);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('debit', 11100112, 5, 11111);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('debit', 22200222, 4, 22222);
INSERT INTO karta (typ_karty, cislo_karty, klient_id, vlastnici_ucet)
VALUES ('debit', 22200223, 5, 22222);

INSERT INTO operace (typ, zamestnanec_id, klient_id, ucet_z, ucet_na, castka)
VALUES ('platba', 2, 1, 12345, 13370, '666');
INSERT INTO operace (stav, typ, zamestnanec_id, klient_id, ucet_z, ucet_na, castka)
VALUES ('probihajici', 'platba', 1, 1, 12346, 12345, '253');
INSERT INTO operace (stav, typ, zamestnanec_id, klient_id, ucet_z, ucet_na, castka)
VALUES ('dokoncena', 'platba', 3, 1, 12346, 12345, '333');
INSERT INTO operace (stav, typ, zamestnanec_id, klient_id, ucet_z, ucet_na, castka)
VALUES ('probihajici', 'platba', 2, 1, 11111, 22222, '444');
INSERT INTO operace (stav, typ, zamestnanec_id, klient_id, ucet_z, ucet_na, castka)
VALUES ('zrusena', 'platba', 3, 1, 22222, 12345, '1563');


--pridani noveho zamestnance
INSERT INTO zamestnanec (opravneni, osoba_id, pobocka_id)
VALUES ('upravy', (SELECT rodne_cislo FROM osoba WHERE jmeno = 'Pamela' AND prijmeni = 'Andersonova'), (SELECT id FROM pobocka WHERE mesto = 'Brno' AND cislo_popisne = '1234'));

--pridani noveho disponenta 
INSERT INTO disponence (limit, opravneni, disponent_id, ucet_cislo)
VALUES ('2500', 'vyber', (SELECT id FROM klient WHERE osoba_id = '9235419865'), 12345);
--operace
INSERT INTO operace (stav, typ, klient_id, zamestnanec_id, ucet_z, ucet_na, castka)
VALUES ('cekajici', 'platba', (SELECT id FROM klient WHERE osoba_id = (SELECT rodne_cislo FROM osoba WHERE jmeno = 'Myspulin' AND prijmeni = 'Kot')), (SELECT id FROM zamestnanec WHERE osoba_id = (SELECT rodne_cislo FROM osoba WHERE jmeno = 'Myspulin' AND prijmeni = 'Kot')), 22222, 12345, '1563');


--vyhleda vsechny ucty a operace zrizene zamestnancem Janem Novakem
SELECT *
FROM ucet natural join operace
WHERE zamestnanec_id = (SELECT id FROM zamestnanec WHERE osoba_id = (SELECT rodne_cislo FROM osoba WHERE jmeno = 'Jan' AND prijmeni = 'Novak'));


