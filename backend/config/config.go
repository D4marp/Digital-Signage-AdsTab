package config

import (
	"os"
	"strconv"
)

type Config struct {
	// Database
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string

	// JWT
	JWTSecret string

	// Server
	Port    string
	GinMode string

	// Upload
	UploadPath      string
	MaxUploadSizeMB int64
}

func Load() *Config {
	return &Config{
		// Database
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "3306"),
		DBUser:     getEnv("DB_USER", "root"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		DBName:     getEnv("DB_NAME", "digital_signage"),

		// JWT
		JWTSecret: getEnv("JWT_SECRET", "your-secret-key-change-this"),

		// Server
		Port:    getEnv("PORT", "8080"),
		GinMode: getEnv("GIN_MODE", "debug"),

		// Upload
		UploadPath:      getEnv("UPLOAD_PATH", "./uploads"),
		MaxUploadSizeMB: getEnvAsInt("MAX_UPLOAD_SIZE", 100),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int64) int64 {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseInt(valueStr, 10, 64); err == nil {
		return value
	}
	return defaultValue
}
