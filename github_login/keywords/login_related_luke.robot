*** Keywords ***
Login New User with URL
    [Arguments]  ${login_url}  ${username}  ${password}
    # Initiate Context Dictionary
    Go To  ${login_url}
    Maximize Browser Window
    Sleep  2s
    Click Element  ${rl_button_xpath}
    Clear And Input Text  ${username_xpath}  ${username}
    Clear And Input Text  ${password_xpath}  ${password}
    Click Element  ${submit_button_xpath}
    Sleep  5s

 
Clear And Input Text
    [Arguments]  ${the_xpath}  ${the_value}
    Clear Element Text  ${the_xpath}
    Input Text  ${the_xpath}  ${the_value}
    
