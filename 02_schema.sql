USE ride_requests_db;

-- ==========================================
-- RIDE_REQUEST table (managed by dashboard-service)
-- ==========================================
DROP TABLE IF EXISTS RIDE_REQUEST;
CREATE TABLE RIDE_REQUEST (
                              id                          BIGINT          NOT NULL,
                              identifier                  VARCHAR(255)    NULL UNIQUE,
                              status                      VARCHAR(32)     NULL,
                              accepted_rider_identifier   VARCHAR(255)    NULL,
                              accepted_driver_display_id  VARCHAR(255)    NULL,
                              accepted_at                 DATETIME(6)     NULL,
                              PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- driver dispatch projection (managed by ride-request)
-- ==========================================
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
