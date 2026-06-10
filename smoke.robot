*** Settings ***
Library    Browser
Library    Collections
Test Setup    Open Browser And Sign In


*** Variables ***
${USER}        standard_user
${PASSWORD}    secret_sauce
${URL}         https://www.saucedemo.com
${HEADLESS}    false
${BROWSER}     chromium

*** Test Cases ***
User can log in, click through all the products and log out
    [Documentation]    Open the site, sign in, verify and then log out
    Open Browser And Sign In
    Wait For Elements State    id=logout_sidebar_link    visible    timeout=2s
    ${title}=    Get Title
    Should Contain    ${title}    Swag Labs
    Click Through All Products
    Log Out User
    Wait For Elements State    id=login-button    visible    timeout=2s

User cannot sign in with faulty credentials
    [Documentation]    Attempt to sign in with invalid credentials and verify error message
    [Setup]    Open Page
    Log In With Credentials    bad_user    bad_pass
    Wait For Elements State    css=.error-message-container    visible    timeout=2s
    ${err}=    Get Text    css=.error-message-container
    Should Contain    ${err}    do not match

Locked out user cannot sign in
    [Documentation]    Locked-out account should be rejected with clear message
    [Setup]    Open Page
    Log In With Credentials    locked_out_user    secret_sauce
    Wait For Elements State    css=.error-message-container    visible    timeout=2s
    ${err2}=    Get Text    css=.error-message-container
    Should Contain    ${err2}    locked out

User can add and remove from cart
    [Documentation]    Add N random items (1-5) and then remove same items by name; final cart must be empty
    Open Browser And Sign In

    ${n}=    Evaluate    random.randint(1,5)    modules=random
    ${products}=    Add N Random Items To Cart    ${n}
    Remove Items By Names    @{products}
    Verify Cart Is Empty

Cart persists after reload
    [Documentation]    Items added to cart should remain after a page reload
    Open Browser And Sign In
    ${products}=    Add N Random Items To Cart    2
    Reload Page
    Verify Cart Contains Products    @{products}
    # cleanup
    Remove Items By Names    @{products}
    Verify Cart Is Empty

User can checkout from the cart
    [Documentation]    Add a random product and go through the checkout flow
    Open Browser And Sign In
    Select Random Product
    Click    css=.shopping_cart_link
    Wait For Elements State    css=.cart_list    visible    timeout=2s
    ${confirmation}=    Checkout From Cart
    Should Contain    ${confirmation}    Thank you


*** Keywords ***

Open Browser And Sign In
    [Documentation]    Open a new browser and page, then sign in as the standard user
    ${headless_bool}=    Evaluate    '${HEADLESS}'.lower() in ('true','1')
    New Browser    browser=${BROWSER}    headless=${headless_bool}
    New Page       ${URL}
    Wait For Elements State    id=user-name    visible    timeout=2s
    Log In Standard User

Log In Standard User
    [Documentation]    Fill login form and wait until the logout link is visible to confirm login
    Fill Text       id=user-name    ${USER}
    Fill Text       id=password    ${PASSWORD}
    Click           id=login-button
    Wait For Elements State    id=logout_sidebar_link    visible    timeout=2s


Select Random Product
    [Documentation]    Choose a random product that has an "Add to cart" button, return its name and add it to the cart
    Wait For Elements State    css=.inventory_list    visible    timeout=2s
    ${items}=    Get Elements    css=.inventory_item:has(button:has-text("Add to cart"))
    ${count}=    Get Length      ${items}
    Run Keyword If    ${count} == 0    Fail    No "Add to cart" buttons available (maybe all items already added)
    ${index}=    Evaluate    random.randint(0, ${count}-1)    modules=random
    ${locator}=    Set Variable    css=.inventory_item:has(button:has-text("Add to cart")) >> nth=${index}
    Wait For Elements State    ${locator}    visible    timeout=2s
    ${name}=    Get Text    ${locator} >> css=.inventory_item_name
    ${prev}=    Get Cart Count
    Click    ${locator} >> css=button:has-text("Add to cart")
    Wait Until Keyword Succeeds    2s    1s    Cart Count Increased    ${prev}
    RETURN    ${name}

Get Cart Count
    [Documentation]    Return integer value from cart badge or 0 if not present
    ${status}    ${text}=    Run Keyword And Ignore Error    Get Text    css=.shopping_cart_badge
    ${count}=    Run Keyword If    '${status}' == 'PASS'    Convert To Integer    ${text}    ELSE    Set Variable    0
    RETURN    ${count}

Cart Count Increased
    [Documentation]    Helper used by Wait Until Keyword Succeeds to detect cart count increment
    [Arguments]    ${prev}
    ${count}=    Get Cart Count
    Run Keyword If    ${count} > ${prev}    No Operation
    ...    ELSE    Fail    Cart count did not increase yet


Add N Random Items To Cart
    [Documentation]    Add the given number of random products to the cart and return list of added product names
    [Arguments]    ${n}
    ${products}=    Create List
    FOR    ${i}    IN RANGE    ${n}
        ${name}=    Select Random Product
        Append To List    ${products}    ${name}
    END
    RETURN    ${products}


Remove Items By Names
    [Documentation]    Remove cart items matching the provided product names (in order)
    [Arguments]    @{names}
    Click    css=.shopping_cart_link
    Wait For Elements State    css=.cart_list    visible    timeout=2s
    FOR    ${name}    IN    @{names}
        ${item_locator}=    Set Variable    css=.cart_item:has(.inventory_item_name:has-text("${name}"))
        ${remove_btn}=    Set Variable    ${item_locator} >> css=button:has-text("Remove")
        Wait For Elements State    ${remove_btn}    visible    timeout=2s
        Click    ${remove_btn}
    END

Verify Cart Contains Products
    [Documentation]    Verify the listed product names exist in the cart
    [Arguments]    @{names}
    Click    css=.shopping_cart_link
    Wait For Elements State    css=.cart_list    visible    timeout=2s
    FOR    ${name}    IN    @{names}
        ${locator}=    Set Variable    css=.cart_item:has(.inventory_item_name:has-text("${name}"))
        ${ok}=    Run Keyword And Return Status    Wait For Elements State    ${locator}    visible    timeout=2s
        Run Keyword If    not ${ok}    Fail    Product ${name} not found in cart after reload
    END

Verify Cart Is Empty
    [Documentation]    Open the cart and assert that there are zero items left
    Click    css=.shopping_cart_link
    Wait For Elements State    css=.cart_list    visible    timeout=2s
    ${items}=    Get Elements    css=.cart_item
    ${count}=    Get Length    ${items}
    Should Be Equal As Integers    ${count}    0

Click Through All Products
    [Documentation]    Click each product link and verify the details page shows the same product name as in the listing
    Wait For Elements State    css=.inventory_list    visible    timeout=2s
    ${count}=    Get Element Count    css=.inventory_item .inventory_item_name
    Run Keyword If    ${count} == 0    Fail    No products found to iterate
    FOR    ${i}    IN RANGE    ${count}
        ${item_locator}=    Set Variable    css=.inventory_item .inventory_item_name >> nth=${i}
        Wait For Elements State    ${item_locator}    visible    timeout=2s
        ${list_name}=    Get Text    ${item_locator}
        Click    ${item_locator}
        Wait For Elements State    css=.inventory_details_name    visible    timeout=2s
        ${detail_name}=    Get Text    css=.inventory_details_name
        Should Be Equal    ${detail_name}    ${list_name}
        Go Back
        Wait For Elements State    css=.inventory_list    visible    timeout=2s
    END

Checkout From Cart
    [Documentation]    Assumes user is on the cart page; performs checkout flow (filling customer info) and returns confirmation header text
    Click    css=#checkout
    Wait For Elements State    id=first-name    visible    timeout=2s
    Fill Text    id=first-name    Test
    Fill Text    id=last-name     User
    Fill Text    id=postal-code  00000
    Click    id=continue
    Wait For Elements State    css=.summary_info    visible    timeout=2s
    Click    id=finish
    Wait For Elements State    css=.checkout_complete_container    visible    timeout=2s
    ${confirmation}=    Get Text    css=.complete-header
    RETURN  ${confirmation}

Open Page
    [Documentation]    Open the browser and navigate to the login page without performing sign in
    ${headless_bool}=    Evaluate    '${HEADLESS}'.lower() in ('true','1')
    New Browser    browser=${BROWSER}    headless=${headless_bool}
    New Page    ${URL}
    Wait For Elements State    id=user-name    visible    timeout=2s

Reload Page
    [Documentation]    Reload the current page and wait for the inventory list to be visible
    Browser.Reload
    Wait For Elements State    css=.inventory_list    visible    timeout=2s

Log In With Credentials
    [Documentation]    Attempt to log in with provided username and password
    [Arguments]    ${username}    ${password}
    Fill Text    id=user-name    ${username}
    Fill Text    id=password    ${password}
    Click    id=login-button

Log Out User
    [Documentation]    Open the side menu and click the logout link to sign out the current user
    Click    id=react-burger-menu-btn
    Wait For Elements State    id=logout_sidebar_link    visible    timeout=2s
    Click    id=logout_sidebar_link
    Wait For Elements State    id=login-button    visible    timeout=2s

