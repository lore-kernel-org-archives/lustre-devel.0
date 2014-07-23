From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 23 Jul 2014 10:44:35 -0500
Subject: [Lustre-devel] lustre-1.8.8: rdma_listen() backlog 0 breaks iWARP
Message-ID: <005801cfa68d$00d607e0$028217a0$@opengridcomputing.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I'm trying to get lustre-1.8.8/RHEL6 running over Chelsio iWARP RNICs and connection setup
is failing at the server due to kiblnd_startup() calling rdma_listen() with a backlog of
0.  This effectively rejects all incoming connection requests.   I looked at lustre-1.8.7,
and the backlog was 256 in that release.  

Q:  Why was it changed to 0?   

Thanks,

Steve.
