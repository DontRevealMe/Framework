# SubChannelsManager

Manages SubChannelsChannels. SubChannelsManager manage SubChannelChannels which are in charge of listening on each channel.
So if you pass in "MyManager" as your name, and add 3 ChannelListeners, you'll end up with each channelistener listening on "MyManager1", "MyManager2", and etc...

## API

### Properties

| Propety name | Description |
|--------------|-------------|
| ``string`` Name | Name of SubChannelChannels that the class is listening onto. |
| ``table`` ChannelListeners | A table containing all the channel listeners. |
| ``table`` _listeners | Contains all connections that are connected to the class. |
| ``Maid`` _maid | Maid class to help clean up garbage. |
| ``Signal`` _onPacketRecieved | Will fire when one of the SubChannelsChannel Listener recives a packet. |
| ``RBXScriptSignal`` OnPacketReieved | The event class of the signal class. |

### Methods

| Method Name | Description | Returns |
|-------------|-------------|---------|
| ``void`` :Add(``integer`` amount) | Adds listeners to the class. |