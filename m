From: Stuart Midgley <sdm900@gmail.com>
Date: Fri, 24 Jul 2009 14:21:36 +0800
Subject: [Lustre-devel] Mac OS and Windows clients
In-Reply-To: <20090723230340.GJ4231@webber.adilger.int>
References: <689C4F2B-8759-4B61-B2ED-39BCC194608C@swedisk.se>
	<1248382212.21455.5.camel@berloga.shadowland>
	<20090723230340.GJ4231@webber.adilger.int>
Message-ID: <01F08BE9-3AE5-4A0B-9DC4-84A4BE9BD8B8@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We started with the partial AIX port and got someway but never got a  
working Fuse port.  If I remember correctly, it was just a matter of  
working through the code and hooking it correctly to MacOSX which does  
things slightly differently.

Sorry
Stu.


-- 
Dr Stuart Midgley
sdm900 at gmail.com



On 24/07/2009, at 7:03 AM, Andreas Dilger wrote:

> On Jul 23, 2009  23:50 +0300, Alexey Lyashkov wrote:
>> On Thu, 2009-07-23 at 10:00 +0200, Tuve Nordius wrote:
>>> I have chosen the FreeBSD port of lustre (http://lustre.sev.net.ua/)
>>> as a starting point for liblustre and the source tree also contains
>>> some kind of fuse client, but i suspect this port is based on lustre
>>> 1.6 ?
>>
>> Isn't. this based on HEAD branch which checkouted ~4 month ago.  
>> When i
>> will have time, i will be update to last HEAD sources.
>> Work on FreeBSD client is stoped to wait some work from CLIO and  
>> libcfs
>> cleanups, which need to make Solaris port.
>
> Also, Stuart Midgeley (CC'd) worked on a FUSE client for OS/X.  I  
> don't
> know the current status of that (I'm not sure if it was made available
> for wider use or not).
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
