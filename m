From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Thu, 21 Aug 2008 14:43:32 +0400
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <op.uf8d8iklatmt0c@goga>
References: <C4D1B2E1.575A%peter.braam@sun.com> <op.uf7ac4keatmt0c@goga>
	<200808211324.09313.alexander.zarochentsev@sun.com>
	<op.uf8d8iklatmt0c@goga>
Message-ID: <fb7be0fc9fc.48ad7f14@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

my 2c:

__lvfs_set_rdonly() -> fsync_bdev() -> fsync_super() -> ext3_sync_fs():

if (journal_start_commit(EXT3_SB(sb)->s_journal, &target)) {
if (wait)
  log_wait_commit(EXT3_SB(sb)->s_journal, target);

if this is called by process started transaction - deadlock before rdonly
if some another process holding transaction hits assertion - again deadlock before rdonly.

thanks, Alex


> On Thu, 21 Aug 2008 13:24:08 +0400, Alexander Zarochentsev  
> <Alexander.Zarochentsev@sun.com> wrote:
> 
> > On 20 August 2008 23:42:39 Mikhail Pershin wrote:
> >> Also to be sure that all before barrier is on disk, many test cases
> >> about recovery rely on the fact that operations before barrier are 
> on
> >> disk. This is important with HARD failure case especially, without
> >> sync before barrier the operations before barrier may be lost and
> >> affect the tests. I agree that syncless variant of barrier is needed
> >> but we also need barrier with sync depending on test case.
> >
> > You don't need lctl readonly to do a sync, the replay_barrier function
> > from test-framework.sh adds a sync explicitly
> 
> You are right, it is safe in that case.
> 
> 
> -- 
> Mikhail Pershin
> Staff Engineer
> Lustre Group
> Sun Microsystems, Inc.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
