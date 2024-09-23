package main

import (
	"fmt"
	"html/template"
	"log"
	"math/rand"
	"net/http"
	"path/filepath"
	"sync"
	"time"
)

// URL mapping in-memory
var urlStore = make(map[string]string)
var mutex = &sync.Mutex{}

// Seed random number generator
func init() {
	rand.Seed(time.Now().UnixNano())
}

// Serve HTML form
func homeHandler(w http.ResponseWriter, r *http.Request) {
	// Serve static HTML file
	tmpl := template.Must(template.ParseFiles(filepath.Join("templates", "index.html")))
	err := tmpl.Execute(w, nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// Shorten Handler- takes long URL and generates shortened version
func shortenHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Parse form to get long URL
	longURL := r.FormValue("url")
	if longURL == "" {
		http.Error(w, "URL parameter is required", http.StatusBadRequest)
		return
	}

	// Generate short URL
	shortURL := generateShortURL()

	// Store mapping between short and long URL
	mutex.Lock()
	urlStore[shortURL] = longURL
	mutex.Unlock()

	// Return shortened URL in HTML format
	shortenedLink := fmt.Sprintf("http://localhost:8080/%s", shortURL)
	fmt.Fprintf(w, `<p>Shortened URL: <a href="%s" target="_blank">%s</a></p>`, shortenedLink, shortenedLink)
}

// Redirect Handler - Redirects short URLs to original long URLs
func redirectHandler(w http.ResponseWriter, r *http.Request) {
	// Extract the short URL from the path
	shortURL := r.URL.Path[1:]

	// Lookup long URL for short URL
	mutex.Lock()
	longURL, exists := urlStore[shortURL]
	mutex.Unlock()

	if !exists {
		http.Error(w, "Short URL not found", http.StatusNotFound)
		return
	}

	// Redirect to original long URL
	http.Redirect(w, r, longURL, http.StatusFound)
}

// Utility function
// Generate random 6-character string for short URL
func generateShortURL() string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	shortURL := make([]byte, 6)
	for i := range shortURL {
		shortURL[i] = charset[rand.Intn(len(charset))]
	}
	return string(shortURL)
}

func main() {
	// Serve static files
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Handle serving home page
	http.HandleFunc("/", homeHandler)

	// Handle shortened URL redirects
	http.HandleFunc("/r/", redirectHandler)

	// Handle URL shortening
	http.HandleFunc("/shorten", shortenHandler)

	// Start server
	fmt.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
