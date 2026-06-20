USE ride_requests_db;

-- Shared MySQL schema for ride-request, outbox-publisher-service, and dashboard-service.

CREATE TABLE IF NOT EXISTS USERS (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NULL,
    identifier VARCHAR(255) NULL UNIQUE,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS driver (
    id BIGINT NOT NULL AUTO_INCREMENT,
    identifier VARCHAR(255) NULL UNIQUE,
    driver_identifier VARCHAR(255) NULL UNIQUE,
    driver_display_id VARCHAR(255) NULL UNIQUE,
    name VARCHAR(255) NULL,
    license_number VARCHAR(255) NULL UNIQUE,
    date_of_birth DATE NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS RIDE_REQUEST (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NULL,
    identifier VARCHAR(255) NULL UNIQUE,
    status VARCHAR(32) NULL,
    location POINT NULL,
    accepted_rider_identifier VARCHAR(255) NULL,
    accepted_driver_display_id VARCHAR(255) NULL,
    accepted_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    KEY idx_ride_request_user_id (user_id),
    CONSTRAINT fk_ride_request_user FOREIGN KEY (user_id) REFERENCES USERS(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS RIDE_REQUEST_DRIVER_OFFER (
    id BIGINT NOT NULL AUTO_INCREMENT,
    ride_request_id BIGINT NOT NULL,
    rider_id BIGINT NOT NULL,
    notification_round INT NOT NULL,
    notified_at DATETIME(6) NOT NULL,
    status VARCHAR(32) NOT NULL,
    responded_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    KEY idx_offer_ride_request_round_time (ride_request_id, notification_round, notified_at),
    KEY idx_offer_ride_request_status (ride_request_id, status),
    KEY idx_offer_rider_id (rider_id),
    CONSTRAINT fk_offer_ride_request FOREIGN KEY (ride_request_id) REFERENCES RIDE_REQUEST(id),
    CONSTRAINT fk_offer_rider FOREIGN KEY (rider_id) REFERENCES driver(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS EVENT_OUTBOX (
    id BIGINT NOT NULL AUTO_INCREMENT,
    event_type VARCHAR(255) NOT NULL,
    status VARCHAR(32) NOT NULL,
    ride_request_id BIGINT NOT NULL,
    ride_request_identifier VARCHAR(255) NOT NULL,
    requester_id VARCHAR(255) NOT NULL,
    rider_id VARCHAR(255) NULL,
    payload LONGTEXT NOT NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,
    processed_at DATETIME(6) NULL,
    retry_count INT NOT NULL DEFAULT 0,
    last_error VARCHAR(255) NULL,
    PRIMARY KEY (id),
    KEY idx_event_outbox_status_created (status, created_at),
    KEY idx_event_outbox_ride_request_status_created (ride_request_id, status, created_at),
    KEY idx_event_outbox_requester_status_created (requester_id, status, created_at),
    KEY idx_event_outbox_rider_status_created (rider_id, status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS add_column_if_missing;

DELIMITER //

CREATE PROCEDURE add_column_if_missing(
    IN target_table VARCHAR(128),
    IN target_column VARCHAR(128),
    IN column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND LOWER(table_name) = LOWER(target_table)
          AND LOWER(column_name) = LOWER(target_column)
    ) THEN
        SET @ddl = CONCAT(
            'ALTER TABLE `', target_table,
            '` ADD COLUMN `', target_column,
            '` ', column_definition
        );
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

CALL add_column_if_missing('USERS', 'name', 'VARCHAR(255) NULL');
CALL add_column_if_missing('USERS', 'identifier', 'VARCHAR(255) NULL');

CALL add_column_if_missing('driver', 'identifier', 'VARCHAR(255) NULL');
CALL add_column_if_missing('driver', 'driver_identifier', 'VARCHAR(255) NULL');
CALL add_column_if_missing('driver', 'driver_display_id', 'VARCHAR(255) NULL');
CALL add_column_if_missing('driver', 'name', 'VARCHAR(255) NULL');
CALL add_column_if_missing('driver', 'license_number', 'VARCHAR(255) NULL');
CALL add_column_if_missing('driver', 'date_of_birth', 'DATE NULL');

CALL add_column_if_missing('RIDE_REQUEST', 'user_id', 'BIGINT NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'identifier', 'VARCHAR(255) NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'status', 'VARCHAR(32) NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'location', 'POINT NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'accepted_rider_identifier', 'VARCHAR(255) NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'accepted_driver_display_id', 'VARCHAR(255) NULL');
CALL add_column_if_missing('RIDE_REQUEST', 'accepted_at', 'DATETIME(6) NULL');

CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'ride_request_id', 'BIGINT NOT NULL');
CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'rider_id', 'BIGINT NOT NULL');
CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'notification_round', 'INT NOT NULL');
CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'notified_at', 'DATETIME(6) NOT NULL');
CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'status', 'VARCHAR(32) NOT NULL');
CALL add_column_if_missing('RIDE_REQUEST_DRIVER_OFFER', 'responded_at', 'DATETIME(6) NULL');

CALL add_column_if_missing('EVENT_OUTBOX', 'event_type', 'VARCHAR(255) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'status', 'VARCHAR(32) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'ride_request_id', 'BIGINT NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'ride_request_identifier', 'VARCHAR(255) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'requester_id', 'VARCHAR(255) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'rider_id', 'VARCHAR(255) NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'payload', 'LONGTEXT NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'created_at', 'DATETIME(6) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'updated_at', 'DATETIME(6) NOT NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'processed_at', 'DATETIME(6) NULL');
CALL add_column_if_missing('EVENT_OUTBOX', 'retry_count', 'INT NOT NULL DEFAULT 0');
CALL add_column_if_missing('EVENT_OUTBOX', 'last_error', 'VARCHAR(255) NULL');

DROP PROCEDURE add_column_if_missing;

ALTER TABLE EVENT_OUTBOX
    MODIFY COLUMN payload LONGTEXT NOT NULL;

