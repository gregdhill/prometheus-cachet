package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"

	"github.com/andygrunwald/cachet"
	"github.com/prometheus/alertmanager/template"
)

type alerts struct {
	client    *cachet.Client
	incidents map[string]int
	mutex     sync.Mutex
}

func (alt *alerts) cachetAlert(status, name, message string) {
	if _, ok := alt.incidents[name]; ok {
		if strings.ToUpper(status) == "RESOLVED" {
			log.Printf("Resolving alert \"%s\".\n", name)
			alt.client.Incidents.Delete(alt.incidents[name])
			alt.mutex.Lock()
			delete(alt.incidents, name)
			alt.mutex.Unlock()
		} else {
			log.Printf("Alert \"%s\" already reported.\n", name)
		}
		return
	}

	incident := &cachet.Incident{
		Name:    name,
		Message: message,
		Status:  cachet.IncidentStatusInvestigating,
	}
	newIncident, _, _ := alt.client.Incidents.Create(incident)

	log.Printf("Reported: %s\n", newIncident.Name)

	id := newIncident.ID
	alt.mutex.Lock()
	alt.incidents[name] = id
	alt.mutex.Unlock()

	log.Printf("ID: %d\n", newIncident.ID)
}

func (alt *alerts) prometheusAlert(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	data := template.Data{}
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		fmt.Println(err)
		return
	}
	status := data.Status
	// log.Printf("Alerts: Status=%v", data.Status)
	for _, alert := range data.Alerts {
		// log.Printf("Alert: status=%s,Labels=%v,Annotations=%v", alert.Status, alert.Labels, alert.Annotations)
		alt.cachetAlert(status, alert.Labels["alertname"], alert.Annotations["summary"])
	}
}

func health(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Alive")
}

func main() {
	statusPage := os.Getenv("CACHET_URL")
	if len(statusPage) == 0 {
		panic("CACHET_URL must not be empty.")
	}
	client, err := cachet.NewClient(statusPage, nil)
	if err != nil {
		panic(err)
	}
	apiKey := os.Getenv("CACHET_KEY")
	if len(apiKey) == 0 {
		panic("CACHET_KEY must not be empty.")
	}
	client.Authentication.SetTokenAuth(apiKey)
	// client.Authentication.SetBasicAuth("test@example.com", "test123")

	alerts := alerts{incidents: make(map[string]int), client: client}
	http.HandleFunc("/health", health)
	http.HandleFunc("/webhook", alerts.prometheusAlert)
	listenAddress := "127.0.0.1:8080"
	log.Printf("Listening on %v", listenAddress)
	log.Fatal(http.ListenAndServe(listenAddress, nil))
}
