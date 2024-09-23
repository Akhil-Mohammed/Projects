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

// URL mapping in-memory (using a map)
var urlStore = make(map[string]string)
var mutex = &sync.Mutex{}

// Seed random number generator
func init() {
	rand.Seed(time.Now().UnixNano())
}

// Serve the HTML form
func homeHandler(w http.ResponseWriter, r *http.Request) {
	// Serve the static HTML file
	tmpl := template.Must(template.ParseFiles(filepath.Join("templates", "index.html")))
	err := tmpl.Execute(w, nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// Shorten Handler - Takes a long URL and generates a shortened version
func shortenHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Parse the form to get the long URL
	longURL := r.FormValue("url")
	if longURL == "" {
		http.Error(w, "URL parameter is required", http.StatusBadRequest)
		return
	}

	// Generate a short URL (6 random alphanumeric characters)
	shortURL := generateShortURL()

	// Store the mapping between short and long URL
	mutex.Lock()
	urlStore[shortURL] = longURL
	mutex.Unlock()

	// Return the shortened URL in HTML format
	shortenedLink := fmt.Sprintf("http://localhost:8080/%s", shortURL)
	fmt.Fprintf(w, `<p>Shortened URL: <a href="%s" target="_blank">%s</a></p>`, shortenedLink, shortenedLink)
}

// Redirect Handler - Redirects short URLs to the original long URLs
func redirectHandler(w http.ResponseWriter, r *http.Request) {
	// Extract the short URL from the path
	shortURL := r.URL.Path[1:]

	// Lookup the long URL for the short URL
	mutex.Lock()
	longURL, exists := urlStore[shortURL]
	mutex.Unlock()

	if !exists {
		http.Error(w, "Short URL not found", http.StatusNotFound)
		return
	}

	// Redirect to the original long URL
	http.Redirect(w, r, longURL, http.StatusFound)
}

// Utility function to generate a random 6-character string for the short URL
func generateShortURL() string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	shortURL := make([]byte, 6)
	for i := range shortURL {
		shortURL[i] = charset[rand.Intn(len(charset))]
	}
	return string(shortURL)
}

func main() {
	// Serve static files (like CSS)
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Handle serving the home page
	http.HandleFunc("/", homeHandler)

	// Handle shortened URL redirects (adjust the route to avoid conflicts with the homepage)
	http.HandleFunc("/r/", redirectHandler)

	// Handle URL shortening (keeps this one distinct from the main "/" route)
	http.HandleFunc("/shorten", shortenHandler)

	// Start the server
	fmt.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
