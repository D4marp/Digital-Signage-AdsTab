package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"
)

type Device struct {
	ID          string          `json:"id"`
	DeviceID    string          `json:"device_id"`
	Location    string          `json:"location"`
	IsOnline    bool            `json:"is_online"`
	LastActive  time.Time       `json:"last_active"`
	TodayViews  int             `json:"today_views"`
	Settings    DeviceSettings  `json:"settings"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

type DeviceSettings struct {
	SlideshowInterval int      `json:"slideshowInterval"`
	VideoAutoplay     bool     `json:"videoAutoplay"`
	EnabledAds        []string `json:"enabledAds"`
}

func (ds *DeviceSettings) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		return nil
	}
	return json.Unmarshal(b, ds)
}

func (ds DeviceSettings) Value() (driver.Value, error) {
	return json.Marshal(ds)
}

type RegisterDeviceRequest struct {
	DeviceID   string `json:"device_id"`
	DeviceName string `json:"device_name"`
	DeviceType string `json:"device_type"`
	Location   string `json:"location" binding:"required"`
}

type UpdateDeviceRequest struct {
	Location   *string         `json:"location"`
	IsOnline   *bool           `json:"is_online"`
	TodayViews *int            `json:"today_views"`
	Settings   *DeviceSettings `json:"settings"`
}
