From: Ben Evans <Ben.Evans@terascala.com>
Date: Tue, 27 Jul 2010 14:03:38 -0400
Subject: [Lustre-devel] Lnet routing preferences
Message-ID: <2C7DE72B9BD00F44BAECA5B0CBB87395C3F4A6@hermes.terascala.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I've been poking around and experimenting with the luster internals on
my own, and ran into a question that I haven't been able to track down.

 

For MDS/OSS communications, where there are multiple possible paths
(Ethernet, IB, etc.) how does LNET (or Lustre) decide which interface to
send messages?

 

Ideally, I'd like to send server-to-server messages over a private
network and let the clients communicate over the public network.

 

I'm interested in finding out if there are any gains to be made from a
setup like this.

 

Thanks

 

-Ben Evans  

ben at terascala.com

Terascala, inc.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100727/66db2f23/attachment.htm>
