# PAD Laboratory Project - UNO Live
The following subchapters describe the architecture and development details of an Online Multiplayer Game Server Hosted Uno game for the Distributed Aplication Programming course.

## Application Suitability

Uno represents a multiplayer card game that can be played by 2 to 10 adults concurrently within a lobby. Althought it may not be as graphics intensive as most games that require Server Side Processing, such as First Person Shooters, it can still benefit from Microservice Architecture, to combat cheating, especially within a ranked tournament, as well as to eliminate the connection and machine-related game instability that peer-to-peer hosted games may experience[1].

There are quite a few proposals for Server Side Processed games available that make use of the Microservice Architecture, both non-card[2][3] and card natured [4], as such this choice of topic is quite fitting. The Uno Backend may be easily split into User System and Game System, where the Game System's horizontal growth is expected to be required far earlier than it's couterpart due to the amount of concurrent connections to it.


## Service Boundaries
The application will have the following architecture, with the service boundaries being described below:

![The Architecture Diagram of the System](https://github.com/AlmightyCrickityCrick/PAD1/blob/main/PAD_Lab1._Architecture_Diagram.png)

Gateway - Route the client requests to the proper service swarm;
Load Balancer - Select a service to handle the incoming request from the assigned swarm;
Service Discovery - Keep registry of the existing service addresses and periodically check their health. If the health is not satisfactory, notifies the other services not to route through them and logs the defect;
User Service - Handle HTTP requests related to user login/register/state modification;
Game Service - Handle requests related to game process and lobbies;
Cache - Will temporarily store the information about the ongoing game processes.

## Technology Stack and Communication Patterns
The User Service and Game Service will be written in Elixir, while the Gateway, Service Discovery and Load Balancer will be written in Kotlin, using the Ktor library. The User Service will receive RESTful requests from users, while the Game Service will also make use of Websockets or TCP sockets for the game within the lobby. Communication between the Service Discovery and the rest of the components will be through HTTP with RPC type requests.

## Data Management
The User Service and Game Service will each have their own database, with the Game Service also employing the Redis API for storing ongoing game information for a limited period of time. All messages passed will be in JSON format, with the following requests and responses expected for each Service and endpoint:

### Common:
- Endpoint for API health checking
```
Endpoint: /getHealth
Method: POST
Payload: {}
Response: 200 OK
{
	"database" : "none",
	"load":"ok"
}

Response: 503 Service Unavailable
{
	"database" : "ok",
	"load": "full",
    "lobbies": 3
}
Response: 503 Service Unavailable
{
	"database": "disconnected",
	"load":" ok"
}

```
### Gateway:
- Login
```
Endpoint: /login
Method: POST
Payload: {
    "email" : "user1@cemail.com",
    "password" : "password1"
}
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "is_banned": "false"
}
```
- Register
```
Endpoint: /register
Method: POST
Payload: {
    "email" : "user1@cemail.com",
    "password" : "password1"
}
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "is_banned": "false"
}
```

- Get User
```
Endpoint: /user/12345
Method: GET
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "is_banned": "false"
}
```

- Join Lobby
```
Endpoint: /join
Method: POST
Payload: {
    "id" : 12345
}
Response: 200 OK
{
    "lobby_link": ":59999/lobby/id234",
}
Response: 403 
{
    "reason" : "user_ban"
}
```

- Get all the games played by a user
```
Endpoint: /getGames/userid123/
Method: POST
Payload: 
{
    "userid" : "12345,
}
Response: 
{
    "lobby_number": 1234,
    "time_started": "2023-09-18",
    "time_ended": "2023-09-18",
    "winner": 12345,
    "players": [1234, 2617, 28394, 2637]
}
```

- Get User Friends
```
Endpoint: /user/12345/friends
Method: GET
Response: {
    friends:[
        {
            "id": 1671,
            "username": "user2",
            "rank" : 1,
        }
    ]
}
```

- Add friend 
```
Endpoint: /befriend/5678
Method: POST
Payload: {
    "id" : "12345,
}
Response: 201 OK
```

- Delete friend 
```
Endpoint: /unfriend/5678
Method: POST
Payload: {
    "id" : "12345,
}
Response: 201 OK
```

- Create Friend Lobby
```
Endpoint: /privatejoin
Method: POST
Payload: {
    "id" : 12345
    "friend_id" : [152636, 8494957, 12536]
}
Response: 200 OK
{
    "lobby_link": "/privatelobby/id234",
}

```

### Service Discovery:
- Service Registration
```
Endpoint: /register
Method: POST
Payload: {
    "type" : "game/user/lb/gate",
    "address" : "game-service-3",
    "internal_port": 7070,
    "external_port": 59800
}
Response: 201 Created
```

### Ranking Service:
- Login
```
Endpoint: /login
Method: POST
Payload: {
    "email" : "user1@cemail.com",
    "password" : "password1"
}
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "is_banned": "false"
}
```
- Register
```
Endpoint: /register
Method: POST
Payload: {
    "email" : "user1@cemail.com",
    "password" : "password1"
}
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "is_banned": "false"
}
```

- Get User
```
Endpoint: /user/12345
Method: GET
Response: {
    "id": 12345,
    "username": "user1",
    "rank" : 1,
    "isBanned": "false"
}
```

- Get User Friends
```
Endpoint: /user/12345/friends
Method: GET
Response: {
    friends:[
        {
            "id": 1671,
            "username": "user2",
            "rank" : 1,
        }
    ]
}
```


- Change Rank of User
```
Endpoint: /changeRank
Method: POST
Payload: {
    "id" : "12345",
    "value": -1256
}
Response: 200 OK
```

- Ban User
```
Endpoint: /banUser
Method: POST
Payload: {
    "id" : "12345",
}
Response: 200 OK
```
- Add friend 
```
Endpoint: /befriend/5678
Method: POST
Payload: {
    "friend_id" : "12345,
}
Response: 201 OK
```

- Delete friend 
```
Endpoint: /unfriend/5678
Method: POST
Payload: {
    "friend_id" : "12345,
}
Response: 201 OK
```
### Game Service:
- Join Lobby
```
Endpoint: /join
Method: POST
Payload: {
    "id" : 12345
}
Response: 200 OK
{
    "lobby_link": ":59999/lobby/id234",
}

Response: 403 
{
    "reason" : "user_ban"
}
```

- Create Friend Lobby
```
Endpoint: /privatejoin
Method: POST
Payload: {
    "id" : 12345
    "friendId" : [152636, 8494957, 12536]
}
Response: 200 OK
{
    "lobby_link": ":59999/privatelobby/id234",
}

```

- Lobby Endpoint (Direct longterm Websocket connection to the lobby)
```
Endpoint: /lobby/id234?userid=2
Accepted Payloads: 
```
```
Payload: 
{
    "id" : 1234,
    "move" : "put_card",
    "card": "red_reverse"
},
Response:
{
    "accepted": "true/false",
	"hand_cards": ["blue_2"],
	"current_card": "red_reverse",
    "next_user_id": 567
}

```
```

Payload:
{
    "id" : 1234,
    "move" : "take_card_4",
}
Response:
{
    "accepted": "true/false",
    "hand_cards": ["yellow_2", "red_plus2", "plus4", "color_change", "blue_2"],
	"current_card": "blue",
    "next_user_id": 567
}
```
```
Payload: 
{
    "id" : 1234,
    "move" : "put_card",
    "card": "color_change",
    "color": "red"
},
Response:
{
    "accepted": "true/false",
	"hand_cards": ["blue_2"],
	"current_card": "color_change",
    "next_user_id": 567
}
```


```
Payload: 
{
    "id" : 1234,
    "move" : "uno",
},
Response:
{
    "accepted": "true/false",
    "next_user_id": null,
    "winner_id": 1234
}

```
- Exit Lobby
```
Endpoint: /exit/lobbyid234/
Method: POST
Payload: {
    "userid" : "12345,
}
Response: 200 OK
```
- Get all the games played by a user
```
Endpoint: /getGames/userid123/
Method: POST
Payload: 
{
    "userid" : "12345,
}
Response: 
{
    "lobby_number": 1234,
    "time_started": "2023-09-18",
    "time_ended": "2023-09-18",
    "winner": 12345,
    "players": [1234, 2617, 28394, 2637]
}
```

Optional:
- Scale Up (Special endpoint sent by User Service when an uptick of users happens)
```
Endpoint: /scaleup
Method: POST
Payload: {
}
Response: 200 OK
Response: 503 Service Unavailable
```

## Deployment and Scaling
The services are expected to be deployed using Docker, with horizontal scaling being accounted for the User System and Game System. As the services are expected to be replicas, no Host port can be set within the Docker Compose file (Thanks v2), so the services are running requests to the Daemon to find their own ports. Please make sure in the docker settings that the tcp:2375 port is exposed to non tlc protected connections.
(Not good, but it is what it is)
## Bibliography

[1] [Peer to Peer vs Server Hosted Games](https://www.servers.com/news/blog/differences-between-peer-to-peer-and-dedicated-game-server-hosting) 

[2] [Designing a Distributed System for an Online Multiplayer Game — Architecture](https://theredrad.medium.com/designing-a-distributed-system-for-an-online-multiplayer-game-architecture-part-3-f9483ebbe5ac)

[3] [Global Gaming Servers: Typical System Design and Case Study](https://www.alibabacloud.com/blog/global-gaming-servers-2-typical-system-design-and-case-study_594582)

[4] [Exploring Architecture Building a Card Game](https://www.infoq.com/articles/exploring-architecture-building-game/)