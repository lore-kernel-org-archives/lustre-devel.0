From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 07:41:58 +0000
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <87h8ehi8s6.fsf@notabene.neil.brown.name>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
 <87h8ehi8s6.fsf@notabene.neil.brown.name>
Message-ID: <B72A8E2A-DCA8-4DF5-94FF-E3A317ED13D1@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 9, 2019, at 18:46, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Jan 08 2019, James Simmons wrote:
>> 
>> I have been thinking what would be a better approach since I like to
>> approach this problem for the 2.13 time frame. Our admins at my work
>> place want to be able to collect application stats without being root.
>> So placing stats in debugfs is not an option, which we currently do
>> the linux client :-( The stats are not a good fit for sysfs.
> 
> How much statistics data are we talking about here?
>  /proc/self/mountstats
> shows over 2K of stats for NFS filesystems.
> Is this in the ball-park or do you need an order-of-magnitude more?

Ah, the joys of being grandfathered into the code...  One of the larger
normal /proc files is the "obdfilter.*.brw_stats" files, which I agree
is a bit of an abomination of ASCII formatted output.

Most of the regular stats files are about 1KB in size, like:

wc /proc/fs/lustre//osc/myth-OST000*/stats
14 107 1028 /proc/fs/lustre//osc/myth-OST0000-osc-ffff880429ee7c00/stats
14 107 1011 /proc/fs/lustre//osc/myth-OST0001-osc-ffff880429ee7c00/stats
13 99 989 /proc/fs/lustre//osc/myth-OST0002-osc-ffff880429ee7c00/stats
14 107 1043 /proc/fs/lustre//osc/myth-OST0003-osc-ffff880429ee7c00/stats
14 107 1075 /proc/fs/lustre//osc/myth-OST0004-osc-ffff880429ee7c00/stats

The {obdfilter,mdt}.*.job_stats files can become quite big on a large
system if there are lots of jobs running.  James would have to report
on what kind of sizes they get on their nearly-largest-in-the-world
filesystem.  Definitely into the MB range.  I don't think there would be
a need to poll that super frequently, maybe in the 60s range, as it keeps
the stats for some minutes after a job stops IO, or it would be impossible
to gather accurate stats for the whole job.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
