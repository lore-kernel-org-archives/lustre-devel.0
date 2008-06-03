From: Andreas Dilger <adilger@sun.com>
Date: Tue, 03 Jun 2008 12:41:51 -0600
Subject: [Lustre-devel] Commit on share
In-Reply-To: <op.ub15vdu9atmt0c@goga>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
	<20080531024524.GB2992@webber.adilger.int> <op.ub15vdu9atmt0c@goga>
Message-ID: <20080603184151.GA2961@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 01, 2008  11:03 +0400, Mike Pershin wrote:
> On Sat, 31 May 2008 06:45:24 +0400, Andreas Dilger <adilger@sun.com> wrote:
>> RepACK is currently needed for recovery.  I don't think it is a false
>> conflict in most cases, though I agree in some cases it is.  If MDS
>> thread is only e.g. passing through a directory to do some operation
>> in a previously-existing subdirectory, or wants to stat a file that
>> existed before the conflicting lock was taken then this is a false
>> dependency.
>
> RepACK is not needed for recovery if COS is enabled, because COS will sync 
> the share cases so there is no need to be sure that client got reply and 
> will do replay as there are no dependent replays on it.
>
> Also the cases are creations from different clients or unlinks (operations 
> of same type). They are not dependent actually, the only dependency here 
> may be create vs unlink or unlink vs create. Currently such cases are not 
> distinguished and we block access for any operation from different client.

In 2.0 with per-name-hash locking we will remove almost all such false
dependencies, so I don't know whether the intermediate optimization is
worthwhile or not.

>> Also, isn't it enough to store a single such item per object directly
>> on the object?  Once we know there is ANY such conflict that is enough
>> to invoke COS.  For per-object data this can be stored on 1.6 in the
>> i_filterdata structure that we can attach onto every server inode.
>
> It is per-object, yes. And this is very valuable advice about i_filterdata. 
> I thought we have no access to inode_info from upper level at server side. 
> This will reduce need for hash at all and simplify things a lot.

Well, in 1.6/1.8 the layering isn't so strict, and in HEAD the problem
goes away because of per-object data/locking.  I also don't think Alex's
worry about the i_filterdata lifetime is warranted.  If the inode is
being evicted from cache, then it surely must have been written to disk,
so there is no need to cache the last-modified data at all as COS is
not needed anymore.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
