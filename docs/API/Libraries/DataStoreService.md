# DataStoreService

!!! Accessibility
    This library can only be accessed by the server

!!! Warning
    DataStoreService will soon be [overhauled](https://github.com/DontRevealMe/Framework/issues/6). So there isn't documentation for it.
    Any documentation that does appear, it will be for the overhauled version.

## API

### Properties

| Property Name | Description |
|---------------|-------------|
| ``table`` _cache ``[internal]`` | Contains cache of all DataStores. |

### Functions

| Function Name | Description | Returns |
|---------------|-------------|---------|
| ``NormalDataStore``/``OrderedBackups``/``OrderedDataStore`` .new(``string`` name, ``string`` key, ``string`` callingMethod) | Creates a new DataStore class. | ``DataStore``/``OrderedBackup``/``OrderedDataStore`` |

### .new

| ``NormalDataStore``/``OrderedBackups``/``OrderedDataStore`` .new(``string`` name, ``string`` key, ``string`` callingMethod) |
|----------------------------------------------------------------------------------------------------------------------|
| Constructor function to create a new class. It's class depends on your callingMethod argument. |

## Calling Methods

### NormalDataStores

This is your average normal DataStore saving system. It uses :UpdateAsync() to overwrite existing keys.

### OrderedDataStores

This is your average OrderedDataStore saving system. Uses Roblox's OrderedDataStores.

### OrderedBackups

!!! Notice
    It's highly reccomended you use this method to store player data as it drastically lowers the risk of data loss. Using NormalDataStores might be better suited for non-player data.

This uses Berezaa's saving method. The idea is that you'll make a new key each time you save and store the key that you used to save it in a OrderedDataStore. When you need to retrive the key, you'll use :GetSortedAsync() to retrive the latest the key and use that to get the lastest data. This is all done automatically when you pass through "OrderedBackups" as your savingMethod.
