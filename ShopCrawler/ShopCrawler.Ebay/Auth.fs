module ShopCrawler.Ebay.Auth

open ShopCrawler.Common
open Types
open Providers
open FSharp.Data
open FSharp.Data.HttpRequestHeaders

let private authUrl config =
    sprintf "%s/%s" config.AuthBaseUrl "identity/v1/oauth2/token"

let private credentials config =
    let raw = sprintf "%s:%s" config.ClientId config.ClientSecret
    
    Encoding.encodeBase64 raw |> sprintf "Basic %s"


let auth config =
    let response =
        Http.Request
            (authUrl config,
             headers =
                 [ ContentType HttpContentTypes.FormValues
                   Authorization (credentials config) ],
             silentHttpErrors = true,
             body =
                 FormValues [ "grant_type", "client_credentials"
                              "scope", (config.Scopes |> String.concat " ") ])

    match response.StatusCode, response.Body with
    | 200, Text body ->
        let json = TokenResponse.Parse body
        
        Ok { Token = json.AccessToken }
    | _, Text error ->
        Error error
    | _, _ ->
        Error "Unknown error"
