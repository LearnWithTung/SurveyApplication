# Survey iOS Application

## How to use

1. clone project
2. cd  `SurveyiOSApplication/SurveyiOSApplication/`            
3. run  `pod install`
4. open `SurveyiOSApplication.xcworkspace`

##  ⚠️ 
* If you run tests from  `SurveyFramework` on iOS  you'll see two tests `test_load_returnsSavedToken` and `test_load_returnsLastSavedToken`  fails due to testing Keychain requires a host application. You can make it pass by:
1. Create a host iOS application and run the tests on it.
or
2. Run the test on macOS.

* I notice that your development endpoint doesn't work properly so please run the app with `Release` configuration 

## Use Case Specs

### Login Use Case

#### Data:
- URL
- grant_type
- username
- password
- client_id
- clent_secret

#### Primary course:
1. Execute "login" command with above data.
2. System creates request with above data.
3. System sends created request to the backend.
4. System validates response data.
5. System creatse token.
6. System delivers token.

#### Connectivity error - error course:
1. System delivers connectivity error.

#### Invalid data error - error course:
1. System delivers invalid data error.

### Load Token From Cache Use Case

#### Data:

#### Primary course:
1. Execute "load token from cache" command with above data.
2. System fetches data from the cache.
3. System validates fetched data.
4. System delivers cached token.

#### Token not found error - error course:
1. System delivers error.

#### Invalid data error - error course:
1. System delivers error.

### Cache Token Use Case

#### Data:

#### Primary course:
1. Execute "cache token" command with above data.
2. System deletes old cache.
2. System encodes token.
3. System save new cache data.
4. System delivers success message.

#### Delete cache error - error course:
1. System delivers error.

#### Saving error - error course:
1. System delivers error.

### Load Surveys From Remote Use Case

#### Data:
- URL
- page number
- page size

#### Primary course:
1. Execute "load surveys from remote" command with above data.
2. System creates request with above data.
3. System sends created request to the backend.
4. System validates response data.
5. System creates servey items from validated data.
5. System delivers a list of servey items.

#### Connectivity error - error course:
1. System delivers connectivity error.

#### Invalid data error - error course:
1. System delivers invalid data error.


### Load Token From Remote Use Case

#### Data:
- URL
- grant_type
- refresh_token
- client_id
- clent_secret

#### Primary course:
1. Execute "load token from remote" command with above data.
2. System creates request with above data.
3. System sends created request to the backend.
4. System validates response data.
5. System creatse token.
6. System delivers token.

#### Connectivity error - error course:
1. System delivers connectivity error.

#### Invalid data error - error course:
1. System delivers invalid data error.


### Logout Use Case

#### Data:

#### Primary course:
1. Execute "logout" command with above data.
2. System clears the cache.
3. System delivers success message.

## Stats

### `SurveyFramework` target

#### 32 test cases

#### Coverage: 93,7 %

#### Total run time: 0.456 seconds

### `SurveyiOSApplication` target

####  69 test cases

#### Coverage: 81,3 %

#### Total run time: 0.8 seconds
