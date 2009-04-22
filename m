From: Nic Henke <nic@cray.com>
Date: Wed, 22 Apr 2009 17:20:10 -0500
Subject: [Lustre-devel] faking LNET scale
In-Reply-To: <20090422213746.GZ6559@sun.com>
References: <49E8B7E9.5080101@cray.com> <20090422213746.GZ6559@sun.com>
Message-ID: <49EF981A.6030802@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Isaac Huang wrote:
> On Fri, Apr 17, 2009 at 12:10:01PM -0500, Nicholas Henke wrote:
>   
>> ......
>> However, to do this either hacking up lnet_ptlcompat_matchXXX to look at another 
>> flag besides the_lnet.ln_ptlcompat or some other way of allowing a server with a 
>> single NET (ptl0) to accept requests from a variety of nets (ptl1, ptl2, etc). 
>> One cannot use multiple interfaces for the same net type with ln_ptlcompat enabled.
>>     
>
> Note that Portals compatibility (lnet_ptlcompat_, the_lnet.ln_ptlcompat, and friends)
> have already been removed from lnet HEAD, on which all 2.x and future releases will 
> be based.
>
>   
>> 	Is there a better way to do this ? What would be the least abusive of th e rules ?
>>     
>
> If you only have limited number of test nodes, one way to drive the
> network as hard as possible is to have all nodes use a very high
> ptllnd peercredits option and run LST test with a high concurrency
> (with the latest LST patch from 15332).
>
> Thanks,
> Isaac
>   
I was more interested in scaling the number of peers/connections. The
previous suggestion about doing a localnet check would help do that. 
From past experience, we don't often find too many issues just getting
the data moving when changing to higher scale - it is all the mgmt of
peers/connections that end up getting 'fun'.

As you say - just using higher credits is usually sufficient to max out
the network throughput for a given set of nodes.


Nic
