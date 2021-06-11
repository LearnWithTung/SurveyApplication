# Survey iOS Application

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
