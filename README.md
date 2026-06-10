Project: (Robot Framework + Browser)
Command for usage: robot --variable BROWSER:chromium --variable HEADLESS:True smoke.robot

Summary
- Robot Framework tests for https://www.saucedemo.com using the RobotFramework Browser library 

Prerequisites
- Python 3.12 (recommended)
- Node.js (required for Browser library / Playwright)
- Install Robot Framework and Browser library:
  pip install robotframework robotframework-browser
- Initialize Browser / Playwright (installs browser binaries and node deps):
  rfbrowser init


Running tests
- Run full smoke suite: robot smoke.robot
- Run legacy/full suite (if present): robot smoke.robot
- Run a single test by name: robot --test "User can add and remove from cart" smoke.robot


Useful CLI variables
- HEADLESS (true/false) — control headed/headless browser. Default: false
  Example: robot --variable HEADLESS:True smoke.robot
- USER / PASSWORD — override credentials for targeted scenarios
  Example: robot --variable USER:locked_out_user --variable PASSWORD:secret_sauce smoke.robot

Notes
- Tests use Browser library selectors (css/text/:has/:has-text). Timeouts are configurable in keywords (defaults ≤5s).
- Resources file could be added to store the keywords
- The locator strategy currently is working, but might be needed tweaking in the long run.
- There is for some reason slowness in the random selection strategy of the products. This would be a place for improvement to speed up test suite run.
- I think The Cart persists after reload && User can add and remove from cart is a duplicate test. Should be combined.
- The Readme should be cleaned up
