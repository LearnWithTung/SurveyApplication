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
5. System delivers token.

#### Connectivity error - error course:
1. System delivers connectivity error.

#### Invalid data error - error course:
1. System delivers invalid data error.

