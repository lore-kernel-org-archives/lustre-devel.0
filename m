From: James Simmons <jsimmons@infradead.org>
Date: Fri, 22 May 2009 18:21:07 +0100 (BST)
Subject: [Lustre-devel] bz-18539 and osc_statfs_interpret
Message-ID: <alpine.LFD.2.00.0905221738460.28089@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Form bugzilla the approach recommended to set the oscc_flag was to use
the MDS-side code in osc_statfs_interpret(). First question is why this 
approach instead of defining a new osc_import_event. On the OST we will 
be setting the state with something like: 

/proc/fs/lustre/obdfilter/*/degraded_raid 

So the flow will be from the OST to the OSC. Just curious why it is not 
done this way.

	The second question deals with setting the oscc_flag from 
osc_statfs_interpret. After looking at the code I noticed oscc_flag is a 
field in struct osc_creator. The only place I could find osc_creator was
in struct client_obd which I could only find in struct obd_device or
struct osc_brw_async_args which we are not using for this. 
	Now for struct osc_async_args which is passed into 
osc_statfs_interpret just contains a pointer to struct obd_info. Looking
at the components for struct obd_info I don't see a easy way to get the 
proper obd_device to get the client_obd I need. What am I missing? 
 
  
