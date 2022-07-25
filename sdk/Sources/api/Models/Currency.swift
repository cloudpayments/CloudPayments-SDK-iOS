//
//  Currency.swift
//  sdk
//
//  Created by Sergey Iskhakov on 22.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public enum Currency: String {
    case ruble = "RUB"      //    Российский рубль
    case euro = "EUR"       //    Евро
    case usd = "USD"        //    Доллар США
    case gbp = "GBP"        //    Фунт стерлингов
    case uah = "UAH"        //    Украинская гривна
    case byn = "BYN"        //    Белорусский рубль
    case kzt = "KZT"        //    Казахский тенге
    case azn = "AZN"        //    Азербайджанский манат
    case chf = "CHF"        //    Швейцарский франк
    case czk = "CZK"        //    Чешская крона
    case cad = "CAD"        //    Канадский доллар
    case pln = "PLN"        //    Польский злотый
    case sek = "SEK"        //    Шведская крона
    case tur = "TRY"        //    Турецкая лира
    case cny = "CNY"        //    Китайский юань
    case inr = "INR"        //    Индийская рупия
    case brl = "BRL"        //    Бразильский реал
    case zar = "ZAR"        //    Южноафриканский рэнд
    case uzs = "UZS"        //    Узбекский сум
    case bgl = "BGL"        //    Болгарский лев
    
    func currencySign() -> String {
        switch self {
        case .ruble:
            return .RUBLE_SIGN
        case .usd:
            return "$"
        case .euro:
            return .EURO_SIGN
        case .gbp:
            return .GBP_SIGN
        default:
            return self.rawValue
        }
    }
}
