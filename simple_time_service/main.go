package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	// Register a handler for the root path "/"
	http.HandleFunc("/", handler)

	// Start the HTTP server
	fmt.Println("Server starting on port 8081...")
	log.Fatal(http.ListenAndServe(":8081", nil))
}

// handler function for the root path
func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, Go Web App!")
}
