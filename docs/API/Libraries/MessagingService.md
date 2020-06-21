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

!!! Warning
    If your packets exceeds the packet size limit, not the data size limit, expect all other packets to be delayed by ``math.ceil(length / 800)`` seconds. Length is calculate by using HttpService:JSONEncode().

### Properties

None.

### Functions

| Function Name | Description | Returns |
|---------------|-------------|---------|
| ``Promise`` :SendAsync(``table`` data, ``string`` name, ``bool`` subChannels=``nil`` ``[optional]``) | Sends data to other servers. | ``RBXScriptConnection`` |
| ``RBXScriptConnection`` :Listen(``string`` name, ``bool`` getComplete=``true`` ``[optional]``, ``bool`` subChannels=``true`` ``[optional]``, ``Function`` callback) | Listens for a specific channel. | ``TopicListener`` |

### :SendAsync

| ``Promise`` :SendAsync(``table`` data, ``string`` name, ``bool`` subChannels=``false`` ``[optional]``) |
|----|
| Sends data to other servers. ``subChannels`` argument is used to determine whether or not the packet will be sent through a subchannel channel. |

### Listen

| ``RBXScriptConnection`` :Listen(``string`` name, ``bool`` getComplete=``true`` ``[optional]``, ``bool`` subChannels=``true`` ``[optional]``, ``Function`` callback) |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Listens for a specfiic channel. ``getComplete`` argument means it will only recieve complete packets and not segment packets. ``subChannels`` argument means whether or not the listener will listen onto subchannels instead of regular channels. Callback will be passed arguments such as ``data``, ``timeSent``, and ``packet``. |

#### Callback arguments

Everytime a packet is sent, the callback function will be passed the following arguments:

| Argument | Description |
|----------|-------------|
| ``table`` data | The data of the packet. |
| ``number`` timeSent | The UNIX time of when the packet was sent. |
| ``Packet`` packet | The packet itself. It may contain information about the packet's UID, topic, and etc... See [Packet](../../Classes/MessagingService/Packet) for more info |

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
