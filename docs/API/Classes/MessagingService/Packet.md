# Packet

Packets are used to hold data for MessagingService.There is currently no documentation for the packet class that is created by the packet module.

!!! Notice
    This is a recieving packet ie the packet that is passed through in a callback function. The packet that is created by a class hasn't been documented yet.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ``table`` Data | Contains data that the packet holds |
| ``string`` Name | If the packet is sent through a subchannel, it will have a name property. |
| ``string`` UID | If the packet is a segment, it will have a unique ID. |
| ``string`` Order | If the packet is a segment, it will have a string that contains it's order ie ``1/3``. |
