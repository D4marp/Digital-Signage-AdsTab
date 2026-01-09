package models

import (
	"time"
)

type Impression struct {
	ID       string    `json:"id"`
	AdID     string    `json:"ad_id"`
	DeviceID string    `json:"device_id"`
	ViewedAt time.Time `json:"viewed_at"`
}

type CreateImpressionRequest struct {
	AdID     string `json:"ad_id" binding:"required"`
	DeviceID string `json:"device_id" binding:"required"`
}

type AdAnalytics struct {
	ID            string    `json:"id"`
	AdID          string    `json:"ad_id"`
	Date          time.Time `json:"date"`
	Impressions   int       `json:"impressions"`
	UniqueDevices int       `json:"unique_devices"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type AnalyticsQuery struct {
	StartDate string `form:"start_date"`
	EndDate   string `form:"end_date"`
	AdID      string `form:"ad_id"`
}
