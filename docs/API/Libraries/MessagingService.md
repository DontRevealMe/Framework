# MessagingService

!!! Accessibility
    This library can only be accessed by the server

Manages the sending and handling of packets across server.

## API

### Limitations

This is measured using ``HttpService:JSONEncode()``.

| Property | Limit |
|----------|-------|
| Packet size | 800 characters |
| Package size | 950 characters |

### Properties

None.

### Functions

| Function Name | Description | Returns |
|---------------|-------------|---------|
| ``RBXScriptConnection`` :SendAsync(``table`` data, ``string`` name ) | Sends a packet to other servers. | ``RBXScriptConnection`` |
| :ListenAsync() | Listens for a specific topic. | ``TopicListener`` |

### :SendAsync

| ``void`` :SendAsync(``string`` topic, ``Variant`` data) |
|----|
| Sends the given data to other servers in the form of a packet. |

!!! Warning
    If your packets exceed 800 characters, expect all other packets to be delayed by ``math.ceil(length / 800)``. Length is calculate by using HttpService:JSONEncode().

## How it works

### Packets

Packets are an internal OOP class which are comprised of properties that contain it's topic, data, and unique ID if the packet is a segment.

### Packages

Packages contain a group of packets and will be sent automically after a 1 second it has been created or they have reached the package size limit.

### Segments

In the odd case there is a packet larger than 800 characters, the server will attempt to split the packet data up into serveral segments. These segment packets will be sent through.
The con of this is that it may delay publishes by several seconds which is why it's reccomended that you try to keep data below 800 characters.

### SubChannels

The idea of SubChannel is to reduce the amount of Channels being listened onto. This means you could have 3 SubChannel Channels but have 10 packets firing through 10 channels.
The cons of a SubChannels is that they may have less capacity vs a normal channel since they also need to store the topic name.
