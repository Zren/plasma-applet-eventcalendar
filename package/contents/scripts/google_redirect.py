"""Script to handle oauth redirects from Google"""
import json
import urllib.parse
import urllib.request
import urllib.error
import argparse
import logging
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

# Initialize logging
logging.basicConfig(level=logging.INFO)

class OAuthRedirectHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = urlparse(self.path).query
        params = parse_qs(query)

        if "code" in params:
            code = params["code"][0]
            # Validate the received code here
            try:
                token_data = self.server.exchange_code_for_token(code)
                logging.info(json.dumps(token_data, sort_keys=True))
                self.respond_success()
            except urllib.error.HTTPError as e:
                logging.error(e.read().decode("utf-8"))
                self.respond_failure("Handling redirect failed.")
        else:
            self.respond_failure("Missing code parameter in redirect.")

    def respond_success(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"OAuth redirect handled successfully. You can close this tab now.")

    def respond_failure(self, message):
        self.send_response(400)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(message.encode())

class OAuthServer(HTTPServer):
    def __init__(self, server_address, handler_class, client_id, client_secret, listen_port):
        super().__init__(server_address, handler_class)
        self.client_id = client_id
        self.client_secret = client_secret
        self.listen_port = listen_port

    def exchange_code_for_token(self, code):
        token_params = {
            "code": code,
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "redirect_uri": f"http://127.0.0.1:{self.listen_port}/",
            "grant_type": "authorization_code",
        }
        data = urllib.parse.urlencode(token_params).encode("utf-8")
        req = urllib.request.Request("https://oauth2.googleapis.com/token", data)
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OAuth Redirect Server")
    parser.add_argument("--client_id", required=True, help="Client ID for OAuth")
    parser.add_argument("--client_secret", required=True, help="Client Secret for OAuth")
    parser.add_argument("--listen_port", required=True, type=int, help="Port to listen on")
    args = parser.parse_args()

    server_address = ('', args.listen_port)
    httpd = OAuthServer(server_address, OAuthRedirectHandler, args.client_id, args.client_secret, args.listen_port)
    logging.info("Starting server...")
    httpd.serve_forever()
