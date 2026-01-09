package handlers

import (
	"database/sql"
	"net/http"

	"digital-signage-backend/config"
	"digital-signage-backend/database"
	"digital-signage-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type DeviceHandler struct {
	cfg *config.Config
}

func NewDeviceHandler(cfg *config.Config) *DeviceHandler {
	return &DeviceHandler{cfg: cfg}
}

func (h *DeviceHandler) GetDevices(c *gin.Context) {
	rows, err := database.DB.Query(`
		SELECT id, device_id, location, is_online, last_active, today_views, settings, created_at, updated_at
		FROM devices
		ORDER BY location, device_id
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch devices"})
		return
	}
	defer rows.Close()

	devices := []models.Device{}
	for rows.Next() {
		var device models.Device
		err := rows.Scan(
			&device.ID, &device.DeviceID, &device.Location, &device.IsOnline,
			&device.LastActive, &device.TodayViews, &device.Settings,
			&device.CreatedAt, &device.UpdatedAt,
		)
		if err != nil {
			continue
		}
		devices = append(devices, device)
	}

	c.JSON(http.StatusOK, devices)
}

func (h *DeviceHandler) GetDeviceByID(c *gin.Context) {
	id := c.Param("id")

	var device models.Device
	err := database.DB.QueryRow(`
		SELECT id, device_id, location, is_online, last_active, today_views, settings, created_at, updated_at
		FROM devices WHERE id = ?
	`, id).Scan(
		&device.ID, &device.DeviceID, &device.Location, &device.IsOnline,
		&device.LastActive, &device.TodayViews, &device.Settings,
		&device.CreatedAt, &device.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Device not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	c.JSON(http.StatusOK, device)
}

func (h *DeviceHandler) RegisterDevice(c *gin.Context) {
	var req models.RegisterDeviceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if device already exists
	var existingID string
	err := database.DB.QueryRow("SELECT id FROM devices WHERE device_id = ?", req.DeviceID).Scan(&existingID)
	if err == nil {
		// Device exists, update it
		var device models.Device
		_, err = database.DB.Exec(`
			UPDATE devices SET location = ?, is_online = true, last_active = NOW()
			WHERE device_id = ?
		`, req.Location, req.DeviceID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update device"})
			return
		}
		err = database.DB.QueryRow(`
			SELECT id, device_id, location, is_online, last_active, today_views, settings, created_at, updated_at
			FROM devices WHERE device_id = ?
		`, req.DeviceID).Scan(
			&device.ID, &device.DeviceID, &device.Location, &device.IsOnline,
			&device.LastActive, &device.TodayViews, &device.Settings,
			&device.CreatedAt, &device.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update device"})
			return
		}
		c.JSON(http.StatusOK, device)
		return
	}

	// Create new device
	defaultSettings := models.DeviceSettings{
		SlideshowInterval: 5,
		VideoAutoplay:     true,
		EnabledAds:        []string{},
	}

	deviceID := uuid.New().String()
	_, err = database.DB.Exec(`
		INSERT INTO devices (id, device_id, location, is_online, settings)
		VALUES (?, ?, ?, true, ?)
	`, deviceID, req.DeviceID, req.Location, defaultSettings)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register device"})
		return
	}
	
	var device models.Device
	err = database.DB.QueryRow(`
		SELECT id, device_id, location, is_online, last_active, today_views, settings, created_at, updated_at
		FROM devices WHERE id = ?
	`, deviceID).Scan(
		&device.ID, &device.DeviceID, &device.Location, &device.IsOnline,
		&device.LastActive, &device.TodayViews, &device.Settings,
		&device.CreatedAt, &device.UpdatedAt,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register device"})
		return
	}

	c.JSON(http.StatusCreated, device)
}

func (h *DeviceHandler) UpdateDevice(c *gin.Context) {
	id := c.Param("id")

	var req models.UpdateDeviceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Build dynamic update query
	updates := []string{}
	args := []interface{}{}

	if req.Location != nil {
		updates = append(updates, "location = ?")
		args = append(args, *req.Location)
	}
	if req.IsOnline != nil {
		updates = append(updates, "is_online = ?")
		args = append(args, *req.IsOnline)
		if *req.IsOnline {
			updates = append(updates, "last_active = NOW()")
		}
	}
	if req.TodayViews != nil {
		updates = append(updates, "today_views = ?")
		args = append(args, *req.TodayViews)
	}
	if req.Settings != nil {
		updates = append(updates, "settings = ?")
		args = append(args, req.Settings)
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No fields to update"})
		return
	}

	// Add id to args
	args = append(args, id)

	query := "UPDATE devices SET " + updates[0]
	for i := 1; i < len(updates); i++ {
		query += ", " + updates[i]
	}
	query += " WHERE id = ?"

	_, err := database.DB.Exec(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update device"})
		return
	}

	// Get updated device
	var device models.Device
	err = database.DB.QueryRow(`
		SELECT id, device_id, location, is_online, last_active, today_views, settings, created_at, updated_at
		FROM devices WHERE id = ?
	`, id).Scan(
		&device.ID, &device.DeviceID, &device.Location, &device.IsOnline,
		&device.LastActive, &device.TodayViews, &device.Settings,
		&device.CreatedAt, &device.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Device not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update device"})
		return
	}

	c.JSON(http.StatusOK, device)
}

func (h *DeviceHandler) DeleteDevice(c *gin.Context) {
	id := c.Param("id")

	result, err := database.DB.Exec("DELETE FROM devices WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete device"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Device not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Device deleted successfully"})
}

func (h *DeviceHandler) Heartbeat(c *gin.Context) {
	deviceID := c.Param("id")

	_, err := database.DB.Exec(`
		UPDATE devices SET is_online = true, last_active = NOW()
		WHERE device_id = ?
	`, deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update heartbeat"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Heartbeat received"})
}

func (h *DeviceHandler) IncrementViews(c *gin.Context) {
	deviceID := c.Param("id")

	_, err := database.DB.Exec(`
		UPDATE devices SET today_views = today_views + 1
		WHERE device_id = ?
	`, deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to increment views"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Views incremented"})
}
