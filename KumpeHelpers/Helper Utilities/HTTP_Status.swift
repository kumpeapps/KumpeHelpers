//
//  HTTP_Status.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 9/5/22.
//

import UIKit

public struct HTTP_Status_Response {
    public let statusCode: Int
    public var statusCategory: HTTP_Status_Category {
        switch statusCode {
        case 100...199:
            return .Informational
        case 200...299:
            return .Success
        case 300...399:
            return .Redirection
        case 400...499:
            return .ClientError
        case 500...599:
            return .ServerError
        default:
            return .Unknown
        }
    }
    public var statusDescription: String {
        switch statusCode {
        case 100:
            return "Continue"
        case 101:
            return "Switching Protocols"
        case 102:
            return "Processing (WebDAV)"
        case 200:
            return "OK"
        case 201:
            return "Created"
        case 202:
            return "Accepted"
        case 203:
            return "Non-Authoritative Information"
        case 204:
            return "No Content"
        case 205:
            return "Reset Content"
        case 206:
            return "Partial Content"
        case 207:
            return "Multi-Status (WebDAV)"
        case 208:
            return "Already Reported (WebDAV)"
        case 226:
            return "IM Used"
        case 300:
            return "Multiple Choices"
        case 301:
            return "Moved Permanently"
        case 302:
            return "Found"
        case 303:
            return "See Other"
        case 304:
            return "Not Modified"
        case 305:
            return "Use Proxy"
        case 306:
            return "(Unused)"
        case 307:
            return "Temporary Redirect"
        case 308:
            return "Permanent Redirect (experimental)"
        case 400:
            return "Bad Request"
        case 401:
            if KumpeHelpers.KumpeAPIClient.isKumpeAppsApi {
                return "Unauthorized- API credentials not supplied. Ensure you have passed proper Username and Password parameters"
            } else {
                return "Unauthorized"
            }
        case 402:
            return "Payment Required"
        case 403:
            if KumpeHelpers.KumpeAPIClient.isKumpeAppsApi {
                return "User access is denied."
            } else {
                return "Forbidden"
            }
        case 404:
            return "Not Found"
        case 405:
            if KumpeHelpers.KumpeAPIClient.isKumpeAppsApi {
                return "API Access Denied! Your API account does not have access to this Verb Method!"
            } else {
                return "Method Not Allowed"
            }
        case 406:
            return "Not Acceptable"
        case 407:
            return "Proxy Authentication Required"
        case 408:
            return "Request Timeout"
        case 409:
            return "Conflict"
        case 410:
            return "Gone"
        case 411:
            return "Length Required"
        case 412:
            if KumpeHelpers.KumpeAPIClient.isKumpeAppsApi {
                return "API Access Denied! Your API key is invalid or has expired!"
            } else {
                return "Precondition Failed"
            }
        case 413:
            return "Request Entity Too Large"
        case 414:
            return "Request-URI Too Long"
        case 415:
            return "Unsupported Media Type"
        case 416:
            return "Requested Range Not Satisfiable"
        case 417:
            return "Expectation Failed"
        case 418:
            return "I'm a teapot"
        case 420:
            return "Enhance Your Calm"
        case 422:
            return "Unprocessable Entity"
        case 423:
            return "Locked"
        case 424:
            return "Failed Dependency"
        case 425:
            return "Reserved for WebDAV"
        case 426:
            return "Upgrade Required"
        case 428:
            return "Precondition Required"
        case 429:
            return "Too Many Requests"
        case 431:
            return "Request Header Fields Too Large"
        case 444:
            return "No Response"
        case 449:
            if KumpeHelpers.KumpeAPIClient.isKumpeAppsApi {
                return "OTP Required is configured for this User. Retry login with OTP"
            } else {
                return "Retry With"
            }
        case 450:
            return "Blocked by Windows Parental Controls"
        case 451:
            return "Unavailable For Legal Reasons"
        case 499:
            return "Client Closed Request"
        case 500:
            return "Internal Server Error"
        case 501:
            return "Not Implemented"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        case 504:
            return "Gateway Timeout"
        case 505:
            return "HTTP Version Not Supported"
        case 506:
            return "Variant Also Negotiates"
        case 507:
            return "Insufficient Storage"
        case 508:
            return "Loop Detected"
        case 509:
            return "Bandwith Limit Exceeded"
        case 510:
            return "Not Extended"
        case 511:
            return "Network Authentication Required"
        case 598:
            return "Network read timeout error"
        case 599:
            return "Network connect timeout error"
        default:
            return "Unknown Error"
        }
    }
    public init(_ statusCode:Int) {
        self.statusCode = statusCode
    }
}

public enum HTTP_Status_Category:String {
    case Informational
    case Success
    case Redirection
    case ClientError
    case ServerError
    case Unknown
}
