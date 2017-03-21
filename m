From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:27 -0700
Subject: [lustre-devel] [PATCH 0/6] Rate-limiting Quality of Service
Message-ID: <cover.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch enables rate-limiting quality of service (RLQOS) support as
talked in the ASCAR paper [1]. The purpose of RLQOS is to provide a
client-side rate limiting mechanism that controls max_rpcs_in_flight
and minimal gap between brw RPC requests (called tau in the code and
paper). It is very different from the existing LOV QOS in Lustre. I
have presented this work at LUG'16 and am sorry for the belated code
release. This is my first code patch to the Lustre mailing list so I'm
sure lot of things can be improved. Please kindly let me know.

The main idea is to provide a rule-based rate limiting mechanism on
Lustre clients that can be used to ease congestion and improve
performance during peak hours. The rules designate how
max_rpcs_in_flight and tau can be changed based on three metrics. The
rules are set through a procfs handle. In the research paper [1], a
machine learning-based heuristics method is used to generate the
traffic control rules that can improve performance. The traffic
control rules can also be hand crafted based on benchmark results.

I probably should write more details here but the email would be
rather long. The paper [1] has detailed introduction of the idea and
implementation. I also believe there should be better documentation on
this feature. I'm not sure if I should create a wiki page for this or
provide a documentation within the code base.

This function is still under development, and the latest code can be
found at https://github.com/mlogic/ascar-lustre-2.9-client . 

This research was supported in part by the National Science Foundation
under awards IIP-1266400, CCF-1219163, CNS-1018928, CNS-1528179, by
the Department of Energy under award DE-FC02-10ER26017/DESC0005417, by
a Symantec Graduate Fellowship, by a grant from Intel Corporation, and
by industrial members of the Center for Research in Storage Systems in
UC Santa Cruz.

[1] http://storageconference.us/2015/Papers/14.Li.pdf

Yan Li (6):
  Autoconf option for rate-limiting Quality of Service (RLQOS)
  Added fields to message for RLQOS support
  RLQOS main data structure
  lprocfs interfaces for showing, parsing, and controlling rules
  Throttle the outgoing requests according to tau
  Adjust max_rpcs_in_flight according to metrics

 lustre/autoconf/lustre-core.m4     |  17 ++++
 lustre/include/Makefile.am         |   3 +-
 lustre/include/lustre/lustre_idl.h |   4 +
 lustre/include/obd.h               |   8 ++
 lustre/include/rlqos.h             | 136 ++++++++++++++++++++++++++++++
 lustre/obdclass/genops.c           |  25 ++++++
 lustre/obdclass/lprocfs_status.c   |  32 +++++++
 lustre/osc/Makefile.in             |   2 +-
 lustre/osc/lproc_osc.c             | 157 ++++++++++++++++++++++++++++++-----
 lustre/osc/osc_cache.c             |   3 +
 lustre/osc/osc_internal.h          |  66 +++++++++++++++
 lustre/osc/osc_request.c           | 165 +++++++++++++++++++++++++++++++++++++
 lustre/osc/qos_rules.c             | 125 ++++++++++++++++++++++++++++
 lustre/ptlrpc/pack_generic.c       |   5 ++
 lustre/ptlrpc/wiretest.c           |   2 +
 lustre/utils/wiretest.c            |   2 +
 16 files changed, 730 insertions(+), 22 deletions(-)
 create mode 100644 lustre/include/rlqos.h
 create mode 100644 lustre/osc/qos_rules.c

-- 
1.8.3.1
