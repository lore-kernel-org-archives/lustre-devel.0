From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 18 Dec 2008 12:15:06 -0800
Subject: [Lustre-devel] imperative recovery
In-Reply-To: <046101c95ef4$2fe3a8d0$8faafa70$@com>
References: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
	<046101c95ef4$2fe3a8d0$8faafa70$@com>
Message-ID: <494AAF4A.4030304@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
>
>> Other options I've thought of to explore this idea:
>>
>> - MGS notifies clients (somehow) after a server has restarted.
>>     
This seems like a no-brainer easy win today, and doesn't depend on any 
advanced features like message priority.  The only scalability issue 
would seem to be the broadcast of the message to all clients, but this 
is no different than the current broadcast mechanism the MGS employs to 
update client configs.  The message from the MGS would be taken as a 
suggestion, "Why don't y'all time out all your current RPCs since I 
noticed OST0004 restarted.  Oh, and use failover nid #2."  Current 
replay/recovery need not be touched.
