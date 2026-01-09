package handlers

import (
	"database/sql"
	"encoding/json"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"digital-signage-backend/config"
	"digital-signage-backend/database"
	"digital-signage-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type AdHandler struct {
	cfg *config.Config
}

func NewAdHandler(cfg *config.Config) *AdHandler {
	return &AdHandler{cfg: cfg}
}

func (h *AdHandler) GetAds(c *gin.Context) {
	location := c.Query("location")
	activeOnly := c.Query("active") == "true"

	query := `
		SELECT id, title, media_url, media_type, duration_seconds, order_index,
		       is_enabled, target_locations, created_by, is_deleted, 
		       description, company_name, contact_info, website_url,
		       created_at, updated_at
		FROM ads
		WHERE is_deleted = false
	`
	args := []interface{}{}

	if activeOnly {
		query += " AND is_enabled = true"
	}

	query += " ORDER BY order_index ASC"

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch ads"})
		return
	}
	defer rows.Close()

	ads := []models.Ad{}
	for rows.Next() {
		var ad models.Ad
		err := rows.Scan(
			&ad.ID, &ad.Title, &ad.MediaURL, &ad.MediaType, &ad.DurationSeconds,
			&ad.OrderIndex, &ad.IsEnabled, &ad.TargetLocations, &ad.CreatedBy,
			&ad.IsDeleted, &ad.Description, &ad.CompanyName, &ad.ContactInfo,
			&ad.WebsiteURL, &ad.CreatedAt, &ad.UpdatedAt,
		)
		if err != nil {
			continue
		}

		// Filter by location if specified
		if location != "" {
			hasLocation := false
			for _, loc := range ad.TargetLocations {
				if loc == "all" || loc == location {
					hasLocation = true
					break
				}
			}
			if !hasLocation {
				continue
			}
		}

		ads = append(ads, ad)
	}

	c.JSON(http.StatusOK, ads)
}

func (h *AdHandler) GetAdByID(c *gin.Context) {
	id := c.Param("id")

	var ad models.Ad
	err := database.DB.QueryRow(`
		SELECT id, title, media_url, media_type, duration_seconds, order_index,
		       is_enabled, target_locations, created_by, is_deleted,
		       description, company_name, contact_info, website_url,
		       created_at, updated_at
		FROM ads WHERE id = ? AND is_deleted = false
	`, id).Scan(
		&ad.ID, &ad.Title, &ad.MediaURL, &ad.MediaType, &ad.DurationSeconds,
		&ad.OrderIndex, &ad.IsEnabled, &ad.TargetLocations, &ad.CreatedBy,
		&ad.IsDeleted, &ad.Description, &ad.CompanyName, &ad.ContactInfo,
		&ad.WebsiteURL, &ad.CreatedAt, &ad.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Ad not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	c.JSON(http.StatusOK, ad)
}

func (h *AdHandler) CreateAd(c *gin.Context) {
	var req models.CreateAdRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, _ := c.Get("user_id")

	// Get max order index
	var maxOrder int
	err := database.DB.QueryRow("SELECT COALESCE(MAX(order_index), -1) FROM ads").Scan(&maxOrder)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Convert target locations to JSON
	targetLocationsJSON, err := json.Marshal(req.TargetLocations)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid target locations"})
		return
	}

	// Insert ad
	adID := uuid.New().String()
	_, err = database.DB.Exec(`
		INSERT INTO ads (id, title, media_url, media_type, duration_seconds, order_index,
		                 is_enabled, target_locations, created_by, description,
		                 company_name, contact_info, website_url)
		VALUES (?, ?, ?, ?, ?, ?, true, ?, ?, ?, ?, ?, ?)
	`, adID, req.Title, req.MediaURL, req.MediaType, req.DurationSeconds, maxOrder+1,
		targetLocationsJSON, userID, req.Description, req.CompanyName, req.ContactInfo, req.WebsiteURL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create ad"})
		return
	}

	// Get created ad
	var ad models.Ad
	err = database.DB.QueryRow(`
		SELECT id, title, media_url, media_type, duration_seconds, order_index,
		       is_enabled, target_locations, created_by, is_deleted,
		       description, company_name, contact_info, website_url,
		       created_at, updated_at
		FROM ads WHERE id = ?
	`, adID).Scan(
		&ad.ID, &ad.Title, &ad.MediaURL, &ad.MediaType, &ad.DurationSeconds,
		&ad.OrderIndex, &ad.IsEnabled, &ad.TargetLocations, &ad.CreatedBy,
		&ad.IsDeleted, &ad.Description, &ad.CompanyName, &ad.ContactInfo,
		&ad.WebsiteURL, &ad.CreatedAt, &ad.UpdatedAt,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve created ad"})
		return
	}

	c.JSON(http.StatusCreated, ad)
}

func (h *AdHandler) UpdateAd(c *gin.Context) {
	id := c.Param("id")

	var req models.UpdateAdRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Build dynamic update query for MySQL
	updates := []string{}
	args := []interface{}{}

	if req.Title != nil {
		updates = append(updates, "title = ?")
		args = append(args, *req.Title)
	}
	if req.MediaURL != nil {
		updates = append(updates, "media_url = ?")
		args = append(args, *req.MediaURL)
	}
	if req.MediaType != nil {
		updates = append(updates, "media_type = ?")
		args = append(args, *req.MediaType)
	}
	if req.DurationSeconds != nil {
		updates = append(updates, "duration_seconds = ?")
		args = append(args, *req.DurationSeconds)
	}
	if req.IsEnabled != nil {
		updates = append(updates, "is_enabled = ?")
		args = append(args, *req.IsEnabled)
	}
	if req.Description != nil {
		updates = append(updates, "description = ?")
		args = append(args, *req.Description)
	}
	if req.CompanyName != nil {
		updates = append(updates, "company_name = ?")
		args = append(args, *req.CompanyName)
	}
	if req.ContactInfo != nil {
		updates = append(updates, "contact_info = ?")
		args = append(args, *req.ContactInfo)
	}
	if req.WebsiteURL != nil {
		updates = append(updates, "website_url = ?")
		args = append(args, *req.WebsiteURL)
	}
	if req.TargetLocations != nil {
		targetLocationsJSON, _ := json.Marshal(req.TargetLocations)
		updates = append(updates, "target_locations = ?")
		args = append(args, targetLocationsJSON)
	}
	if req.OrderIndex != nil {
		updates = append(updates, "order_index = ?")
		args = append(args, *req.OrderIndex)
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No fields to update"})
		return
	}

	// Add id to args
	args = append(args, id)

	query := "UPDATE ads SET " + updates[0]
	for i := 1; i < len(updates); i++ {
		query += ", " + updates[i]
	}
	query += " WHERE id = ?"

	_, err := database.DB.Exec(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update ad"})
		return
	}

	// Get updated ad
	var ad models.Ad
	err = database.DB.QueryRow(`
		SELECT id, title, media_url, media_type, duration_seconds, order_index,
		       is_enabled, target_locations, created_by, is_deleted,
		       description, company_name, contact_info, website_url,
		       created_at, updated_at
		FROM ads WHERE id = ?
	`, id).Scan(
		&ad.ID, &ad.Title, &ad.MediaURL, &ad.MediaType, &ad.DurationSeconds,
		&ad.OrderIndex, &ad.IsEnabled, &ad.TargetLocations, &ad.CreatedBy,
		&ad.IsDeleted, &ad.Description, &ad.CompanyName, &ad.ContactInfo,
		&ad.WebsiteURL, &ad.CreatedAt, &ad.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Ad not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get updated ad"})
		return
	}

	c.JSON(http.StatusOK, ad)
}

func (h *AdHandler) DeleteAd(c *gin.Context) {
	id := c.Param("id")

	result, err := database.DB.Exec(`
		UPDATE ads SET is_deleted = true
		WHERE id = ? AND is_deleted = false
	`, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete ad"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Ad not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Ad deleted successfully"})
}

func (h *AdHandler) UploadMedia(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	// Check file size
	maxSize := h.cfg.MaxUploadSizeMB * 1024 * 1024
	if file.Size > maxSize {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File too large"})
		return
	}

	// Generate unique filename
	ext := filepath.Ext(file.Filename)
	filename := uuid.New().String() + ext
	filepath := filepath.Join(h.cfg.UploadPath, filename)

	// Open uploaded file
	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open file"})
		return
	}
	defer src.Close()

	// Create destination file
	dst, err := os.Create(filepath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}
	defer dst.Close()

	// Copy file
	if _, err = io.Copy(dst, src); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	// Return URL (adjust based on your server configuration)
	url := "/uploads/" + filename

	c.JSON(http.StatusOK, gin.H{
		"url":      url,
		"filename": filename,
	})
}

func (h *AdHandler) ReorderAds(c *gin.Context) {
	var req struct {
		Orders []struct {
			ID    string `json:"id" binding:"required"`
			Order int    `json:"order" binding:"required"`
		} `json:"orders" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	tx, err := database.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	for _, item := range req.Orders {
		_, err := tx.Exec(`
			UPDATE ads SET order_index = ?
			WHERE id = ?
		`, item.Order, item.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reorder ads"})
			return
		}
	}

	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Ads reordered successfully"})
}
