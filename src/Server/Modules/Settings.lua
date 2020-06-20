return {
    DataStoreService = {
        SaveInStudio = true; --    Save data in studio. Due to :BindToClose() being buggy, it can result to wait times of 30 seconds before studio even shuts down. 
    },
    MessagingService = {
        UseSubChannels = true; --    Have channels enabled on by default.
        TotalSubChannels = 3; --    Total channels that will be reserved for subchannels.
    }
}