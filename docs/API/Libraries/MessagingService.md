# MessagingService

!!! Notice
    This library can only be accessed by the server

Manages the sending and handling of packets across server.

## How it works

### Packets

Packets are an internal OOP class which are comprised of properties that contain it's topic, data, and unique ID if the packet is a segment.

### Packages

Packages contain a group of packets and will be sent automically after a 1 second it has been created. Packages can only contain at most, 850 data in length, but each packet is restricted to 800 characters.

### Segments

In the odd case there is a packet larger than 800 characters, the server will attempt to split the packet data up into serveral segments. These segment packets will be sent through.
The con of this is that it may delay publishes by several seconds which is why it's reccomended that you try to keep data below 800 characters.

## API

### Functions

| Function Name | Description | Returns |
|---------------|-------------|---------|
| :SendAsync() | Sends a packet to other servers. | ``void`` |
| :ListenAsync() | Listens for a specific topic. | ``TopicListener`` |

### :SendAsync

| ``void`` :SendAsync(``string`` topic=nil, ``Variant`` data=nil) |
|----|
| Sends the given data to other servers in the form of a packet. |

!!! Warning
    If your packets exceed 800 characters, expect all other packets to be delayed by ``math.ceil(length / 800)``. Length is calculate by using HttpService:JSONEncode().
