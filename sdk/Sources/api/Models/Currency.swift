//
//  Currency.swift
//  sdk
//
//  Created by Sergey Iskhakov on 22.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class Currency {
    static let ruble: String = "RUB"      //    Российский рубль
    static let euro: String = "EUR"       //    Евро
    static let usd: String = "USD"        //    Доллар США
    static let gbp: String = "GBP"        //    Фунт стерлингов
    static let uah: String = "UAH"        //    Украинская гривна
    static let byn: String = "BYN"        //    Белорусский рубль
    static let kzt: String = "KZT"        //    Казахский тенге
    static let azn: String = "AZN"        //    Азербайджанский манат
    static let chf: String = "CHF"        //    Швейцарский франк
    static let czk: String = "CZK"        //    Чешская крона
    static let cad: String = "CAD"        //    Канадский доллар
    static let pln: String = "PLN"        //    Польский злотый
    static let sek: String = "SEK"        //    Шведская крона
    static let tur: String = "TRY"        //    Турецкая лира
    static let cny: String = "CNY"        //    Китайский юань
    static let inr: String = "INR"        //    Индийская рупия
    static let brl: String = "BRL"        //    Бразильский реал
    static let zar: String = "ZAR"        //    Южноафриканский рэнд
    static let uzs: String = "UZS"        //    Узбекский сум
    static let bgl: String = "BGL"        //    Болгарский лев
    
    static func getCurrencySign(code: String) -> String {
        switch code {
            case ruble:
                return .RUBLE_SIGN
            case usd:
                return "$"
            case euro:
                return .EURO_SIGN
            case gbp:
                return .GBP_SIGN
            default:
                return code
        }
    }
}
