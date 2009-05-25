From: Andreas Dilger <adilger@sun.com>
Date: Mon, 25 May 2009 16:48:15 -0600
Subject: [Lustre-devel] bz-18539 and osc_statfs_interpret
In-Reply-To: <alpine.LFD.2.00.0905221738460.28089@casper.infradead.org>
References: <alpine.LFD.2.00.0905221738460.28089@casper.infradead.org>
Message-ID: <20090525224814.GK19035@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 22, 2009  18:21 +0100, James Simmons wrote:
> Form bugzilla the approach recommended to set the oscc_flag was to use
> the MDS-side code in osc_statfs_interpret(). First question is why this 
> approach instead of defining a new osc_import_event. On the OST we will 
> be setting the state with something like: 
> 
> /proc/fs/lustre/obdfilter/*/degraded_raid 
> 
> So the flow will be from the OST to the OSC. Just curious why it is not 
> done this way.

The reason osc_import_event can't be used is that this is only a local
event notification.  The "degraded_raid" state will be set on the OSS
node, while the osc_import_event can only be called on the client node
(in this case the MDS).

> 	The second question deals with setting the oscc_flag from 
> osc_statfs_interpret. After looking at the code I noticed oscc_flag is a 
> field in struct osc_creator. The only place I could find osc_creator was
> in struct client_obd which I could only find in struct obd_device or
> struct osc_brw_async_args which we are not using for this. 
> 	Now for struct osc_async_args which is passed into 
> osc_statfs_interpret just contains a pointer to struct obd_info. Looking
> at the components for struct obd_info I don't see a easy way to get the 
> proper obd_device to get the client_obd I need. What am I missing? 

You can get the struct obd_device pointer for the OBD in question via
req->rq_export->exp_obd and get the proper struct osc_creator from that

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
