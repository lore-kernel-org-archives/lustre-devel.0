From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Fri, 22 May 2009 11:25:41 -0400
Subject: [Lustre-devel] new to lustre and bug 18539
In-Reply-To: <alpine.LFD.2.00.0905221406320.28089@casper.infradead.org>
References: <alpine.LFD.2.00.0905191416100.22823@casper.infradead.org>
	<EDB5B425-FEE9-43EA-B0B5-C082367D43DE@sun.com>
	<alpine.LFD.2.00.0905221406320.28089@casper.infradead.org>
Message-ID: <2AC331CC-827A-4266-809D-85CE6756E717@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On May 22, 2009, at 9:29 AM, James Simmons wrote:

>>> 	My second set of questions deals with osc_statfs*. From the notes
>>> in the bugzilla osc_statfs_interpret is a MDS side function.  
>>> Looking at
>>> the code I noticed it is the call back to osc_statfs_async. Knowing
>>> that osc_statfs_async is a obd_ops and thus has a wrapper,  
>>> obd_statfs_async.
>>> I scanning the code for this and noticed that this wrapper used  
>>> with the
>>> proper obd_device for the osc was used in the lov layer. The two  
>>> areas in
>>> the lov layer where lov_statfs_async and qos_statfs_update handled  
>>> this.
>>> If I remember right this is on the client side of the code. Where  
>>> does the
>>> mds fit into this? Lov_statfs_async is for when the client queries  
>>> data
>> MDS is a client to OSTs, that's why it has client bits to deal with  
>> them
>> (LOV and OSCs).
> Because the lov is present also on the MDS as well as the client  
> then the
> callback, aa->aa_oi->oi_cb_up, is going to depend on it being a MDS  
> or a
> cleint. Correct or am I wrong?

Actually what I see in the code is LOV always assigns the same value,  
so it
should be the same. On the other hand it is a possibility to pass down  
such a callback
from a layer above LOV, then it might be different.

Bye,
     Oleg
