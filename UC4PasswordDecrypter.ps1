Function Get-UC4Pass {
<#
.SYNOPSIS
Author: Alexander Sturz (@_61106960_)
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION
Decrypts a DES encrypted Automation Engine UC4 password.

The Automation Engine (fomerly UC4) product of the vendor Broadcom (formerly Automic)
uses a encrypted password for various components.
The encryption is done with DES/ECB/NoPadding and the static hex key '7a736972e1666b61'

https://docs.automic.com/documentation/webhelp/english/AWA/11.2/AE/11.2/All%20Guides/Content/ucaber.htm

.PARAMETER CryptUC4PW
Specifies the encrypted password to decrypt.

.EXAMPLE
Get-UC4Pass -CryptUC4PW "--10A73D221123460AB1CBF70F7D770CCE65"

.EXAMPLE
Get-UC4Pass "--10A73D221123460AB1CBF70F7D770CCE65"
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $CryptUC4PW
    )

    BEGIN {
        $ErrorActionPreference = "SilentlyContinue"
    }

    PROCESS {
    
        if ($CryptUC4PW -match "^--10") {
            Write-Verbose "[Get-UC4Pass] Header of DES encrypted UC4 password found"
            
            $CryptUC4Raw = $CryptUC4PW.Substring(4) # Strip UC4 specific header --10
            Write-Verbose "[Get-UC4Pass] '$CryptUC4Raw' will be processed"
            
            if ($CryptUC4Raw.Length % 16 -ne 0) {
                Write-Verbose "[Get-UC4Pass] Provided hex string is no valid DES encrypted UC4 password"
                Break
            }

            $PlainUC4Raw = Convert-CryptToPlain $CryptUC4Raw # Do the decryption
            $PlainUC4 = Remove-NonPrintableChars $PlainUC4Raw # Remove non-printable characters
            return $PlainUC4

        }
        
        else {
            Write-Verbose "[Get-UC4Pass] No valid header of DES encrypted UC4 password found"

            $CryptUC4Raw = $CryptUC4PW.Substring(4) # Strip UC4 specific header --10
            Write-Verbose "[Get-UC4Pass] Trying to work with '$CryptUC4Raw'"
            
            if ($CryptUC4Raw.Length % 16 -ne 0) {
                Write-Verbose "[Get-UC4Pass] Provided hex string is no valid DES encrypted UC4 password"
                Break
            }

            $PlainUC4Raw = Convert-CryptToPlain $CryptUC4Raw # Do the decryption
            $PlainUC4 = Remove-NonPrintableChars $PlainUC4Raw # Remove non-printable characters
            return $PlainUC4
        }
    }
}

Function Convert-HexToByteArray {
# Helper Function

    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HexString
    )

    Write-Verbose "[Convert-HexToByteArray] '$HexString' will be converted to ByteArray"
    $Bytes = [byte[]]::new($HexString.Length / 2)

    For($i=0; $i -lt $HexString.Length; $i+=2){
        $Bytes[$i/2] = [convert]::ToByte($HexString.Substring($i, 2), 16)
    }

    $Bytes
}

Function Remove-NonPrintableChars {
# Helper Function

    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $String
    )

    Write-Verbose "[Remove-NonPrintableChars] Cleartext password '$String' will be cleaned"
    $CleanString = @()
    For($i=0; $i -lt $String.Length; $i+=1){
                
        $toByte = [convert]::ToByte($String[$i])

        if ($toByte -eq 0) { # If Null-Byte then end function
            break
        }
        if ($toByte -gt 32) { # Show printable characters only
            $CleanString += $toByte
        }
        else {
            Write-Verbose "[Remove-NonPrintableChars] Non-printable char removed at position $i, maybe your hash is wrong!"
        }
    }

    [System.Text.Encoding]::ASCII.GetString($CleanString)
}

Function Convert-CryptToPlain {
# Helper Function

    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HexString
    )

    $DataByte = Convert-HexToByteArray $HexString

    Write-Verbose "[Convert-CryptToPlain] '$DataByte' will be decrypted"
    $Decrypt = New-Object System.Security.Cryptography.DESCryptoServiceProvider
    $Decrypt.Padding = [System.Security.Cryptography.PaddingMode]::None # No Padding
    $Decrypt.Mode =  [System.Security.Cryptography.CipherMode]::ECB # DES in ECB Mode
    $Decrypt.Key = [Convert]::FromBase64String('enNpcuFma2E=') # Fixed DES Key Hex '7a736972e1666b61'
    $Decrypt.IV = [Convert]::FromBase64String('AAAAAAAAAAA=') # No Initialization Vektor IV = (0,0,0,0,0,0,0,0)

    $CryptedInput = New-Object System.IO.MemoryStream(,$DataByte) #array of one item must have a preceding coma
    $DESDecryptor = New-Object System.Security.Cryptography.CryptoStream($CryptedInput,$Decrypt.CreateDecryptor(), [System.Security.Cryptography.CryptoStreamMode]::Read)

    $Reader = New-Object System.IO.StreamReader($DESDecryptor)
    $DecryptedOut = $Reader.ReadToEnd()
    $Reader.Dispose()

    $DecryptedOut
}
