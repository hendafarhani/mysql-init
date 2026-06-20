USE ride_requests_db;

-- Canonicalize the dispatch projection table on case-sensitive MySQL hosts.
-- Hibernate uses the lowercase `driver` table. Older initialization created
-- an uppercase `DRIVER` table, which is a different table when
-- lower_case_table_names=0.

CREATE TABLE IF NOT EXISTS driver (
    id                  BIGINT          NOT NULL AUTO_INCREMENT,
    identifier          VARCHAR(255)    NULL UNIQUE,
    driver_identifier   VARCHAR(255)    NULL UNIQUE,
    driver_display_id   VARCHAR(255)    NULL UNIQUE,
    name                VARCHAR(255)    NULL,
    license_number      VARCHAR(255)    NULL UNIQUE,
    date_of_birth       DATE            NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS migrate_legacy_driver_table;

DELIMITER //

CREATE PROCEDURE migrate_legacy_driver_table()
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = 'driver'
          AND column_name = 'driver_identifier'
    ) THEN
        ALTER TABLE driver
            ADD COLUMN driver_identifier VARCHAR(255) NULL UNIQUE;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND table_name = 'driver'
          AND column_name = 'driver_display_id'
    ) THEN
        ALTER TABLE driver
            ADD COLUMN driver_display_id VARCHAR(255) NULL UNIQUE;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_name = 'DRIVER'
    ) THEN
        INSERT INTO driver (
            identifier,
            driver_identifier,
            driver_display_id,
            name,
            license_number,
            date_of_birth
        )
        SELECT
            legacy.identifier,
            COALESCE(NULLIF(legacy.driver_identifier, ''), legacy.identifier),
            COALESCE(
                NULLIF(legacy.driver_display_id, ''),
                CONCAT(
                    'DRV-',
                    UPPER(
                        REGEXP_REPLACE(
                            COALESCE(NULLIF(legacy.driver_identifier, ''), legacy.identifier),
                            '[^A-Z0-9]+',
                            '-'
                        )
                    )
                )
            ),
            legacy.name,
            legacy.license_number,
            legacy.date_of_birth
        FROM DRIVER legacy
        ON DUPLICATE KEY UPDATE
            name = COALESCE(VALUES(name), driver.name),
            license_number = COALESCE(VALUES(license_number), driver.license_number),
            date_of_birth = COALESCE(VALUES(date_of_birth), driver.date_of_birth),
            driver_identifier = COALESCE(VALUES(driver_identifier), driver.driver_identifier),
            driver_display_id = COALESCE(VALUES(driver_display_id), driver.driver_display_id);

        DROP TABLE DRIVER;
    END IF;
END//

DELIMITER ;

CALL migrate_legacy_driver_table();
DROP PROCEDURE migrate_legacy_driver_table;

UPDATE driver
SET driver_identifier = identifier
WHERE driver_identifier IS NULL OR driver_identifier = '';

UPDATE driver
SET driver_display_id = CONCAT(
    'DRV-',
    UPPER(REGEXP_REPLACE(driver_identifier, '[^A-Z0-9]+', '-'))
)
WHERE (driver_display_id IS NULL OR driver_display_id = '')
  AND driver_identifier IS NOT NULL
  AND driver_identifier <> '';
