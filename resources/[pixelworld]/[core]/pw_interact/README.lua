--[[
PW Interaction Menu Documentation

The SynCity Interaction Menu allows for User input and interaction througout the framework, and can support menus, forms and input from the end user,
We have 3 distinct definations defined of the menu these are "Menu", "Form" and "Slider"
]]
----------------------
=== STANDARD MENUS ---
----------------------
--[[
    Standard Menus are for user interaction primarily, and propose a "Menu" styled interface for the user to interact with, 
    for example the SynCity Admin Menu is this type of menu

    The menu can be created from a table, here is an example listed below,
]]--

local menuTable = {}
table.insert(menuTable, {['label'] = "TEXT DISPLAYED TO THE USER", ['color'] = 'primary' ['action'] = "pw_vehicleshop:client:fireStaff", ['triggertype'] = 'client', ['value'] = { ['name'] = "Name", ['table'] = v } })

-- The Menu can also support a dropdown style button, make a submenu using the above example again but under a different table name for your "Options"
-- We can then get Javascript to recongnise the menu as a drop down by adding the "subMenu" value to the table

table.insert(menuTable, {['label'] = "SUBMENU LABEL", ['color'] = 'primary', ['subMenu'] = submenuTable })

-- For SubMenus you do not need to specify the ['action'], ['value'] or ['triggertype'] options in the parent menu options, but they do need to be specified in the actual submenu table for the specific options.
-- We then Generate the Menu as a TriggerEvent to the pw_interact Resource

TriggerEvent('pw_interact:generateMenu', menuTable, 'MENU TITLE HEADING')

-- This menu will now generate two options to the user initially, showing two buttons in a column type style, named "TEXT DISPLAYED TO THE USER" and "SUBMENU LABEL"

-- When the user clicks SUBMENU LABEL, a dropdown style menu will appear and show them the submenu options you have specified.

-- You will notice the ['color'] tag also on the parent menus, this will control the color of the button displayed to the user

--[[
    success = "a green button"
    warning = "a yellow button with black text"
    danger = "a red button with white text"
    info = "a lighter color blue with white text"
    primary = "a darker color blue with white text"
    dark = "a dark grey background with white text"
    secondary = "a light grey colored background with white text"
    light = "a white background with dark colored text"
    transparent = "a transparent background with dark text"

    We also got text options aswell

    text-success = "green colored text"
    text-warning = "yellow colored text"
    text-danger = "red colored text"
    text-info = "a light blue colored text"
    text-dark = "dark colored nearly black text"
    text-secondary = "a light grey colored text"
    text-light = "white colored text"
    text-black-50 = "text in a black color with a 50% transparency effect"
    text-white-50 = "text in a white color with a 50% transparency effect"

    You can also disable a button aswell by adding "disabled"

    With these you can mix and match them aswell but it must start with a primary color for example

    ['color'] = "success text-warning disabled"

    will make a green button, with yellow text, and set the button to a disabled state,

    If disabled is specified, the color will appear "lighter" than normal, and will be unclickable.

]]

--==========================================================================================================================================================================================================================================--

-------------
=== FORMS ===
-------------

--[[
    Forms are a way for users to input information into the server, to make changes etc.. here is an example form
]]

local dropDownOptions = {}
table.insert(dropDownOptions, {['label'] = "Text Displayed to the User", ['label'] = 4 ]})

local formTable = {}
table.insert(formTable, {['type'] = "writting", ['align'] = "left", ['value'] = "<small>By Removing "..data.name.." from the gang, you will revoke there permissions, any items they have stored in the Gangs Inventory will remain, and they will lose access to this.</small>" })
table.insert(formTable, {['type'] = "hr" })
table.insert(formTable, {['type'] = "writting", ['align'] = "center", ['value'] = "Are you sure you want to do this?" })
table.insert(formTable, {['type'] = "hidden", ['name'] = "info", ['value'] = "", ['data'] = data})
table.insert(formTable, {['type'] = "dropdown", ['name'] = "info", ['options'] = dropDownOptions})
table.insert(formTable, { ['type'] = "yesno", ['success'] = "Yes", ['reject'] = "No"  })

TriggerEvent('pw_interact:generateForm', 'TARGET EVENT TRIGGER', 'TRIGGER TYPE', formTable, 'Form Title')

--[[
Target Event Trigger is the event that will be fired upon successfully submitting the form,
Trigger Type is either one of two options "client" or "server" and will depend on where the target trigger is, serverside or client side.
]]

--[[ 
    There are alot of options avaliable to forms here is a list breakdown

    "writting" 
    this is just normal writting, maybe for information for the end user? like instructions, its go no user interaction. ['value'] = the text/html ['align'] can be left/center/right
    --------------
    "text" 
    a Single Line text field
    --------------
    "textbox"
    a multiline text box
    --------------
    "date" 
    a date selector, only dates can be entered.
    --------------
    "number" 
    a number field, only numbers can be entered on this type of field
    --------------
    "checkbox" 
    a checkbox (tick) a value must be specified aswell, if the checkbox is checked, the value is echoed, else returns nil,
    --------------
    "dropdown" 
    a dropdown form, a options value must be supplied as a table, which is the options displayed in the dropdown.
    --------------
    "range" 
    a range slider
    ['min'] = 1 -- Sets the Minimum number that can be selected.
    ['max'] = 100 -- Sets the Maximum number that can be selected
    So a Slider effect bar will appear to the user which will allow the user to select a range between 1 and 100
    --------------
    "hidden" 
    this is not shown to the end-user, a value must be specified, this is useful to send across hidden information like, CIDs and identifiers,
    --------------
    "password" 
    the result is in plain text, however to the user astrix's are shown as inputs
    --------------
    "hr" 
    a Horizontal Rule line, does not require any other variables passed.
    --------------
    "yesno" 
    Will remove the default Accept / Close form buttons and replace with a Yes / No option, Accepts to additional optional variables ['success'] = the text of the success / green button, ['reject'] = the text of the reject / red button 
    (This only replaces the original submit / close form buttons, and does excately the same action, just looks neater for confirmation boxes for example)
    --------------
]]