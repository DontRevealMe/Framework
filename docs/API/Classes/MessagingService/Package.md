# Package

Packages contain multiple packets classes.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ``string`` Name | Contains the name of package. |
| ``table`` Packets | Contains all the packets stored. |
| ``number`` Size | Size of the all the packets. |

### Methods

| Method Name | Description |
|-------------|-------------|
| ``void`` :Destroy() | Destroys the class. |
| ``void`` :FireAllResponses(``Variant`` data) | Fires a packet response signals. |
| ``number`` :GetSize() | Gets the size of all the packet datas. |
| ``bool`` :AddPacket(``Packet`` packet, ``bool`` check) | Adds a packet to the package. If check is set to true, it will check if there is room or not and if there isn't, it will return false. |
| ``void`` :Send(``bool`` dontReplace) | Sends the package and puts it in the SendQueue. If dontReplace is set to true, it won't automically replaced the package in currentlyBoxing. |
