# ChannelListener

Listens onto MessagingService channels. This class is not commonly used but is still documented. It's mainly internal.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ``string`` Name | Name of what channel the listener is listening onto. |
| ``Signal`` OnRecievedSignal | Signal will fire when the channel recieves a packet. |
| ``Maid`` _maid | Maid class to help clean up the listener if the Destroy method is called. |
| ``RBXScriptConnection`` Connection | Connection that is connected to SubscribeAsync. |

### Methods

| Method Name | Description |
|-------------|-------------|
| ``RBXScriptConnection`` :Connect(``bool`` getCompleteOnly, ``Function`` callbackFunction) | Connects the function to the listener. |
| ``void`` :Destroy() | Destroys the listener class. |
