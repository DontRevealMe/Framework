# Packet

Packets are used to hold data for MessagingService. Please note this is the recieving packet. There is currently no documentation for the packet class that is created by the packet module.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ``table`` Data | Contains data that the packet holds |
| ``string`` Topic | If the packet is sent through a subchannel, it will have a topic property. |
| ``string`` UID | If the packet is a segment, it will have a unique ID. |
| ``string`` Order | If the packet is a segment, it will have a string that contains it's order ie ``1/3``. ]
