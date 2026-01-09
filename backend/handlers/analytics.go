package handlers

import (
	"net/http"
	"time"

	"digital-signage-backend/config"
	"digital-signage-backend/database"
	"digital-signage-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type AnalyticsHandler struct {
	cfg *config.Config
}

func NewAnalyticsHandler(cfg *config.Config) *AnalyticsHandler {
	return &AnalyticsHandler{cfg: cfg}
}

func (h *AnalyticsHandler) CreateImpression(c *gin.Context) {
	var req models.CreateImpressionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert impression
	impressionID := uuid.New().String()
	_, err := database.DB.Exec(`
		INSERT INTO impressions (id, ad_id, device_id)
		VALUES (?, ?, ?)
	`, impressionID, req.AdID, req.DeviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create impression"})
		return
	}

	var impression models.Impression
	err = database.DB.QueryRow(`
		SELECT id, ad_id, device_id, viewed_at
		FROM impressions WHERE id = ?
	`, impressionID).Scan(
		&impression.ID, &impression.AdID, &impression.DeviceID, &impression.ViewedAt,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create impression"})
		return
	}

	// Update analytics
	today := time.Now().Format("2006-01-02")
	_, err = database.DB.Exec(`
		INSERT INTO ad_analytics (id, ad_id, date, impressions, unique_devices)
		VALUES (?, ?, ?, 1, 1)
		ON DUPLICATE KEY UPDATE
			impressions = impressions + 1
	`, uuid.New().String(), req.AdID, today)
	if err != nil {
		// Log error but don't fail the request
		// The impression is still recorded
	}

	c.JSON(http.StatusCreated, impression)
}

func (h *AnalyticsHandler) GetAnalytics(c *gin.Context) {
	var query models.AnalyticsQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Default to last 30 days if not specified
	endDate := time.Now()
	startDate := endDate.AddDate(0, 0, -30)

	if query.StartDate != "" {
		if t, err := time.Parse("2006-01-02", query.StartDate); err == nil {
			startDate = t
		}
	}
	if query.EndDate != "" {
		if t, err := time.Parse("2006-01-02", query.EndDate); err == nil {
			endDate = t
		}
	}

	sqlQuery := `
		SELECT a.id, a.ad_id, a.date, a.impressions, a.unique_devices, a.created_at, a.updated_at
		FROM ad_analytics a
		WHERE a.date BETWEEN ? AND ?
	`
	args := []interface{}{startDate.Format("2006-01-02"), endDate.Format("2006-01-02")}

	if query.AdID != "" {
		sqlQuery += " AND a.ad_id = ?"
		args = append(args, query.AdID)
	}

	sqlQuery += " ORDER BY a.date DESC"

	rows, err := database.DB.Query(sqlQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch analytics"})
		return
	}
	defer rows.Close()

	analytics := []models.AdAnalytics{}
	for rows.Next() {
		var analytic models.AdAnalytics
		err := rows.Scan(
			&analytic.ID, &analytic.AdID, &analytic.Date, &analytic.Impressions,
			&analytic.UniqueDevices, &analytic.CreatedAt, &analytic.UpdatedAt,
		)
		if err != nil {
			continue
		}
		analytics = append(analytics, analytic)
	}

	c.JSON(http.StatusOK, analytics)
}

func (h *AnalyticsHandler) GetDashboardStats(c *gin.Context) {
	stats := gin.H{}

	// Total ads
	var totalAds, activeAds int
	database.DB.QueryRow("SELECT COUNT(*) FROM ads WHERE is_deleted = false").Scan(&totalAds)
	database.DB.QueryRow("SELECT COUNT(*) FROM ads WHERE is_deleted = false AND is_enabled = true").Scan(&activeAds)
	stats["total_ads"] = totalAds
	stats["active_ads"] = activeAds

	// Total devices
	var totalDevices, onlineDevices int
	database.DB.QueryRow("SELECT COUNT(*) FROM devices").Scan(&totalDevices)
	database.DB.QueryRow("SELECT COUNT(*) FROM devices WHERE is_online = true").Scan(&onlineDevices)
	stats["total_devices"] = totalDevices
	stats["online_devices"] = onlineDevices

	// Today's impressions
	var todayImpressions int
	today := time.Now().Format("2006-01-02")
	database.DB.QueryRow(`
		SELECT COALESCE(SUM(impressions), 0) FROM ad_analytics WHERE date = ?
	`, today).Scan(&todayImpressions)
	stats["today_impressions"] = todayImpressions

	// Total impressions (last 30 days)
	var totalImpressions int
	thirtyDaysAgo := time.Now().AddDate(0, 0, -30).Format("2006-01-02")
	database.DB.QueryRow(`
		SELECT COALESCE(SUM(impressions), 0) FROM ad_analytics WHERE date >= ?
	`, thirtyDaysAgo).Scan(&totalImpressions)
	stats["total_impressions_30d"] = totalImpressions

	// Top performing ads (last 7 days)
	sevenDaysAgo := time.Now().AddDate(0, 0, -7).Format("2006-01-02")
	rows, err := database.DB.Query(`
		SELECT a.ad_id, ad.title, SUM(a.impressions) as total
		FROM ad_analytics a
		JOIN ads ad ON a.ad_id = ad.id
		WHERE a.date >= ?
		GROUP BY a.ad_id, ad.title
		ORDER BY total DESC
		LIMIT 5
	`, sevenDaysAgo)
	if err == nil {
		topAds := []gin.H{}
		for rows.Next() {
			var adID, title string
			var total int
			if err := rows.Scan(&adID, &title, &total); err == nil {
				topAds = append(topAds, gin.H{
					"ad_id":       adID,
					"title":       title,
					"impressions": total,
				})
			}
		}
		rows.Close()
		stats["top_ads"] = topAds
	}

	c.JSON(http.StatusOK, stats)
}

func (h *AnalyticsHandler) GetAdPerformance(c *gin.Context) {
	adID := c.Param("id")
	days := 30

	if daysParam := c.Query("days"); daysParam != "" {
		if d, err := time.ParseDuration(daysParam + "h"); err == nil {
			days = int(d.Hours() / 24)
		}
	}

	startDate := time.Now().AddDate(0, 0, -days).Format("2006-01-02")

	rows, err := database.DB.Query(`
		SELECT date, impressions, unique_devices
		FROM ad_analytics
		WHERE ad_id = ? AND date >= ?
		ORDER BY date ASC
	`, adID, startDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch performance data"})
		return
	}
	defer rows.Close()

	performance := []gin.H{}
	for rows.Next() {
		var date time.Time
		var impressions, uniqueDevices int
		if err := rows.Scan(&date, &impressions, &uniqueDevices); err == nil {
			performance = append(performance, gin.H{
				"date":           date.Format("2006-01-02"),
				"impressions":    impressions,
				"unique_devices": uniqueDevices,
			})
		}
	}

	c.JSON(http.StatusOK, performance)
}
