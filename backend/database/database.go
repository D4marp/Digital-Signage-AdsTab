package database

import (
	"database/sql"
	"fmt"

	"digital-signage-backend/config"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func Initialize(cfg *config.Config) error {
	// MySQL connection string format: user:password@tcp(host:port)/dbname?parseTime=true
	connStr := fmt.Sprintf(
		"%s:%s@tcp(%s:%s)/%s?parseTime=true&charset=utf8mb4&collation=utf8mb4_unicode_ci",
		cfg.DBUser, cfg.DBPassword, cfg.DBHost, cfg.DBPort, cfg.DBName,
	)

	var err error
	DB, err = sql.Open("mysql", connStr)
	if err != nil {
		return fmt.Errorf("error opening database: %w", err)
	}

	if err = DB.Ping(); err != nil {
		return fmt.Errorf("error connecting to database: %w", err)
	}

	// Run migrations
	if err = runMigrations(); err != nil {
		return fmt.Errorf("error running migrations: %w", err)
	}

	return nil
}

func Close() error {
	if DB != nil {
		return DB.Close()
	}
	return nil
}

func runMigrations() error {
	migrations := []string{
		// Users table
		`CREATE TABLE IF NOT EXISTS users (
			id VARCHAR(36) PRIMARY KEY,
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			display_name VARCHAR(255) NOT NULL,
			role VARCHAR(50) NOT NULL DEFAULT 'admin',
			created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			INDEX idx_email (email)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

		// Ads table
		`CREATE TABLE IF NOT EXISTS ads (
			id VARCHAR(36) PRIMARY KEY,
			title VARCHAR(255) NOT NULL,
			media_url TEXT NOT NULL,
			media_type VARCHAR(50) NOT NULL,
			duration_seconds INT NOT NULL DEFAULT 5,
			order_index INT NOT NULL DEFAULT 0,
			is_enabled BOOLEAN NOT NULL DEFAULT true,
			target_locations JSON NOT NULL,
			created_by VARCHAR(36) NOT NULL,
			is_deleted BOOLEAN NOT NULL DEFAULT false,
			description TEXT,
			company_name VARCHAR(255),
			contact_info VARCHAR(255),
			website_url VARCHAR(500),
			created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			INDEX idx_order (order_index),
			INDEX idx_enabled (is_enabled),
			INDEX idx_created_by (created_by),
			FOREIGN KEY (created_by) REFERENCES users(id)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

		// Devices table
		`CREATE TABLE IF NOT EXISTS devices (
			id VARCHAR(36) PRIMARY KEY,
			device_id VARCHAR(255) UNIQUE NOT NULL,
			location VARCHAR(255) NOT NULL,
			is_online BOOLEAN NOT NULL DEFAULT false,
			last_active TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			today_views INT NOT NULL DEFAULT 0,
			settings JSON NOT NULL,
			created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			INDEX idx_device_id (device_id),
			INDEX idx_location (location)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

		// Impressions table
		`CREATE TABLE IF NOT EXISTS impressions (
			id VARCHAR(36) PRIMARY KEY,
			ad_id VARCHAR(36) NOT NULL,
			device_id VARCHAR(36) NOT NULL,
			viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			INDEX idx_ad_id (ad_id),
			INDEX idx_device_id (device_id),
			INDEX idx_viewed_at (viewed_at),
			FOREIGN KEY (ad_id) REFERENCES ads(id) ON DELETE CASCADE,
			FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,

		// Analytics table
		`CREATE TABLE IF NOT EXISTS ad_analytics (
			id VARCHAR(36) PRIMARY KEY,
			ad_id VARCHAR(36) NOT NULL,
			date DATE NOT NULL,
			impressions INT NOT NULL DEFAULT 0,
			unique_devices INT NOT NULL DEFAULT 0,
			created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			UNIQUE KEY unique_ad_date (ad_id, date),
			INDEX idx_date (date),
			FOREIGN KEY (ad_id) REFERENCES ads(id) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
	}

	for _, migration := range migrations {
		if _, err := DB.Exec(migration); err != nil {
			return fmt.Errorf("migration error: %w", err)
		}
	}

	return nil
}
