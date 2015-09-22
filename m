From: Anton Gerasimov <anton.gerasimov@openmailbox.org>
Date: Wed, 23 Sep 2015 01:21:40 +0300
Subject: [lustre-devel] [PATCH 0/3] staging: lustre: fix (non-)static
	symbols issues
Message-ID: <20150922222134.GA2749@linux-0hv4.site>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This series of patches eliminates some sparse warnings concerning
static variables in lustre rtlrpc module where it seemed reasonable.
Symbols that are really local to a source file are made static and
declarations added to a header for symbols that are shared between
source files.

Anton Gerasimov (3):
  staging: lustre: add shared variables to the header
  staging: lustre: include header with local ptlrpc declarations
  staging: lustre: make non-exported functions static

 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c    | 8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h | 6 ++++++
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c        | 2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c        | 2 ++
 4 files changed, 14 insertions(+), 4 deletions(-)

-- 
2.5.1
