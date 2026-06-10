Test design: Saucedemo.com user flows

Scope
- Smoke and basic E2E flows: login, browse products, add/remove cart items, checkout, logout.

Strategy
- communicated with AI on what tests would be good to have. For the scope of testcases i wanted one testcase to do multiple things
- Some testcases were left singled out (locked out user) e.g.
- The amount of 4-6 testcases are covering basic functionalities of the site. The sorting mekanism was left out, but could be added later on.
- Basic functionality would be: User can sign in and sign out, user can do a purchase from the website. Links to the products are working.

Test cases (high level)
- User can log in and log out
- User can add and remove from cart (add N random items, remove same items)
- User can checkout from the cart
- User cannot sign in with faulty credentials
- Click through all products (open each details page and verify name)
- Locked-out user : attempt sign-in with locked_out_user and assert the specific locked-out error message. 
- Cart persistence : add items, reload or navigate away and back, assert cart still contains those items. 


