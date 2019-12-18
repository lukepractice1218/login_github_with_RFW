*** Keywords ***

Clear And Input Text
    [Arguments]  ${the_xpath}  ${the_value}
    Clear Element Text  ${the_xpath}
    Input Text  ${the_xpath}  ${the_value}
    
Create New Random Account and passoword Value 
   [Arguments]  ${qa_user}
   ${add_id_random4} =  Generate Random String  4  [NUMBERS]
   Set Test Variable  ${new_user_id}  ${qa_user}${add_id_random4}
   Set Test Variable  ${new_user_email}  ${qa_user}${add_id_random4}@gmail.com
   ${add_pwd_random8} =  Generate Random String  8  [NUMBERS]
   Set Test Variable  ${password}  ${add_pwd_random8}
   
   # [Return]  ${new_user_id}
Create New Random Account
    [Arguments]  ${login_url}  ${username}  ${password}   ${email}
    Go To  ${login_url}
    Maximize Browser Window
    Sleep  2s
    Click Element  ${rl_button_xpath}
    Clear And Input Text  ${reg_username_xpath}  ${username}
    Clear And Input Text  ${reg_email_xpath}  ${email}
    Clear And Input Text  ${reg_password_xpath1}  ${password}
    Clear And Input Text  ${reg_password_xpath2}  ${password}
    Click Element  ${reg_submit_button_xpath}
    Sleep  5s
    Wait Until Element Is Visible  ${reg_success_msg_xpath1}
    Page Should Contain  ${reg_email_xpath_success_msg1}
    Page Should Contain  ${reg_email_xpath_success_msg2}    
    
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
    
Wait And Click Link
    [Arguments]  ${link}
    Sleep  5s
    Wait Until Element Is Visible  link=${link}
    Click Element  link=${link}
    
    
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
    Close browser    

Loop_I Check Purchase History Validation
    [Arguments]    ${purchaseHistory_result}  ${counts}
    # ${counts}    Get Length  ${purchaseHistory_result["payments"]}  
    : for    ${i}    IN RANGE    0    ${counts}  
    \  log  ${i}    
    \  Should Equal  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[1]  ${purchaseHistory_result["payments"][${i}]["id"]}  
    \  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row block-title"]//div[1]//h4  Order #  
    \  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row block-title"]//div[3]//h4  Title
    \  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row block-title"]//div[4]//h4  Date of Purchase
    \  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row block-title"]//div[5]//h4  Price
    \  ${j_counts}  Get Length  ${purchaseHistory_result["payments"][${i}]["products"]}  
    \  Loop_J   ${i}   ${j_counts}  ${purchaseHistory_result}
           
Loop_J
     [Arguments]     ${i}   ${j_counts}  ${purchaseHistory_result}
    : for    ${j}    IN RANGE    0    ${j_counts}  
    \  log  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["title"]}    
    \  Page Should Contain Element  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[1]//img
    \  Should Equal  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[2]//h4  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["title"]}     
    \  ${status}  Run Keyword And Return Status  Should Be Equal  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["purchase_type"]}  purchase
    \  Run Keyword If  ${status}==True  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//span[1]  Purchase:
    \    ${api_return_price2}   custom get rounded number  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["price"]}
    \  Run Keyword If  ${status}==True  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[4]//div//div  ${api_return_price2}  
    \    ...  ELSE  Run Keywords  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//span  Rental:   
    \    ...  AND  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[4]//div  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["price"]}       
    \    ...  AND  Date Should Equal   //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//div//div   ${purchaseHistory_result["payments"][${i}]["payment_date"]}
    \  ${tradeinstatus}  Run Keyword And Return Status  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//span[2]  Trade-in:
    \  Run Keyword If  ${tradeinstatus}==True  Tradein Date Convert  ${purchaseHistory_result["payments"][${i}]["payment_date"]}  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["trade_in"]["trade_in_date"]}
    \  Run Keyword If  ${tradeinstatus}==True  Element Should Contain  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[4]//div//div//span[3]  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["trade_in"]["trade_in_price"]}
    \  Run Keyword If  ${tradeinstatus}==True  Should Equal   //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//div//div   ${tradein_datenew}  
    \  Log      //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//div//div
    \  Log    ${purchaseHistory_result["payments"][${i}]["payment_date"]}  
    \  Run Keyword If  ${tradeinstatus}==False  Date Should Equal  //div[${i+1}][@class="gf-repeat-animation ng-scope"]//div[@class="row"]//div[${j+2}]//div[3]//div//div  ${purchaseHistory_result["payments"][${i}]["payment_date"]}      


    
Should Equal
    [Arguments]   ${xpath}   ${json}
    ${converted_str}  Convert To String  ${json}
    Element Should Contain   ${xpath}  ${converted_str}
    
Date Should Equal
    [Arguments]   ${xpath}   ${json}
    ${converted_date}  Rearrange Release Date String  ${json}
    Element Should Contain   ${xpath}  ${converted_date}    
     
Rearrange Release Date String          
    [Arguments]    ${date} 
    ${timezone_format}  Fetch From Left  ${date}  .000	 
    ${python_date}=  Convert Date  ${timezone_format}   result_format=%m/%d/%Y    
    [Return]  ${python_date}
    
Tradein Date Convert
    [Arguments]    ${payment_date}   ${tradein_date}
    ${payment_datec}  Rearrange Release Date String  ${payment_date}        
    ${tradein_datec}  Rearrange Release Date String  ${tradein_date}
    Set Test Variable  ${tradein_datenew}  Purchase:\n${payment_datec}\nTrade-in:\n${tradein_datec} 
    [Return]  ${tradein_datenew}
Split To Lines Tradein
    [Arguments]    ${i}  ${j}  ${purchaseHistory_result}
    ${tradein_date}=  Split To Lines  ${purchaseHistory_result["payments"][${i}]["products"][${j}]["trade_in"]["trade_in_date"]}  -1
    [Return]  ${tradein_date}
Convert Values And Compare Values
    [Arguments]  ${valuea}  ${valueb}
    ${valuea}=  Convert To String  ${valuea}
    ${valueb}=  Convert To String  ${valueb}
    ${valuea}=  Convert To Uppercase  ${valuea}
    ${valueb}=  Convert To Uppercase  ${valueb}
    Should Be Equal  ${valuea}  ${valueb}

Check If Key Existed
    [Arguments]  ${objecta}  ${objectb}  ${keya}  ${keyb}
    ${checka}=  Run Keyword And Return Status  Get From Dictionary  ${objecta}  ${keya}
    ${checkb}=  Run Keyword And Return Status  Get From Dictionary  ${objectb}  ${keyb}
    ${checkboth}=  Evaluate  ${checka}&${checkb}
    [Return]  ${checkboth}

Compare Sub Actions
    [Arguments]  ${objecta}  ${objectb}  ${keya}  ${keyb}  ${not_case_sensitive}
    ${valuea}=  Get From Dictionary  ${objecta}  ${keya}
    ${valueb}=  Get From Dictionary  ${objectb}  ${keyb}
    log  ${valuea}
    log  ${valueb}
    ${valuea}=  Convert To String  ${valuea}
    ${valueb}=  Convert To String  ${valueb}
    Run Keyword If  ${not_case_sensitive}  Convert Values And Compare Values  ${valuea}  ${valueb}
    Run Keyword Unless  ${not_case_sensitive}  Should Be Equal  ${valuea}  ${valueb}

Compare
    [Arguments]  ${objecta}  ${objectb}  ${sub_dict}  ${not_case_sensitive}=${False}
    ${keys_dict}=  Get From Dictionary  ${vars_dict}  ${sub_dict}
    ${keys}=  Get Dictionary keys  ${keys_dict}
    ${count}=  Get Length  ${keys}
    :FOR  ${i}  IN RANGE  0  ${count}
    \  Set Test Variable  ${keya}  ${keys[${i}]}
    \  Set Test Variable  ${keyb}  ${keys_dict[\'${keya}\']}
    \  ${checkboth}=  Check If Key Existed  ${objecta}  ${objectb}  ${keya}  ${keyb}
    \  Run Keyword If  ${checkboth}  Compare Sub Actions  ${objecta}  ${objectb}  ${keya}  ${keyb}  ${not_case_sensitive}


Download File And Verify
    [Arguments]  ${remote_url}  ${local_file_name}  ${file_size}=${False}
    ${result}=  download_file  ${remote_url}  ${local_file_name}  ${file_size}
    Should Be True  ${result}

Open Connection And Log In
    Open Connection  ${IP}
    Login With Public Key  ${server_username}  ${ssh_key_pair}

Verify Messages and Status in Response Body: Status 200
    [Arguments]  ${get_returned_json_object}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Not Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    Should Not Be Equal  ${get_returned_json_object['data']}  ${null}

Verify Messages and Status in Response Body: Status 400
    [Arguments]  ${get_returned_json_object}
    # Should Be Equal  ${get_returned_json_object['status']}  ${error_status}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${400}
    Should Not Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    ${check1}=  Run Keyword And Return Status  Should Be Equal  ${get_returned_json_object['data']}  ${null}
    Run Keyword Unless  ${check1}  Should Be Empty  ${get_returned_json_object['data']}

Verify Messages and Status in Not Found: Status 404
    [Arguments]  ${get_returned_json_object}
    # Should Be Equal  ${get_returned_json_object['status']}  ${error_status3}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${404}
    Should Not Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    ${check1}=  Run Keyword And Return Status  Should Be Equal  ${get_returned_json_object['data']}  ${null}
    Run Keyword Unless  ${check1}  Should Be Empty  ${get_returned_json_object['data']}

Verify Messages and Status in Response Body: Bad Request
    [Arguments]  ${get_returned_json_object}
    ${check1}=  Run Keyword And Return Status  Should Be Equal  ${get_returned_json_object['status']}  ${error_status}
    Run Keyword Unless  ${check1}  Should Be Equal  ${get_returned_json_object['status']}  ${error_status2}
    Should Be Equal  ${get_returned_json_object['status']}  ${error_status2}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${400}
    Should Not Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    Should Be Equal  ${get_returned_json_object['data']}  ${null}

Verify Messages and Status in Response Body: Not Found
    [Arguments]  ${get_returned_json_object}
    ${check1}=  Run Keyword And Return Status  Should Be Equal  ${get_returned_json_object['status']}  ${error_status}
    Run Keyword Unless  ${check1}  Should Be Equal  ${get_returned_json_object['status']}  ${error_status3}
    Should Be Equal  ${get_returned_json_object['status']}  ${error_status3}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${404}
    Should Not Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    Should Be Equal  ${get_returned_json_object['data']}  ${null}
    
Verify Messages and Status in Response Body: 200 OK With No Content
    [Arguments]  ${get_returned_json_object}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Not Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    Should Be Equal  ${get_returned_json_object['data']}  ${null}

Verify Messages and Status in Response Body: 200 OK With INFO message
    [Arguments]  ${get_returned_json_object}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Not Be Empty  ${get_returned_json_object['messages']['info']}
    Should Be Equal  ${get_returned_json_object['data']}  ${null}

Verify Return Status 200 with Specific Message
    [Arguments]  ${get_returned_json_object}  ${expected_success_message}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Equal  ${get_returned_json_object['messages']['success'][0]}  ${expected_success_message}
    Should Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}

Verify Return Status 200 with Specific Warning
    [Arguments]  ${get_returned_json_object}  ${expected_warning_message}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['error']}
    Should Be Equal  ${get_returned_json_object['messages']['warning'][0]}  ${expected_warning_message}
    Should Be Empty  ${get_returned_json_object['messages']['info']}

Verify Return Status 200 with Specific Error
    [Arguments]  ${get_returned_json_object}  ${expected_error_message}
    Should Be Equal  ${get_returned_json_object['statusCode']}  ${200}
    Should Be Equal  ${get_returned_json_object['status']}  ${success_status}
    Should Be Equal  ${get_returned_json_object['messages']['error'][0]}  ${expected_error_message}
    Should Be Empty  ${get_returned_json_object['messages']['success']}
    Should Be Empty  ${get_returned_json_object['messages']['warning']}
    Should Be Empty  ${get_returned_json_object['messages']['info']}
    
Verify Response Data Contains
    [Arguments]  ${json_response}  ${expected_elem}
    Set Test Variable  ${elem_found}  ${False}
    ${count}=  Get Length  ${json_response['data']}
    :FOR  ${i}  IN RANGE  0  ${count}
    \  Set Test Variable  ${elem}  ${json_response['data'][${i}]}
    \  Run Keyword If  ${elem}==${expected_elem}  Set Test Variable  ${elem_found}  ${True}
    Should Be Equal  ${elem_found}  ${True}


Pop Data From Json Response and Verify Json body
    [Arguments]  ${json_object}  ${body_sample_to_compare}
    ${data}=  Pop From Dictionary  ${json_object}  data
    Should Be Equal  ${json_response_body_200}  ${body_sample49713358
        _to_compare}
    [return]  ${data}

Login Into Server
    [Arguments]  ${IP}  ${username}  ${password}
    Open Connection  ${IP}
    Login  ${username}  ${password}

custom get rounded number
   [Arguments]    ${price}
   ${price}=  Convert To Number  ${price}
   ${price}=  Evaluate  ${price} + 0.0001  #add 0.0001 to rounded this number
   ${price}=  Convert To Number  ${price}  2
   log  ${price}
   ${price_str}  convert to string  ${price}
   [Return]  ${price_str}

    
