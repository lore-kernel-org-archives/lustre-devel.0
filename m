From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 9 Jan 2019 00:15:45 +0000
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
Message-ID: <9BDCA6A9-A826-49A7-9126-BC1DCC96AC1D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 14:47, James Simmons <jsimmons@infradead.org> wrote:
> 
>>>> sanity: FAIL: test_104b lfs check servers test failed
>>> 
>>> sysfs bug. I have a patch for this.
>>> 
>>>> sanity: FAIL: test_130a filefrag /mnt/lustre/f130a.sanity failed
>>>> sanity: FAIL: test_130b filefrag /mnt/lustre/f130b.sanity failed
>>>> sanity: FAIL: test_130c filefrag /mnt/lustre/f130c.sanity failed
>>>> sanity: FAIL: test_130e filefrag /mnt/lustre/f130e.sanity failed
>>>> sanity: FAIL: test_130f filefrag /mnt/lustre/f130f.sanity failed
>>> 
>>> What version of e2fsprog are you running? You need a 1.44 version and
>>> this should go away.
>> 
>> To be clear - the Lustre-patched "filefrag" at:
>> 
>> https://downloads.whamcloud.com/public/e2fsprogs/1.44.3.wc1/
>> 
>> Once Lustre gets into upstream, or convince another filesystem to use the
>> Lustre filefrag extension (multiple devices, which BtrFS and XFS could
>> use) we can get the support landed into the upstream e2fsprogs.
> 
> I swore that Ubuntu18 testing passed with the default e2fsprogs (1.44.4).
> To let Neil know, this is why lustre_fiemap.h exist in the uapi headers 
> directory. This kind of functionality would help the community at large.

The returned data is identical for single-striped files, so the vanilla
filefrag will work on Lustre in the common case.

>>>> sanity: FAIL: test_160a changelog 'f160a.sanity' fid  != file fid [0x240002342:0xd:0x0]
>>>> sanity: FAIL: test_161d cat failed
>>> 
>>> Might be missing some more changelog improvements.
>>> 
>>>> sanity: FAIL: test_205 No jobstats for id.205.mkdir.9480 found on mds1::*.lustre-MDT0000.job_stats
>>> 
>>> Strange?
>> 
>> This might be because the upstream Lustre doesn't allow setting per-process
>> JobID via environment variable, only as a single per-node value.  The real
>> unfortunate part is that the "get JobID from environment" actually works for
>> every reasonable architecture (even the one which was originally broken
>> fixed it), but it got yanked anyway.  This is actually one of the features
>> of Lustre that lots of HPC sites like to use, since it allows them to track
>> on the servers which users/jobs/processes on the client are doing IO.
> 
> To give background for Neil see thread:
> 
> https://lore.kernel.org/patchwork/patch/416846
> 
> In this case I do agree with Greg. The latest jobid does implement an
> upcall and upcalls don't play niece with containers. Their is also the
> namespace issue pointed out. I think the namespace issue might be fixed
> in the latest OpenSFS code.

I'm not sure what you mean?  AFAIK, there is no upcall for JobID, except
maybe in the kernel client where we weren't allowed to parse the process
environment directly.  I agree an upcall is problematic with namespaces,
in addition to being less functional (only a JobID per node instead of
per process), which is why direct access to JOBENV is better IMHO.

> The whole approach to stats in lustre is
> pretty awful. Take jobstats for example. Currently the approach is
> to poll inside the kernel at specific intervals. Part of the polling is 
> scanning the running processes environment space. On top of this the 
> administor ends up creating scripts to poll the proc / debugfs entry. 
> Other types of lustre stat files take a similar approach. Scripts have
> to poll debugfs / procfs entries.

I think that issue is orthogonal to getting the actual JobID.  That is
the stats collection from the kernel.  We shouldn't be inventing a new
way to process that.  What does "top" do?  Read a thousand /proc files
every second because that is flexible for different use cases.  There
are much fewer Lustre stats files on a given node, and I haven't heard
that the actual stats reading interface is a performance issue.

> I have been thinking what would be a better approach since I like to
> approach this problem for the 2.13 time frame. Our admins at my work
> place want to be able to collect application stats without being root.
> So placing stats in debugfs is not an option, which we currently do
> the linux client :-( The stats are not a good fit for sysfs. The solution 
> I have been pondering is using netlink. Since netlink is socket based it 
> can be treated as a pipe. Now you are thinking well you still need to poll 
> on the netlink socket but you don't have too. systemd does it for you :-)  
> We can create systemd service file which uses

For the love of all that is holy, do not make Lustre stats usage depend
on Systemd to be usable.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
