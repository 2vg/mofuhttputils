import times, httpcore, strformat
export httpcore.`[]`

const
  HTTP100* = "HTTP/1.1 100 Continue" & "\r\L"
  HTTP101* = "HTTP/1.1 101 Switching Protocols" & "\r\L"
  HTTP200* = "HTTP/1.1 200 OK" & "\r\L"
  HTTP201* = "HTTP/1.1 201 Created" & "\r\L"
  HTTP202* = "HTTP/1.1 202 Accepted" & "\r\L"
  HTTP203* = "HTTP/1.1 203 Non-Authoritative Information" & "\r\L"
  HTTP204* = "HTTP/1.1 204 No Content" & "\r\L"
  HTTP205* = "HTTP/1.1 205 Reset Content" & "\r\L"
  HTTP206* = "HTTP/1.1 206 Partial Content" & "\r\L"
  HTTP207* = "HTTP/1.1 207 Multi-Status" & "\r\L"
  HTTP208* = "HTTP/1.1 208 Already Reported" & "\r\L"
  HTTP226* = "HTTP/1.1 226 IM Used" & "\r\L"
  HTTP300* = "HTTP/1.1 300 Multiple Choices" & "\r\L"
  HTTP301* = "HTTP/1.1 301 Moved Permanently" & "\r\L"
  HTTP302* = "HTTP/1.1 302 Found" & "\r\L"
  HTTP303* = "HTTP/1.1 303 See Other" & "\r\L"
  HTTP304* = "HTTP/1.1 304 Not Modified" & "\r\L"
  HTTP305* = "HTTP/1.1 305 Use Proxy" & "\r\L"
  HTTP307* = "HTTP/1.1 307 Temporary Redirect" & "\r\L"
  HTTP308* = "HTTP/1.1 308 Permanent Redirect" & "\r\L"
  HTTP400* = "HTTP/1.1 400 Bad Request" & "\r\L"
  HTTP401* = "HTTP/1.1 401 Unauthorized" & "\r\L"
  HTTP402* = "HTTP/1.1 402 Payment Required" & "\r\L"
  HTTP403* = "HTTP/1.1 403 Forbidden" & "\r\L"
  HTTP404* = "HTTP/1.1 404 Not Found" & "\r\L"
  HTTP405* = "HTTP/1.1 405 Method Not Allowed" & "\r\L"
  HTTP406* = "HTTP/1.1 406 Not Acceptable" & "\r\L"
  HTTP407* = "HTTP/1.1 407 Proxy Authentication Required" & "\r\L"
  HTTP408* = "HTTP/1.1 408 Request Timeout" & "\r\L"
  HTTP409* = "HTTP/1.1 409 Conflict" & "\r\L"
  HTTP410* = "HTTP/1.1 410 Gone" & "\r\L"
  HTTP411* = "HTTP/1.1 411 Length Required" & "\r\L"
  HTTP412* = "HTTP/1.1 412 Precondition Failed" & "\r\L"
  HTTP413* = "HTTP/1.1 413 Request Entity Too Large" & "\r\L"
  HTTP414* = "HTTP/1.1 414 Request-URI Too Long" & "\r\L"
  HTTP415* = "HTTP/1.1 415 Unsupported Media Type" & "\r\L"
  HTTP416* = "HTTP/1.1 416 Requested Range Not Satisfiable" & "\r\L"
  HTTP417* = "HTTP/1.1 417 Expectation Failed" & "\r\L"
  HTTP418* = "HTTP/1.1 418 I'm a teapot" & "\r\L"
  HTTP421* = "HTTP/1.1 421 Misdirected Request" & "\r\L"
  HTTP422* = "HTTP/1.1 422 Unprocessable Entity" & "\r\L"
  HTTP423* = "HTTP/1.1 423 Locked" & "\r\L"
  HTTP424* = "HTTP/1.1 424 Failed Dependency" & "\r\L"
  HTTP426* = "HTTP/1.1 426 Upgrade Required" & "\r\L"
  HTTP428* = "HTTP/1.1 428 Precondition Required" & "\r\L"
  HTTP429* = "HTTP/1.1 429 Too Many Requests" & "\r\L"
  HTTP431* = "HTTP/1.1 431 Request Header Fields Too Large" & "\r\L"
  HTTP451* = "HTTP/1.1 451 Unavailable For Legal Reasons" & "\r\L"
  HTTP500* = "HTTP/1.1 500 Internal Server Error" & "\r\L"
  HTTP501* = "HTTP/1.1 501 Not Implemented" & "\r\L"
  HTTP502* = "HTTP/1.1 502 Bad Gateway" & "\r\L"
  HTTP503* = "HTTP/1.1 503 Service Unavailable" & "\r\L"
  HTTP504* = "HTTP/1.1 504 Gateway Timeout" & "\r\L"
  HTTP505* = "HTTP/1.1 505 HTTP Version Not Supported" & "\r\L"
  HTTP506* = "HTTP/1.1 506 Variant Also Negotiates" & "\r\L"
  HTTP507* = "HTTP/1.1 507 Insufficient Storage" & "\r\L"
  HTTP508* = "HTTP/1.1 508 Loop Detected" & "\r\L"
  HTTP509* = "HTTP/1.1 509 Bandwidth Limit Exceeded" & "\r\L"
  HTTP510* = "HTTP/1.1 510 Not Extended" & "\r\L"

var serverName {.threadvar.}: string
var serverTime {.threadvar.}: string

proc getServerTime*(): string =
  result = format(getTime().inZone(utc()), "ddd, dd MMM yyyy hh:mm:ss 'GMT'")

proc getGlobalServerTime*(): string =
  result = serverTime

proc updateServerTime*() =
  serverTime = getServerTime()

proc setServerName*(name: string) =
  serverName = name

proc baseResp*(statusLine, mime: string, len: int): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}\r\l" &
        "Content-Length: {len}\r\l")

proc baseResp*(statusLine, mime: string, len: int, charset: string): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}; charset={charset}\r\l" &
        "Content-Length: {len}\r\l")

proc headerGen*(headers: openArray[tuple[name: string, value: string]]): string {.inline.} =
  result = ""
  for v in headers:
    result.add(fmt("{v.name}: {v.value}\r\l"))

proc headerGen*(headers: HttpHeaders): string {.inline.} =
  result = ""
  for v in headers.pairs:
    result.add(fmt("{v.key}: {v.value}\r\l"))

proc makeResp*(statusLine, mime, body: string): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}\r\l" &
        "Content-Length: {body.len}\r\l\r\l" &
        "{body}")

proc makeResp*(statusLine, mime, body, charset: string): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}; charset={charset}\r\l" &
        "Content-Length: {body.len}\r\l\r\l" &
        "{body}")

proc makeResp*(statusLine, mime, body: string,
               headers: openArray[tuple[name: string, value: string]]): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}\r\l" &
        "Content-Length: {body.len}\r\l" &
        "{headerGen(headers)}" &
        "\r\l" &
        "{body}")

proc makeResp*(statusLine, mime, body: string,
               headers: HttpHeaders): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}\r\l" &
        "Content-Length: {body.len}\r\l" &
        "{headerGen(headers)}" &
        "\r\l" &
        "{body}")

proc makeResp*(statusLine, mime, body, charset: string,
               headers: openArray[tuple[name: string, value: string]]): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}; charset={charset}\r\l" &
        "Content-Length: {body.len}\r\l" &
        "{headerGen(headers)}" &
        "\r\l" &
        "{body}")

proc makeResp*(statusLine, mime, body, charset: string,
               headers: HttpHeaders): string {.inline.} =
  result =
    fmt("{statusLine}" &
        "Server: {serverName}\r\l" &
        "Date: {serverTime}\r\l" &
        "Content-Type: {mime}; charset={charset}\r\l" &
        "Content-Length: {body.len}\r\l" &
        "{headerGen(headers)}" &
        "\r\l" &
        "{body}")

proc redirectTo*(URL: string): string {.inline.} =
  result = makeResp(HTTP301, "text/html", "", [("Location", URL)])

proc badRequest*(): string {.inline.} =
  result = makeResp(HTTP400, "text/html", "")

proc notFound*(): string {.inline.} =
  result = makeResp(HTTP404, "text/html", "404 Not Found")

proc bodyTooLarge*(): string {.inline.}=
  result = makeResp(HTTP413, "text/html", "413 Request Entity Too Large")