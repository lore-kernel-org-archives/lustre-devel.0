From: Nicholas Henke <nic@cray.com>
Date: Fri, 09 Jan 2009 13:43:42 -0600
Subject: [Lustre-devel] imperative recovery
In-Reply-To: <C8209894-129B-4115-94BC-0F4B80EFADCE@sun.com>
References: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
	<046101c95ef4$2fe3a8d0$8faafa70$@com>
	<494AAF4A.4030304@sun.com> <49676CF9.5050805@cray.com>
	<C8209894-129B-4115-94BC-0F4B80EFADCE@sun.com>
Message-ID: <4967A8EE.2030102@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Robert Read wrote:
> 
> On Jan 9, 2009, at 07:27 , Nicholas Henke wrote:

>>
>> I do think this will miss a significant case: combo MGS+MDS. A 
>> majority of our
>> customers are deploying with this configuration. Perhaps exposing this 
>> mechanism
>> on the clients via a /proc file would be enough - that way a failover 
>> framework
>> could manually trigger the timeout and/or nid switching.
> 
> Yes, exactly what I was thinking. Exposing this feature via proc (or 
> lctl) on the clients is the first step. It's has minimal impact, 
> requires no changes to the server, and should integrate well with 
> existing failover frameworks.  We also need to get the server to end 
> recovery sooner (without waiting for all the stale exports), but VBR 
> should help with that.
> 
> robert

FWIW: we'd prefer /proc. We don't ship lctl on our computes for memory 
(initramfs) usage reasons. Being in /proc makes it easy for someone to use the 
functionality from another kernel module as well; we can just call the .read or 
.write functions directly.

Nic
