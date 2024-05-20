## Articles Headlines App
Create a proof of concept for an App that displays trend articles and allows the user to save the news for reading later.

## Requirements
- App to be built with a tab bar main navigation containing 3 tabs: **Headlines, Sources, Saved.**
- **Headlines**: screen to display a list of headlines based on the user-selected sources, each row should display (title, description, author, and thumbnail picture)
  - Tapping on a row should open the headline URL to read the full article within the app.
  - When viewing an article the user should be able to save it for reading later.
- **Sources**: screen to display the list of available sources for articles, the user should be able to select multiple sources and the selection should persist user sessions.
- **Saved**: screen to display a list of previously saved headlines, tapping a row should open the article for reading, the same way as the Headlines screen.
- User should be able to delete previously saved articles
- Previously saved articles should persist app launches
- Integrate the app with [https://newsapi.org/](https://newsapi.org/) API to fetch data (register to get your API Key)  

## Key points under evaluation
- Design and implement an app that can achieve all of the goals described above
- Highly modular
- Use of modern Swift syntax
- Good use of MVC, MVVM preferable
- Reuse of components
- Simple and concise code and project structure
- Clarity over brevity
- It is expected from the App to offer a good UX
- **Programmatic UI with UIKit** _(Having experience with SwiftUI is valuable but we require this submission to use UIKit)_
- RxSwift would be a bonus
- Unit testing, provide coverage of important areas in the code

## Points of consideration
- Pagination is not required, API will return only the latest 10 articles per source
- Documentation for the API [https://newsapi.org/#documentation](https://newsapi.org/#documentation)
- Filter sources to be only for the English language
- A note on the usage of certain Libraries, you can use libraries you would normally use in a real project, however, use good judgment when deciding which ones, for example, using a NewsAPI client is not acceptable

## Allocated time and submission
- Please provide submission no more than 3 days after received.
- After finishing the project, kindly compress it and send it via email to your recruiter. Make sure to eliminate any redundant build or generated files, as they can significantly increase the size of the compressed file.
