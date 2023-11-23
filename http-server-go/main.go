package main

import (
    "log"
    "net"
    "net/http"
    "time"
    "io"
    "golang.org/x/net/netutil"
)

func getHello(w http.ResponseWriter, r *http.Request) {
    link := `<a href="/ssi-proxy"><button class="button-choose pure-button">Try it!</button></a>`
    info := r.URL.Query().Get("info")
    if info != "" {
        link = `<a href="/info/ssi-proxy"><button class="button-choose pure-button">More info</button></a>`
    }

    time.Sleep(10 * time.Millisecond)
	io.WriteString(w, `<div class="pure-u-1 pure-u-md-1-2">
                           <div class="pricing-table pricing-table-proxy">
                               <div class="pricing-table-header">
                                   <h2>SSI proxy Addon</h2>
                                   <span class="pricing-table-price">
                                               $15 <span>setup up costs</span>
                                           </span>
                               </div>

                               <ul class="pricing-table-list">
                                   <li>Scale horizontally</li>
                                   <li>FrankenPHP/RoadRunner support</li>
                                   <li>Multi-technology support</li>
                                   <li>Hell yeah, response from golang!</li>
                               </ul>
                                `+link+`
                           </div>
                       </div>`)
}

func main() {
	http.HandleFunc("/golang/ssi", getHello)

    listener, err := net.Listen("tcp", ":3333")
    if err != nil {
        log.Fatalf("Unable to listen on :3333: %v", err)
    }

    // Limit the max number of concurrent connections to 100
    listener = netutil.LimitListener(listener, 30)

    server := &http.Server{}
    server.SetKeepAlivesEnabled(true)

    if err := server.Serve(listener); err != nil {
        log.Fatalf("Unable to serve: %v", err)
    }
}
