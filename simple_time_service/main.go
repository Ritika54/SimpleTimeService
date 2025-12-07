package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net" // Import the net package
	"net/http"
	"strings"
	"time"
)

// ResponseData defines the structure of our JSON output
type ResponseData struct {
	Timestamp string `json:"timestamp"`
	IP        string `json:"ip"`
}

// getClientIPAddress extracts the client's single IP address from the request.
func getClientIPAddress(r *http.Request) string {
	// 1. Check standard proxy header first (highest priority)
	if forwarded := r.Header.Get("X-Forwarded-For"); forwarded != "" {
		// This header can be a comma-separated list: "client_ip, proxy_ip_1, proxy_ip_2"
		parts := strings.Split(forwarded, ",")
		if len(parts) > 0 {
			// **FIXED:** Access the first element [0] and then trim whitespace
			return strings.TrimSpace(parts[0])
		}
	}

	// 2. Check alternative proxy header
	if realIP := r.Header.Get("X-Real-Ip"); realIP != "" {
		return realIP
	}

	// 3. Fallback to the direct connection address provided by Go's HTTP server
	// Use net.SplitHostPort to safely extract the IP regardless of IPv4/IPv6 format
	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		// If splitting fails (e.g., malformed RemoteAddr), return the raw string
		return r.RemoteAddr
	}
	// Return the extracted IP address string
	return ip
}

// jsonHandler handles the HTTP request, gathers data, and sends the JSON response.
func jsonHandler(w http.ResponseWriter, r *http.Request) {
	// Set the Content-Type header to tell the browser we are sending JSON
	w.Header().Set("Content-Type", "application/json")

	// Get current time and format it
	timestampStr := time.Now().Format(time.RFC3339)

	// Get the visitor's IP address
	clientIP := getClientIPAddress(r)

	// Populate the struct
	data := ResponseData{
		Timestamp: timestampStr,
		IP:        clientIP,
	}

	// Encode the struct to JSON and write it to the response writer
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		log.Printf("Error encoding JSON: %v", err)
	}
}

func main() {
	http.HandleFunc("/", jsonHandler)
	fmt.Println("Server listening on http://localhost:8081")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
