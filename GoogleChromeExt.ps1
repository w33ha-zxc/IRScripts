echo '-------------------------';
echo "[+] INFO: Showing Default Chrome Plugins"
echo '-------------------------';

    $UserPaths = (Get-WmiObject win32_userprofile | Where-Object localpath -notmatch 'Windows').localpath
      foreach ($Path in $UserPaths) {
          # Google Chrome extension path
          $ExtPath = $Path + '\' + '\AppData\Local\Google\Chrome\User Data\Default\Extensions'
          if (Test-Path $ExtPath) {
              # Username
              $Username = $Path | Split-Path -Leaf
              # Extension folders
              $ExtFolders = Get-Childitem $ExtPath | Where-Object Name -ne 'Temp'
              foreach ($Folder in $ExtFolders) {
                  # Extension version folders
                  $VerFolders = Get-Childitem $Folder.FullName
                  foreach ($Version in $VerFolders) {
                      # Check for json manifest
                      if (Test-Path -Path ($Version.FullName + '\manifest.json')) {
                          $Manifest = Get-Content ($Version.FullName + '\manifest.json') | ConvertFrom-Json
                          # If extension name looks like an App name
                          if ($Manifest.name -like '__MSG*') {
                              $AppId = ($Manifest.name -replace '__MSG_','').Trim('_')
                              # Check locales folders for additional json
                              @('\_locales\en_US\', '\_locales\en\') | ForEach-Object {
                                  if (Test-Path -Path ($Version.Fullname + $_ + 'messages.json')) {
                                      $AppManifest = Get-Content ($Version.Fullname + $_ +
                                      'messages.json') | ConvertFrom-Json
                                      # Check json for potential app names and save the first one found
                                      @($AppManifest.appName.message, $AppManifest.extName.message,
                                      $AppManifest.extensionName.message, $AppManifest.app_name.message,
                                      $AppManifest.application_title.message, $AppManifest.$AppId.message) |
                                      ForEach-Object {
                                          if (($_) -and (-not($ExtName))) {
                                              $ExtName = $_
                                          }
                                      }
                                  }
                              }
                          }
                          else {
                              # Capture extension name
                              $ExtName = $Manifest.name
                          }
                          # Output formatted string

                          Write-Output (($Path | Split-Path -Leaf) + ": " + [string] $ExtName +
                          " v" + $Manifest.version + " (" + $Folder.name + ")") |Select-String -Pattern "(aapocclcgogkmnckokdopfmhonfmgoek|aohghmighlieiainnegkcijnfilokake|apdfllckaahabafndbhieahigkjlhalf|blpcfgokakmgnkcojhhkbfbldkacnbeo|felcaaldnbdncclmgdcncolpebgiejap|ghbmnnjooekpmoecnnnilnnbdlolhkhi|nmmhkkegccagdldgiimedpiccmgmieda|pjkljhegncpnkpknbcohdijeoejaedia|pkedcjkdefgpdelpbcmbmeomcjbeemfm)" -NotMatch 
                          # Reset extension name for next lookup
                          if ($ExtName) {
                              Remove-Variable -Name ExtName
                          }
                      }
                  }
              }
          }
      }