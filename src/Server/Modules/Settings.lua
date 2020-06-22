return {
    DataStoreService = {
        SaveInStudio = true; --  Save data in studio. Due to :BindToClose() being buggy, it can result to wait times of 30 seconds before studio even shuts down.
        OnUpdateMessaging = true; ---  If the Framework's OnUpdate is enabled.
    },
    MessagingService = {
        DefaultSubChannels = {
            Enabled = false; --  If default subchannels should be on
            Amount = 3; --  Amount of default subchannels
        },
        SizeLimits = {
            DataSize = 800; --  Maximum size of inputted data.
            PacketSize = 850; --  Maximum size of a packet. The difference between DataSize and PacketSize will generally be the max size for your name if you're using subchannels.
            PackageSize = 950; --   Maximum size of a package. 
        },
        MaxFailedAttempts = 5; --   Maximum failed attempts for a package in queue to be dropped.
    },
}