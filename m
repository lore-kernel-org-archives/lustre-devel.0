From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:40 +1000
Subject: [lustre-devel] [PATCH 00/22] Lustre: use while loop when emptying a
 list
Message-ID: <153292153459.13840.17465048403476297915.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If you have a list that needs to be emptied, it is best to have a loop
like
  while (!list_empty(...))

because then it is obvious what the purpose of the loop is.
Many places in lustre use
  list_for_each_entry_safe()
instead, which obscures the purpose.
Several of these were from patches which deliberately converted from
the while loop the list list_for_each_entry_safe() loop, at least some
of which introduced real bugs.

This series reverts all those patches, and then makes other
conversions.
There are still several places which could be converted, but I got
bored...
I've particularly converted all where the list_head is a local
variable. In these cases it is obviously wrong not to empty the
list completely.

For those conversions that I did manual (not reverts) I use
  list_first_entry()
to get the first entry, rather then list_entry(head->next).
Others could be converted as well.

NeilBrown


---

NeilBrown (22):
      Revert "staging: lustre: lnet: api-ni: Use list_for_each_entry_safe"
      Revert "staging: lustre: o2iblnd: Use list_for_each_entry_safe in kiblnd_destroy_fmr_pool_list"
      Revert "staging: lustre: lnet: o2iblnd: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: socklnd: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: socklnd_proto: Use list_for_each_entry_safe"
      Revert "staging: lustre: osc_cache: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: peer: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: config: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: router: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: conrpc: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: lib-move: Use list_for_each_entry_safe"
      Revert "staging: lustre: obdclass: Use list_for_each_entry_safe"
      Revert "staging: lustre: lnet: Use list_for_each_entry_safe"
      Revert: Staging: lustre: Iterate list using list_for_each_entry
      lustre: o2iblnd: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: tracefile: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: lib-move:  convert list_for_each_entry_safe() to while(!list_empty())
      lustre: net_fault: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: fld_request: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: lov_obd: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: ldlm_request: convert list_for_each_entry_safe() to while(!list_empty())
      lustre: sec_config: convert list_for_each_entry_safe() to while(!list_empty())


 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   21 ++++++++++++--------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   12 ++++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    9 +++++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    5 +++--
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 ++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   12 +++++++----
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   10 ++++++----
 drivers/staging/lustre/lnet/lnet/config.c          |    5 +++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   13 +++++++-----
 drivers/staging/lustre/lnet/lnet/net_fault.c       |    7 +++++--
 drivers/staging/lustre/lnet/lnet/peer.c            |    4 ++--
 drivers/staging/lustre/lnet/lnet/router.c          |    4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    5 +++--
 drivers/staging/lustre/lustre/fld/fld_request.c    |    6 ++++--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    6 ++++--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    5 +++--
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    5 +++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    9 +++++----
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    7 ++++---
 19 files changed, 87 insertions(+), 62 deletions(-)

--
Signature
