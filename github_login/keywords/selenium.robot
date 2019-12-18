*** Keywords ***
Initiate
    [Arguments]  ${download_directory}=${EMPTY}  ${browser}=Chrome
    ${orig wait}  Set Selenium Implicit Wait  10 seconds
    Run Keyword If  '${browser}'=='Chrome'  Setup Chrome Browser And Download Directory  ${download_directory}
    Run Keyword If  '${browser}'=='Firefox'  Setup Firefox Browser And Download Directory  ${download_directory}
    Run Keyword If  '${browser}'=='IE'  Setup IE Browser

Setup IE browser
    ## set all time zone in protected mode
    Create Web Driver  Ie


Setup Chrome Browser And Download Directory
    [Arguments]  ${download_directory}
    ${options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}    Create Dictionary    download.default_directory=${download_directory}   profile.password_manager_enabled=${False}  credentials_enable_service=${False}
    Call Method  ${options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${options}  add_argument  --disable-gpu
    Call Method  ${options}  add_argument  --disable-infobars
    Create Web Driver  Chrome  chrome_options=${options}

#firefox version 47
Setup Firefox Browser And Download Directory
    [Arguments]  ${download_directory}
    ${profile}  Evaluate  sys.modules['selenium.webdriver'].FirefoxProfile()  sys,selenium.webdriver
    Call Method  ${profile}  set_preference  browser.download.folderList  ${2}
    Call Method  ${profile}  set_preference  browser.download.manager.showWhenStarting  ${False}
    Call Method  ${profile}  set_preference  browser.download.dir  ${download_directory}
    Call Method  ${profile}  set_preference  browser.helperApps.neverAsk.saveToDisk  application/json,image/*,text/plain,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/pdf
    Call Method  ${profile}  set_preference  pdfjs.disabled   ${true}
    Create WebDriver  Firefox  firefox_profile=${profile}



Setup Resolution
    [Arguments]  ${width}  ${height}
    Set Window Size  ${width}  ${height}
    log  Set the window width to ${width}
    log  Set the window height to ${height}

Clear And Input Text
    [Arguments]  ${the_xpath}  ${the_value}
    Clear Element Text  ${the_xpath}
    Input Text  ${the_xpath}  ${the_value}

Wait And Input Text
    [Arguments]  ${xpath}  ${value}
    Sleep  2s
    Wait Until Element Is Visible  ${xpath}
    Clear And Input Text  ${xpath}  ${value}

Wait And Click Element
    [Arguments]  ${xpath}
    Sleep  2s
    Wait Until Element Is Visible  ${xpath}
    Click Element  ${xpath}

Wait And Click Link
    [Arguments]  ${link}
    Sleep  2s
    Wait Until Element Is Visible  link=${link}
    Click Element  link=${link}


Login
    [Arguments]  ${login_url}=${login_url}  ${username}=${username}  ${password}=${password}  ${context}=${context}
    Initiate Context Dictionary
    Go To  ${login_url}
    Clear And Input Text  ${username_xpath}  ${username}
    Clear And Input Text  ${password_xpath}  ${password}
    Wait And Click Element  ${submit_button_xpath}
    Maximize Browser Window
    Sleep  10s
    Login Context  ${context}
    Sleep  2s

Login Context
    [arguments]  ${context}=${context}
    Click Value From Context Dictionary  context  ${context}
    Wait And Click Element  ${context_button_xpath}
    Sleep  7s


Click Value From Context Dictionary
    [arguments]  ${field}  ${dic_key}
    Click Element  ${${field}_xpath}
    ${value}  Get From Dictionary  ${${field}_dic}  ${dic_key}
    Click Element  ${value}

Initiate Context Dictionary
    ${context_dic}  Create Dictionary
    ...  0000001=xpath=//*[@id="modalForm"]/p/div/div/ul/li[1]
    ...  0000002=xpath=//*[@id="modalForm"]/p/div/div/ul/li[2]
    ...  0000003=xpath=//*[@id="modalForm"]/p/div/div/ul/li[3]
    ...  0000004=xpath=//*[@id="modalForm"]/p/div/div/ul/li[4]
    Set Suite Variable  ${context_dic}

Logout
    [arguments]  ${log_off_url}=${log_off_url}
    Go To  ${log_off_url}

Click Element Max
    [Arguments]  ${xpath}
    Maximize Browser Window
    Wait Until Element Is Visible  ${xpath}  ${pause_for_get}
    Focus  ${xpath}
    Click Element  ${xpath}

Click And Input Text
    [Arguments]  ${xpath}  ${value}
    Click Element  ${xpath}
    Input Text  ${xpath}  ${value}