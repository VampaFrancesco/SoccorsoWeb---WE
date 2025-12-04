-- ==============================================================================
-- Script Database SoccorsoWeb - MariaDB
-- ==============================================================================

DROP DATABASE IF EXISTS soccorsodb_we;
CREATE DATABASE soccorsodb_we CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE soccorsodb_we;

-- ==============================================================================
-- CREAZIONE TABELLE
-- ==============================================================================

-- Tabella Ruoli
CREATE TABLE ruoli (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       nome VARCHAR(50) NOT NULL UNIQUE,
                       INDEX idx_ruolo_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Utenti
CREATE TABLE utenti (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        email VARCHAR(255) NOT NULL UNIQUE,
                        password VARCHAR(255) NOT NULL,
                        nome VARCHAR(100) NOT NULL,
                        cognome VARCHAR(100) NOT NULL,
                        data_nascita DATE NULL,
                        telefono VARCHAR(20) NULL,
                        indirizzo VARCHAR(255) NULL,
                        attivo TINYINT(1) NOT NULL DEFAULT 1,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        INDEX idx_email (email),
                        INDEX idx_attivo (attivo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Utenti_Ruoli (Many-to-Many)
CREATE TABLE utenti_ruoli (
                              utente_id BIGINT NOT NULL,
                              ruolo_id BIGINT NOT NULL,
                              PRIMARY KEY (utente_id, ruolo_id),
                              INDEX idx_ruolo_id (ruolo_id),
                              CONSTRAINT fk_utenti_ruoli_utente FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE CASCADE,
                              CONSTRAINT fk_utenti_ruoli_ruolo FOREIGN KEY (ruolo_id) REFERENCES ruoli(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Patenti
CREATE TABLE patenti (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         tipo VARCHAR(50) NOT NULL UNIQUE,
                         descrizione TEXT NULL,
                         INDEX idx_tipo (tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Utenti_Patenti (Many-to-Many)
CREATE TABLE utenti_patenti (
                                utente_id BIGINT NOT NULL,
                                patente_id BIGINT NOT NULL,
                                conseguita_il DATE NULL,
                                PRIMARY KEY (utente_id, patente_id),
                                INDEX idx_patente_id (patente_id),
                                CONSTRAINT fk_utenti_patenti_utente FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE CASCADE,
                                CONSTRAINT fk_utenti_patenti_patente FOREIGN KEY (patente_id) REFERENCES patenti(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Abilità
CREATE TABLE abilita (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         nome VARCHAR(100) NOT NULL UNIQUE,
                         descrizione TEXT NULL,
                         INDEX idx_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Utenti_Abilità (Many-to-Many)
CREATE TABLE utenti_abilita (
                                utente_id BIGINT NOT NULL,
                                abilita_id BIGINT NOT NULL,
                                livello VARCHAR(50) NULL,
                                PRIMARY KEY (utente_id, abilita_id),
                                INDEX idx_abilita_id (abilita_id),
                                CONSTRAINT fk_utenti_abilita_utente FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE CASCADE,
                                CONSTRAINT fk_utenti_abilita_abilita FOREIGN KEY (abilita_id) REFERENCES abilita(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Caposquadra
CREATE TABLE caposquadra (
                             id BIGINT AUTO_INCREMENT PRIMARY KEY,
                             utente_id BIGINT NOT NULL UNIQUE,
                             INDEX idx_utente_id (utente_id),
                             CONSTRAINT fk_caposquadra_utente FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Squadre
CREATE TABLE squadre (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         nome VARCHAR(100) NOT NULL,
                         descrizione TEXT NULL,
                         caposquadra_id BIGINT NOT NULL,
                         attiva TINYINT(1) NOT NULL DEFAULT 1,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         INDEX idx_caposquadra (caposquadra_id),
                         INDEX idx_attiva (attiva),
                         CONSTRAINT fk_squadre_caposquadra FOREIGN KEY (caposquadra_id) REFERENCES caposquadra(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Squadre_Operatori (Many-to-Many)
CREATE TABLE squadre_operatori (
                                   squadra_id BIGINT NOT NULL,
                                   utente_id BIGINT NOT NULL,
                                   ruolo VARCHAR(50) NULL,
                                   assegnato_il DATE NULL,
                                   PRIMARY KEY (squadra_id, utente_id),
                                   INDEX idx_utente_id (utente_id),
                                   CONSTRAINT fk_squadre_operatori_squadra FOREIGN KEY (squadra_id) REFERENCES squadre(id) ON DELETE CASCADE,
                                   CONSTRAINT fk_squadre_operatori_utente FOREIGN KEY (utente_id) REFERENCES utenti(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Richieste_Soccorso
CREATE TABLE richieste_soccorso (
                                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    descrizione TEXT NOT NULL,
                                    indirizzo VARCHAR(255) NOT NULL,
                                    latitudine DECIMAL(10, 8) NULL,
                                    longitudine DECIMAL(11, 8) NULL,
                                    nome_segnalante VARCHAR(100) NOT NULL,
                                    email_segnalante VARCHAR(255) NOT NULL,
                                    telefono_segnalante VARCHAR(20) NULL,
                                    foto_url VARCHAR(255) NULL,
                                    ip_origine VARCHAR(45) NULL,
                                    token_convalida VARCHAR(255) NULL UNIQUE,
                                    stato ENUM('INVIATA', 'ATTIVA', 'IN_CORSO', 'CHIUSA', 'IGNORATA') NOT NULL DEFAULT 'INVIATA',
                                    convalidata_at TIMESTAMP NULL,
                                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    INDEX idx_stato (stato),
                                    INDEX idx_email_segnalante (email_segnalante),
                                    INDEX idx_token (token_convalida)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Mezzi
CREATE TABLE mezzi (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       nome VARCHAR(100) NOT NULL,
                       descrizione TEXT NULL,
                       tipo VARCHAR(50) NULL,
                       targa VARCHAR(20) NULL,
                       disponibile TINYINT(1) NOT NULL DEFAULT 1,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       INDEX idx_disponibile (disponibile),
                       INDEX idx_tipo (tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Materiali
CREATE TABLE materiali (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           nome VARCHAR(100) NOT NULL,
                           descrizione TEXT NULL,
                           tipo VARCHAR(50) NULL,
                           quantita INT NOT NULL DEFAULT 0,
                           disponibile TINYINT(1) NOT NULL DEFAULT 1,
                           created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           INDEX idx_disponibile (disponibile),
                           INDEX idx_tipo (tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Missioni
CREATE TABLE missioni (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                          richiesta_id BIGINT NOT NULL UNIQUE,
                          squadra_id BIGINT NULL,
                          caposquadra_id BIGINT NOT NULL,
                          obiettivo TEXT NOT NULL,
                          posizione VARCHAR(255) NULL,
                          latitudine DECIMAL(10, 8) NULL,
                          longitudine DECIMAL(11, 8) NULL,
                          stato ENUM('IN_CORSO', 'CHIUSA', 'FALLITA') NOT NULL DEFAULT 'IN_CORSO',
                          inizio_at TIMESTAMP NULL,
                          fine_at TIMESTAMP NULL,
                          livello_successo INT NULL,
                          commenti_finali TEXT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          INDEX idx_stato (stato),
                          INDEX idx_caposquadra (caposquadra_id),
                          INDEX idx_squadra (squadra_id),
                          INDEX idx_richiesta (richiesta_id),
                          CONSTRAINT fk_missioni_richiesta FOREIGN KEY (richiesta_id) REFERENCES richieste_soccorso(id) ON DELETE CASCADE,
                          CONSTRAINT fk_missioni_squadra FOREIGN KEY (squadra_id) REFERENCES squadre(id) ON DELETE SET NULL,
                          CONSTRAINT fk_missioni_caposquadra FOREIGN KEY (caposquadra_id) REFERENCES caposquadra(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Aggiornamenti_Missioni
CREATE TABLE aggiornamenti_missioni (
                                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                        missione_id BIGINT NOT NULL,
                                        admin_id BIGINT NOT NULL,
                                        descrizione TEXT NOT NULL,
                                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                        INDEX idx_missione (missione_id),
                                        INDEX idx_admin (admin_id),
                                        INDEX idx_created (created_at),
                                        CONSTRAINT fk_aggiornamenti_missione FOREIGN KEY (missione_id) REFERENCES missioni(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_aggiornamenti_admin FOREIGN KEY (admin_id) REFERENCES utenti(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Missioni_Operatori (Many-to-Many)
CREATE TABLE missioni_operatori (
                                    missione_id BIGINT NOT NULL,
                                    operatore_id BIGINT NOT NULL,
                                    notificato_at TIMESTAMP NULL,
                                    assegnato_at TIMESTAMP NULL,
                                    PRIMARY KEY (missione_id, operatore_id),
                                    INDEX idx_operatore (operatore_id),
                                    CONSTRAINT fk_missioni_operatori_missione FOREIGN KEY (missione_id) REFERENCES missioni(id) ON DELETE CASCADE,
                                    CONSTRAINT fk_missioni_operatori_utente FOREIGN KEY (operatore_id) REFERENCES utenti(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Missioni_Mezzi (Many-to-Many)
CREATE TABLE missioni_mezzi (
                                missione_id BIGINT NOT NULL,
                                mezzo_id BIGINT NOT NULL,
                                assegnato_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                PRIMARY KEY (missione_id, mezzo_id),
                                INDEX idx_mezzo (mezzo_id),
                                CONSTRAINT fk_missioni_mezzi_missione FOREIGN KEY (missione_id) REFERENCES missioni(id) ON DELETE CASCADE,
                                CONSTRAINT fk_missioni_mezzi_mezzo FOREIGN KEY (mezzo_id) REFERENCES mezzi(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Missioni_Materiali (Many-to-Many)
CREATE TABLE missioni_materiali (
                                    missione_id BIGINT NOT NULL,
                                    materiale_id BIGINT NOT NULL,
                                    quantita_usata INT NOT NULL DEFAULT 1,
                                    assegnato_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    PRIMARY KEY (missione_id, materiale_id),
                                    INDEX idx_materiale (materiale_id),
                                    CONSTRAINT fk_missioni_materiali_missione FOREIGN KEY (missione_id) REFERENCES missioni(id) ON DELETE CASCADE,
                                    CONSTRAINT fk_missioni_materiali_materiale FOREIGN KEY (materiale_id) REFERENCES materiali(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- DATI INIZIALI
-- ==============================================================================

-- Inserimento ruoli base
INSERT INTO ruoli (nome) VALUES ('ADMIN'), ('OPERATORE');

-- Inserimento patenti base
INSERT INTO patenti (tipo, descrizione) VALUES
                                            ('A', 'Patente motocicli'),
                                            ('B', 'Patente automezzi'),
                                            ('C', 'Patente automezzi pesanti'),
                                            ('NAUTICA', 'Patente nautica'),
                                            ('AEREA', 'Brevetto di volo');

-- Inserimento abilità base
INSERT INTO abilita (nome, descrizione) VALUES
                                            ('INFERMIERE', 'Diploma infermieristico'),
                                            ('ELETTRICISTA', 'Qualifica elettricista'),
                                            ('MECCANICO', 'Qualifica meccanico'),
                                            ('SOCCORRITORE', 'Corso di primo soccorso'),
                                            ('SOMMOZZATORE', 'Brevetto subacqueo');

-- ==============================================================================
-- FINE SCRIPT
-- ==============================================================================