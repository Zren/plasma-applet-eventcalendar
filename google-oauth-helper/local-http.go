package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"time"
)

type oAuthHandler struct{}

var (
	pIni map[string]string
)

type oAuthToken struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    int    `json:"expires_in"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
}

func (oAuthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	data := url.Values{
		"client_id":     {pIni["sessionClientId"]},
		"client_secret": {pIni["sessionClientSecret"]},
		"code":          {r.FormValue("code")},
		"grant_type":    {"authorization_code"},
		"redirect_uri":  {"http://127.0.0.1:8080"},
	}

	rt, _ := http.PostForm("https://oauth2.googleapis.com/token", data)
	defer rt.Body.Close()
	rtjdata, _ := io.ReadAll(rt.Body)

	var token oAuthToken
	json.Unmarshal(rtjdata, &token)

	fmt.Fprintf(w, "accessToken=%s\naccessTokenExpiresAt=%d\naccessTokenType=%s\nrefreshToken=%s\n",
		token.AccessToken, time.Now().Unix()+int64(token.ExpiresIn*1000), token.TokenType, token.RefreshToken)

}

func main() {

	var err error
	pIni, err = parsePlasmoidIni(os.Getenv("HOME") + "/.config/plasma-org.kde.plasma.desktop-appletsrc")
	if err != nil {
		fmt.Println("unable to read plasmoid config: ", err)
		return
	}

	fmt.Println("Please open https://accounts.google.com/o/oauth2/v2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ftasks&response_type=code&redirect_uri=http%3A%2F%2F127.0.0.1:8080&client_id=" + pIni["sessionClientId"])

	log.Fatal(http.ListenAndServe(":8080", oAuthHandler{}))

}

func parsePlasmoidIni(filename string) (map[string]string, error) {
	res := make(map[string]string)

	file, err := os.Open(filename)
	if err != nil {
		return res, fmt.Errorf("%s read error: %w", filename, err)
	}

	section := regexp.MustCompile(`^(\[.*\])\s*$`)
	value := regexp.MustCompile(`^(\w*)\s*=\s*(.*?)\s*$`)
	reader := bufio.NewReader(file)

	found := false
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			break
		}

		match := section.FindStringSubmatch(line)

		if len(match) > 0 {
			found = strings.HasSuffix(match[1], "[Configuration][Google Calendar]")
			continue
		}

		if !found {
			continue
		}

		match = value.FindStringSubmatch(line)
		if len(match) > 0 {
			res[match[1]] = match[2]
			continue
		}

	}

	return res, nil
}
