
## Step by step: how to organize INBO coding club

### Workflow

#### > 2 months before coding club

*   Set up date and location (room with beamer and chairs + tables)
*   Add information to [agenda for intranet](https://docs.google.com/spreadsheets/d/1h3KNIlOL8X0OUjQCI9sqGVwncZHZxLFjpzwNgimjQpc/edit?ts=5ae9afdd#gid=1369004377) and create a new title/section in this document (see [template](#invitation-email-example)).

#### 4 weeks before coding club

*   Define a topic (e.g. "_data wrangling_",...) and the level (introductory, intermediate or advanced). Provide this information to the session info in this sheet.
*   Create a new column [in the subscription table](https://docs.google.com/spreadsheets/d/1D80p7lxLUnWUxEkTIYOMhhYdL39kZOKgKmLOXsr4HGM/edit) and provide subscription/waiting list as function of the room space availability
*   Sent out an invitation mail to dg_user@inbo.be AND all email addresses listed on the [external_invites sheet of the subscription sheets](https://docs.google.com/spreadsheets/d/1D80p7lxLUnWUxEkTIYOMhhYdL39kZOKgKmLOXsr4HGM/edit). Introduce the topic, the complexity level and add a link to the subscription table. Add the [coding club logo]({{ site.baseurl }}{% link /assets/images/coding_club_logo_1.png %}) to the mail.

#### Within 1 week before coding club

*   Add calendar item in google calendar with an invite to the subscribed people as a reminder of the coding session.
*   Create new presentation in the [coding club > docs > sessions](https://github.com/inbo/coding-club/tree/master/docs/sessions) folder. Make a COPY of the [template presentation]({{ site.baseurl }}{% link sessions/template.html  %}), call the copy `yyyymmdd_topicname.html` and adapt to the requirements/needs of the session (don't take the template to rigid ;-). Slides are created in [remark](https://github.com/gnab/remark) and can be written as a markdown file. Note the extension is `html` to properly render in the web page (more info [here](https://github.com/gnab/remark/wiki/Using-with-Jekyll)):
    *   To create the topic badge in green, we use [Inkscape](https://inkscape.org/en/). The source file is [here](https://github.com/inbo/coding-club/blob/master/docs/assets/images/coding_club_badges.svg).
    *   Make sure to keep the sticky note concept slide as people may join for the first time!
    *   Create a new hackmd with [https://hackmd.io/new](https://hackmd.io/new), and update link to the new hackmd in the presentation. You can use the [template](#hackmd-template) to add to the hackmd.
    * When creating the slideshow, serving the website live is possible with setting up a local server in the terminal: `bundle exec jekyll serve --baseurl ""` (make sure to have Ruby, with the gems `jekyll`, `jekyll-theme-minimal` and `github-pages` installed ). Info on the theme used is available [here](https://github.com/pages-themes/minimal).
* Set up 3 challenges (we experienced that 3 is mostly enough for a 2 hour session) with an increasing complexity:
    *   Explain the challenges in the slideshow
    *   Provide a draft working script in a file `yyyymmdd_challenges.R` and add it to the `src` folder
    *   Provide example solutions in a file `yyyymmdd_solutions.R` for yourself
    *   If the challenge uses new datasets, add them to the [data](https://github.com/inbo/coding-club/tree/master/data) folder. Use consistent naming, e.g. `yyyymmdd_topic_with_underscores_lower_case.csv`
    * If useful, provide a script to get started and add it to the  [src](https://github.com/inbo/coding-club/tree/master/src) folder.
* Update the [session overview page](https://github.com/inbo/coding-club/blob/master/docs/sessions/index.md) overview table with the date, topic name, slideshow link, hackmd link and location (room).
*   If a cheat sheet exists about the topic, download it and add it to the [cheatsheet folder](https://github.com/inbo/coding-club/tree/master/cheat_sheets). Use consistent naming, `yyyymmdd_cheat_sheet_topicname.pdf`.
*   (Make sure all subscribers do have internet access, otherwise provide them with internet access: for the Hermann Teirlinck building see [https://bezoekers.vonet.be/](https://bezoekers.vonet.be/))

__Remark__, when creating links to other files, make sure to use the [jekyll link system](https://jekyllrb.com/docs/liquid/tags/#links) by combining the base url reference with the relative link.

#### Day of the coding club

*   Collect sufficient postits (> 3x subscibers)
*   If a cheat sheet exists about the topic, provide prints for each subscriber
*   Make sure you have internet access and a computer compatible with the [Barco clickshare](https://www.barco.com/en/product/clickshare-button) (in general, windows and MAC pc's are ok)
*   Make sure there are enough power cables, otherwise bring additional
*   Make sure you remove any fancy features from Rstudio (no dark backgrounds,...) and increase the font size of the editor (_Tool --> Global Options --> Appearance --> Then you can adjust the font size at the right panel_).

#### During the coding club

*   Be positive, be helpful and be welcoming!
*   Beware for too technical or too complex discussions...
*   Actively engage people to help each other (cfr. number of sticky notes) and to provide snippets to the hackmd. Ask them to add code to the hackmd!
*   Discuss the provided snippets or interesting solutions by LIVE CODING:
    *   Code live and say what you're typing (copy paste to the minimal, except when adding code to the hackmd ;-)
    *   Be happy with mistakes, explain the error messages to the audience!
*   Make sure you have time enough for short feedback

#### After coding club

*   Upload the `YYYYMMDD_solutions.R` file to the [src](https://github.com/inbo/coding-club/tree/master/src) folder.


## Templates


### Invitation email example

_change links to proper links_

If your unaware of the coding club existence, make sure to check the [coding club introduction page](https://inbo.github.io/coding-club/) on intranet. In short, the coding club is open to anyone who want to develop R skills in a pleasant and supportive environment to do research more effectively.

The next coding club will take place on __Tuesday 26 February__, room 01.70 - Ferdinand Peeters at Herman Teirlinck (Tour & Taxis Brussels), 10-12h. The topic of this coding club is geospatial data handling in R and more specific working with simple features (sf), also known as vector data (cfr. stored in shapefiles or geojson files). Hence we will try to read in files, transform data, combine the spatial data with non-spatial data, etc. (Notice, making maps will be the topic of a follow-up coding club.)

The concept of the coding club remains the same: everyone works together and learns from each other. We will provide some challenges and appropriate test cases. As always, presence at previous edition is not required to join in this time, you can just jump in this edition as well.

To subscribe, fill in your name on this [gsheet](https://docs.google.com/spreadsheets/d/1D80p7lxLUnWUxEkTIYOMhhYdL39kZOKgKmLOXsr4HGM/edit#gid=0). The limitation of subscriptions is defined by the number of spaces in the room.

See you all theRe in good shape,

Dirk, Hans, Damiano, Stijn

![logo]({{site.baseurl}}/assets/images/coding_club_logo_1.png)

### Hackmd template


    # INBO CODING CLUB
    26 April, 2018
    
    Welcome!
    
    ## Share your code snippet
    
    If you want to share your code snippet, copy paste your snippet within a section of three backticks (```):
    
    As an **example**:
    ```r
    library(tidyverse)
    
    ...
    ```
    (*you can copy paste this example and add your code further down, but do not fill in your code in this section*)
    
    Your snippets:
    
    ### ADD A TITLE OF YOUR SNIPPET
    
    ```r
    # ADD YOUR CODE HERE
    ```
    
    ###...


