---
layout: post
title: Using async await and TcpClient TcpServer
categories: .net tcp game

---

Some time ago, I tried to implement a simple tcp server using the System.Net.Sockets classes, TcpClient and TcpServer. While building a synchronous server was straight forward, it was a little awkward to use the old Begin/End async methods. Having to use callbacks for everything asynchronous leads to more methods and harder to read code.

For instance, accepting new clients might look something like this

{% prism csharp %}
private TcpListener _listener;
private void AcceptNewClients()
{
    _listener.BeginAcceptTcpClient(EndAcceptNewClients, null);
}

private void EndAcceptNewClients(IAsyncResult ar)
{
    var client = _listener.EndAcceptTcpClient(ar);
    var player = new Player(client);
    PlayerQueue.Enqueue(player);
    ActivePlayers.TryAdd(player.Id, player);
}
{% endprism %}

It doesn't look too bad, but once you start considering variable scopes and error handling, the callback method approach starts to feel like a burden.

{% prism csharp %}
private async void AcceptNewClients()
{
    var listener = new TcpListener(IPAddress.Any, Port);
    while (true)
    {
        TcpClient client = await listener.AcceptTcpClientAsync();
        var player = new Player(client);
        PlayerQueue.Enqueue(player);
        ActivePlayers.TryAdd(player.Id, player);
    }
}
{% endprism %}

Using the new async keyword on my method, I can simply use await and the Async method to inline the callback. These two pieces are functionally equivalent. Its important to realize that when we await the AcceptTcpClientAsync method, our code does not block the thread, so other useful things can continue running while the connection is established. 

If you're interested in seeing more on async await or TcpClient/TcpListener take a look at the TcpSample repository on my github. The biggest takeaway I had from working on this project was that async only starts to show its benefits when you are dealing with longer running external tasks and that debugging multi threaded programs is hard.