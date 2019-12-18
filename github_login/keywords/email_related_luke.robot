*** Keywords ***

Check Confirm Email
    [Arguments]    ${last_email}
    Open Mailbox    host=imap.gmail.com	user=${email_qa_gmail_user}    password=${email_qa_gmail_user_pwd}
    ${LATEST} =    Wait For Email   recipient=${last_email}    timeout=300
    @{all_links}=  Get Links From Email  ${LATEST}
    Set Test Variable  ${confirm_link}  @{all_links}[7]
    Should Contain  ${confirm_link}  ${email_confirm_prefix_url}
    ${Body}=  Get Email Body  ${LATEST}
    ${username}=  Remove String  ${last_email}  @gmail.com
    Should Contain  ${Body}.decode('utf-8')  ${username}  
    Log   ${Body}
    Close Mailbox
    [Return]  ${confirm_link}

Open Confirm Link
    [Arguments]    ${confirm_link}
    Open browser  ${confirm_link}  ${BROWSER}
    # Maximize Browser Window
    Wait Until Element Is Visible  ${verified_email_msg_xpath}
    Page Should Contain  ${verified_email_msg}
    Click Element  ${verified_email_msg_xpath}
    Run Keyword And Ignore Error  Wait Until Page Contains  ${verified_email_success_msg}
    Close browser
      

Check purchase Email
    [Arguments]    ${last_email}  ${item_name}  ${item_name_vip_price}
    Open Mailbox    host=imap.gmail.com	user=${email_qa_gmail_user}    password=${email_qa_gmail_user_pwd}
    ${LATEST} =    Wait For Email   text=${item_name}  sender=support@direct2drive.com  recipient=${last_email}  timeout=300
    ${Body}=  Get Email Body  ${LATEST}
    Should Contain  ${Body}.decode('utf-8')    ${item_name}
    Should Contain  ${Body}.decode('utf-8')    ${item_name_vip_price}
    Log   ${Body}
    Close Mailbox

