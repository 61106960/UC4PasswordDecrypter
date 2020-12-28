# UC4PasswordDecrypter

This Powershell script decrypts a DES encrypted Automation Engine UC4 password.

The Automation Engine (fomerly UC4) product of the vendor Broadcom (formerly Automic)
uses a encrypted password for various components.
The encryption is done with DES/ECB/NoPadding and the static hex key '7a736972e1666b61'

https://docs.automic.com/documentation/webhelp/english/AWA/11.2/AE/11.2/All%20Guides/Content/ucaber.htm

## How To Use

```sh
import-module .\UC4PasswordDecrypter.ps1
Get-UC4Pass -CryptUC4PW "--10A73D221123460AB1CBF70F7D770CCE65"
UC4_secureSM@
```

```sh
import-module .\UC4PasswordDecrypter.ps1
Get-UC4Pass --10B54D085AD1A3D3D42A465974A71A0B41
MTFV9zvtgqd2Ug
```

```sh
. .\UC4PasswordDecrypter.ps1
Get-UC4Pass --1011A5E9D4669E1503D85868DBA3C7C4BA -verbose
AUSFÜHRLICH: [Get-UC4Pass] Header of DES encrypted UC4 password found
AUSFÜHRLICH: [Get-UC4Pass] '11A5E9D4669E1503D85868DBA3C7C4BA' will be processed
AUSFÜHRLICH: [Convert-HexToByteArray] '11A5E9D4669E1503D85868DBA3C7C4BA' will be converted to ByteArray
AUSFÜHRLICH: [Convert-CryptToPlain] '17 165 233 212 102 158 21 3 216 88 104 219 163 199 196 186' will be decrypted
AUSFÜHRLICH: [Remove-NonPrintableChars] Cleartext password 'Un1ver$e!�����' will be cleaned
Un1ver$e!
```