package main

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"time"
)

type oAuthHandler struct{}

var (
	clientID string
	clientSecret string
)

func (oAuthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	if r.FormValue("code") == "" {
		w.Write([]byte("code required"))
		return
	}

	data := url.Values{
		"client_id":     {clientID},
		"client_secret": {clientSecret},
		"code":          {r.FormValue("code")},
		"grant_type":    {"authorization_code"},
		"redirect_uri":  {"http://127.0.0.1:8080"},
	}

	rt, err := http.PostForm("https://oauth2.googleapis.com/token", data)
	if err != nil {
		fmt.Println("error on processing token request: ", err)
		os.Exit(3)
		return
	}

	defer rt.Body.Close()
	rtjdata, err := io.ReadAll(rt.Body)
	if err != nil {
		fmt.Println("error on reading result of token request: ", err)
		os.Exit(4)
		return
	}

	w.Write([]byte("please close this window"))

		fmt.Println(string(rtjdata))
	go func() {
		time.Sleep(time.Second)
		os.Exit(0)
	}()

}

func main() {

	if len(os.Args) != 3 {
		fmt.Println("invalid params")
		os.Exit(2)
	}

	clientID, clientSecret = os.Args[1], os.Args[2]

	openURL("https://accounts.google.com/o/oauth2/v2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ftasks&response_type=code&redirect_uri=http%3A%2F%2F127.0.0.1:8080&client_id=" + clientID)

	http.ListenAndServe(":8080", oAuthHandler{})
}

func openURL(url string) error {
	// this works only for linux... but plasma is also for linux? :)
	return exec.Command("xdg-open", url).Start()
}
