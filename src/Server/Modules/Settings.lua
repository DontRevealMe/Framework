return {
    DataStoreService = {
        SaveInStudio = true; --    Save data in studio. Due to :BindToClose() being buggy, it can result to wait times of 30 seconds before studio even shuts down. 
    },
    MessagingService = {
        UseSubChannels = true; --    Have channels enabled on by default.
        TotalSubChannels = 3; --    Total channels that will be reserved for subchannels.
        SizeLimits = {
            DataSize = 800; --  Maximum size of inputted data.
            PacketSize = 850; --  Maximum size of a packet. The difference between DataSize and PacketSize will generally be the max size for your name if you're using subchannels.
            PackageSize = 950; --   Maximum size of a package. 
        },
        MaxPackageAttempts = 5; -- Maximum failed attempts for a package in queue to be dropped.
    }
}