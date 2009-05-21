From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 May 2009 15:46:20 +0100 (BST)
Subject: [Lustre-devel] new to lustre and bug 18539
Message-ID: <alpine.LFD.2.00.0905191416100.22823@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hello!!

	As you can tell I'm new to this project but I'm looking forward to 
contributing. Recently I have worked on some patch for the lustre utilies 
and I'm now looking to the core file system code. 
	For my first dive into the code I'm tackling bug 18539. Of course 
looking at the code base opened up alot of questions. Looking at what was
recommended by Andreas Dilger was to make use of the oscc_flags. The other 
part of the solution was to bump up the return value of osc_precreate.
	My first set of questions delas with the places where the 
oscc_flag is used in some fashion. I noticed one spot for its use was 
osc_set_info_async. Looking through the code it appears to be only called 
by a osc shrink grant which itself appears to happen on a osc disconnect.
This is correct or is this function used in other places? The next 
question is about osc_import_events. Does this function handle events 
coming from multiple sources, clients, mds, ost? Also are these events
the type that are sent out when a state changes versus someone sending a 
rpc to request the state? 
	My second set of questions deals with osc_statfs*. From the notes
in the bugzilla osc_statfs_interpret is a MDS side function. Looking at 
the code I noticed it is the call back to osc_statfs_async. Knowing 
that osc_statfs_async is a obd_ops and thus has a wrapper, obd_statfs_async.
I scanning the code for this and noticed that this wrapper used with the 
proper obd_device for the osc was used in the lov layer. The two areas in 
the lov layer where lov_statfs_async and qos_statfs_update handled this.
If I remember right this is on the client side of the code. Where does the 
mds fit into this? Lov_statfs_async is for when the client queries data 
about the file. Whereas qos_statfs_update is what is called durning 
inital file create or when the statfs info is to old. Please correct me if 
I'm wrong. 
