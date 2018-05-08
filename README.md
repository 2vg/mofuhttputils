# mofuhttputils

> useful minimal http server utils.

This is a proprietary library for HTTP responses originally used in [mofuw](https://github.com/2vg/mofuw).

This library just generates a character string.

So I thought that it could be used with other HTTP servers, so it was released as a module.

## API

- `getServerTime(): string`

Returns the current time formatted for HTTP response.

It is UTC standard.

- `getGlobalServerTime(): string`

Returns the current cached server time.

- `updateServerTime(): string`

Updates the cached time variable with the current time.

It is best to call this function every second using an event loop etc.

- `addHeaders(body: string, headers: HttpHeaders): string`

- `addHeaders(body: string, headers: openArray[tuple[name: string, value: string]])`

It adds the second argument HTTP header information to the first argument string and returns it.

The two functions are whether you pass an array or pass HttpHeaders.

- `addBody*(str, mime, body: string): string`

- `addBody*(str, mime, body, charset: string): string`

It adds the second argument Content-Type and the response body to the first argument string and returns it.

The two functions specify character encoding or not.

- `makeRespNoBody(statusLine: string): string`

Returns a string with the Server header and Date header added to the HTTP status code of the first argument.

The Server header can be changed at compile time.

It can be changed like `-d: serverName: example`.

The Date header is the value of the variable at the current cached time.

This function is normally not used alone.

It is used in combination with other functions.

- `makeResp(statusLine, mime, body: string): string`

- `makeResp(statusLine, mime, body, charset: string): string`

It first calls makeNoResp function and returns a character string obtained by adding the first argument HTTP status code, the second argument Content-Type header, and the third argument response body to the string returned from makeNodeResp.

Character encoding can be specified with the fourth argument.

- `makeResp(statusLine: string, headers: openArray[tuple[name: string, value: string]], mime, body, charset: string): string`

- `makeResp(statusLine: string, headers: openArray[tuple[name: string, value: string]], mime, body, charset: string): string`

First, call the makeNoResp function and call the response argument of the first argument HTTP status code, HTTP header arrays of the second argument, Content-Type header of the third argument, and the fourth argument to the string returned from makeNodeResp And add it back.

The fifth argument allows you to specify character encoding.

- `makeResp(statusLine: string, headers: HttpHeaders, mime, body): string`

- `makeResp(statusLine: string, headers: HttpHeaders, mime, body, charset: string): string`

First, call the makeNoResp function and call the response argument of the first argument HTTP status code, HTTP header of the second argument, Content-Type header of the third argument, and the fourth argument to the string returned from makeNodeResp And add it back.

The fifth argument allows you to specify character encoding.

- `redirectTo(URL: string): string`

Generate HTTP response for redirect.

The redirect destination is the character string of the first argument.

- ` badRequest(): string`

It generates HTTP response of HTTP 400 Bad Request.

- `notFound(): string`

It generates HTTP response of HTTP 404 Not Found.

- `bodyTooLarge(): string`

It generates HTTP response of HTTP 413 Request Entity Too Large.