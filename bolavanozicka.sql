DROP TABLE "operace";
DROP TABLE "karta";
DROP TABLE "disponence";
DROP TABLE "ucet";
DROP TABLE "zamestnanec";
DROP TABLE "pobocka";
DROP TABLE "klient";
DROP TABLE "osoba";


CREATE TABLE "osoba" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"jmeno" VARCHAR(255) NOT NULL,
	"prijmeni" VARCHAR(255) NOT NULL,
	"email" VARCHAR(255) NOT NULL
		CHECK(REGEXP_LIKE(
			"email", '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
	"telefon" VARCHAR(255) NOT NULL,
	"mesto" VARCHAR(255) NOT NULL,
	"ulice" VARCHAR(255) NOT NULL,
	"cislo_popisne" INT DEFAULT NULL,
	"psc" INT DEFAULT NULL
);

CREATE TABLE "pobocka" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "Umisteni" VARCHAR(80) NOT NULL
);

CREATE TABLE "klient" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"datum_registrace" DATE DEFAULT NULL,
    "osoba_id" INT DEFAULT NULL,
        CONSTRAINT "osoba_klient_id_fk"
		FOREIGN KEY ("osoba_id") REFERENCES "osoba" ("id")
		ON DELETE SET NULL
);

CREATE TABLE "zamestnanec" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "opravneni" VARCHAR(80) NOT NULL,
    "osoba_id" INT DEFAULT NULL,
        CONSTRAINT "osoba_zamestnanec_id_fk"
		FOREIGN KEY ("osoba_id") REFERENCES "osoba" ("id")
		ON DELETE SET NULL,
    "pobocka_id" INT DEFAULT NULL,
        CONSTRAINT "zamestnanec_pobocka_id_fk"
	    FOREIGN KEY ("pobocka_id") REFERENCES "pobocka" ("id")
	    ON DELETE SET NULL    
);

CREATE TABLE "ucet" (
    "cislo" INT NOT NULL PRIMARY KEY,
    "zustatek" VARCHAR(255) DEFAULT NULL,
    "typ" VARCHAR(80) NOT NULL
        CHECK("typ" IN ('bezny', 'sporici', 'junior')),
    "vlastnik_id" INT DEFAULT NULL,
        CONSTRAINT "vlastnik_ucet_id_fk"
		FOREIGN KEY ("vlastnik_id") REFERENCES "klient" ("id")
        ON DELETE SET NULL,
    "zamestnanec_id" INT DEFAULT NULL,
        CONSTRAINT "zamestnanec_zridil_id_fk"
		FOREIGN KEY ("zamestnanec_id") REFERENCES "zamestnanec" ("id")
        ON DELETE SET NULL
);

CREATE TABLE "disponence" (
    "limit" VARCHAR(255) DEFAULT NULL,
    "opravneni" VARCHAR(80) DEFAULT NULL,
	"disponent_id" INT NOT NULL,
        CONSTRAINT "disponent_id_fk"
		FOREIGN KEY ("disponent_id") REFERENCES "klient" ("id")
        ON DELETE SET NULL,
    "ucet_cislo" INT NOT NULL,    
        CONSTRAINT "ucet_cislo_fk"
		FOREIGN KEY ("ucet_cislo") REFERENCES "ucet" ("cislo")
        ON DELETE SET NULL
);

CREATE TABLE "karta" (
    "cislo_karty" INT NOT NULL PRIMARY KEY,
	"typ_karty" VARCHAR(80) NOT NULL,
    "klient_id" INT DEFAULT NULL,
        CONSTRAINT "klient_karta_id_fk"
		FOREIGN KEY ("klient_id") REFERENCES "klient" ("id")
		ON DELETE SET NULL,
    "vlastnici_ucet" INT DEFAULT NULL,
        CONSTRAINT "vlastnici_ucet_fk"
		FOREIGN KEY ("vlastnici_ucet") REFERENCES "ucet" ("cislo")
		ON DELETE SET NULL
);

CREATE TABLE "operace" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "datum_provedeni" DATE DEFAULT CURRENT_TIMESTAMP,
    "typ" VARCHAR(80) NOT NULL,
    "stav" VARCHAR(80) default 'cekajici'
		CHECK("stav" IN ('cekajici', 'dokoncena', 'zrusena', 'probihajici')),
    "zamestnanec_id" INT DEFAULT NULL,
        CONSTRAINT "zamestnanec_provedl_id_fk"
		FOREIGN KEY ("zamestnanec_id") REFERENCES "zamestnanec" ("id")
        ON DELETE SET NULL,
    "klient_id" INT DEFAULT NULL,
        CONSTRAINT "klient_operace_id_fk"
		FOREIGN KEY ("klient_id") REFERENCES "klient" ("id")
		ON DELETE SET NULL,
    "ucet_z" INT DEFAULT NULL,
        CONSTRAINT "ucet_z_fk"
		FOREIGN KEY ("ucet_z") REFERENCES "ucet" ("cislo")
		ON DELETE SET NULL,
    "ucet_na" INT DEFAULT NULL,
        CONSTRAINT "ucet_na_fk"
		FOREIGN KEY ("ucet_na") REFERENCES "ucet" ("cislo")
		ON DELETE SET NULL
);


INSERT INTO "osoba" ("jmeno", "prijmeni", "email", "telefon", "mesto", "ulice", "cislo_popisne", "psc")
VALUES ('Jan', 'Novák', 'novak@gmail.com', '773821234', 'turbo', 'turbo', 211, 76432);

INSERT INTO "osoba" ("jmeno", "prijmeni", "email", "telefon", "mesto", "ulice", "cislo_popisne", "psc")
VALUES ('Kosmodisk', 'Autor', 'auto@gmail.com', '773222111', 'kompresor', 'kompresor', 211, 76432);

INSERT INTO "osoba" ("jmeno", "prijmeni", "email", "telefon", "mesto", "ulice", "cislo_popisne", "psc")
VALUES ('Pracovnicek', 'Malinky', 'workhard@gmail.com', '774223765', 'V6', 'V8', 211, 76432);

INSERT INTO "pobocka" ("Umisteni")
VALUES ('Zlin');

INSERT INTO "pobocka" ("Umisteni")
VALUES ('Brno');

INSERT INTO "klient" ("datum_registrace", "osoba_id")
VALUES (TO_DATE('1972-07-30', 'yyyy/mm/dd'), 2);

INSERT INTO "klient" ("datum_registrace", "osoba_id")
VALUES (TO_DATE('1972-07-31', 'yyyy/mm/dd'), 3);

INSERT INTO "zamestnanec" ("opravneni", "osoba_id", "pobocka_id")
VALUES ('all', 1, 1);

INSERT INTO "zamestnanec" ("opravneni", "osoba_id", "pobocka_id")
VALUES ('small', 2, 2);

INSERT INTO "ucet" ("cislo", "zustatek", "typ", "vlastnik_id", "zamestnanec_id")
VALUES (12345, '566321', 'bezny',  2, 1);

INSERT INTO "ucet" ("cislo", "zustatek", "typ", "vlastnik_id", "zamestnanec_id")
VALUES (13370, '2500666', 'sporici',  1, 1);

INSERT INTO "ucet" ("cislo", "zustatek", "typ", "vlastnik_id", "zamestnanec_id")
VALUES (12346, '566321', 'bezny',  2, 1);

INSERT INTO "disponence" ("limit", "opravneni", "disponent_id", "ucet_cislo")
VALUES ('5000', 'vyber', 1, 12345);

INSERT INTO "karta" ("typ_karty", "cislo_karty", "klient_id")
VALUES ('gold', 47791333, 1);

INSERT INTO "karta" ("typ_karty", "cislo_karty", "klient_id")
VALUES ('silver', 47791334, 2);

INSERT INTO "operace" ("typ", "zamestnanec_id", "klient_id", "ucet_z")
VALUES ('platba_odchozi', 2, 1, 12345);