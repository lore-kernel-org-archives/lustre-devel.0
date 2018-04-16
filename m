From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 16 Apr 2018 17:27:33 +0300
Subject: [lustre-devel] [PATCH 07/25] staging: lustre: libcfs: NUMA
 support
In-Reply-To: <1523851807-16573-8-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-8-git-send-email-jsimmons@infradead.org>
Message-ID: <20180416142733.s3f36jdd56rkbfbb@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:49AM -0400, James Simmons wrote:
> @@ -114,6 +115,15 @@ struct cfs_cpt_table *
>  	memset(cptab->ctb_cpu2cpt, -1,
>  	       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));
>  
> +	cptab->ctb_node2cpt = kvmalloc_array(nr_node_ids,
> +					     sizeof(cptab->ctb_node2cpt[0]),
> +					     GFP_KERNEL);
> +	if (!cptab->ctb_node2cpt)
> +		goto failed;
> +
> +	memset(cptab->ctb_node2cpt, -1,
> +	       nr_node_ids * sizeof(cptab->ctb_node2cpt[0]));
> +
>  	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
>  					  GFP_KERNEL);
>  	if (!cptab->ctb_parts)


You didn't introduce this, but I was explaining earlier that you should
always be suspicious of code which does "goto failed".  The bug here is
that cptab->ctb_parts is allocated with kvmalloc_array() which
doesn't zero out the memory.  So if we only initialize it part way
because art->cpt_nodemask = kzalloc() fails or something then it's
problem:

    91  void
    92  cfs_cpt_table_free(struct cfs_cpt_table *cptab)
    93  {
    94          int i;
    95  
    96          kvfree(cptab->ctb_cpu2cpt);
    97  
    98          for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
    99                  struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
   100  
   101                  kfree(part->cpt_nodemask);
                             ^^^^^^^^^^^^^^^^^^^
   102                  free_cpumask_var(part->cpt_cpumask);
                                         ^^^^^^^^^^^^^^^^^
These are uninitialized so it will crash.  It turns out there isn't a
kvcalloc() or kvzalloc_array() function.  We don't seem to have a
vcalloc() either...  Very strange.

   103          }
   104  
   105          kvfree(cptab->ctb_parts);
   106  
   107          kfree(cptab->ctb_nodemask);
   108          free_cpumask_var(cptab->ctb_cpumask);
   109  
   110          kfree(cptab);
   111  }

regards,
dan carpenter
