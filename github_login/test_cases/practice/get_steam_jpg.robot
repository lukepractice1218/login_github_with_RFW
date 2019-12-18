coding: utf-8
*** Settings ***
Library  ImapLibrary
Library  Selenium2Library
Library  String
Library  requests
Library  OperatingSystem
Library  RequestsLibrary
Library  Collections
Library  DateTime
Resource  ../../keywords/selenium_keyword_luke.robot


*** Variable ***
${steam_api_url}   https://api.steampowered.com
${uri}  
*** Test Cases ***
Get steam page
    Open browser  https://store.steampowered.com/app/252490?l=tchinese  ${BROWSER}

	# Maximize Browser Window
	Set Selenium Speed  0.3 seconds
	Set Browser Implicit Wait  5 seconds
    Sleep  1s
    # Go To  ${d2durl}
    ${counts}    Get Element Count  //div[@id='highlight_strip_scroll']//img
    ${Attribute}  Get Element Attribute   //div[@id='highlight_strip_scroll']//img  src       
    : for    ${i}    IN RANGE    0    ${counts}          
    \  ${Attribute}  Get Element Attribute   //div[@class='highlight_strip_item highlight_strip_screenshot'][${i+1}]/img  src
    [Teardown]  Close Browser

Loop Get steam page
    Open browser  https://store.steampowered.com/app/252490?l=tchinese  ${BROWSER}

	# Maximize Browser Window
	Set Selenium Speed  0.3 seconds
	Set Browser Implicit Wait  5 seconds
    Sleep  1s
    ${elements}=    Get WebElements    //div[@id='highlight_strip_scroll']//img
    FOR    ${element}    IN    @{elements}
     ${Attribute}  Get Element Attribute   ${element}   src    
	END
	[Teardown]  Close Browser
Loop2
    Open browser  https://store.steampowered.com/app/252490/  ${BROWSER}
	...  desired_capabilities=devise:D2D Desktop
	# Maximize Browser Window
	Set Selenium Speed  0.3 seconds
	Set Browser Implicit Wait  5 seconds
    Sleep  1s
    ${elements}=    Get WebElements    //div[@id='highlight_strip_scroll']//img
    FOR    ${element}    IN    @{elements}
     ${Attribute}  Get Element Attribute   ${element}   src
    sleep  1s
	END
	[Teardown]  Close Browser	
	
Get game list
    ${now_start_date}  Get Current Date  UTC  exclude_millis=True  result_format=%d_%m_%Y_%H%M
    set test variable   ${game_file_path}  ${EXECDIR}/testdata/all_steam_game${now_start_date}.txt      
   
    Create Session  steamapi  ${steam_api_url}   verify=True
    ${response}=  Get Request  steamapi  /ISteamApps/GetAppList/v2/  headers=${steam_api_headers}
    ${result} =  To Json  ${response.content}
    ${counts}    Get Length  ${result["applist"]["apps"]}
     # FOR    ${count}    IN    ${counts}
    # set Test Variable  ${game_title}   ${result["applist"]["apps"][${count}]["name"]}  
    # set Test Variable  ${appid}   ${result["applist"]["apps"][${count}]["appid"]}  
    # Write_variable_in_file  ${appid},${game_title} ${\n}  ${game_file_path}   
     Loop_products    ${counts}      ${result}  
     
     
*** Keywords ***
Loop_products
     [Arguments]   ${lastItemIndex}  ${result}  
    : for    ${l}    IN RANGE    0    ${lastItemIndex}
    \  set Test Variable  ${game_title}   ${result["applist"]["apps"][${l}]["name"]}  
    \  set Test Variable  ${appid}   ${result["applist"]["apps"][${l}]["appid"]}  
    \  Write_variable_in_file  ${appid},${game_title} ${\n}  ${game_file_path}      
Write_variable_in_file
    [Arguments]  ${variable1}  ${file_path}
    Append To File  ${file_path}  ${variable1}    
    