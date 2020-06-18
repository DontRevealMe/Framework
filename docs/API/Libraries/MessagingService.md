# MessagingService

!!! Warning
    This library can only be accessed by the server.

Framework for handling the recieving and sending of data through messaging service.

## How it works

The framework's MessagingService works by treating send requests as packets. These packets are put into a ```package``` and are sent all at once. A package will generally hold as many packets possible until it reaches the 800 character limit.
If your packet exceeds the 800 character limit, it will generally be broken up into multiple packets and sent overtime.

!!! Warning
    Packets that exceed the 800 character limit may have longer send times. This will also affect other packages waiting in queue awaiting to be sent.

## API

### Functions

| Function Name | Description | Returns |
|---------------|-------------|---------|
| ```void``` :SendAsync(```table``` data=```nil```, ```string``` name=```nil``` ```[optional]```) | Generates a new MessagingService class. | Returns a ```MessagingService``` class. |
