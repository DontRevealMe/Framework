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

Packages contain a group of packets and will be sent automically after a 1 second it has been created. Packages can only contain at most, 850 data in length, but each packet is restricted to 800 characters.

### Segments

In the odd case there is a packet larger than 800 characters, the server will attempt to split the packet data up into serveral segments. These segment packets will be sent through.
The con of this is that it may delay publishes by several seconds which is why it's reccomended that you try to keep data below 800 characters.

### Channels

If a value isn't passed in for the ``topic`` argument, the message/listener will use channels. These channels have the bonus of not eating into your subscribe limit, but have a con of less storage due to how they store topic as data.
On default settings, there are 3 MessagingService channels. Due to each topic having a throttle limit, we split it across 3 channels. Of course, this method is not fool proof but it helps lower the chances of a throttle.
If you go higher, you may run into the risk of throttling the Subscribe limit which can break MessagingService.

!!! Warning
    ``FrameworkChannel[NUMBER]`` is reserved. You'll be fine if you use a topic called "FrameworkChannelABC" as it's not using a number at the end, but you really shouldn't be doing that.
