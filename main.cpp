#include <iostream>
#include <string>
#include <unicode/unistr.h>
#include <unicode/ustream.h>
#include <unicode/locid.h>
#include <Windows.h>

using namespace std::string_literals;
int main()
{
    using namespace icu;
    #ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
    #endif

    std::u16string data = u"İstanbul, Diyarbakır, DİYARBAKIR, Türkiye 🌍 İiIı 🌍 \u0130\u0069\u0049\u0131 - Default locale = "s;
    std::string data2 =  u8"İstanbul, Diyarbakır, DİYARBAKIR, Türkiye 🌍 İiIı 🌍 \u0130\u0069\u0049\u0131 - Custom Locale  = "s;
    
    UnicodeString localeName;

    UnicodeString uni_str(data.c_str(), data.length());
    uni_str.toLower();
    uni_str += Locale::getDefault().getDisplayName(localeName);

    UnicodeString uni_str2 = UnicodeString::fromUTF8(StringPiece(data2));
    Locale turkishLocale("tr", "TR");
    uni_str2.toLower(turkishLocale);
    uni_str2 += turkishLocale.getDisplayName(localeName);
    

    std::string str;
    uni_str.toUTF8String(str);

    std::string str2;
    uni_str2.toUTF8String(str2);

    std::cout << str << std::endl;
    std::cout << str2 << std::endl;
    
    return EXIT_SUCCESS;//0
}