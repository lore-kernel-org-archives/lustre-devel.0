From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 16 Jan 2018 11:12:08 +0300
Subject: [lustre-devel] [bug report] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <9FC73D3DBECE0941BD2ED069D26863425CE75889@irsmsx110.ger.corp.intel.com>
References: <20180115092657.om2gdrcwlajo2tvi@mwanda>
 <9FC73D3DBECE0941BD2ED069D26863425CE75889@irsmsx110.ger.corp.intel.com>
Message-ID: <20180116081208.memd4z76ncbpnb6l@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jan 15, 2018 at 06:27:26PM +0000, Eremin, Dmitry wrote:
> Hello Dan,
> 
> The function kiblnd_destroy_conn() is conditionally free the conn pointer.
> 
> void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
> {
> [?]
>                 if (free_conn)
>                                LIBCFS_FREE(conn, sizeof(*conn));

This check is not there in the kernel.org kernel.  In the upstream
kernel it frees it unconditionally.  The "free_conn" parameter was added
in commit 4d99b2581eff ("staging: lustre: avoid intensive reconnecting
for ko2iblnd") but that line must have been left out.

regards,
dan carpenter
