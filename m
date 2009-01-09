From: Robert Read <rread@sun.com>
Date: Fri, 09 Jan 2009 09:04:59 -0800
Subject: [Lustre-devel] imperative recovery
In-Reply-To: <49676CF9.5050805@cray.com>
References: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
	<046101c95ef4$2fe3a8d0$8faafa70$@com> <494AAF4A.4030304@sun.com>
	<49676CF9.5050805@cray.com>
Message-ID: <C8209894-129B-4115-94BC-0F4B80EFADCE@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jan 9, 2009, at 07:27 , Nicholas Henke wrote:

> Nathaniel Rutman wrote:
>> Eric Barton wrote:
>>>> Other options I've thought of to explore this idea:
>>>>
>>>> - MGS notifies clients (somehow) after a server has restarted.
>>>>
>> This seems like a no-brainer easy win today, and doesn't depend on  
>> any
>> advanced features like message priority.  The only scalability issue
>> would seem to be the broadcast of the message to all clients, but  
>> this
>> is no different than the current broadcast mechanism the MGS  
>> employs to
>> update client configs.  The message from the MGS would be taken as a
>> suggestion, "Why don't y'all time out all your current RPCs since I
>> noticed OST0004 restarted.  Oh, and use failover nid #2."  Current
>> replay/recovery need not be touched.
>
> This would be a great enhancement for OSS failover or reboot, it is  
> really the
> only way we'll get to recovery times under ~2.5 x obd_timeout.  
> Adaptive Timeouts
> really aren't buying us much here, as at scale and under load we are  
> seeing the
> timeouts approach the usual static obd_timeout of 300s. It only  
> takes one client
> with a higher timeout to push the recovery time out.
>
> I do think this will miss a significant case: combo MGS+MDS. A  
> majority of our
> customers are deploying with this configuration. Perhaps exposing  
> this mechanism
> on the clients via a /proc file would be enough - that way a  
> failover framework
> could manually trigger the timeout and/or nid switching.

Yes, exactly what I was thinking. Exposing this feature via proc (or  
lctl) on the clients is the first step. It's has minimal impact,  
requires no changes to the server, and should integrate well with  
existing failover frameworks.  We also need to get the server to end  
recovery sooner (without waiting for all the stale exports), but VBR  
should help with that.

robert

>
>
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
