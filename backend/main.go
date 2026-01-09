package main

import (
	"log"
	"os"

	"digital-signage-backend/config"
	"digital-signage-backend/database"
	"digital-signage-backend/routes"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize configuration
	cfg := config.Load()

	// Initialize database
	if err := database.Initialize(cfg); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Create uploads directory
	if err := os.MkdirAll(cfg.UploadPath, 0755); err != nil {
		log.Fatalf("Failed to create uploads directory: %v", err)
	}

	// Set Gin mode
	gin.SetMode(cfg.GinMode)

	// Setup router
	router := routes.SetupRouter(cfg)

	// Start server
	log.Printf("Server starting on port %s", cfg.Port)
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
