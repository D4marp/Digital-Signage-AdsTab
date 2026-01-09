package routes

import (
	"digital-signage-backend/config"
	"digital-signage-backend/handlers"
	"digital-signage-backend/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRouter(cfg *config.Config) *gin.Engine {
	router := gin.Default()

	// Middleware
	router.Use(middleware.CORS())

	// Static files (uploads)
	router.Static("/uploads", cfg.UploadPath)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(cfg)
	adHandler := handlers.NewAdHandler(cfg)
	deviceHandler := handlers.NewDeviceHandler(cfg)
	analyticsHandler := handlers.NewAnalyticsHandler(cfg)

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// API v1
	v1 := router.Group("/api/v1")
	{
		// Auth routes (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/reset-password", authHandler.ResetPassword)
			auth.GET("/me", middleware.AuthMiddleware(cfg), authHandler.GetCurrentUser)
		}

		// Ads routes
		ads := v1.Group("/ads")
		{
			ads.GET("", adHandler.GetAds)                                                    // Public - can filter by location
			ads.GET("/:id", adHandler.GetAdByID)                                             // Public
			ads.POST("", middleware.AuthMiddleware(cfg), adHandler.CreateAd)                 // Protected
			ads.PUT("/:id", middleware.AuthMiddleware(cfg), adHandler.UpdateAd)              // Protected
			ads.DELETE("/:id", middleware.AuthMiddleware(cfg), adHandler.DeleteAd)           // Protected
			ads.POST("/upload", middleware.AuthMiddleware(cfg), adHandler.UploadMedia)       // Protected
			ads.POST("/reorder", middleware.AuthMiddleware(cfg), adHandler.ReorderAds)       // Protected
		}

		// Devices routes
		devices := v1.Group("/devices")
		{
			devices.GET("", middleware.AuthMiddleware(cfg), deviceHandler.GetDevices)        // Protected
			devices.GET("/:id", middleware.AuthMiddleware(cfg), deviceHandler.GetDeviceByID) // Protected
			devices.POST("/register", deviceHandler.RegisterDevice)                          // Public - for device registration
			devices.PUT("/:id", middleware.AuthMiddleware(cfg), deviceHandler.UpdateDevice)  // Protected
			devices.DELETE("/:id", middleware.AuthMiddleware(cfg), deviceHandler.DeleteDevice) // Protected
			devices.POST("/:id/heartbeat", deviceHandler.Heartbeat)                          // Public - for device heartbeat
			devices.POST("/:id/increment-views", deviceHandler.IncrementViews)               // Public - for tracking
		}

		// Analytics routes
		analytics := v1.Group("/analytics")
		{
			analytics.POST("/impressions", analyticsHandler.CreateImpression)                          // Public - for tracking
			analytics.GET("", middleware.AuthMiddleware(cfg), analyticsHandler.GetAnalytics)           // Protected
			analytics.GET("/dashboard", middleware.AuthMiddleware(cfg), analyticsHandler.GetDashboardStats) // Protected
			analytics.GET("/ads/:id/performance", middleware.AuthMiddleware(cfg), analyticsHandler.GetAdPerformance) // Protected
		}
	}

	return router
}
