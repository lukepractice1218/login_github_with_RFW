*** Keywords ***
Check file is not exist
    [Arguments]  ${file_path}=${EXECDIR}/testdata/file_with_new_user_info.txt
    @{file_status1} =    File Should Not Exist   ${file_path}
    [Return]   @{file_status1}
    
Get The Last User From Testdata List
    [Arguments]  ${file_path}=${EXECDIR}/testdata/file_with_new_user_info.txt
    ${FILE_CONTENT}=   Get File    ${file_path}
    Log    File Content: ${FILE_CONTENT}
    @{LINES}=    Split To Lines    ${FILE_CONTENT}
    @{new_user_data}=    Split String  @{LINES}[-1]  ,
    Set Test Variable  ${last_email}  @{new_user_data}[-2]
    Set Test Variable  ${last_pwd}  @{new_user_data}[-1]
    [Return]    ${last_email}    ${last_pwd} 
     
Write_variable_in_file
    [Arguments]  ${variable1}  ${file_path}=${EXECDIR}/testdata/file_with_new_user_info.txt 
    Append To File  ${file_path}  ${variable1}
      
Create New Random Account Value
   [Arguments]  ${qa_user}
   ${secs} =	Get Time	epoch
   Set Test Variable  ${new_user_id}  ${qa_user}${secs}
   Set Test Variable  ${new_user_email}  ${qa_user}${secs}@gmail.com
   ${add_pwd_random8} =  Generate Random String  8  [NUMBERS]
   [Return]  ${new_user_id}  ${new_user_email}

Write_variable_in_file_element
    [Arguments]  ${variable1}  ${file_path}=${EXECDIR}/testdata/all_payment_elements.txt
    Append To File  ${file_path}  ${variable1}
