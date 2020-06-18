# Queue Class

The queue class is a class that makes the creation and handling of queues much easier.
It also has performance improvements by yielding the couroutine loop when it has finished all of the queue.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ```table``` Queue | Table containing the queue. |
| ```internal``` ```Signal``` _wakeUp | Wakes up the queue coroutine. |
| ```internal``` ```Coroutine``` _updateCoroutine | The couroutine function that is in charge of managing the queue. |

### Methods

| Method Name | Description |
|---------------|-------------|
| ```void``` :Dequeue(```integer``` index) | Removes a specific index from the queue. |
| ```void``` :Enqueue(```Variant``` value) | Adds passed value into the queue. |
| ```void``` :SetUpdater(```Function``` updater) | Function that will be called each time the next slot in the queue is ready. Function will be given the current front most value. |