coding: utf-8
*** Settings ***
Library  Selenium2Library

Variables  ../../variables/github.py

*** Variable ***
${user_name}    //input username here
${user_pw}   // input password here
${url}  https://github.com/login
${BROWSER}  chrome
${project_name}  lukepractice1218
*** Test Cases ***

Login Test
    Open browser  ${url}  ${BROWSER}
	Set Window Size  1500  900
	Set Selenium Speed  0.1 seconds
	Set Browser Implicit Wait  15 seconds
    Sleep  3s
    Login User Github   ${user_name}  ${user_pw}  
        
    [Teardown]  Close Browser
*** Keywords ***
Login User Github    
    [Arguments]  ${login_user}   ${loginPassword} 
    Wait Until Element Contains   ${Login_Page_XP}     Sign in to GitHub
    Element Should Contain    ${Username_title_XP}     Username or email address
    Element Should Contain    ${Passowrd_title_XP}     Password
    Element Should Contain    ${Forgot_password_XP}    Forgot password?
    Input Text    ${Username_input_XP}    ${login_user}
    Input Text    ${Passowrd_input_XP}    ${loginPassword}
    Click Element    ${SUBMIT_BUTTON_XPATH} 
    sleep  1s
    Wait Until Element Contains    ${Repositories_XP}     Repositories


Create New Random Account Value
   [Arguments]  ${qa_user}
   ${add_id_random4} =  Generate Random String  4  [NUMBERS]
   Set Test Variable  ${new_user_id}  ${qa_user}${add_id_random4}
   Set Test Variable  ${new_user_email}  ${qa_user}${add_id_random4}@gmail.com
   ${add_pwd_random8} =  Generate Random String  8  [NUMBERS]
   Set Test Variable  ${password}  ${add_pwd_random8}

Write_variable_in_file
    [Arguments]  ${variable1} 
    Append To File  ${EXECDIR}/testdata/file_with_new_user_info.txt  ${variable1}

   
Get The Last User From Testdata List
    [Arguments]
    ${FILE_CONTENT}=   Get File    ${EXECDIR}/testdata/file_with_new_user_info.txt
    Log    File Content: ${FILE_CONTENT}
    @{LINES}=    Split To Lines    ${FILE_CONTENT}
    @{new_user_data}=    Split String  @{LINES}[-1]  ,
    # ${last_email}=  @{new_user_data}[-2]
    # ${last_pwd}=  @{new_user_data}[-1]
    Set Test Variable  ${last_email}  @{new_user_data}[-2]
    Set Test Variable  ${last_pwd}  @{new_user_data}[-1]
    

Check Confirm Email
    Open Mailbox    host=imap.gmail.com	user=${email_qa_gmail_user}    password=${email_qa_gmail_user_pwd}
    ${LATEST} =    Wait For Email   recipient=${last_email}    timeout=300
    @{all_links}=  Get Links From Email  ${LATEST}
    Set Test Variable  ${confirm_link}  @{all_links}[0]
    Should Contain  ${confirm_link}  ${email_confirm_prefix_url}
    ${Body}=  Get Email Body  ${LATEST}
    ${username}=  Remove String  ${last_email}  @gmail.com
    Should Contain  ${Body}.decode('utf-8')  ${username}  
    Log   ${Body}
    Close Mailbox

Open Confirm Link
    [Arguments]    ${confirm_link}
    Open browser  ${confirm_link}  ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible  ${verified_email_msg_xpath}
    Page Should Contain  ${verified_email_msg}
 
Login New User
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
    
Wait And Click Link
    [Arguments]  ${link}
    Sleep  5s
    Wait Until Element Is Visible  link=${link}
    Click Element  link=${link}
    



