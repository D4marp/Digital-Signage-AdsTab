package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"
)

type Ad struct {
	ID              string         `json:"id"`
	Title           string         `json:"title"`
	MediaURL        string         `json:"media_url"`           // Main image untuk tab display
	MediaType       string         `json:"media_type"`
	DurationSeconds int            `json:"duration_seconds"`
	OrderIndex      int            `json:"order_index"`
	IsEnabled       bool           `json:"is_enabled"`
	TargetLocations StringArray    `json:"target_locations"`
	CreatedBy       string         `json:"created_by"`
	IsDeleted       bool           `json:"is_deleted"`
	Description     string         `json:"description"`
	CompanyName     string         `json:"company_name"`
	ContactInfo     string         `json:"contact_info"`
	WebsiteURL      string         `json:"website_url"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	// Gallery images - semua foto promo untuk detail page
	GalleryImages   StringArray    `json:"gallery_images"`
	// Total views untuk tracking
	TotalViews      int            `json:"total_views"`
}

// StringArray is a custom type for handling JSON arrays in MySQL
type StringArray []string

func (sa *StringArray) Scan(value interface{}) error {
	if value == nil {
		*sa = []string{}
		return nil
	}
	
	b, ok := value.([]byte)
	if !ok {
		return nil
	}
	
	return json.Unmarshal(b, sa)
}

func (sa StringArray) Value() (driver.Value, error) {
	if len(sa) == 0 {
		return json.Marshal([]string{"all"})
	}
	return json.Marshal(sa)
}

type CreateAdRequest struct {
	Title           string   `json:"title" binding:"required"`
	MediaURL        string   `json:"media_url" binding:"required"`     // Main image
	MediaType       string   `json:"media_type" binding:"required,oneof=image video pdf"`
	DurationSeconds int      `json:"duration_seconds" binding:"required,min=1"`
	TargetLocations []string `json:"target_locations" binding:"required"`
	Description     string   `json:"description"`
	CompanyName     string   `json:"company_name"`
	ContactInfo     string   `json:"contact_info"`
	WebsiteURL      string   `json:"website_url"`
	GalleryImages   []string `json:"gallery_images"`                   // Semua foto promo
}

type UpdateAdRequest struct {
	Title           *string  `json:"title"`
	MediaURL        *string  `json:"media_url"`                        // Main image
	MediaType       *string  `json:"media_type"`
	DurationSeconds *int     `json:"duration_seconds"`
	IsEnabled       *bool    `json:"is_enabled"`
	Description     *string  `json:"description"`
	CompanyName     *string  `json:"company_name"`
	ContactInfo     *string  `json:"contact_info"`
	WebsiteURL      *string  `json:"website_url"`
	TargetLocations []string `json:"target_locations"`
	OrderIndex      *int     `json:"order_index"`
	GalleryImages   []string `json:"gallery_images"`                   // Semua foto promo
}
