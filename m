From: James Simmons <jsimmons@infradead.org>
Date: Wed, 9 Jan 2019 18:28:27 +0000 (GMT)
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <9BDCA6A9-A826-49A7-9126-BC1DCC96AC1D@whamcloud.com>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
 <9BDCA6A9-A826-49A7-9126-BC1DCC96AC1D@whamcloud.com>
Message-ID: <alpine.LFD.2.21.1901091734180.18138@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> This might be because the upstream Lustre doesn't allow setting per-process
> >> JobID via environment variable, only as a single per-node value.  The real
> >> unfortunate part is that the "get JobID from environment" actually works for
> >> every reasonable architecture (even the one which was originally broken
> >> fixed it), but it got yanked anyway.  This is actually one of the features
> >> of Lustre that lots of HPC sites like to use, since it allows them to track
> >> on the servers which users/jobs/processes on the client are doing IO.
> > 
> > To give background for Neil see thread:
> > 
> > https://lore.kernel.org/patchwork/patch/416846
> > 
> > In this case I do agree with Greg. The latest jobid does implement an
> > upcall and upcalls don't play niece with containers. Their is also the
> > namespace issue pointed out. I think the namespace issue might be fixed
> > in the latest OpenSFS code.
> 
> I'm not sure what you mean?  AFAIK, there is no upcall for JobID, except
> maybe in the kernel client where we weren't allowed to parse the process
> environment directly.  I agree an upcall is problematic with namespaces,
> in addition to being less functional (only a JobID per node instead of
> per process), which is why direct access to JOBENV is better IMHO.

I have some evil ideas about this. Need to think about it some more since
this is a more complex problem.
 
> > The whole approach to stats in lustre is
> > pretty awful. Take jobstats for example. Currently the approach is
> > to poll inside the kernel at specific intervals. Part of the polling is 
> > scanning the running processes environment space. On top of this the 
> > administor ends up creating scripts to poll the proc / debugfs entry. 
> > Other types of lustre stat files take a similar approach. Scripts have
> > to poll debugfs / procfs entries.
> 
> I think that issue is orthogonal to getting the actual JobID.  That is
> the stats collection from the kernel.  We shouldn't be inventing a new
> way to process that.  What does "top" do?  Read a thousand /proc files
> every second because that is flexible for different use cases.  There
> are much fewer Lustre stats files on a given node, and I haven't heard
> that the actual stats reading interface is a performance issue.

Because the policy for the linux kernel is not to add non processes 
related information in procfs anymore. "top" reads process information
from procfs which is okay. This means the stats lustre generates are
required to be placed in debugfs. The problem their is you need to be
root to access this information. I told the administrator about this
and they told me in no way will they run an application as root just
to read stats. We really don't want to require users to mount their
debugfs partitions to allow non root uses to access it. So I looked 
into alteranatives. Actually with netlink you have far more power for 
handling stats then polling some proc file. Also while for most cases the 
stat files are not huge in general but if we do end up having a stat 
seq_file with a huge amount of data then polling that file can really 
spike the load on an node. 

> > I have been thinking what would be a better approach since I like to
> > approach this problem for the 2.13 time frame. Our admins at my work
> > place want to be able to collect application stats without being root.
> > So placing stats in debugfs is not an option, which we currently do
> > the linux client :-( The stats are not a good fit for sysfs. The solution 
> > I have been pondering is using netlink. Since netlink is socket based it 
> > can be treated as a pipe. Now you are thinking well you still need to poll 
> > on the netlink socket but you don't have too. systemd does it for you :-)  
> > We can create systemd service file which uses
> 
> For the love of all that is holy, do not make Lustre stats usage depend
> on Systemd to be usable.

I never write code that locks in one approach ever. Take for example the
lctl conf_param / set_param -P handling with the move to sysfs. Instead
of the old upcall method to lctl now we have a udev rule. That rule is not
law!!! A site could create their own udev rule if they want to say log
changes to the lustre tunables. Keep in mind udev rules need to be simple
since they block until completed much like upcalls do. If you want to
run a heavy application you can create a system.d service to handle the
tunable uevent. If you are really clever you can use dbus to send that
the tuning event to external nodes. Their are many creative options.

The same is true with the stats netlink approach. I was up late last night
pondering a design for the netlink stats. I have to put together a list
of my ideas and run it by my admins. So no systemd is not a hard 
requirment. Just an option for people into that sort of thing. Using
udev and netlink opens up a whole new stack to take advantage of.
