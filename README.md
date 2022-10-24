# Freecell


MVC:
 - model is gameState getters exposing data.  Stores the current state.
 - controller is gameState methods/setters.
 - UI shows model.
 - UI events call controller methods which change model.
 - UI subscribes to model changes to rebuild, via provider.
 
 - so the only way model changes is by UI calling controller methods.
 - if i did it right, it is testable from tests by calling methods that UI would have called, and reading model state that UI would read.


## TODOs

state:
 - intro: we are showing introscreen
 - click deal: set seed, change state to playing, push gamescreen with fade
   - hero transition checks gamestate, knows what opacity to and from to use
     - Navigator.canPop() knows if we're on introscreen or redeal modal
 

- gamestate becomes winning when 0 badlyplacedcards unless 3333333
- gamestate becomes game over when winning & foundationsfull
- push IntroScreen in a postframecallback in main() instead of from a widget

- sound listen() to gamestate to control music
- sound listen() to gamestate for numfreecells


- togglewinmusic like other, include notifylisteners
- ensure win/music started or stopped based on state at the beginning of game screen, not when it commands a change in game state
- tiger doesn't complete win so it's a better test
- win music reliable, why are transitions so fast when it's wrong?
- card z index when cancel redeal, maybe v1.1

Finally:
- PR playing_cards changes
- ship to store

v1.1:
- randomly selected bg
- honor user's music request after redeal
- trim blank space around tiger image, icon image
- better sound management around redealing - honor user's sound requests
- tiger turns on sound upon win? something's wrong there.
- upon click tiger after victory, he should fly (disabled Hero causes this)

- less ugly seed input
- random photos on AJQK
- Discouragement for more free cells
  - tiger mocks you (make these many options so it doesn't get old)
  - background image changes to something less pleasant
- Encouragement as you approach winner
  - SFX
  - tiger comments (make these very many options so it doesn't get old)

## Sequence

1. Intro
Mat has free spaces and foundations.  Cards dealt face down.
Tiger large in center with FREECELL over him.  Tiger/freecell/both? floating around a bit.
Music playing.

Buttons (not floating) beneath him: [COMPETE] [START]

2. Click [COMPETE]: 
COMPETE replaced with textfield. Tiger asks for race code.
[ race number ] [START]

3. Click [START]
If no race number entered, assign a random one.
Freecell slides below cards (and then underneath their z-index).
Tiger slides to settings panel as a Hero?  Or just appears there (separate widget) if too hard
Beneath him is textfield with race code, [GIVE UP]
Cards fade out, fade in with the real deal.

4a. Click [GIVE UP]
Music dies
Cards fall off screen? That would be cool.  Or fade to black or transparent at least.
Back to #1, same race code filled in underneath COMPETE if they click that again.

4b. Win
Stop music, if playing
Start win music - a dirge if >6 free cells
Win animation (unless >=6 free cells)
At end of win animation, big tiger back in center, congratulates you somehow,
shows [PLAY AGAIN] - takes you back to #1 with same race code under COMPETE

### Features:
Cards can be face down or up depending on game state loading or playing
Tiger widget can show or hide a text bubble over him.
Logo widget can animate movement in Stack and change z index when done
