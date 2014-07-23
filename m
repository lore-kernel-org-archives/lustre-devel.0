From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 23 Jul 2014 18:52:50 +0000
Subject: [Lustre-devel] lustre-1.8.8: rdma_listen() backlog 0 breaks
 iWARP
In-Reply-To: <005801cfa68d$00d607e0$028217a0$@opengridcomputing.com>
References: <005801cfa68d$00d607e0$028217a0$@opengridcomputing.com>
Message-ID: <CFF56046.B2EDD%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2014/07/23, 9:44 AM, "Steve Wise" <swise@opengridcomputing.com> wrote:

>Hello,
>
>I'm trying to get lustre-1.8.8/RHEL6 running over Chelsio iWARP RNICs and
>connection setup
>is failing at the server due to kiblnd_startup() calling rdma_listen()
>with a backlog of
>0.  This effectively rejects all incoming connection requests.   I looked
>at lustre-1.8.7,
>and the backlog was 256 in that release.
>
>Q:  Why was it changed to 0?

Since I'm not familiar with the LNET code myself, I'd recommend to check
the
commit messages in Git to see if there is an explanation, or in the linked
Jira/Bugzilla ticket.

You may also want to see if this is fixed with the 1.8.9 release.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
