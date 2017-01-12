From: Sagi Grimberg <sagi@grimberg.me>
Date: Thu, 12 Jan 2017 13:45:31 +0200
Subject: [lustre-devel] [PATCH 9/9] treewide: Inline ib_dma_map_*()
	functions
In-Reply-To: <20170111005648.14988-10-bart.vanassche@sandisk.com>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
	<20170111005648.14988-10-bart.vanassche@sandisk.com>
Message-ID: <811bac91-39f4-edac-db8a-d44989440b21@grimberg.me>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bart Van Assche <bart.vanassche@sandisk.com>, Doug Ledford <dledford@redhat.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>, devel@driverdev.osuosl.org, linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, linux-rdma@vger.kernel.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org, Anna Schumaker <anna.schumaker@netapp.com>, Oleg Drokin <oleg.drokin@intel.com>, Eric Van Hensbergen <ericvh@gmail.com>, target-devel@vger.kernel.org, Ron Minnich <rminnich@sandia.gov>, James Simmons <jsimmons@infradead.org>, v9fs-developer@lists.sourceforge.net, rds-devel@oss.oracle.com, "David S . Miller" <davem@davemloft.net>, lustre-devel@lists.lustre.org

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
