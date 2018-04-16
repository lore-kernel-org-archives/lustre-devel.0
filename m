From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 16 Apr 2018 16:42:03 +0300
Subject: [lustre-devel] [PATCH 01/25] staging: lustre: libcfs: remove
 useless CPU partition code
In-Reply-To: <1523851807-16573-2-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20180416134203.ehtebtyes34p2tsm@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:43AM -0400, James Simmons wrote:
> @@ -1033,6 +953,7 @@ static int cfs_cpu_dead(unsigned int cpu)
>  #endif
>  	ret = -EINVAL;
>  
> +	get_online_cpus();
>  	if (*cpu_pattern) {
>  		char *cpu_pattern_dup = kstrdup(cpu_pattern, GFP_KERNEL);
>  
> @@ -1058,13 +979,7 @@ static int cfs_cpu_dead(unsigned int cpu)
>  		}
>  	}
>  
> -	spin_lock(&cpt_data.cpt_lock);
> -	if (cfs_cpt_table->ctb_version != cpt_data.cpt_version) {
> -		spin_unlock(&cpt_data.cpt_lock);
> -		CERROR("CPU hotplug/unplug during setup\n");
> -		goto failed;
> -	}
> -	spin_unlock(&cpt_data.cpt_lock);
> +	put_online_cpus();
>  
>  	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
>  		 num_online_nodes(), num_online_cpus(),
> @@ -1072,6 +987,7 @@ static int cfs_cpu_dead(unsigned int cpu)
>  	return 0;
>  
>   failed:
> +	put_online_cpus();
>  	cfs_cpu_fini();
>  	return ret;
>  }

When you have a one label called "failed" then I call that "one err"
style error handling and it's the most bug prone style of error handling
to use.  Always be suspicious of code that uses a "err:" labels.

The bug here is typical.  We are calling put_online_cpus() on paths
where we didn't call get_online_cpus().

The best way to do error handling is to keep track of each resource that
was allocated and then only free the things that have been allocated.
Also the label name should indicate what was freed.  Generally avoid
magic, opaque functions like cfs_cpu_fini().  As a reviewer, it's
harder for me to check that cfs_cpu_fini() frees everything correctly
instead of the a normal list of frees like:

free_table:
	cfs_cpt_table_free(cfs_cpt_table);
free_hotplug_stuff:
	cpuhp_remove_state_nocalls(lustre_cpu_online);
set_state_dead:
	cpuhp_remove_state_nocalls(CPUHP_LUSTRE_CFS_DEAD);

When I'm reading the code, and I see a "goto free_table;", I only need
to ask, "Was table the most recently allocated resource?"  If yes, then
the code is correct, if no then it's buggy.  It's simple review.

regards,
dan carpenter
