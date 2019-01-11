From: NeilBrown <neilb@suse.com>
Date: Fri, 11 Jan 2019 11:00:45 +1100
Subject: [lustre-devel] [PATCH 0/4] lustre: rename foo0() to __foo()
Message-ID: <154716475327.28978.3817067697027604609.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This change was suggested by Andreas - I liked it so much I applied it
to all of lustre.
Except cl_env_init0 - it didn't quite fit the pattern, so I haven't
changed that.

NeilBrown


---

NeilBrown (4):
      lustre: osc: change some foo0() to __foo()
      lustre: llite: change some foo0() to __foo()
      lustre: obdclass: change some foo0() to __foo()
      lustre: ptlrpc: change some foo0() to __foo()


 drivers/staging/lustre/lustre/include/cl_object.h  |    6 +--
 drivers/staging/lustre/lustre/llite/glimpse.c      |    2 -
 .../staging/lustre/lustre/llite/llite_internal.h   |    6 +--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   11 ++---
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    8 ++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   14 +++---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    8 ++--
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   36 ++++++++--------
 .../staging/lustre/lustre/obdecho/echo_client.c    |   20 +++++----
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   44 ++++++++++----------
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    8 ++--
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   20 +++++----
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    2 -
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    6 +--
 14 files changed, 95 insertions(+), 96 deletions(-)

--
Signature
